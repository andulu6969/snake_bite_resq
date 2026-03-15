<?php
/**
 * get_recent_patient.php
 * Returns the most recently admitted patient for the logged-in unit.
 *
 * Query params:
 *   ?unit_id=KDH-HSB-01  (required — scopes to this unit)
 *
 * Example response:
 *   {
 *     "status": "success",
 *     "data": {
 *       "patient_id":  "KDH-ER-26-0006",
 *       "species":     "Non-venomous Snake",
 *       "severity":    "LOW",
 *       "disposition": "Discharge",
 *       "recorded_at": "2026-02-22 20:00:00"
 *     }
 *   }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

$unit_id = isset($_GET['unit_id']) ? trim($_GET['unit_id']) : '';

if (!empty($unit_id)) {
    $stmt = $conn->prepare(
        "SELECT patient_id,
                species_identified  AS species,
                severity_level      AS severity,
                final_disposition   AS disposition,
                recorded_at
         FROM patients
         WHERE unit_id = ?
         ORDER BY id DESC
         LIMIT 1"
    );
    $stmt->bind_param("s", $unit_id);
}
else {
    // Fallback: no unit filter (shows most recent overall)
    $stmt = $conn->prepare(
        "SELECT patient_id,
                species_identified  AS species,
                severity_level      AS severity,
                final_disposition   AS disposition,
                recorded_at
         FROM patients
         ORDER BY id DESC
         LIMIT 1"
    );
}

$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    echo json_encode([
        "status" => "success",
        "data" => $result->fetch_assoc(),
    ]);
}
else {
    echo json_encode([
        "status" => "empty",
        "message" => "No patient records found",
    ]);
}

$stmt->close();
$conn->close();
?>