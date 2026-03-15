<?php
/**
 * login.php
 * Validates a station unit OR admin login for the SnakeBiteResQ app.
 *
 * Expects POST body (JSON):
 *   { "unit_id": "KDH-ER-01", "passcode": "1234" }
 *
 * Returns on success (station):
 *   { "status": "success", "hospital_name": "Hospital Sultanah Bahiyah", "role": "station" }
 *
 * Returns on success (admin):
 *   { "status": "success", "hospital_name": "Ministry of Health", "role": "admin" }
 *
 * Returns on failure:
 *   { "status": "error", "message": "..." }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

// Handle pre-flight CORS request from browsers/web
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Method not allowed"]);
    exit();
}

require_once 'db_connect.php';

// --- 1. Parse JSON body ---
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data || empty($data['unit_id']) || empty($data['passcode'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "unit_id and passcode are required"]);
    $conn->close();
    exit();
}

$unit_id = trim($data['unit_id']);
$passcode = trim($data['passcode']);

// --- 2. Check admin_users table first ---
$adminStmt = $conn->prepare(
    "SELECT passcode_hash, display_name, is_active
     FROM admin_users
     WHERE username = ?
     LIMIT 1"
);
$adminStmt->bind_param("s", $unit_id);
$adminStmt->execute();
$adminResult = $adminStmt->get_result();

if ($adminResult->num_rows > 0) {
    $adminRow = $adminResult->fetch_assoc();
    $adminStmt->close();

    // Check if active
    if (!$adminRow['is_active']) {
        http_response_code(403);
        echo json_encode(["status" => "error", "message" => "This admin account has been deactivated"]);
        $conn->close();
        exit();
    }

    // Verify passcode
    $inputHash = hash('sha256', $passcode);
    if (!hash_equals($adminRow['passcode_hash'], $inputHash)) {
        http_response_code(401);
        echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
        $conn->close();
        exit();
    }

    // Admin login success
    echo json_encode([
        "status" => "success",
        "hospital_name" => $adminRow['display_name'],
        "unit_id" => $unit_id,
        "role" => "admin",
    ]);
    $conn->close();
    exit();
}
$adminStmt->close();

// --- 3. Fall back to station_units lookup ---
$stmt = $conn->prepare(
    "SELECT passcode_hash, hospital_name, is_active
     FROM station_units
     WHERE unit_id = ?
     LIMIT 1"
);
$stmt->bind_param("s", $unit_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(401);
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
    $stmt->close();
    $conn->close();
    exit();
}

$row = $result->fetch_assoc();

// Check if unit is active
if (!$row['is_active']) {
    http_response_code(403);
    echo json_encode(["status" => "error", "message" => "This unit has been deactivated"]);
    $stmt->close();
    $conn->close();
    exit();
}

// Verify passcode (SHA-256 hash comparison)
$inputHash = hash('sha256', $passcode);

if (!hash_equals($row['passcode_hash'], $inputHash)) {
    http_response_code(401);
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
    $stmt->close();
    $conn->close();
    exit();
}

// Station login success
echo json_encode([
    "status" => "success",
    "hospital_name" => $row['hospital_name'],
    "unit_id" => $unit_id,
    "role" => "station",
]);

$stmt->close();
$conn->close();
?>
