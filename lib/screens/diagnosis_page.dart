import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/diagnosis_result_page.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/logic/diagnosis_logic.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  // --- STATE VARIABLES ---
  final TextEditingController _patientIdController = TextEditingController();
  DateTime _biteTime = DateTime.now().subtract(const Duration(minutes: 45));
  Timer? _timer;
  String _durationSinceBite = "00h 00m";

  // Clinical Inputs
  String? _snakeIdentified = 'No';
  String? _identifiedSpecies;
  String? _wbctResult;
  String? _urineColor;
  String? _ptosis;
  String? _swelling;
  String? _necrosis;
  String? _musclePain;
  String? _bleeding;
  String? _bruises; // New Variable
  String? _neostigmine;

  @override
  void initState() {
    super.initState();
    _fetchNextId();
    _updateDuration();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _updateDuration(),
    );
  }

  void _updateDuration() {
    final duration = DateTime.now().difference(_biteTime);
    setState(() {
      _durationSinceBite =
          "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    });
  }

  Future<void> _fetchNextId() async {
    String nextId = await ApiService.getNextPatientId();
    setState(() {
      _patientIdController.text = nextId;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
            _buildHeader(),

            // --- 2. SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    // THE TWO COLUMNS ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- LEFT COLUMN (EASIER / VISIBLE SYMPTOMS) ---
                        Expanded(
                          child: Column(
                            children: [
                              // 1. GENERAL SYMPTOMS (Easiest to see)
                              _buildSectionCard(
                                title: "1. General Symptoms",
                                icon: Icons
                                    .accessibility_new_rounded, // Body icon
                                color: Colors.teal.shade700,
                                children: [
                                  _buildChipSelector(
                                    "Active Bleeding (Gums/Wound)",
                                    ["Yes", "No", "N/A"],
                                    _bleeding,
                                    (v) => setState(() => _bleeding = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "Bruises / Ecchymosis",
                                    ["Yes", "No", "N/A"],
                                    _bruises,
                                    (v) => setState(() => _bruises = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "Generalized Muscle Pain",
                                    ["Yes", "No", "N/A"],
                                    _musclePain,
                                    (v) => setState(() => _musclePain = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 2. LOCAL ENVENOMATION (Visible at site)
                              _buildSectionCard(
                                title: "2. Local Envenomation",
                                icon: Icons.healing_rounded, // Hand/Limb icon
                                color: Colors.orange.shade800,
                                children: [
                                  _buildChipSelector(
                                    "Rapid Swelling (>½ limb)",
                                    ["Yes", "Mild", "None", "N/A"],
                                    _swelling,
                                    (v) => setState(() => _swelling = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "Necrosis / Gangrene",
                                    ["Yes", "No", "N/A"],
                                    _necrosis,
                                    (v) => setState(() => _necrosis = v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20), // Spacing between columns
                        // --- RIGHT COLUMN (HARDER / LABS / SPECIFIC CHECKS) ---
                        Expanded(
                          child: Column(
                            children: [
                              // 3. NEUROTOXIC SIGNS (Specific check)
                              _buildSectionCard(
                                title: "3. Neurotoxic Signs",
                                icon: Icons.visibility_rounded, // Eye icon
                                color: Colors.purple.shade700,
                                children: [
                                  _buildChipSelector(
                                    "Ptosis (Drooping Eyelids)",
                                    ["Yes", "No", "N/A"],
                                    _ptosis,
                                    (v) => setState(() => _ptosis = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 4. BEDSIDE & LAB TESTS (Hardest / Takes time)
                              _buildSectionCard(
                                title: "4. Bedside & Lab Tests",
                                icon: Icons.science_rounded, // Lab icon
                                color: Colors.blue.shade700,
                                children: [
                                  _buildChipSelector(
                                    "Did user bring the snake?",
                                    ["Yes", "No", "N/A"],
                                    _snakeIdentified,
                                    (v) => setState(() => _snakeIdentified = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "Urine Color",
                                    ["Normal", "Dark/Cola", "Red", "N/A"],
                                    _urineColor,
                                    (v) => setState(() => _urineColor = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "20WBCT (Clotting Test)",
                                    [
                                      "Clotted (Normal)",
                                      "Liquid (>20m)",
                                      "N/A",
                                    ],
                                    _wbctResult,
                                    (v) => setState(() => _wbctResult = v),
                                  ),
                                  const Divider(height: 30),
                                  _buildChipSelector(
                                    "Neostigmine Test",
                                    ["Positive", "Negative", "N/A"],
                                    _neostigmine,
                                    (v) => setState(() => _neostigmine = v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- 3. BIG ACTION BUTTON BAR ---
                    Container(
                      width: double.infinity,
                      height: 70, // Made bigger
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Capture context-dependent refs before any await
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          // 1. Run the Logic
                          final outcome = DiagnosisLogic.evaluate(
                            snakeIdentified: _snakeIdentified,
                            identifiedSpecies: _identifiedSpecies,
                            bleeding: _bleeding,
                            bruises: _bruises,
                            musclePain: _musclePain,
                            swelling: _swelling,
                            necrosis: _necrosis,
                            ptosis: _ptosis,
                            urineColor: _urineColor,
                            wbctResult: _wbctResult,
                            neostigmine: _neostigmine,
                          );

                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Analyzing Clinical Rules..."),
                              backgroundColor: Colors.teal.shade800,
                              duration: const Duration(milliseconds: 800),
                            ),
                          );

                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (!mounted) return;
                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) => DiagnosisResultPage(
                                  patientId: _patientIdController.text,
                                  outcome: outcome, // PASS THE OUTCOME HERE
                                ),
                              ),
                            );
                          });
                        },
                        icon: const Icon(Icons.analytics_outlined, size: 32),
                        label: const Text(
                          "RUN DIAGNOSIS PROTOCOL",
                          style: TextStyle(
                            fontSize: 18, // Bigger font
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _biteTime = DateTime.now().subtract(const Duration(minutes: 45));
      _updateDuration();
      _snakeIdentified = 'No';
      _identifiedSpecies = null;
      _wbctResult = null;
      _urineColor = null;
      _ptosis = null;
      _swelling = null;
      _necrosis = null;
      _musclePain = null;
      _bleeding = null;
      _bruises = null;
      _neostigmine = null;
    });
  }

  Future<void> _selectBiteTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _biteTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.orange.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_biteTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.orange.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime newBiteTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // If selected time is in the future, cap it to now
      if (newBiteTime.isAfter(now)) {
        newBiteTime = now;
      }

      setState(() {
        _biteTime = newBiteTime;
        _updateDuration();
      });
    }
  }

  // ... (buildHeader implementation updated below)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // Ensures both boxes are the same height
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PATIENT ID INPUT (Left Side) ---
            Expanded(
              flex: 3,
              child: TextField(
                controller: _patientIdController,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: "SYSTEM PATIENT ID",
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.qr_code,
                    color: Colors.teal,
                    size: 24,
                  ),
                  suffixIcon: const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.teal.withOpacity(0.05),
                  isDense: true, // Makes it compact
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 21,
                    horizontal: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),
            // --- TIMER BOX (Right Side - FIXED OVERFLOW) ---
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _selectBiteTime(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  // CHANGED: Row -> Column (Stacks vertically to prevent overflow)
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TIME SINCE BITE",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 12,
                            color: Colors.orange[800],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 6),
                          // Flexible ensures text shrinks if screen is extremely tiny
                          Flexible(
                            child: Text(
                              _durationSinceBite,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // --- RESET BUTTON ---
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Reset Diagnosis"),
                      content: const Text(
                        "Are you sure you want to clear all entered symptoms and lab results?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _resetFields();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Diagnosis fields reset."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                          ),
                          child: const Text(
                            "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.refresh_rounded, color: Colors.red.shade700),
                tooltip: "Reset Diagnosis",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ), // Bigger Font
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChipSelector(
    String label,
    List<String> options,
    String? currentValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ), // Bigger Font
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(option);
              },
              selectedColor: _getChipColor(option),
              backgroundColor: Colors.grey[50],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14, // Bigger Font for chips
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ), // Bigger Touch Area
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getChipColor(String option) {
    if (option == "N/A") return Colors.grey; // Specific color for N/A
    if (option.contains("Liquid") ||
        option.contains("Dark") ||
        option.contains("Positive") ||
        option.contains("Yes") ||
        option.contains("Rapid")) {
      return Colors.redAccent;
    }
    if (option.contains("Mild")) return Colors.orangeAccent;
    return Colors.teal;
  }
}
