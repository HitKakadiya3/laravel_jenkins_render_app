<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }} - @yield('title', 'Dashboard')</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    
    <!-- Additional CSS -->
    <style>
        .sidebar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .card {
            background: white;
            border-radius: 0.5rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.2s;
        }
        .btn-primary:hover {
            transform: translateY(-1px);
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body class="font-sans antialiased bg-gray-100">
    <div class="min-h-screen">
        @auth
            <!-- Sidebar Navigation -->
            <div class="flex">
                <div class="w-64 min-h-screen sidebar text-white">
                    <div class="p-6">
                        <h2 class="text-2xl font-bold">{{ config('app.name') }}</h2>
                        <p class="text-sm opacity-75">Welcome, {{ Auth::user()->name }}</p>
                    </div>
                    
                    <nav class="mt-6">
                        <div class="px-6 py-3">
                            <a href="{{ route('dashboard') }}" class="flex items-center py-2 px-4 rounded hover:bg-white hover:bg-opacity-10 {{ request()->routeIs('dashboard') ? 'bg-white bg-opacity-20' : '' }}">
                                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
                                </svg>
                                Dashboard
                            </a>
                        </div>
                        
                        @if(Auth::user()->hasPermission('view_analytics'))
                        <div class="px-6 py-3">
                            <a href="{{ route('dashboard.analytics') }}" class="flex items-center py-2 px-4 rounded hover:bg-white hover:bg-opacity-10 {{ request()->routeIs('dashboard.analytics') ? 'bg-white bg-opacity-20' : '' }}">
                                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2-2V7a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 012-2h2a2 2 0 012 2v12a2 2 0 01-2 2H9z"></path>
                                </svg>
                                Analytics
                            </a>
                        </div>
                        @endif
                        
                        @if(Auth::user()->hasPermission('manage_users'))
                        <div class="px-6 py-3">
                            <a href="{{ route('dashboard.users') }}" class="flex items-center py-2 px-4 rounded hover:bg-white hover:bg-opacity-10 {{ request()->routeIs('dashboard.users') ? 'bg-white bg-opacity-20' : '' }}">
                                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                                </svg>
                                Users
                            </a>
                        </div>
                        @endif
                        
                        <div class="px-6 py-3">
                            <a href="{{ route('dashboard.profile') }}" class="flex items-center py-2 px-4 rounded hover:bg-white hover:bg-opacity-10 {{ request()->routeIs('dashboard.profile') ? 'bg-white bg-opacity-20' : '' }}">
                                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                                </svg>
                                Profile
                            </a>
                        </div>
                        
                        <div class="px-6 py-3 mt-6 border-t border-white border-opacity-20">
                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <button type="submit" class="flex items-center py-2 px-4 rounded hover:bg-white hover:bg-opacity-10 w-full text-left">
                                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                                    </svg>
                                    Logout
                                </button>
                            </form>
                        </div>
                    </nav>
                </div>
                
                <!-- Main Content -->
                <div class="flex-1">
                    <header class="bg-white shadow">
                        <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
                            <h1 class="text-3xl font-bold text-gray-900">@yield('header', 'Dashboard')</h1>
                        </div>
                    </header>
                    
                    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
                        @if(session('success'))
                            <div class="mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
                                {{ session('success') }}
                            </div>
                        @endif
                        
                        @if(session('error'))
                            <div class="mb-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
                                {{ session('error') }}
                            </div>
                        @endif
                        
                        @yield('content')
                    </main>
                </div>
            </div>
        @else
            <!-- Guest Layout -->
            <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
                @yield('content')
            </div>
        @endauth
    </div>
</body>
</html>