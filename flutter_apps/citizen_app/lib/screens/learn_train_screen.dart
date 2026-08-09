// Flutter Screen 14: Learn & Train — Interactive Emergency Training with Quizzes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class LearnTrainScreen extends StatefulWidget {
  const LearnTrainScreen({Key? key}) : super(key: key);

  @override
  State<LearnTrainScreen> createState() => _LearnTrainScreenState();
}

class _LearnTrainScreenState extends State<LearnTrainScreen> {
  final Map<String, bool> _completedModules = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (final key in _modules.map((m) => m['id'] as String)) {
        _completedModules[key] = prefs.getBool('module_$key') ?? false;
      }
    });
  }

  Future<void> _markComplete(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('module_$moduleId', true);
    setState(() => _completedModules[moduleId] = true);
  }

  static final List<Map<String, dynamic>> _modules = [
    {
      'id': 'first_aid',
      'title': 'First Aid Basics',
      'icon': Icons.medical_information_rounded,
      'color': Colors.orange,
      'lessons': [
        {'title': 'Scene Safety', 'content': '1. LOOK for danger — broken glass, fire, traffic.\n2. LISTEN for warnings — sirens, gas leaks.\n3. DO NOT approach if YOU could get hurt.\n4. Call 112 first, then approach safely.\n\n✅ Golden Rule: You can\'t help if you become a victim too.'},
        {'title': 'Call for Help', 'content': '1. Call 112 (National Emergency) or 108 (Ambulance).\n2. State: "I need an ambulance at [location]."\n3. Describe: How many people injured, what happened.\n4. Stay on the line until told to hang up.\n5. Ask a specific person: "YOU in the blue shirt — call 112!"\n\n✅ Delegation saves time. Don\'t assume someone else called.'},
        {'title': 'Check Consciousness', 'content': '1. Tap the person\'s shoulder firmly.\n2. Shout: "Are you okay? Can you hear me?"\n3. If NO response → Check breathing.\n4. If they respond → Keep them still, ask where it hurts.\n\n✅ NEVER move an unconscious person unless they\'re in danger.'},
        {'title': 'Recovery Position', 'content': '1. Kneel beside the person.\n2. Place their far arm across chest, hand on cheek.\n3. Bend their far knee up.\n4. Roll them gently onto their side.\n5. Tilt head back slightly to keep airway open.\n6. Stay with them until help arrives.\n\n✅ Recovery position prevents choking if they vomit.'},
      ],
    },
    {
      'id': 'cpr',
      'title': 'CPR Training',
      'icon': Icons.favorite_rounded,
      'color': AppColors.emergencyRed,
      'lessons': [
        {'title': 'When to Start CPR', 'content': '1. Person is UNRESPONSIVE — no movement, no eye opening.\n2. NOT BREATHING — chest is not rising and falling.\n3. NO PULSE — if you can\'t feel pulse at neck (carotid).\n\n⚠️ START CPR IMMEDIATELY. Every minute without CPR reduces survival by 10%.'},
        {'title': 'Hand Placement', 'content': '1. Place the heel of one hand on CENTER of chest (between nipples).\n2. Place your other hand ON TOP, interlock fingers.\n3. Keep arms STRAIGHT — push with your body weight.\n4. Push HARD and FAST — at least 5 cm deep.\n\n✅ Don\'t be afraid to push hard. Broken ribs heal. Death doesn\'t.'},
        {'title': 'Compression Rhythm', 'content': '1. Push at 100–120 beats per minute.\n2. Think of the song "Stayin\' Alive" by Bee Gees — match that tempo.\n3. Count aloud: "1 and 2 and 3 and 4..."\n4. After 30 compressions → 2 rescue breaths (if trained).\n5. If not trained → hands-only CPR is still effective!\n\n✅ Continue until ambulance arrives or person starts breathing.'},
        {'title': 'Rescue Breaths', 'content': '1. Tilt head back, lift chin up.\n2. Pinch nose shut.\n3. Cover their mouth with yours — make a seal.\n4. Blow steadily for 1 second — watch chest rise.\n5. Give 2 breaths, then resume compressions.\n\n⚠️ If you\'re not comfortable with mouth-to-mouth, HANDS-ONLY CPR saves lives too.'},
      ],
    },
    {
      'id': 'bleeding',
      'title': 'Stop Bleeding',
      'icon': Icons.bloodtype_rounded,
      'color': AppColors.emergencyRed,
      'lessons': [
        {'title': 'Direct Pressure', 'content': '1. Use a clean cloth, towel, or even your shirt.\n2. Press FIRMLY on the wound — don\'t lift to check.\n3. If blood soaks through → add more cloth ON TOP.\n4. Never remove the first layer.\n5. Maintain pressure for at least 10 minutes.\n\n✅ Most bleeding stops with firm direct pressure.'},
        {'title': 'Elevation', 'content': '1. If the wound is on an arm or leg, elevate it ABOVE the heart.\n2. Keep the person lying down.\n3. Continue applying pressure while elevated.\n\n⚠️ Do NOT elevate if you suspect a broken bone.'},
        {'title': 'Tourniquet Use', 'content': '1. ONLY for life-threatening arm/leg bleeding that won\'t stop.\n2. Place 2-3 inches ABOVE the wound.\n3. Use a belt, scarf, or torn cloth — 2 inches wide minimum.\n4. Tighten until bleeding stops.\n5. Note the TIME you applied it.\n6. Do NOT remove — let paramedics handle it.\n\n⚠️ Tourniquet is last resort. Direct pressure first!'},
      ],
    },
    {
      'id': 'road_safety',
      'title': 'Road Accident Protocol',
      'icon': Icons.add_road_rounded,
      'color': AppColors.brandPurple,
      'lessons': [
        {'title': 'Securing the Scene', 'content': '1. Park your vehicle safely AWAY from the accident.\n2. Turn on hazard lights.\n3. Place warning triangles 50m before and after the scene.\n4. If at night — use phone flashlight or car headlights.\n5. Direct traffic around the scene if safe.\n\n✅ A secured scene prevents additional accidents.'},
        {'title': 'Helping Victims', 'content': '1. Check for immediate dangers — fire, fuel leak, unstable vehicle.\n2. Do NOT move victims unless there\'s immediate danger.\n3. Turn off the crashed vehicle\'s engine.\n4. Cover victims with a blanket to prevent shock.\n5. Talk to them — reassurance helps.\n\n✅ You are protected by Good Samaritan Law (Section 134A MV Act).'},
        {'title': 'What NOT To Do', 'content': '1. ❌ Do NOT give water to an unconscious person.\n2. ❌ Do NOT remove a helmet from a motorcyclist.\n3. ❌ Do NOT straighten broken limbs.\n4. ❌ Do NOT pull out objects stuck in wounds.\n5. ❌ Do NOT crowd the victim — give them space.\n\n✅ Sometimes doing LESS is more helpful. Wait for paramedics.'},
        {'title': 'Legal Protection', 'content': '1. Good Samaritan Law (2019) protects YOU.\n2. No civil or criminal liability for helping in good faith.\n3. Hospitals MUST treat accident victims — cannot refuse.\n4. Police cannot detain you for questioning at the scene.\n5. You can remain anonymous if you choose.\n\n✅ Use the Sahay app to generate your Legal Protection Certificate after helping.'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final completedCount = _completedModules.values.where((v) => v).length;
    final totalModules = _modules.length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('LEARN & TRAIN', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brandPurple, AppColors.brandPurple.withAlpha(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.brandPurple.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(30),
                    ),
                    child: Center(
                      child: Text('$completedCount/$totalModules', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completedCount == totalModules ? '🏆 Golden Hour Certified!' : 'Training Progress',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completedCount == totalModules
                              ? 'You are a certified first responder!'
                              : 'Complete all modules to earn certification',
                          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalModules > 0 ? completedCount / totalModules : 0,
                            backgroundColor: Colors.white.withAlpha(40),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('COURSES & MODULES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            // Module Cards
            ..._modules.map((module) {
              final isComplete = _completedModules[module['id']] ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildModuleCard(context, module, isComplete),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, Map<String, dynamic> module, bool isComplete) {
    final color = module['color'] as Color;
    final lessons = module['lessons'] as List<Map<String, String>>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
        border: isComplete ? Border.all(color: AppColors.successGreen, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openModule(context, module),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                  child: Icon(module['icon'] as IconData, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text('${lessons.length} Lessons', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                else
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openModule(BuildContext context, Map<String, dynamic> module) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _TrainingModuleScreen(
      module: module,
      onComplete: () => _markComplete(module['id'] as String),
      isCompleted: _completedModules[module['id']] ?? false,
    )));
  }
}

// ──────────────────────────────────────────────────────────
// Internal Training Module Screen with Lessons & Quiz
// ──────────────────────────────────────────────────────────
class _TrainingModuleScreen extends StatefulWidget {
  final Map<String, dynamic> module;
  final VoidCallback onComplete;
  final bool isCompleted;
  const _TrainingModuleScreen({required this.module, required this.onComplete, required this.isCompleted});
  @override
  State<_TrainingModuleScreen> createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<_TrainingModuleScreen> {
  int _currentLesson = 0;
  bool _showQuiz = false;
  int _quizScore = 0;
  int _quizQuestion = 0;
  bool _quizComplete = false;

  final List<Map<String, dynamic>> _quizQuestions = [
    {'q': 'What is the first thing you should check at an accident scene?', 'options': ['Victim\'s name', 'Scene safety', 'Traffic flow', 'Phone signal'], 'answer': 1},
    {'q': 'What rate should CPR compressions be performed at?', 'options': ['60 BPM', '80 BPM', '100-120 BPM', '140 BPM'], 'answer': 2},
    {'q': 'If blood soaks through the first bandage, you should:', 'options': ['Remove it and replace', 'Add more cloth on top', 'Apply a tourniquet', 'Pour water on it'], 'answer': 1},
    {'q': 'Under the Good Samaritan Law, can you be arrested for helping?', 'options': ['Yes, always', 'Only if the victim dies', 'No, you are protected', 'Only at night'], 'answer': 2},
  ];

  @override
  Widget build(BuildContext context) {
    final lessons = widget.module['lessons'] as List<Map<String, String>>;
    final color = widget.module['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          (widget.module['title'] as String).toUpperCase(),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _showQuiz ? _buildQuiz(color) : _buildLesson(lessons, color),
    );
  }

  Widget _buildLesson(List<Map<String, String>> lessons, Color color) {
    final lesson = lessons[_currentLesson];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: List.generate(lessons.length, (i) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i <= _currentLesson ? color : color.withAlpha(30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text('Lesson ${_currentLesson + 1} of ${lessons.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          // Lesson Title
          Text(lesson['title']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 20),

          // Lesson Content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow,
            ),
            child: Text(
              lesson['content']!,
              style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              if (_currentLesson > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _currentLesson--),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: color),
                      foregroundColor: color,
                    ),
                  ),
                ),
              if (_currentLesson > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentLesson < lessons.length - 1) {
                      setState(() => _currentLesson++);
                    } else {
                      setState(() => _showQuiz = true);
                    }
                  },
                  icon: Icon(_currentLesson < lessons.length - 1 ? Icons.arrow_forward_rounded : Icons.quiz_rounded),
                  label: Text(_currentLesson < lessons.length - 1 ? 'Next Lesson' : 'Take Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(Color color) {
    if (_quizComplete) {
      final passed = _quizScore >= 3;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(passed ? Icons.emoji_events_rounded : Icons.refresh_rounded, size: 80, color: passed ? Colors.amber : color),
              const SizedBox(height: 24),
              Text(passed ? '🏆 Module Completed!' : 'Try Again', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: passed ? AppColors.successGreen : color)),
              const SizedBox(height: 12),
              Text('Score: $_quizScore / ${_quizQuestions.length}', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              if (passed)
                ElevatedButton.icon(
                  onPressed: () { widget.onComplete(); Navigator.pop(context); },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Claim Badge & Return'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => setState(() { _showQuiz = false; _currentLesson = 0; _quizScore = 0; _quizQuestion = 0; _quizComplete = false; }),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Review Lessons & Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final q = _quizQuestions[_quizQuestion];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Text('Question ${_quizQuestion + 1} of ${_quizQuestions.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_quizQuestion + 1) / _quizQuestions.length,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 32),
          Text(q['q'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          const SizedBox(height: 24),
          ...List.generate((q['options'] as List).length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (i == q['answer']) _quizScore++;
                  if (_quizQuestion < _quizQuestions.length - 1) {
                    setState(() => _quizQuestion++);
                  } else {
                    setState(() => _quizComplete = true);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: color.withAlpha(60)),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  (q['options'] as List)[i] as String,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
