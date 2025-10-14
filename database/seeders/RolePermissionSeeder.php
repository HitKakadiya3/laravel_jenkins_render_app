<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\Permission;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class RolePermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create permissions
        $permissions = [
            ['name' => 'view_dashboard', 'display_name' => 'View Dashboard', 'description' => 'Can view the dashboard'],
            ['name' => 'manage_users', 'display_name' => 'Manage Users', 'description' => 'Can create, edit, and delete users'],
            ['name' => 'manage_roles', 'display_name' => 'Manage Roles', 'description' => 'Can manage roles and permissions'],
            ['name' => 'view_analytics', 'display_name' => 'View Analytics', 'description' => 'Can view analytics and reports'],
            ['name' => 'system_settings', 'display_name' => 'System Settings', 'description' => 'Can modify system settings'],
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission['name']], $permission);
        }

        // Create roles
        $adminRole = Role::firstOrCreate(
            ['name' => 'admin'],
            [
                'display_name' => 'Administrator',
                'description' => 'Full system access'
            ]
        );

        $moderatorRole = Role::firstOrCreate(
            ['name' => 'moderator'],
            [
                'display_name' => 'Moderator',
                'description' => 'Limited administrative access'
            ]
        );

        $userRole = Role::firstOrCreate(
            ['name' => 'user'],
            [
                'display_name' => 'User',
                'description' => 'Standard user access'
            ]
        );

        // Assign permissions to roles
        $adminRole->permissions()->sync(Permission::all()->pluck('id'));
        $moderatorRole->permissions()->sync(Permission::whereIn('name', [
            'view_dashboard', 'manage_users', 'view_analytics'
        ])->pluck('id'));
        $userRole->permissions()->sync(Permission::where('name', 'view_dashboard')->pluck('id'));

        // Create default admin user
        $adminUser = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Administrator',
                'password' => Hash::make('password'),
                'bio' => 'System Administrator',
                'is_active' => true,
            ]
        );

        // Create default moderator user
        $moderatorUser = User::firstOrCreate(
            ['email' => 'moderator@example.com'],
            [
                'name' => 'Moderator',
                'password' => Hash::make('password'),
                'bio' => 'System Moderator',
                'is_active' => true,
            ]
        );

        // Create default regular user
        $regularUser = User::firstOrCreate(
            ['email' => 'user@example.com'],
            [
                'name' => 'Regular User',
                'password' => Hash::make('password'),
                'bio' => 'Regular system user',
                'is_active' => true,
            ]
        );

        // Assign roles to users
        $adminUser->roles()->sync([$adminRole->id]);
        $moderatorUser->roles()->sync([$moderatorRole->id]);
        $regularUser->roles()->sync([$userRole->id]);
    }
}