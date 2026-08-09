<?php
// Sahay Database & Global Configuration File
define('DB_HOST', 'localhost');
define('DB_NAME', 'sahay_db');
define('DB_USER', 'root');
define('DB_PASS', '');

define('HMAC_SECRET_KEY', 'sahay_bhavnagar_national_sec_134a_key_2026');
define('GOOGLE_MAPS_API_KEY', 'AIzaSy_YOUR_GOOGLE_MAPS_API_KEY_HERE');

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
} catch (PDOException $e) {
    // Fallback for development if local MySQL service is offline
    $pdo = null;
}
?>
