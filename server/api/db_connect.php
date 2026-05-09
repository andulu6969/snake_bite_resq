<?php
/**
 * db_connect.php
 * Shared database connection for all SnakeBiteResQ API endpoints.
 * Require this file at the top of every API script.
 */

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Change for production
define('DB_NAME', 'snake_bite_db');

// Create connection with forced timeout
$conn = new mysqli();
$conn->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);

if (!$conn->real_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME)) {
    http_response_code(500);
    die(json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error,
        "timestamp" => date('Y-m-d H:i:s'),
        "debug" => "Check if MySQL service is running on localhost:3306"
    ]));
}

$conn->set_charset("utf8mb4");
