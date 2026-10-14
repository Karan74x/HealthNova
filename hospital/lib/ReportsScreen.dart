import 'package:flutter/material.dart';
import 'package:hospital/PredictionScreen.dart';
import 'package:hospital/models/prediction.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

/// Disease-risk checks: the six conditions the trained models cover, and the
/// patient's earlier results.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsData {
  const _ReportsData(this.models, this.history);

  final List<DiseaseModel> models;
  final List<Prediction> history;
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<_ReportsData> _data;

  @override
  void initState() {
    super.initState();
    _data = _fetch();
  }

  Future<_ReportsData> _fetch() async {
    // Both requests run at once; Future.wait rethrows the first failure
    final models = HealthNovaApi.predictionModels();
    final history = HealthNovaApi.myPredictions();
    await Future.wait<Object>([models, history]);
    return _ReportsData(await models, await history);
  }

  Future<void> _load() async {
    final next = _fetch();
    setState(() => _data = next);
    try {
      await next;
    } catch (_) {
      // Shown by the FutureBuilder
    }
  }

  Future<void> _open(DiseaseModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PredictionScreen(model: model)),
    );
    // A new result may have been added
    if (mounted) _load();
  }

  IconData _icon(String key) {
    switch (key) {
      case 'diabetes':
        return Icons.bloodtype;
      case 'heart':
        return Icons.favorite;
      case 'liver':
        return Icons.science;
      case 'kidney':
        return Icons.water_drop;
      case 'stroke':
        return Icons.psychology;
      case 'hypertension':
        return Icons.speed;
      default:
        return Icons.monitor_heart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Health Reports'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FutureBuilder<_ReportsData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  ErrorView(message: errorText(snapshot.error!), onRetry: _load),
                ],
              );
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    'Check your risk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Answer a few questions about your health and a machine-learning '
                    'model estimates your risk. It is a screening aid, not a diagnosis.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                for (final model in data.models)
                  Card(
                    elevation: 7,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Icon(_icon(model.key), color: Colors.blue),
                      ),
                      title: Text(
                        model.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(model.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(model),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: Text(
                    'Your results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (data.history.isEmpty)
                  const Card(
                    child: EmptyView(
                      icon: Icons.assignment_outlined,
                      message: 'No results yet. Choose a check above to get started.',
                    ),
                  )
                else
                  for (final prediction in data.history)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          prediction.disease,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(formatDateTime(prediction.createdAt)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusChip(
                              label: '${prediction.riskLevel} risk',
                              color: riskColor(prediction.riskLevel),
                            ),
                            if (prediction.confidence != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${prediction.confidence}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
