<?php
// Ultra-basic debug script - no Laravel dependencies
echo "<!DOCTYPE html>";
echo "<html><head><title>Direct PHP Debug</title></head><body>";
echo "<h1>Direct PHP Access Test</h1>";
echo "<p><strong>Server Time:</strong> " . date('Y-m-d H:i:s') . "</p>";
echo "<p><strong>PHP Version:</strong> " . PHP_VERSION . "</p>";
echo "<p><strong>Document Root:</strong> " . $_SERVER['DOCUMENT_ROOT'] . "</p>";
echo "<p><strong>Server Name:</strong> " . $_SERVER['SERVER_NAME'] . "</p>";
echo "<p><strong>Request URI:</strong> " . $_SERVER['REQUEST_URI'] . "</p>";

echo "<h2>Environment Variables:</h2>";
echo "<ul>";
foreach ($_ENV as $key => $value) {
    if (strpos($key, 'SESSION') !== false || strpos($key, 'CACHE') !== false || strpos($key, 'APP_') !== false) {
        echo "<li><strong>$key:</strong> $value</li>";
    }
}
echo "</ul>";

echo "<h2>Laravel Files Check:</h2>";
$files_to_check = [
    '/var/www/html/artisan',
    '/var/www/html/config/session.php',
    '/var/www/html/routes/web.php',
    '/var/www/html/.env'
];

foreach ($files_to_check as $file) {
    if (file_exists($file)) {
        echo "<p>✅ $file exists</p>";
    } else {
        echo "<p>❌ $file missing</p>";
    }
}

echo "</body></html>";
?>