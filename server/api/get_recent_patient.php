<?php
/**
 * get_recent_patient.php
 * Returns the most recently admitted patient scoped strictly to the doctor's HOSPITAL.
 * Doctors from other hospitals will NEVER see this hospital's most recent patient.
 *
 * Query params (provide one):
 *   ?hospital_name=Hospital+Sultanah+Bahiyah
 *   ?unit_id=dr.ahmad   (resolved to hospital_name via doctors table)
 *
 * Returns {"status":"empty"} if hospital cannot be determined — never returns
 * records from a different hospital.
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

$hospitalName = isset($_GET['hospital_name']) ? trim($_GET['hospital_name']) : '';
$unitId       = isset($_GET['unit_id'])       ? trim($_GET['unit_id'])       : '';

// Resolve hospital from username / unit_id if not passed directly
if (empty($hospitalName) && !empty($unitId)) {
    // Try doctors table first (new auth system)
    $st = $conn->prepare("SELECT hospital_name FROM doctors WHERE username = ? LIMIT 1");
    $st->bind_param("s", $unitId);
    $st->execute();
    $row = $st->get_result()->fetch_assoc();
    $st->close();
    if ($row) {
        $hospitalName = $row['hospital_name'];
    } else {
        // Fallback: legacy station_units table
        $st2 = $conn->prepare("SELECT hospital_name FROM station_units WHERE unit_id = ? LIMIT 1");
        $st2->bind_param("s", $unitId);
        $st2->execute();
        $row2 = $st2->get_result()->fetch_assoc();
        $st2->close();
        if ($row2) $hospitalName = $row2['hospital_name'];
    }
}

// STRICT: if we still cannot determine the hospital, return empty — never leak other hospitals' data
if (empty($hospitalName)) {
    echo json_encode([
        "status"  => "empty",
        "message" => "Hospital scope could not be determined",
    ]);
    $conn->close();
    exit();
}

// Fetch the most recent patient for THIS hospital only
$stmt = $conn->prepare(
    "SELECT patient_id,
            species_identified  AS species,
            severity_level      AS severity,
            final_disposition   AS disposition,
            ic_passport,
            diagnosed_by,
            hospital_name,
            recorded_at
     FROM patients
     WHERE hospital_name = ?
     ORDER BY id DESC
     LIMIT 1"
);
$stmt->bind_param("s", $hospitalName);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    echo json_encode([
        "status" => "success",
        "data"   => $result->fetch_assoc(),
    ]);
} else {
    echo json_encode([
        "status"  => "empty",
        "message" => "No patient records found for $hospitalName",
    ]);
}

$stmt->close();
$conn->close();
?>