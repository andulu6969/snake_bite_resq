<?php
/**
 * save_patient.php
 * Saves a snakebite patient outcome to the database.
 *
 * Expects POST body (JSON):
 *   {
 *     "patient_id":    "HSB-26-0007",
 *     "unit_id":       "dr.ahmad",          (doctor username)
 *     "hospital_name": "Hospital Sultanah Bahiyah",
 *     "species":       "Likely Malayan Pit Viper",
 *     "severity":      "CRITICAL",
 *     "disposition":   "Admit ICU",
 *     "ic_passport":   "970101-01-1234",    (optional)
 *     "diagnosed_by":  "Dr. Ahmad bin Razali",
 *     "timestamp":     "2026-02-22T14:30:00.000Z"  (optional, from offline queue)
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

$patient_id   = trim($data['patient_id']);
$unit_id      = isset($data['unit_id'])       ? trim($data['unit_id'])       : null;
$hospital_name = isset($data['hospital_name']) ? trim($data['hospital_name']) : null;
$species      = isset($data['species'])       ? trim($data['species'])       : 'Unknown';
$severity     = isset($data['severity'])      ? trim($data['severity'])      : 'Unknown';
$disposition  = isset($data['disposition'])   ? trim($data['disposition'])   : 'Unknown';
$ic_passport  = isset($data['ic_passport'])   ? trim($data['ic_passport'])   : null;
$diagnosed_by = isset($data['diagnosed_by'])  ? trim($data['diagnosed_by'])  : null;

// If hospital_name not provided, try resolving from doctors table via unit_id
if (empty($hospital_name) && !empty($unit_id)) {
    $hst = $conn->prepare("SELECT hospital_name FROM doctors WHERE username = ? LIMIT 1");
    $hst->bind_param("s", $unit_id);
    $hst->execute();
    $hrow = $hst->get_result()->fetch_assoc();
    $hst->close();
    if ($hrow) {
        $hospital_name = $hrow['hospital_name'];
    } else {
        // Fallback: station_units
        $hst2 = $conn->prepare("SELECT hospital_name FROM station_units WHERE unit_id = ? LIMIT 1");
        $hst2->bind_param("s", $unit_id);
        $hst2->execute();
        $hrow2 = $hst2->get_result()->fetch_assoc();
        $hst2->close();
        if ($hrow2) $hospital_name = $hrow2['hospital_name'];
    }
}

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
        "INSERT INTO patients
             (patient_id, unit_id, hospital_name, species_identified, severity_level,
              final_disposition, ic_passport, diagnosed_by, recorded_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $stmt->bind_param(
        "sssssssss",
        $patient_id, $unit_id, $hospital_name, $species, $severity,
        $disposition, $ic_passport, $diagnosed_by, $recorded_at
    );
} else {
    $stmt = $conn->prepare(
        "INSERT INTO patients
             (patient_id, unit_id, hospital_name, species_identified, severity_level,
              final_disposition, ic_passport, diagnosed_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $stmt->bind_param(
        "ssssssss",
        $patient_id, $unit_id, $hospital_name, $species, $severity,
        $disposition, $ic_passport, $diagnosed_by
    );
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Patient record saved"]);
} else {
    if ($conn->errno === 1062) {
        http_response_code(409);
        echo json_encode(["status" => "error", "message" => "Patient ID already exists: $patient_id"]);
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "DB error: " . $stmt->error]);
    }
}

$stmt->close();
$conn->close();
?>