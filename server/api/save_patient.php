<?php
/**
 * save_patient.php
 * Saves a snakebite patient outcome to the database.
 *
 * Expects POST body (JSON):
 *   {
 *     "patient_id":  "KDH-ER-26-0001",
 *     "unit_id":     "KDH-HSB-01",
 *     "species":     "Likely Malayan Pit Viper",
 *     "severity":    "CRITICAL",
 *     "disposition": "Admit ICU",
 *     "timestamp":   "2026-02-22T14:30:00.000Z"   (optional, from offline queue)
 *   }
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

if (!$data || empty($data['patient_id'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "patient_id is required"]);
    $conn->close();
    exit();
}

$patient_id = trim($data['patient_id']);
$unit_id = isset($data['unit_id']) ? trim($data['unit_id']) : null;
$species = isset($data['species']) ? trim($data['species']) : 'Unknown';
$severity = isset($data['severity']) ? trim($data['severity']) : 'Unknown';
$disposition = isset($data['disposition']) ? trim($data['disposition']) : 'Unknown';

// Accept timestamp from offline queue; fall back to NOW()
$recorded_at = null;
if (!empty($data['timestamp'])) {
    $dt = DateTime::createFromFormat(DateTime::ATOM, $data['timestamp']);
    if (!$dt) {
        $dt = DateTime::createFromFormat('Y-m-d\TH:i:s.u\Z', $data['timestamp']);
    }
    if ($dt) {
        $recorded_at = $dt->format('Y-m-d H:i:s');
    }
}

// --- 2. Insert with prepared statement ---
if ($recorded_at) {
    $stmt = $conn->prepare(
        "INSERT INTO patients (patient_id, unit_id, species_identified, severity_level, final_disposition, recorded_at)
         VALUES (?, ?, ?, ?, ?, ?)"
    );
    $stmt->bind_param("ssssss", $patient_id, $unit_id, $species, $severity, $disposition, $recorded_at);
}
else {
    $stmt = $conn->prepare(
        "INSERT INTO patients (patient_id, unit_id, species_identified, severity_level, final_disposition)
         VALUES (?, ?, ?, ?, ?)"
    );
    $stmt->bind_param("sssss", $patient_id, $unit_id, $species, $severity, $disposition);
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Patient record saved"]);
}
else {
    if ($conn->errno === 1062) {
        http_response_code(409);
        echo json_encode(["status" => "error", "message" => "Patient ID already exists: $patient_id"]);
    }
    else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "DB error: " . $stmt->error]);
    }
}

$stmt->close();
$conn->close();
?>