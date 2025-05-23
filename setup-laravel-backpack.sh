#!/bin/bash
set -e

echo "Setting up Laravel with Backpack CRUD in Docker..."

# Navigate to the working directory
cd /var/www

# Create a new Laravel project in the current directory
composer create-project --prefer-dist laravel/laravel .

# Update database configuration in .env file
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=db/g' .env
sed -i 's/DB_DATABASE=laravel/DB_DATABASE=laravel_backpack/g' .env
sed -i 's/DB_USERNAME=root/DB_USERNAME=backpack/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=secret/g' .env

# Set Redis configuration in .env
sed -i 's/REDIS_HOST=127.0.0.1/REDIS_HOST=valkey/g' .env

# Install Backpack via Composer
composer require backpack/crud:"^6.0"

# Run the Backpack installation command
php artisan backpack:install --no-interaction

# Create a demo model for CRUD operations
php artisan make:model Product -m

# Modify the migration file to add fields for our product
cat > database/migrations/$(ls -t database/migrations | head -n 1) << 'EOL'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->integer('quantity');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
EOL

# Run the migration
php artisan migrate

# Create a Backpack CRUD controller for the Product model
php artisan backpack:crud product

# Update the Product model to work with Backpack
cat > app/Models/Product.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use CrudTrait;
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'quantity',
    ];
}
EOL

# Update the ProductCrudController to configure fields
cat > app/Http/Controllers/Admin/ProductCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\ProductRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class ProductCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\Product::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/product');
        CRUD::setEntityNameStrings('product', 'products');
    }

    protected function setupListOperation()
    {
        CRUD::column('name');
        CRUD::column('description');
        CRUD::column('price');
        CRUD::column('quantity');
        CRUD::column('created_at');
        CRUD::column('updated_at');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(ProductRequest::class);

        CRUD::field('name');
        CRUD::field('description');
        CRUD::field('price');
        CRUD::field('quantity');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
    }
}
EOL

# Create a simple ProductRequest for validation
cat > app/Http/Requests/ProductRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            'name' => 'required|min:2|max:255',
            'description' => 'nullable',
            'price' => 'required|numeric|min:0',
            'quantity' => 'required|integer|min:0',
        ];
    }
}
EOL

# Create a user for accessing the admin panel using a custom command to avoid escaping issues
php -r "echo shell_exec('php artisan backpack:user --name=\"Admin User\" --email=admin@example.com --******');"

# Add some sample data
php artisan tinker << 'EOL'
use App\Models\Product;
Product::create(['name' => 'Product 1', 'description' => 'This is product 1', 'price' => 19.99, 'quantity' => 10]);
Product::create(['name' => 'Product 2', 'description' => 'This is product 2', 'price' => 29.99, 'quantity' => 20]);
Product::create(['name' => 'Product 3', 'description' => 'This is product 3', 'price' => 39.99, 'quantity' => 30]);
exit
EOL

# Set proper permissions
chown -R www:www .
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

# Make storage and bootstrap cache writable
chmod -R 775 storage bootstrap/cache

echo "Laravel with Backpack CRUD has been set up successfully!"
echo "You can access the admin panel at: http://localhost/admin"
echo "Login with: admin@example.com / password"
