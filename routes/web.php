<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\DashboardController;

// Simple test route without any dependencies
Route::get('/test', function () {
    return 'Laravel is working! Time: ' . date('Y-m-d H:i:s');
});

// Static HTML test route 
Route::get('/static', function () {
    return '<!DOCTYPE html><html><head><title>Static Test</title></head><body><h1>Static HTML Working!</h1><p>Laravel routing works without sessions.</p></body></html>';
});

// Health check route - minimal dependencies
Route::get('/health', function () {
    try {
        return response()->json([
            'status' => 'ok',
            'timestamp' => date('Y-m-d H:i:s'),
            'app_name' => 'Laravel Jenkins Render App',
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'session_driver' => 'bypassed for testing'
        ]);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ], 500);
    }
});

// Public routes
Route::get('/', function () {
    // Try to bypass session completely
    return response('<h1>Welcome to Laravel!</h1><p>Application is running successfully.</p><p><a href="/test">Test Route</a> | <a href="/health">Health Check</a> | <a href="/static">Static Test</a></p>')
        ->header('Content-Type', 'text/html');
});

// Authentication routes
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegistrationForm'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// Dashboard routes (protected)
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard/profile', [DashboardController::class, 'profile'])->name('dashboard.profile');
    Route::put('/dashboard/profile', [DashboardController::class, 'updateProfile'])->name('dashboard.profile.update');
    
    // Analytics (requires permission)
    Route::get('/dashboard/analytics', [DashboardController::class, 'analytics'])
        ->name('dashboard.analytics')
        ->middleware('permission:view_analytics');
    
    // User management (requires permission)
    Route::get('/dashboard/users', [DashboardController::class, 'users'])
        ->name('dashboard.users')
        ->middleware('permission:manage_users');
});
