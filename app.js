document.addEventListener('DOMContentLoaded', () => {

    // 1. Tab Navigation Logic
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');

    window.switchTab = function(tabId) {
        tabBtns.forEach(b => b.classList.remove('active'));
        tabPanes.forEach(p => p.classList.remove('active'));

        const targetBtn = document.querySelector(`.tab-btn[data-tab="${tabId}"]`);
        const targetPane = document.getElementById(tabId);

        if (targetBtn && targetPane) {
            targetBtn.classList.add('active');
            targetPane.classList.add('active');
        }
    };

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.getAttribute('data-tab');
            switchTab(tabId);
        });
    });

    // 2. Main SOS Button
    const btnSosMain = document.getElementById('btn-sos-main');
    if (btnSosMain) {
        btnSosMain.addEventListener('click', () => {
            document.getElementById('sos-status-box').classList.remove('hidden');
            speakText("Sahay Emergency SOS Activated. 108 Ambulance and nearest Dhaba Champions dispatched.");
        });
    }

    // 3. AI Accident Scan Simulation
    window.triggerAiScan = function() {
        const simBox = document.getElementById('ai-analysis-sim');
        if (simBox) simBox.classList.remove('hidden');
    };

    window.closeAiSim = function() {
        const simBox = document.getElementById('ai-analysis-sim');
        if (simBox) simBox.classList.add('hidden');
    };

    window.confirmAiAlert = function() {
        closeAiSim();
        document.getElementById('sos-status-box').classList.remove('hidden');
        speakText("AI High Severity Crash Telematics transmitted to 108 Ambulance and Sir T. Hospital ER.");
    };

    // 4. Ambulance Select Hospital Pre-Alert
    window.confirmHospitalSelect = function() {
        speakText("Pre-Alert Sent to City Care Hospital Trauma Center. 128 Slice CT & Blood Bank Pre-Notified.");
        alert("Pre-Alert Sent to City Care Hospital ER Trauma Team!");
    };

    // Helper Speech Function
    function speakText(text) {
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.rate = 0.95;
        window.speechSynthesis.speak(utterance);
    }

    // 5. Voice Prompt Speech Synthesis
    window.playVoicePrompt = function(stepNum) {
        let textToSpeak = "";
        if (stepNum === 1) textToSpeak = "દર્દીનું માથું સહેજ પાછળ તરફ નમવો જેથી શ્વાસનળી ખુલ્લી રહે.";
        else if (stepNum === 2) textToSpeak = "લોહી નીકળતા ઘા પર સ્વચ્છ કપડું મૂકી મજબૂત દબાણ આપો.";
        speakText(textToSpeak);
    };

    // 6. CPR Metronome Beater (100 BPM = 600ms)
    const cprBtn = document.getElementById('cpr-metronome-btn');
    const cprBeater = document.getElementById('cpr-beater');
    let metronomeInterval = null;
    let isBeating = false;

    if (cprBtn) {
        cprBtn.addEventListener('click', () => {
            if (!isBeating) {
                isBeating = true;
                cprBtn.innerHTML = '<i class="fa-solid fa-square"></i> Stop CPR Metronome';
                const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

                metronomeInterval = setInterval(() => {
                    if (cprBeater) cprBeater.classList.add('beating');
                    try {
                        const osc = audioCtx.createOscillator();
                        const gain = audioCtx.createGain();
                        osc.type = 'sine';
                        osc.frequency.setValueAtTime(800, audioCtx.currentTime);
                        gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
                        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.08);
                        osc.connect(gain);
                        gain.connect(audioCtx.destination);
                        osc.start();
                        osc.stop(audioCtx.currentTime + 0.08);
                    } catch(e){}
                    setTimeout(() => { if (cprBeater) cprBeater.classList.remove('beating'); }, 150);
                }, 600);
            } else {
                isBeating = false;
                clearInterval(metronomeInterval);
                cprBtn.innerHTML = '<i class="fa-solid fa-play"></i> Start CPR Metronome Beats';
                if (cprBeater) cprBeater.classList.remove('beating');
            }
        });
    }

    // 7. Hospital ER Sound Chime Simulator
    window.playHospitalChime = function() {
        try {
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5 note
            osc.frequency.setValueAtTime(880, audioCtx.currentTime + 0.15); // A5 note
            gain.gain.setValueAtTime(0.4, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.6);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.6);
        } catch(e){}
    };

    // 8. Hospital QR Scanner Simulator
    const simScanBtn = document.getElementById('sim-scan-btn');
    const scanResultBox = document.getElementById('scan-result-box');

    if (simScanBtn) {
        simScanBtn.addEventListener('click', () => {
            simScanBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Verifying HMAC Signature...';
            setTimeout(() => {
                if (scanResultBox) scanResultBox.classList.remove('hidden');
                simScanBtn.innerHTML = '<i class="fa-solid fa-circle-check"></i> Immunity Verified & ER Unlocked';
                simScanBtn.style.background = 'var(--accent-green)';
            }, 1000);
        });
    }

    // 9. Police Mobile Field Scanner Simulator
    const simPoliceScanBtn = document.getElementById('sim-police-scan-btn');
    const policeScanResult = document.getElementById('police-scan-result');

    if (simPoliceScanBtn) {
        simPoliceScanBtn.addEventListener('click', () => {
            simPoliceScanBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Scanning QR Code...';
            setTimeout(() => {
                if (policeScanResult) policeScanResult.classList.remove('hidden');
                simPoliceScanBtn.innerHTML = '<i class="fa-solid fa-shield-check"></i> Sec 134A Pass Verified';
                simPoliceScanBtn.style.background = 'var(--accent-green)';
            }, 1000);
        });
    }

});
