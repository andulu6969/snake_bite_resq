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

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

$conn->set_charset("utf8mb4");
