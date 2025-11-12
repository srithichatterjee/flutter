
import 'package:flutter/material.dart';

void main() => runApp(const ShNotesApp());

// --- 🏠 Root App & Theming (Exp 6) ---

class ShNotesApp extends StatelessWidget {
  const ShNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashNotes - AI Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal, // FIX: Changed 'color' to 'backgroundColor' as per deprecation warning.
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // FIX: cardTheme expects CardThemeData, not CardTheme widget.
        cardTheme: CardThemeData( 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InputScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}

// --- 💡 Data Model for Results (Exp 9: Data Structuring) ---

class QuizResult {
  final String summary;
  final List<String> keyPoints;
  final List<Map<String, String>> questions;

  QuizResult({
    required this.summary,
    required this.keyPoints,
    required this.questions,
  });
}

// --- ✍️ Input Screen (Exp 7: Forms & Validation) ---

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  // Function to simulate DYNAMIC AI processing
  Future<QuizResult> _processNotes(String notes) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 700));

    // --- Dynamic Generation Logic ---
    final sentences = notes
        .split(RegExp(r'[.!?]')) // Split by common sentence terminators
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Word Count for quiz
    final wordCount = notes.split(RegExp(r'\s+')).length;
    
    // Dynamic Summary: Use the first two sentences of the input.
    final dynamicSummary = sentences.isNotEmpty 
        ? sentences.take(2).join('. ') + (sentences.length > 1 ? '.' : '')
        : 'No sentences found to summarize.';

    // Dynamic Key Points: Use the first three key sentences.
    final dynamicKeyPoints = sentences.take(3).toList();

    // Dynamic Quiz Questions
    final q1 = 'The note contains $wordCount words.';
    final q2 = sentences.isNotEmpty 
        ? 'The first sentence discusses: ${sentences[0].split(' ').take(3).join(' ')}...' 
        : 'N/A';
    final q3 = 'The total number of sentences processed is ${sentences.length}.';

    return QuizResult(
      summary: dynamicSummary,
      keyPoints: dynamicKeyPoints,
      questions: [
        {'q': 'How many words were processed in total?', 'a': q1},
        {'q': 'What is the topic of the first sentence?', 'a': q2},
        {'q': 'How many sentences were identified?', 'a': q3},
      ],
    );
  }

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true; // Exp 5: setState for loading
      });

      final notes = _notesController.text;
      final result = await _processNotes(notes);

      // Navigate to results and pass data (Exp 4: Navigation)
      if (mounted) {
        Navigator.pushNamed(context, '/results', arguments: result);
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Pre-load sample text for easy demonstration
    _notesController.text = 'Flutter is an open-source UI toolkit created by Google. It uses a rich collection of widgets to build high-performance mobile, web, and desktop applications from a single codebase. Dart is the programming language used with Flutter.';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashNotes - AI Quiz App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your notes below to generate a summary and quiz questions.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'Your Notes',
                  hintText: 'e.g., "Flutter uses Dart. It\'s great for cross-platform apps."',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some notes.';
                  }
                  if (value.trim().length < 20) {
                    return 'Notes must be at least 20 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Generate Summary & Quiz'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 📊 Results Screen (Exp 8: Data Display & Lists) ---

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the QuizResult passed from InputScreen (Exp 4: Navigation with arguments)
    final QuizResult result = ModalRoute.of(context)!.settings.arguments as QuizResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Text(
              'Summary:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  result.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Points
            Text(
              'Key Points:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...result.keyPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(child: Text(point)),
                      ],
                    ),
                  ),
                ),
              ),
            ).toList(),
            const SizedBox(height: 24),

            // Quiz Questions
            Text(
              'Quiz Questions:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...result.questions.map(
              (qna) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q: ${qna['q']}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A: ${qna['a']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).toList(),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Go back to the input screen
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}