import 'package:flutter/material.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/models/prediction.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

/// The form for one disease, built from the fields the model expects, and
/// the result once it has run.
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key, required this.model});

  final DiseaseModel model;

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _numbers = {};
  final Map<String, String?> _choices = {};
  bool _running = false;
  PredictionOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    for (final field in widget.model.features) {
      if (field.isSelect) {
        _choices[field.name] = null;
      } else {
        _numbers[field.name] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _numbers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  String? _validateNumber(FeatureField field, String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return field.required ? 'Please fill this in' : null;
    final value = double.tryParse(text);
    if (value == null) return 'Enter a number';
    final min = field.min;
    final max = field.max;
    if (min != null && value < min) return 'Must be at least ${_plain(min)}';
    if (max != null && value > max) return 'Must be at most ${_plain(max)}';
    return null;
  }

  /// Field values in the shape the backend expects; blank optional fields
  /// are left out and the model fills them in.
  Map<String, dynamic> _inputs() {
    final inputs = <String, dynamic>{};
    for (final field in widget.model.features) {
      if (field.isSelect) {
        final choice = _choices[field.name];
        if (choice != null && choice.isNotEmpty) inputs[field.name] = choice;
      } else {
        final text = _numbers[field.name]!.text.trim();
        final value = double.tryParse(text);
        if (value != null) {
          inputs[field.name] = value == value.roundToDouble() ? value.toInt() : value;
        }
      }
    }
    return inputs;
  }

  Future<void> _run() async {
    if (!_formKey.currentState!.validate()) {
      showMessage(context, 'Please check the highlighted fields.', error: true);
      return;
    }

    setState(() => _running = true);
    try {
      final outcome = await HealthNovaApi.predict(widget.model.key, _inputs());
      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        _running = false;
      });
    } catch (error) {
      if (!mounted) return;
      showMessage(context, errorText(error), error: true);
      setState(() => _running = false);
    }
  }

  void _checkAgain() {
    setState(() => _outcome = null);
  }

  String _label(FeatureField field) {
    final unit = field.unit.isNotEmpty ? ' (${field.unit})' : '';
    return '${field.label}$unit';
  }

  String? _helper(FeatureField field) {
    final parts = <String>[];
    if (!field.isSelect && field.min != null && field.max != null) {
      parts.add('${_plain(field.min!)}–${_plain(field.max!)}');
    }
    if (field.help.isNotEmpty) parts.add(field.help);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Widget _numberField(FeatureField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _numbers[field.name],
        keyboardType: TextInputType.numberWithOptions(decimal: !field.wholeNumber),
        textInputAction: TextInputAction.next,
        validator: (value) => _validateNumber(field, value),
        decoration: InputDecoration(
          labelText: _label(field),
          helperText: _helper(field),
          helperMaxLines: 2,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _selectField(FeatureField field) {
    final items = <DropdownMenuItem<String>>[
      if (!field.required)
        const DropdownMenuItem<String>(value: '', child: Text('Not sure')),
      for (final option in field.options)
        DropdownMenuItem<String>(value: option.value, child: Text(option.label)),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormField<String>(
        initialValue: _choices[field.name],
        validator: (value) =>
            field.required && (value == null || value.isEmpty) ? 'Please choose one' : null,
        builder: (state) => InputDecorator(
          isEmpty: false,
          decoration: InputDecoration(
            labelText: _label(field),
            helperText: _helper(field),
            helperMaxLines: 2,
            errorText: state.errorText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.value,
              isDense: true,
              isExpanded: true,
              hint: Text(field.required ? 'Choose' : 'Not sure'),
              items: items,
              onChanged: (value) {
                state.didChange(value);
                _choices[field.name] = value;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    final mandatory = widget.model.features.where((field) => field.required).toList();
    final optional = widget.model.features.where((field) => !field.required).toList();

    Widget fieldFor(FeatureField field) =>
        field.isSelect ? _selectField(field) : _numberField(field);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in mandatory) fieldFor(field),
          if (optional.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Text(
                'Optional details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                'Fill in what you know from recent test reports. Anything left '
                'blank is estimated from typical values.',
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            for (final field in optional) fieldFor(field),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _running ? null : _run,
              icon: _running
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.analytics),
              label: Text(_running ? 'Checking…' : 'Check my risk'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(PredictionOutcome outcome) {
    final prediction = outcome.prediction;
    final color = riskColor(prediction.riskLevel);
    final probability = prediction.confidence;

    final String advice;
    switch (prediction.riskLevel) {
      case 'High':
        advice = 'Your answers look similar to people who had this condition. '
            'Please book a consultation with a doctor soon.';
        break;
      case 'Moderate':
        advice = 'Some of your answers are linked with this condition. '
            'A check-up with a doctor is a good idea.';
        break;
      default:
        advice = 'Your answers look similar to people who did not have this '
            'condition. Keep up regular check-ups.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 7,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  prediction.riskLevel == 'Low' ? Icons.verified : Icons.warning_amber,
                  color: color,
                  size: 56,
                ),
                const SizedBox(height: 8),
                Text(
                  '${prediction.riskLevel} risk',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prediction.result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (probability != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: probability / 100,
                      minHeight: 12,
                      color: color,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Estimated probability: $probability%'),
                ],
                const SizedBox(height: 16),
                Text(advice, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.amber[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber[900]),
                const SizedBox(width: 10),
                Expanded(child: Text(outcome.disclaimer)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (prediction.riskLevel != 'Low')
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorListScreen()),
              );
            },
            icon: const Icon(Icons.medical_services),
            label: const Text('Find a doctor'),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _checkAgain,
          child: const Text('Check again with different values'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final outcome = _outcome;
    final accuracy = model.accuracy;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_sharp, size: 30, color: Colors.white),
        ),
        title: Text(model.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (outcome == null) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.description),
                    if (accuracy != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Model accuracy on unseen test data: ${(accuracy * 100).round()}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _form(),
          ] else
            _result(outcome),
        ],
      ),
    );
  }
}
