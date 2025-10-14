<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class DashboardController extends Controller
{
    /**
     * Show the dashboard.
     */
    public function index(): View
    {
        $user = Auth::user();
        
        // Get dashboard statistics
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('is_active', true)->count(),
            'total_roles' => Role::count(),
            'recent_registrations' => User::where('created_at', '>=', now()->subDays(7))->count(),
        ];

        // Get recent users
        $recentUsers = User::latest()->take(5)->get();

        // Get user-specific data based on role
        $userRoles = $user->roles->pluck('name')->toArray();
        
        $dashboardData = [
            'user' => $user,
            'stats' => $stats,
            'recent_users' => $recentUsers,
            'user_roles' => $userRoles,
            'can_manage_users' => $user->hasPermission('manage_users'),
            'can_view_analytics' => $user->hasPermission('view_analytics'),
            'can_manage_roles' => $user->hasPermission('manage_roles'),
        ];

        return view('dashboard.index', $dashboardData);
    }

    /**
     * Show analytics page.
     */
    public function analytics(): View
    {
        $user = Auth::user();

        if (!$user->hasPermission('view_analytics')) {
            abort(403, 'Unauthorized access to analytics.');
        }

        // Generate analytics data
        $analyticsData = [
            'user_registrations_last_30_days' => User::where('created_at', '>=', now()->subDays(30))
                ->selectRaw('DATE(created_at) as date, COUNT(*) as count')
                ->groupBy('date')
                ->orderBy('date')
                ->get(),
            'user_roles_distribution' => Role::withCount('users')->get(),
            'login_activity' => User::whereNotNull('last_login_at')
                ->where('last_login_at', '>=', now()->subDays(7))
                ->orderBy('last_login_at', 'desc')
                ->take(10)
                ->get(),
        ];

        return view('dashboard.analytics', $analyticsData);
    }

    /**
     * Show user management page.
     */
    public function users(): View
    {
        $user = Auth::user();

        if (!$user->hasPermission('manage_users')) {
            abort(403, 'Unauthorized access to user management.');
        }

        $users = User::with('roles')->paginate(10);
        $roles = Role::all();

        return view('dashboard.users', compact('users', 'roles'));
    }

    /**
     * Show user profile.
     */
    public function profile(): View
    {
        $user = Auth::user();
        return view('dashboard.profile', compact('user'));
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'phone' => ['nullable', 'string', 'max:20'],
            'bio' => ['nullable', 'string', 'max:500'],
            'avatar' => ['nullable', 'image', 'max:1024'], // 1MB max
        ]);

        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('avatars', 'public');
            $validated['avatar'] = basename($avatarPath);
        }

        $user->update($validated);

        return redirect()->route('dashboard.profile')->with('success', 'Profile updated successfully!');
    }
}