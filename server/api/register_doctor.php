<?php
/**
 * register_doctor.php
 * Accepts a new doctor registration request.
 * The account will be set to 'pending' until an admin approves it.
 *
 * Expects POST body (JSON):
 * {
 *   "username":       "dr.newdoctor",
 *   "password":       "somepassword",
 *   "full_name":      "Dr. New Doctor",
 *   "specialization": "General Practitioner",
 *   "hospital_name":  "Hospital Sultanah Bahiyah"
 * }
 *
 * Returns:
 *   { "status": "success", "message": "Registration submitted. Awaiting admin approval." }
 * or
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

$json = file_get_contents('php://input');
$data = json_decode($json, true);

$username       = trim($data['username']       ?? '');
$password       = trim($data['password']       ?? '');
$full_name      = trim($data['full_name']      ?? '');
$specialization = trim($data['specialization'] ?? 'General Practitioner');
$hospital_name  = trim($data['hospital_name']  ?? '');

// --- Validation ---
if (empty($username) || empty($password) || empty($full_name) || empty($hospital_name)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "username, password, full_name, and hospital_name are required"]);
    $conn->close();
    exit();
}

if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Password must be at least 6 characters"]);
    $conn->close();
    exit();
}

// Validate username format (alphanumeric, dots, underscores only)
if (!preg_match('/^[a-zA-Z0-9._]{3,50}$/', $username)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Username must be 3-50 characters (letters, numbers, dots, underscores only)"]);
    $conn->close();
    exit();
}

// Valid Kedah hospitals list
$validHospitals = [
    'Hospital Sultanah Bahiyah',
    'Hospital Sultan Abdul Halim',
    'Hospital Kulim',
    'Hospital Baling',
    'Hospital Sik',
    'Hospital Sultanah Maliha',
    'Hospital Yan',
    'Hospital Jitra',
    'Hospital Kuala Nerang',
    'Hospital Pendang',
];

if (!in_array($hospital_name, $validHospitals)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid hospital name. Must be one of the Kedah government hospitals."]);
    $conn->close();
    exit();
}

// --- Check for duplicate username ---
$checkStmt = $conn->prepare("SELECT id FROM doctors WHERE username = ? LIMIT 1");
$checkStmt->bind_param("s", $username);
$checkStmt->execute();
$checkResult = $checkStmt->get_result();
if ($checkResult->num_rows > 0) {
    http_response_code(409);
    echo json_encode(["status" => "error", "message" => "Username already taken. Please choose another."]);
    $checkStmt->close();
    $conn->close();
    exit();
}
$checkStmt->close();

// Also check admin_users table for username conflict
$adminCheckStmt = $conn->prepare("SELECT id FROM admin_users WHERE username = ? LIMIT 1");
$adminCheckStmt->bind_param("s", $username);
$adminCheckStmt->execute();
$adminCheckResult = $adminCheckStmt->get_result();
if ($adminCheckResult->num_rows > 0) {
    http_response_code(409);
    echo json_encode(["status" => "error", "message" => "Username already taken. Please choose another."]);
    $adminCheckStmt->close();
    $conn->close();
    exit();
}
$adminCheckStmt->close();

// --- Insert pending registration ---
$passwordHash = hash('sha256', $password);
$insertStmt = $conn->prepare(
    "INSERT INTO doctors (username, password_hash, full_name, specialization, hospital_name, status)
     VALUES (?, ?, ?, ?, ?, 'pending')"
);
$insertStmt->bind_param("sssss", $username, $passwordHash, $full_name, $specialization, $hospital_name);

if ($insertStmt->execute()) {
    http_response_code(201);
    echo json_encode([
        "status"  => "success",
        "message" => "Registration submitted successfully. Your account will be activated after admin approval.",
    ]);
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Registration failed. Please try again."]);
}

$insertStmt->close();
$conn->close();
?>
