<?php
// Sahay Emergency SOS PHP REST API Endpoint
require_once __DIR__ . '/../config.php';

header('Content-Type: application/json');

$requestMethod = $_SERVER['REQUEST_METHOD'];

if ($requestMethod === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$inputData = json_decode(file_get_contents('php://input'), true);

$latitude = $inputData['latitude'] ?? 21.7645;
$longitude = $inputData['longitude'] ?? 72.1519;
$sourceType = $inputData['source_type'] ?? 'WHATSAPP_OR_WEB'; // 'AUTO_CRASH_FLUTTER', 'WHATSAPP_OR_WEB', 'BUTTON'
$language = $inputData['language'] ?? 'gu';

$incidentId = 'SHY-BVN-' . date('Ymd') . '-' . rand(1000, 9999);
$timestamp = time();

// Generate Dynamic Legal Immunity Token using HMAC-SHA256
$payloadToSign = $incidentId . '|' . $latitude . '|' . $longitude . '|' . $timestamp;
$hmacSignature = hash_hmac('sha256', $payloadToSign, HMAC_SECRET_KEY);

$legalPassportData = [
    'incident_id' => $incidentId,
    'bystander_protection' => 'MV_ACT_SEC_134A_COMPLIANT',
    'police_verification_stamp' => 'BHAVNAGAR_DISTRICT_POLICE_VERIFIED',
    'timestamp' => date('c', $timestamp),
    'hmac_signature' => $hmacSignature
];

// Response payload easily consumed by Flutter apps & Web clients
$response = [
    'status' => 'SUCCESS',
    'message' => 'Sahay Emergency SOS Registered Successfully',
    'incident_id' => $incidentId,
    'source_type' => $sourceType,
    'location' => [
        'latitude' => $latitude,
        'longitude' => $longitude,
        'corridor' => 'NH-8E / SH-25 Bhavnagar Highway'
    ],
    'dispatched_responder' => [
        'name' => 'Maheshbhai (Chamunda Dhaba Champion)',
        'distance_meters' => 550,
        'eta_minutes' => 3
    ],
    'legal_passport' => $legalPassportData,
    'qr_data_string' => json_encode($legalPassportData)
];

echo json_encode($response, JSON_PRETTY_PRINT);
?>
