import sys

file_path = r'c:\Users\andre\Developer\FYP\snake_bite_resq\lib\screens\diagnosis_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _currentStep
if 'int _currentStep = 0;' not in content:
    content = content.replace('  final TextEditingController _patientIdController = TextEditingController();', '  int _currentStep = 0;\n  final TextEditingController _patientIdController = TextEditingController();')

# 2. Extract parts
build_start = content.index('// --- 2. SCROLLABLE CONTENT ---')
build_end = content.index('// --- WIDGET BUILDERS ---')

before_build = content[:build_start]
after_build = content[build_end:]

# 3. Create Stepper and Step Builders
stepper_view = '''// --- 2. STEPPER FLOW ---
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Colors.blue.shade700,
                  ),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  physics: const ClampingScrollPhysics(),
                  elevation: 0,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep += 1);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  controlsBuilder: (context, details) {
                    if (_currentStep == 2) return const SizedBox.shrink(); // Use custom button for final step
                    return Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: Colors.blueGrey.shade700,
                                  side: BorderSide(color: Colors.blueGrey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('BACK', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Initial'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: _buildStep1Content(),
                    ),
                    Step(
                      title: const Text('Systemic'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: _buildStep2Content(),
                    ),
                    Step(
                      title: const Text('Analyze'),
                      isActive: _currentStep >= 2,
                      content: _buildStep3Content(context),
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

  Widget _buildStep1Content() {
    return Column(
      children: [
        FadeInSlide(
          delay: const Duration(milliseconds: 100),
          child: _buildSectionCard(
            title: "1. General Symptoms",
            icon: Icons.accessibility_new_rounded,
            color: Colors.teal.shade700,
            children: [
              _buildChipSelector("Active Bleeding (Gums/Wound)", ["Yes", "No", "N/A"], _bleeding, (v) => setState(() => _bleeding = v)),
              const Divider(height: 30),
              _buildChipSelector("Bruises / Ecchymosis", ["Yes", "No", "N/A"], _bruises, (v) => setState(() => _bruises = v)),
              const Divider(height: 30),
              _buildChipSelector("Generalized Muscle Pain", ["Yes", "No", "N/A"], _musclePain, (v) => setState(() => _musclePain = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeInSlide(
          delay: const Duration(milliseconds: 200),
          child: _buildSectionCard(
            title: "2. Local Envenomation",
            icon: Icons.healing_rounded,
            color: Colors.orange.shade800,
            children: [
              _buildChipSelector("Rapid Swelling (>½ limb)", ["Yes", "Mild", "None", "N/A"], _swelling, (v) => setState(() => _swelling = v)),
              const Divider(height: 30),
              _buildChipSelector("Necrosis / Gangrene", ["Yes", "No", "N/A"], _necrosis, (v) => setState(() => _necrosis = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      children: [
        FadeInSlide(
          delay: const Duration(milliseconds: 300),
          child: _buildSectionCard(
            title: "3. Neurotoxic Signs",
            icon: Icons.visibility_rounded, // Eye icon
            color: Colors.purple.shade700,
            children: [
              _buildChipSelector("Ptosis (Drooping Eyelids)", ["Yes", "No", "N/A"], _ptosis, (v) => setState(() => _ptosis = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeInSlide(
          delay: const Duration(milliseconds: 400),
          child: _buildSectionCard(
            title: "4. Bedside & Lab Tests",
            icon: Icons.science_rounded, // Lab icon
            color: Colors.blue.shade700,
            children: [
              _buildChipSelector("Did user bring the snake?", ["Yes", "No", "N/A"], _snakeIdentified, (v) => setState(() => _snakeIdentified = v)),
              if (_snakeIdentified == "Yes") ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SnakeGalleryScreen(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _identifiedSpecies = result;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _identifiedSpecies == null ? Icons.search : Icons.check_circle_outline,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _identifiedSpecies ?? "TAP TO IDENTIFY SPECIES",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _identifiedSpecies == null ? Colors.blue.shade700 : Colors.blueGrey.shade900,
                            ),
                          ),
                        ),
                        if (_identifiedSpecies != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _identifiedSpecies = null;
                              });
                            },
                            child: Icon(Icons.close, size: 16, color: Colors.blueGrey.shade400),
                          )
                        else
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ),
              ],
              const Divider(height: 30),
              _buildChipSelector("Urine Color", ["Normal", "Dark/Cola", "Red", "N/A"], _urineColor, (v) => setState(() => _urineColor = v)),
              const Divider(height: 30),
              _buildChipSelector("20WBCT (Clotting Test)", ["Clotted (Normal)", "Liquid (>20m)", "N/A"], _wbctResult, (v) => setState(() => _wbctResult = v)),
              const Divider(height: 30),
              _buildChipSelector("Neostigmine Test", ["Positive", "Negative", "N/A"], _neostigmine, (v) => setState(() => _neostigmine = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep3Content(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.fact_check_rounded, size: 48, color: Colors.blueGrey.shade400),
              const SizedBox(height: 16),
              Text(
                "Review Clinical Input",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
              ),
              const SizedBox(height: 8),
              Text(
                "Please ensure all available symptoms and lab results have been entered accurately before running the diagnosis protocol.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 64, // Bigger height for main action
          child: ElevatedButton.icon(
            onPressed: () async {
              // Capture context-dependent refs before any await
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              // Validation: Ensure at least 3 clinical fields are answered
              final answeredCount = [
                _bleeding,
                _bruises,
                _musclePain,
                _swelling,
                _necrosis,
                _ptosis,
                _urineColor,
                _wbctResult,
              ].where((v) => v != null && v != "N/A").length;

              if (answeredCount < 3) {
                final proceed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Incomplete Assessment"),
                    content: Text(
                      "Only $answeredCount clinical fields have been answered. "
                      "Running diagnosis on incomplete data may produce inaccurate results.\\n\\n"
                      "Proceed anyway?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Back to Assessment"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text("Proceed"),
                      ),
                    ],
                  ),
                );
                if (proceed != true || !mounted) return;
              }

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
                  content: const Text(
                    "Analyzing Clinical Rules...",
                  ),
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
                      outcome: outcome,
                    ),
                  ),
                );
              });
            },
            icon: const Icon(Icons.analytics_outlined, size: 28),
            label: const Text(
              "RUN DIAGNOSIS PROTOCOL",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _currentStep -= 1);
          },
          child: const Text("Go Back and Edit"),
        )
      ],
    );
  }

'''

# Replace from // --- 2. SCROLLABLE CONTENT --- to the end of expanded (which is right before // --- WIDGET BUILDERS ---)
new_content = before_build + stepper_view + '\n  ' + after_build

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print('Refactoring successful')
