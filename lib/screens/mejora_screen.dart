import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/plan_mejora_section.dart';
import '../utils/pdf_mejora.dart';

// Paleta marca
const kDark   = Color(0xFF0D1B2A);
const kNavy   = Color(0xFF1A3A5C);
const kGrey   = Color(0xFF5C6B7A);
const kBg     = Color(0xFFF2F4F6);

class MejoraScreen extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const MejoraScreen({super.key, required this.state, required this.onUpdate});

  @override
  State<MejoraScreen> createState() => _MejoraScreenState();
}

class _MejoraScreenState extends State<MejoraScreen> {
  @override
  void initState() {
    super.initState();
    // Sincronizar problemas del diagnostico al cargar la pantalla
    widget.state.sincronizarProblemas();
  }

  void _upd(VoidCallback fn) { widget.onUpdate(fn); setState(() {}); }

  Future<void> _generarPDF() async {
    try {
      showDialog(context: context, barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generando PDF...'),
            ]),
          ));
      await generarPDFMejora(widget.state);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final urgentes = widget.state.planMejora.where((f) => f.nivelImpacto <= 2).length;
    final medios   = widget.state.planMejora.where((f) => f.nivelImpacto == 3).length;
    final bajos    = widget.state.planMejora.where((f) => f.nivelImpacto >= 5).length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kDark,
        title: const Text('Plan de Mejora',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          // Boton sincronizar
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sincronizar problemas del diagnostico',
            onPressed: () {
              _upd(() => widget.state.sincronizarProblemas());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Problemas sincronizados desde el diagnostico'),
                  backgroundColor: Color(0xFF1E5631),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _generarPDF,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kDark,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 12, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Banner informativo
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kNavy.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: kNavy, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Los problemas se sincronizan automaticamente desde el diagnostico. '
                  'El impacto se calcula segun la calificacion: 1-2 = URGENTE, 3 = MEDIO, 4-5 = BAJO.',
                  style: TextStyle(fontSize: 12, color: kGrey),
                ),
              ),
            ]),
          ),

          // Resumen de impactos
          if (widget.state.planMejora.isNotEmpty) ...[
            Row(children: [
              _impactCard('URGENTE', urgentes, const Color(0xFFC0392B)),
              const SizedBox(width: 8),
              _impactCard('MEDIO', medios, const Color(0xFF7D6608)),
              const SizedBox(width: 8),
              _impactCard('BAJO', bajos, const Color(0xFF1E8449)),
            ]),
            const SizedBox(height: 16),
          ],

          _titulo('Plan de Mejora', Icons.trending_up),
          const SizedBox(height: 12),
          PlanMejoraSection(state: widget.state, onUpdate: _upd),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _generarPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDark,
                foregroundColor: Colors.white,
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

  Widget _impactCard(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _titulo(String t, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: kDark,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );
}
