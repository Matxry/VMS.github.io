import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/plan_implementacion_section.dart';
import '../utils/pdf_avances.dart';

const kPrimary = Color(0xFF0D1B2A);
const kGreen   = Color(0xFF1A3A5C);

class AvancesScreen extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const AvancesScreen({super.key, required this.state, required this.onUpdate});

  @override
  State<AvancesScreen> createState() => _AvancesScreenState();
}

class _AvancesScreenState extends State<AvancesScreen> {
  void _upd(VoidCallback fn) { widget.onUpdate(fn); setState(() {}); }

  Future<void> _pdf() async {
    try {
      showDialog(context: context, barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: Row(children: [
              CircularProgressIndicator(), SizedBox(width: 16),
              Text('Generando PDF...'),
            ]),
          ));
      await generarPDFAvances(widget.state);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final concluidos = widget.state.planImplementacion.where((f) => f.estado == 'Concluido').length;
    final enProgreso = widget.state.planImplementacion.where((f) => f.estado == 'En progreso').length;
    final total      = widget.state.planImplementacion.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Avances de Implementación',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _pdf,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: const Color(0xFF0D1B2A)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 12, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Estadísticas
          Row(children: [
            _stat('Concluidos', '$concluidos', kGreen, Icons.check_circle),
            const SizedBox(width: 10),
            _stat('En Progreso', '$enProgreso', const Color(0xFF7D6608), Icons.pending),
            const SizedBox(width: 10),
            _stat('Total', '$total', kPrimary, Icons.calendar_month),
          ]),
          const SizedBox(height: 10),
          if (total > 0)
            _barraProgreso(concluidos, total),
          const SizedBox(height: 16),
          _titulo('Plan de Implementación', Icons.calendar_month, kGreen),
          const SizedBox(height: 12),
          PlanImplementacionSection(state: widget.state, onUpdate: _upd),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF de Avances',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, Color color, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF5C6B7A)), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _barraProgreso(int concluidos, int total) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Progreso general', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const Spacer(),
        Text('${((concluidos / total) * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5631))),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: concluidos / total,
          minHeight: 10,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A3A5C)),
        ),
      ),
    ]),
  );

  Widget _titulo(String t, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 20), const SizedBox(width: 8),
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );
}
