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

# Create migrations for the sample data models
php artisan make:migration create_t_users_table
php artisan make:migration create_l_user_logs_table
php artisan make:migration create_m_user_roles_table
php artisan make:migration create_t_user_roles_table
php artisan make:migration create_t_user_settings_table

# Modify the t_users migration
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
        Schema::create('t_users', function (Blueprint $table) {
            $table->id();
            $table->string('public_user_id')->unique()->comment('公開用ユーザーID');
            $table->string('user_name')->comment('ユーザー名');
            $table->datetime('created_at')->nullable();
            $table->datetime('updated_at')->nullable();
            $table->datetime('deleted_at')->nullable();
            $table->string('created_by')->nullable()->comment('作成者');
            $table->string('updated_by')->nullable()->comment('更新者');
            $table->string('deleted_by')->nullable()->comment('削除者');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('t_users');
    }
};
EOL

# Modify the m_user_roles migration
cat > database/migrations/$(ls -t database/migrations | grep create_m_user_roles_table) << 'EOL'
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
        Schema::create('m_user_roles', function (Blueprint $table) {
            $table->id();
            $table->string('role_name')->comment('ロール名');
            $table->datetime('created_at')->nullable();
            $table->datetime('updated_at')->nullable();
            $table->datetime('deleted_at')->nullable();
            $table->string('created_by')->nullable()->comment('作成者');
            $table->string('updated_by')->nullable()->comment('更新者');
            $table->string('deleted_by')->nullable()->comment('削除者');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('m_user_roles');
    }
};
EOL

# Modify the l_user_logs migration
cat > database/migrations/$(ls -t database/migrations | grep create_l_user_logs_table) << 'EOL'
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
        Schema::create('l_user_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('t_user_id')->comment('ユーザーID');
            $table->string('log_type')->comment('ログタイプ');
            $table->text('log_message')->comment('ログメッセージ');
            $table->datetime('created_at')->nullable();
            $table->datetime('updated_at')->nullable();
            $table->datetime('deleted_at')->nullable();
            $table->string('created_by')->nullable()->comment('作成者');
            $table->string('updated_by')->nullable()->comment('更新者');
            $table->string('deleted_by')->nullable()->comment('削除者');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('l_user_logs');
    }
};
EOL

# Modify the t_user_roles migration
cat > database/migrations/$(ls -t database/migrations | grep create_t_user_roles_table) << 'EOL'
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
        Schema::create('t_user_roles', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('t_user_id')->comment('ユーザーID');
            $table->unsignedBigInteger('m_user_role_id')->comment('ロールID');
            $table->datetime('created_at')->nullable();
            $table->datetime('updated_at')->nullable();
            $table->datetime('deleted_at')->nullable();
            $table->string('created_by')->nullable()->comment('作成者');
            $table->string('updated_by')->nullable()->comment('更新者');
            $table->string('deleted_by')->nullable()->comment('削除者');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('t_user_roles');
    }
};
EOL

# Modify the t_user_settings migration
cat > database/migrations/$(ls -t database/migrations | grep create_t_user_settings_table) << 'EOL'
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
        Schema::create('t_user_settings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('t_user_id')->comment('ユーザーID');
            $table->string('setting_key')->comment('設定キー');
            $table->text('setting_value')->comment('設定値');
            $table->datetime('created_at')->nullable();
            $table->datetime('updated_at')->nullable();
            $table->datetime('deleted_at')->nullable();
            $table->string('created_by')->nullable()->comment('作成者');
            $table->string('updated_by')->nullable()->comment('更新者');
            $table->string('deleted_by')->nullable()->comment('削除者');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('t_user_settings');
    }
};
EOL

# Run the migration
php artisan migrate

# Create Eloquent models for the sample data models
php artisan make:model TUser
php artisan make:model LUserLog
php artisan make:model MUserRole
php artisan make:model TUserRole
php artisan make:model TUserSetting

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

# Update the TUser model
cat > app/Models/TUser.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TUser extends Model
{
    use CrudTrait;
    use HasFactory;
    use SoftDeletes;

    protected $table = 't_users';
    public $timestamps = true;
    
    protected $fillable = [
        'public_user_id',
        'user_name',
        'created_by',
        'updated_by',
        'deleted_by',
    ];

    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function logs()
    {
        return $this->hasMany(LUserLog::class, 't_user_id');
    }

    public function roles()
    {
        return $this->belongsToMany(MUserRole::class, 't_user_roles', 't_user_id', 'm_user_role_id');
    }

    public function settings()
    {
        return $this->hasMany(TUserSetting::class, 't_user_id');
    }
}
EOL

# Update the LUserLog model
cat > app/Models/LUserLog.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LUserLog extends Model
{
    use CrudTrait;
    use HasFactory;
    use SoftDeletes;

    protected $table = 'l_user_logs';
    public $timestamps = true;
    
    protected $fillable = [
        't_user_id',
        'log_type',
        'log_message',
        'created_by',
        'updated_by',
        'deleted_by',
    ];

    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function user()
    {
        return $this->belongsTo(TUser::class, 't_user_id');
    }
}
EOL

# Update the MUserRole model
cat > app/Models/MUserRole.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class MUserRole extends Model
{
    use CrudTrait;
    use HasFactory;
    use SoftDeletes;

    protected $table = 'm_user_roles';
    public $timestamps = true;
    
    protected $fillable = [
        'role_name',
        'created_by',
        'updated_by',
        'deleted_by',
    ];

    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function users()
    {
        return $this->belongsToMany(TUser::class, 't_user_roles', 'm_user_role_id', 't_user_id');
    }
}
EOL

# Update the TUserRole model
cat > app/Models/TUserRole.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TUserRole extends Model
{
    use CrudTrait;
    use HasFactory;
    use SoftDeletes;

    protected $table = 't_user_roles';
    public $timestamps = true;
    
    protected $fillable = [
        't_user_id',
        'm_user_role_id',
        'created_by',
        'updated_by',
        'deleted_by',
    ];

    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function user()
    {
        return $this->belongsTo(TUser::class, 't_user_id');
    }

    public function role()
    {
        return $this->belongsTo(MUserRole::class, 'm_user_role_id');
    }
}
EOL

# Update the TUserSetting model
cat > app/Models/TUserSetting.php << 'EOL'
<?php

namespace App\Models;

use Backpack\CRUD\app\Models\Traits\CrudTrait;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TUserSetting extends Model
{
    use CrudTrait;
    use HasFactory;
    use SoftDeletes;

    protected $table = 't_user_settings';
    public $timestamps = true;
    
    protected $fillable = [
        't_user_id',
        'setting_key',
        'setting_value',
        'created_by',
        'updated_by',
        'deleted_by',
    ];

    protected $dates = [
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function user()
    {
        return $this->belongsTo(TUser::class, 't_user_id');
    }
}
EOL

# Create Backpack CRUD controllers for the sample data models
php artisan backpack:crud t-user
php artisan backpack:crud l-user-log
php artisan backpack:crud m-user-role
php artisan backpack:crud t-user-role
php artisan backpack:crud t-user-setting

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

# Update the TUserCrudController
cat > app/Http/Controllers/Admin/TUserCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\TUserRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class TUserCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\TUser::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/t-user');
        CRUD::setEntityNameStrings('ユーザー', 'ユーザー');
    }

    protected function setupListOperation()
    {
        CRUD::column('public_user_id')->label('公開用ユーザーID');
        CRUD::column('user_name')->label('ユーザー名');
        CRUD::column('created_at')->label('作成日時');
        CRUD::column('updated_at')->label('更新日時');
        CRUD::column('created_by')->label('作成者');
        CRUD::column('updated_by')->label('更新者');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(TUserRequest::class);

        CRUD::field('public_user_id')->label('公開用ユーザーID');
        CRUD::field('user_name')->label('ユーザー名');
        CRUD::field('created_by')->label('作成者');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
        CRUD::field('updated_by')->label('更新者');
    }
}
EOL

# Update the LUserLogCrudController
cat > app/Http/Controllers/Admin/LUserLogCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\LUserLogRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class LUserLogCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\LUserLog::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/l-user-log');
        CRUD::setEntityNameStrings('ユーザーログ', 'ユーザーログ');
    }

    protected function setupListOperation()
    {
        CRUD::column('t_user_id')->label('ユーザーID');
        CRUD::column('log_type')->label('ログタイプ');
        CRUD::column('log_message')->label('ログメッセージ');
        CRUD::column('created_at')->label('作成日時');
        CRUD::column('updated_at')->label('更新日時');
        CRUD::column('created_by')->label('作成者');
        CRUD::column('updated_by')->label('更新者');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(LUserLogRequest::class);

        CRUD::field('t_user_id')->label('ユーザーID')->type('select')
            ->entity('user')->model('App\Models\TUser')->attribute('user_name');
        CRUD::field('log_type')->label('ログタイプ');
        CRUD::field('log_message')->label('ログメッセージ')->type('textarea');
        CRUD::field('created_by')->label('作成者');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
        CRUD::field('updated_by')->label('更新者');
    }
}
EOL

# Update the MUserRoleCrudController
cat > app/Http/Controllers/Admin/MUserRoleCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\MUserRoleRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class MUserRoleCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\MUserRole::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/m-user-role');
        CRUD::setEntityNameStrings('ユーザーロール', 'ユーザーロール');
    }

    protected function setupListOperation()
    {
        CRUD::column('role_name')->label('ロール名');
        CRUD::column('created_at')->label('作成日時');
        CRUD::column('updated_at')->label('更新日時');
        CRUD::column('created_by')->label('作成者');
        CRUD::column('updated_by')->label('更新者');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(MUserRoleRequest::class);

        CRUD::field('role_name')->label('ロール名');
        CRUD::field('created_by')->label('作成者');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
        CRUD::field('updated_by')->label('更新者');
    }
}
EOL

# Update the TUserRoleCrudController
cat > app/Http/Controllers/Admin/TUserRoleCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\TUserRoleRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class TUserRoleCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\TUserRole::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/t-user-role');
        CRUD::setEntityNameStrings('ユーザーロール割り当て', 'ユーザーロール割り当て');
    }

    protected function setupListOperation()
    {
        CRUD::column('t_user_id')->label('ユーザーID');
        CRUD::column('m_user_role_id')->label('ロールID');
        CRUD::column('created_at')->label('作成日時');
        CRUD::column('updated_at')->label('更新日時');
        CRUD::column('created_by')->label('作成者');
        CRUD::column('updated_by')->label('更新者');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(TUserRoleRequest::class);

        CRUD::field('t_user_id')->label('ユーザーID')->type('select')
            ->entity('user')->model('App\Models\TUser')->attribute('user_name');
        CRUD::field('m_user_role_id')->label('ロールID')->type('select')
            ->entity('role')->model('App\Models\MUserRole')->attribute('role_name');
        CRUD::field('created_by')->label('作成者');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
        CRUD::field('updated_by')->label('更新者');
    }
}
EOL

# Update the TUserSettingCrudController
cat > app/Http/Controllers/Admin/TUserSettingCrudController.php << 'EOL'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Requests\TUserSettingRequest;
use Backpack\CRUD\app\Http\Controllers\CrudController;
use Backpack\CRUD\app\Library\CrudPanel\CrudPanelFacade as CRUD;

class TUserSettingCrudController extends CrudController
{
    use \Backpack\CRUD\app\Http\Controllers\Operations\ListOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\CreateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\UpdateOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\DeleteOperation;
    use \Backpack\CRUD\app\Http\Controllers\Operations\ShowOperation;

    public function setup()
    {
        CRUD::setModel(\App\Models\TUserSetting::class);
        CRUD::setRoute(config('backpack.base.route_prefix') . '/t-user-setting');
        CRUD::setEntityNameStrings('ユーザー設定', 'ユーザー設定');
    }

    protected function setupListOperation()
    {
        CRUD::column('t_user_id')->label('ユーザーID');
        CRUD::column('setting_key')->label('設定キー');
        CRUD::column('setting_value')->label('設定値');
        CRUD::column('created_at')->label('作成日時');
        CRUD::column('updated_at')->label('更新日時');
        CRUD::column('created_by')->label('作成者');
        CRUD::column('updated_by')->label('更新者');
    }

    protected function setupCreateOperation()
    {
        CRUD::setValidation(TUserSettingRequest::class);

        CRUD::field('t_user_id')->label('ユーザーID')->type('select')
            ->entity('user')->model('App\Models\TUser')->attribute('user_name');
        CRUD::field('setting_key')->label('設定キー');
        CRUD::field('setting_value')->label('設定値')->type('textarea');
        CRUD::field('created_by')->label('作成者');
    }

    protected function setupUpdateOperation()
    {
        $this->setupCreateOperation();
        CRUD::field('updated_by')->label('更新者');
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

# Create a simple TUserRequest for validation
cat > app/Http/Requests/TUserRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TUserRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            'public_user_id' => 'required|min:2|max:255|unique:t_users,public_user_id,' . $this->id,
            'user_name' => 'required|min:2|max:255',
            'created_by' => 'nullable|max:255',
            'updated_by' => 'nullable|max:255',
        ];
    }
}
EOL

# Create a simple LUserLogRequest for validation
cat > app/Http/Requests/LUserLogRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LUserLogRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            't_user_id' => 'required|exists:t_users,id',
            'log_type' => 'required|max:255',
            'log_message' => 'required',
            'created_by' => 'nullable|max:255',
            'updated_by' => 'nullable|max:255',
        ];
    }
}
EOL

# Create a simple MUserRoleRequest for validation
cat > app/Http/Requests/MUserRoleRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MUserRoleRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            'role_name' => 'required|min:2|max:255',
            'created_by' => 'nullable|max:255',
            'updated_by' => 'nullable|max:255',
        ];
    }
}
EOL

# Create a simple TUserRoleRequest for validation
cat > app/Http/Requests/TUserRoleRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TUserRoleRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            't_user_id' => 'required|exists:t_users,id',
            'm_user_role_id' => 'required|exists:m_user_roles,id',
            'created_by' => 'nullable|max:255',
            'updated_by' => 'nullable|max:255',
        ];
    }
}
EOL

# Create a simple TUserSettingRequest for validation
cat > app/Http/Requests/TUserSettingRequest.php << 'EOL'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TUserSettingRequest extends FormRequest
{
    public function authorize()
    {
        // Only allow updates if the user is logged in
        return backpack_auth()->check();
    }

    public function rules()
    {
        return [
            't_user_id' => 'required|exists:t_users,id',
            'setting_key' => 'required|max:255',
            'setting_value' => 'required',
            'created_by' => 'nullable|max:255',
            'updated_by' => 'nullable|max:255',
        ];
    }
}
EOL

# Create a user for accessing the admin panel using a custom command to avoid escaping issues
php -r "echo shell_exec('php artisan backpack:user --name=\"Admin User\" --email=admin@example.com --******');"

# Add some sample data
php artisan tinker << 'EOL'
use App\Models\Product;
use App\Models\TUser;
use App\Models\LUserLog;
use App\Models\MUserRole;
use App\Models\TUserRole;
use App\Models\TUserSetting;

// Add sample products
Product::create(['name' => 'Product 1', 'description' => 'This is product 1', 'price' => 19.99, 'quantity' => 10]);
Product::create(['name' => 'Product 2', 'description' => 'This is product 2', 'price' => 29.99, 'quantity' => 20]);
Product::create(['name' => 'Product 3', 'description' => 'This is product 3', 'price' => 39.99, 'quantity' => 30]);

// Add sample users
$user1 = TUser::create([
    'public_user_id' => 'user123',
    'user_name' => 'テストユーザー1',
    'created_by' => 'Admin',
]);

$user2 = TUser::create([
    'public_user_id' => 'user456',
    'user_name' => 'テストユーザー2',
    'created_by' => 'Admin',
]);

// Add sample roles
$role1 = MUserRole::create([
    'role_name' => '管理者',
    'created_by' => 'Admin',
]);

$role2 = MUserRole::create([
    'role_name' => '一般ユーザー',
    'created_by' => 'Admin',
]);

// Add sample user-role relationships
TUserRole::create([
    't_user_id' => $user1->id,
    'm_user_role_id' => $role1->id,
    'created_by' => 'Admin',
]);

TUserRole::create([
    't_user_id' => $user2->id,
    'm_user_role_id' => $role2->id,
    'created_by' => 'Admin',
]);

// Add sample user logs
LUserLog::create([
    't_user_id' => $user1->id,
    'log_type' => 'ログイン',
    'log_message' => 'ユーザーがログインしました',
    'created_by' => 'System',
]);

LUserLog::create([
    't_user_id' => $user2->id,
    'log_type' => 'ログイン',
    'log_message' => 'ユーザーがログインしました',
    'created_by' => 'System',
]);

// Add sample user settings
TUserSetting::create([
    't_user_id' => $user1->id,
    'setting_key' => '言語',
    'setting_value' => '日本語',
    'created_by' => 'Admin',
]);

TUserSetting::create([
    't_user_id' => $user2->id,
    'setting_key' => '言語',
    'setting_value' => '英語',
    'created_by' => 'Admin',
]);

exit
EOL

# Add menu items for the new CRUD panels
cat > resources/views/vendor/backpack/ui/inc/menu_items.blade.php << 'EOL'
{{-- This file is used for menu items by any Backpack-related packages --}}
<li class="nav-item"><a class="nav-link" href="{{ backpack_url('dashboard') }}"><i class="la la-home nav-icon"></i> {{ trans('backpack::base.dashboard') }}</a></li>

<li class="nav-item"><a class="nav-link" href="{{ backpack_url('product') }}"><i class="nav-icon la la-box"></i> Products</a></li>

<li class="nav-item nav-dropdown">
    <a class="nav-link nav-dropdown-toggle" href="#"><i class="nav-icon la la-users"></i> ユーザー管理</a>
    <ul class="nav-dropdown-items">
        <li class="nav-item"><a class="nav-link" href="{{ backpack_url('t-user') }}"><i class="nav-icon la la-user"></i> ユーザー</a></li>
        <li class="nav-item"><a class="nav-link" href="{{ backpack_url('l-user-log') }}"><i class="nav-icon la la-history"></i> ユーザーログ</a></li>
        <li class="nav-item"><a class="nav-link" href="{{ backpack_url('m-user-role') }}"><i class="nav-icon la la-id-badge"></i> ユーザーロール</a></li>
        <li class="nav-item"><a class="nav-link" href="{{ backpack_url('t-user-role') }}"><i class="nav-icon la la-user-tag"></i> ユーザーロール割り当て</a></li>
        <li class="nav-item"><a class="nav-link" href="{{ backpack_url('t-user-setting') }}"><i class="nav-icon la la-cog"></i> ユーザー設定</a></li>
    </ul>
</li>
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
