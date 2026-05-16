<?php
/**
 * get_pending_doctors.php
 * Returns all doctors with status = 'pending'.
 * Used by the admin panel to review and approve/reject registrations.
 *
 * Expects GET params:
 *   ?admin_username=ADMIN&admin_passcode=admin1234
 *
 * Returns:
 *   { "status": "success", "doctors": [ {...}, {...} ] }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_connect.php';

// Simple admin verification
$adminUsername = trim($_GET['admin_username'] ?? '');
$adminPasscode = trim($_GET['admin_passcode'] ?? '');

if (empty($adminUsername) || empty($adminPasscode)) {
    http_response_code(401);
    echo json_encode(["status" => "error", "message" => "Admin credentials required"]);
    $conn->close();
    exit();
}

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

// Fetch all doctors with their status
$filter = trim($_GET['filter'] ?? 'pending'); // 'pending', 'active', 'all'

if ($filter === 'all') {
    $stmt = $conn->prepare(
        "SELECT id, username, full_name, specialization, hospital_name, status, created_at, approved_at, approved_by
         FROM doctors
         ORDER BY FIELD(status,'pending','active','suspended'), created_at DESC"
    );
} elseif ($filter === 'active') {
    $stmt = $conn->prepare(
        "SELECT id, username, full_name, specialization, hospital_name, status, created_at, approved_at, approved_by
         FROM doctors
         WHERE status = 'active'
         ORDER BY created_at DESC"
    );
} else {
    // default: pending
    $stmt = $conn->prepare(
        "SELECT id, username, full_name, specialization, hospital_name, status, created_at, approved_at, approved_by
         FROM doctors
         WHERE status = 'pending'
         ORDER BY created_at ASC"
    );
}

$stmt->execute();
$result = $stmt->get_result();

$doctors = [];
while ($row = $result->fetch_assoc()) {
    $doctors[] = $row;
}

echo json_encode([
    "status"  => "success",
    "filter"  => $filter,
    "count"   => count($doctors),
    "doctors" => $doctors,
]);

$stmt->close();
$conn->close();
?>
