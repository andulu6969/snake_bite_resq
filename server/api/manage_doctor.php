<?php
/**
 * manage_doctor.php
 * Allows admin to approve, suspend, or delete a doctor account.
 *
 * Expects POST body (JSON):
 * {
 *   "admin_username": "ADMIN",
 *   "admin_passcode": "admin1234",
 *   "doctor_id":      5,
 *   "action":         "approve"  // "approve" | "suspend" | "delete"
 * }
 *
 * Returns:
 *   { "status": "success", "message": "..." }
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

$adminUsername = trim($data['admin_username'] ?? '');
$adminPasscode = trim($data['admin_passcode'] ?? '');
$doctorId      = intval($data['doctor_id']      ?? 0);
$action        = trim($data['action']           ?? '');

if (empty($adminUsername) || empty($adminPasscode) || $doctorId <= 0 || empty($action)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "admin_username, admin_passcode, doctor_id, and action are required"]);
    $conn->close();
    exit();
}

// Verify admin
$adminStmt = $conn->prepare(
    "SELECT passcode_hash, is_active FROM admin_users WHERE username = ? LIMIT 1"
);
$adminStmt->bind_param("s", $adminUsername);
$adminStmt->execute();
$adminResult = $adminStmt->get_result();

if ($adminResult->num_rows === 0) {
    http_response_code(401);
    echo json_encode(["status" => "error", "message" => "Invalid admin credentials"]);
    $adminStmt->close();
    $conn->close();
    exit();
}

$adminRow = $adminResult->fetch_assoc();
$adminStmt->close();

if (!$adminRow['is_active'] || !hash_equals($adminRow['passcode_hash'], hash('sha256', $adminPasscode))) {
    http_response_code(401);
    echo json_encode(["status" => "error", "message" => "Invalid admin credentials"]);
    $conn->close();
    exit();
}

// Perform action
if ($action === 'approve') {
    $stmt = $conn->prepare(
        "UPDATE doctors SET status = 'active', approved_at = NOW(), approved_by = ? WHERE id = ?"
    );
    $stmt->bind_param("si", $adminUsername, $doctorId);
    $stmt->execute();
    if ($stmt->affected_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Doctor account approved and activated."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor not found or already approved."]);
    }
    $stmt->close();

} elseif ($action === 'suspend') {
    $stmt = $conn->prepare(
        "UPDATE doctors SET status = 'suspended' WHERE id = ?"
    );
    $stmt->bind_param("i", $doctorId);
    $stmt->execute();
    if ($stmt->affected_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Doctor account suspended."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor not found."]);
    }
    $stmt->close();

} elseif ($action === 'delete') {
    $stmt = $conn->prepare("DELETE FROM doctors WHERE id = ?");
    $stmt->bind_param("i", $doctorId);
    $stmt->execute();
    if ($stmt->affected_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Doctor account deleted."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor not found."]);
    }
    $stmt->close();

} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid action. Use: approve, suspend, or delete"]);
}

$conn->close();
?>
