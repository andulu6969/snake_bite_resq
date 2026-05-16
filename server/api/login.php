<?php
/**
 * login.php
 * Validates a doctor OR admin login for the SnakeBiteResQ app.
 *
 * Expects POST body (JSON):
 *   { "username": "dr.ahmad", "password": "doctor1234" }
 *
 * Returns on success (doctor):
 *   { "status": "success", "role": "doctor",
 *     "username": "dr.ahmad", "full_name": "Dr. Ahmad bin Razali",
 *     "specialization": "Emergency Medicine",
 *     "hospital_name": "Hospital Sultanah Bahiyah" }
 *
 * Returns on success (admin):
 *   { "status": "success", "role": "admin",
 *     "username": "ADMIN", "full_name": "Ministry of Health",
 *     "hospital_name": "Ministry of Health" }
 *
 * Returns on failure:
 *   { "status": "error", "message": "..." }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

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

// Support both new (username/password) and legacy (unit_id/passcode) field names
$username = trim($data['username'] ?? $data['unit_id'] ?? '');
$password = trim($data['password'] ?? $data['passcode'] ?? '');

if (empty($username) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "username and password are required"]);
    $conn->close();
    exit();
}

$inputHash = hash('sha256', $password);

// --- 2. Check admin_users table first ---
$adminStmt = $conn->prepare(
    "SELECT passcode_hash, display_name, is_active
     FROM admin_users
     WHERE username = ?
     LIMIT 1"
);
$adminStmt->bind_param("s", $username);
$adminStmt->execute();
$adminResult = $adminStmt->get_result();

if ($adminResult->num_rows > 0) {
    $adminRow = $adminResult->fetch_assoc();
    $adminStmt->close();

    if (!$adminRow['is_active']) {
        http_response_code(403);
        echo json_encode(["status" => "error", "message" => "This admin account has been deactivated"]);
        $conn->close();
        exit();
    }

    if (!hash_equals($adminRow['passcode_hash'], $inputHash)) {
        http_response_code(401);
        echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
        $conn->close();
        exit();
    }

    // Admin login success
    echo json_encode([
        "status"        => "success",
        "role"          => "admin",
        "username"      => $username,
        "full_name"     => $adminRow['display_name'],
        "hospital_name" => $adminRow['display_name'],
        // Legacy compat fields
        "unit_id"       => $username,
    ]);
    $conn->close();
    exit();
}
$adminStmt->close();

// --- 3. Check doctors table ---
$docStmt = $conn->prepare(
    "SELECT password_hash, full_name, specialization, hospital_name, status
     FROM doctors
     WHERE username = ?
     LIMIT 1"
);
$docStmt->bind_param("s", $username);
$docStmt->execute();
$docResult = $docStmt->get_result();

if ($docResult->num_rows > 0) {
    $docRow = $docResult->fetch_assoc();
    $docStmt->close();

    // Check approval status
    if ($docRow['status'] === 'pending') {
        http_response_code(403);
        echo json_encode([
            "status"  => "error",
            "message" => "Your account is pending admin approval. Please try again later."
        ]);
        $conn->close();
        exit();
    }

    if ($docRow['status'] === 'suspended') {
        http_response_code(403);
        echo json_encode([
            "status"  => "error",
            "message" => "Your account has been suspended. Contact your hospital admin."
        ]);
        $conn->close();
        exit();
    }

    // Verify password
    if (!hash_equals($docRow['password_hash'], $inputHash)) {
        http_response_code(401);
        echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
        $conn->close();
        exit();
    }

    // Doctor login success
    echo json_encode([
        "status"         => "success",
        "role"           => "doctor",
        "username"       => $username,
        "full_name"      => $docRow['full_name'],
        "specialization" => $docRow['specialization'],
        "hospital_name"  => $docRow['hospital_name'],
        // Legacy compat: unit_id maps to username so existing API calls still work
        "unit_id"        => $username,
    ]);
    $conn->close();
    exit();
}
$docStmt->close();

// --- 4. Nothing matched ---
http_response_code(401);
echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
$conn->close();
?>
