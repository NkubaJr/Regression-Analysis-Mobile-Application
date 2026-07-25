import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ArtPriceApp());
}

class ArtPriceApp extends StatelessWidget {
  const ArtPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Price Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  static const String apiBaseUrl = 'https://art-price-api.onrender.com';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();

  bool _isSigned = true;
  int _conditionScore = 3;
  bool _artistKnown = true;
  String _period = 'Contemporary';
  String _movement = 'Abstract';

  bool _isLoading = false;
  String? _resultText;
  String? _errorText;

  static const List<String> _periods = [
    '19th Century',
    'Modern',
    'Post-War',
    'Contemporary',
  ];

  static const List<String> _movements = [
    'Abstract',
    'Abstract Expressionism',
    'Conceptual',
    'Expressionism',
    'Geometric Abstraction',
    'Impressionism',
    'Minimalism',
    'Other',
    'Pop Art',
    'Realism',
    'Surrealism',
  ];

  static const Map<int, String> _conditionLabels = {
    0: 'Damaged / Fair',
    1: 'Good',
    2: 'Very Good',
    3: 'Excellent',
  };

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = null;
      _errorText = null;
    });

    final payload = {
      'year_clean': int.parse(_yearController.text.trim()),
      'is_signed': _isSigned ? 1 : 0,
      'condition_score': _conditionScore,
      'artist_known': _artistKnown ? 1 : 0,
      'period': _period,
      'movement': _movement,
    };

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _resultText = data['predicted_price_formatted'] as String;
        });
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _errorText = 'Invalid input: ${data['detail']}';
        });
      } else {
        setState(() {
          _errorText = 'Server error (${response.statusCode}). Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Could not reach the server. Check your connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Art Price Predictor'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter the artwork details below to estimate its auction price.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year Created',
                    hintText: 'e.g. 2015',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Year is required';
                    }
                    final year = int.tryParse(value.trim());
                    if (year == null) {
                      return 'Enter a valid whole number';
                    }
                    if (year < 1800 || year > 2026) {
                      return 'Year must be between 1800 and 2026';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<bool>(
                  initialValue: _isSigned,
                  decoration: const InputDecoration(
                    labelText: 'Signed',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Yes')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) => setState(() => _isSigned = value!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: _conditionScore,
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                  items: _conditionLabels.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _conditionScore = value!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<bool>(
                  initialValue: _artistKnown,
                  decoration: const InputDecoration(
                    labelText: 'Artist Recognition',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Well-known artist')),
                    DropdownMenuItem(value: false, child: Text('Lesser-known artist')),
                  ],
                  onChanged: (value) => setState(() => _artistKnown = value!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _period,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  items: _periods
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) => setState(() => _period = value!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _movement,
                  decoration: const InputDecoration(
                    labelText: 'Movement',
                    border: OutlineInputBorder(),
                  ),
                  items: _movements
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) => setState(() => _movement = value!),
                ),
                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _isLoading ? null : _predict,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Predict', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),

                if (_resultText != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Price',
                          style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _resultText!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_errorText != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorText!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}