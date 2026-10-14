// The disease-risk forms and results.
//
// The forms are not hard-coded: the backend relays them from the prediction
// service (GET /api/patient/prediction-models), so the app always asks for
// exactly the inputs the trained model expects.

class FeatureOption {
  const FeatureOption({required this.value, required this.label});

  final String value;
  final String label;

  factory FeatureOption.fromJson(Map<String, dynamic> json) {
    return FeatureOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

/// One input on a disease form: a number with a range, or a choice.
class FeatureField {
  const FeatureField({
    required this.name,
    required this.label,
    required this.kind,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.required,
    required this.help,
    required this.options,
  });

  final String name;
  final String label;
  final String kind;
  final String unit;
  final double? min;
  final double? max;
  final double step;
  final bool required;
  final String help;
  final List<FeatureOption> options;

  bool get isSelect => kind == 'select';

  /// Whole-number fields (age, counts) get a keyboard without a decimal point.
  bool get wholeNumber => step >= 1;

  factory FeatureField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return FeatureField(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'number',
      unit: json['unit']?.toString() ?? '',
      min: json['min'] is num ? (json['min'] as num).toDouble() : null,
      max: json['max'] is num ? (json['max'] as num).toDouble() : null,
      step: json['step'] is num ? (json['step'] as num).toDouble() : 1,
      required: json['required'] != false,
      help: json['help']?.toString() ?? '',
      options: rawOptions is List
          ? rawOptions
              .whereType<Map>()
              .map((option) =>
                  FeatureOption.fromJson(Map<String, dynamic>.from(option)))
              .toList()
          : const <FeatureOption>[],
    );
  }
}

/// A disease the patient can check, with its form and how well its model
/// performed on held-out test data.
class DiseaseModel {
  const DiseaseModel({
    required this.key,
    required this.name,
    required this.description,
    required this.dataset,
    required this.accuracy,
    required this.features,
  });

  final String key;
  final String name;
  final String description;
  final String dataset;
  final double? accuracy;
  final List<FeatureField> features;

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] is Map
        ? Map<String, dynamic>.from(json['metrics'] as Map)
        : <String, dynamic>{};
    final rawFeatures = json['features'];
    return DiseaseModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dataset: json['dataset']?.toString() ?? '',
      accuracy: metrics['accuracy'] is num
          ? (metrics['accuracy'] as num).toDouble()
          : null,
      features: rawFeatures is List
          ? rawFeatures
              .whereType<Map>()
              .map((feature) =>
                  FeatureField.fromJson(Map<String, dynamic>.from(feature)))
              .toList()
          : const <FeatureField>[],
    );
  }
}

/// A stored prediction from the patient's history.
class Prediction {
  const Prediction({
    required this.id,
    required this.disease,
    required this.result,
    required this.riskLevel,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final String disease;
  final String result;
  final String riskLevel;

  /// The model's probability for the disease, as a whole percentage.
  final int? confidence;
  final DateTime? createdAt;

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['_id']?.toString() ?? '',
      disease: json['disease']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? '',
      confidence:
          json['confidence'] is num ? (json['confidence'] as num).round() : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
    );
  }
}

/// What POST /api/patient/predictions returns: the stored prediction and the
/// "not a diagnosis" note to show with it.
class PredictionOutcome {
  const PredictionOutcome({required this.prediction, required this.disclaimer});

  final Prediction prediction;
  final String disclaimer;
}
