<?php
// Sahay Emergency SOS & Multi-Device Accept/Decline Dispatch Engine
require_once __DIR__ . '/../config.php';

header('Content-Type: application/json');

$action = $_GET['action'] ?? 'trigger';
$inputData = json_decode(file_get_contents('php://input'), true);

if ($action === 'trigger') {
    $latitude = $inputData['latitude'] ?? 21.7645;
    $longitude = $inputData['longitude'] ?? 72.1519;
    $sourceType = $inputData['source_type'] ?? 'EMPTY_ROAD_SELF_SOS'; // 'EMPTY_ROAD_SELF_SOS', 'CROWDED_CITY_AMBULANCE', 'AUTO_CRASH_FLUTTER'
    $victimName = $inputData['victim_name'] ?? 'Raj Barot';
    
    $incidentId = 'SHY-BVN-' . date('Ymd') . '-' . rand(1000, 9999);
    $timestamp = time();
    
    // HMAC Signed Good Samaritan Immunity Token
    $payloadToSign = $incidentId . '|' . $latitude . '|' . $longitude . '|' . $timestamp;
    $hmacSignature = hash_hmac('sha256', $payloadToSign, HMAC_SECRET_KEY);
    
    echo json_encode([
        'status' => 'SUCCESS',
        'incident_id' => $incidentId,
        'source_type' => $sourceType,
        'victim' => [
            'name' => $victimName,
            'location' => ['lat' => $latitude, 'lng' => $longitude],
            'corridor' => 'NH-8E / SH-25 Bhavnagar Corridor'
        ],
        'broadcast_status' => 'SENT_TO_ALL_NEARBY_DEVICES',
        'legal_pass_qr' => json_encode([
            'incident_id' => $incidentId,
            'bystander_protection' => 'MV_ACT_SEC_134A_COMPLIANT',
            'hmac' => $hmacSignature
        ])
    ], JSON_PRETTY_PRINT);
    exit();
}

if ($action === 'accept') {
    $incidentId = $inputData['incident_id'] ?? 'SHY-BVN-9921';
    $responderName = $inputData['responder_name'] ?? 'Maheshbhai (Chamunda Dhaba Champion)';
    $responderPhone = $inputData['responder_phone'] ?? '+91 98765 43210';
    $responderRole = $inputData['responder_role'] ?? 'Highway Responder Champion';

    echo json_encode([
        'status' => 'ACCEPTED',
        'incident_id' => $incidentId,
        'accepted_by' => [
            'name' => $responderName,
            'phone' => $responderPhone,
            'role' => $responderRole,
            'distance_meters' => 550,
            'eta_minutes' => 3,
            'live_location' => ['lat' => 21.7650, 'lng' => 72.1525]
        ],
        'message_to_victim' => "$responderName HAS ACCEPTED YOUR REQUEST — 550m Away (ETA 3 Mins)"
    ], JSON_PRETTY_PRINT);
    exit();
}

if ($action === 'decline') {
    echo json_encode([
        'status' => 'DECLINED',
        'message' => 'Passed to next nearest corridor responder within 1.5 km geofence'
    ], JSON_PRETTY_PRINT);
    exit();
}
?>
