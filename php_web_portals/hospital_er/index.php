<?php
// Hospital ER Doctor Web Portal (Role 5 — PHP Web)
require_once __DIR__ . '/../config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sahay — Sir T. Hospital ER Casualty Web Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { background: #070a12; color: #fff; font-family: 'Plus Jakarta Sans', sans-serif; padding: 2rem; }
        .card { background: #0f172a; border: 1px solid #1e293b; border-radius: 16px; padding: 1.5rem; margin-bottom: 1.5rem; }
        .alert-banner { background: rgba(255,42,75,0.15); border: 2px solid #ff2a4b; padding: 1.25rem; border-radius: 12px; }
        .badge-green { background: #10b981; color: #000; padding: 4px 10px; border-radius: 20px; font-weight: bold; font-size: 0.8rem; }
    </style>
</head>
<body>
    <div class="card">
        <h1><span style="color:#ff2a4b;">🏥 Sir Takhtasinhji (Sir T.) General Hospital</span> — Emergency Trauma Room</h1>
        <p>Casualty Medical Officer Desk • PMSSY Super Specialty Block</p>
    </div>

    <div class="alert-banner">
        <h2>🚨 REAL-TIME INCOMING TRAUMA VICTIM ALERT (WebSocket Active)</h2>
        <p><strong>Incident Location:</strong> NH-8E Km 14 (Chitra Highway Crossing)</p>
        <p><strong>ETA:</strong> <span class="badge-green">4 MINS</span> | <strong>Vitals:</strong> BP 90/60 • Pulse 124 BPM • SpO2 89% • Blood Group B+</p>
        <p><strong>Action:</strong> 128-Slice CT Scan Room & Blood Bank Pre-Notified.</p>
    </div>
</body>
</html>
