import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/area_card.dart';
import '../widgets/header_section.dart';
import '../utils/pdf_diagnostico.dart';

const kPrimary = Color(0xFF0D1B2A);
const kAccent  = Color(0xFF1E3A5F);

class DiagnosticoScreen extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const DiagnosticoScreen({super.key, required this.state, required this.onUpdate});

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  void _upd(VoidCallback fn) { widget.onUpdate(fn); setState(() {}); }

  Future<void> _generarPDF() async {
    try {
      showDialog(context: context, barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generando PDF de Diagnóstico...'),
            ]),
          ));
      await generarPDFDiagnostico(widget.state);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text('Diagnóstico Deportivo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _generarPDF,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 12, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HeaderSection(state: widget.state, onUpdate: _upd),
          const SizedBox(height: 20),
          _sectionTitle('Diagnóstico Detallado por Área', Icons.assessment),
          const SizedBox(height: 12),
          isWide ? _grid() : _column(),
          const SizedBox(height: 28),
          // ── Gráfica resumen ──
          _sectionTitle('Resumen por Sección', Icons.bar_chart),
          const SizedBox(height: 12),
          _GraficaResumen(areas: widget.state.areas),
          const SizedBox(height: 28),
          Center(
            child: ElevatedButton.icon(
              onPressed: _generarPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF de Diagnóstico',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
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

  Widget _sectionTitle(String t, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [kPrimary, kAccent]),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _column() => Column(
    children: widget.state.areas.map((a) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AreaCard(area: a, onUpdate: _upd),
    )).toList(),
  );

  Widget _grid() {
    final areas = widget.state.areas;
    final rows = <Widget>[];
    for (int i = 0; i < areas.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: AreaCard(area: areas[i], onUpdate: _upd),
          )),
          if (i + 1 < areas.length)
            Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: AreaCard(area: areas[i + 1], onUpdate: _upd),
            ))
          else const Expanded(child: SizedBox()),
        ],
      ));
    }
    return Column(children: rows);
  }
}

// ── Gráfica de barras horizontales ──
class _GraficaResumen extends StatelessWidget {
  final List<AreaModel> areas;
  const _GraficaResumen({required this.areas});

  Color _colorBarra(double v) {
    if (v <= 0) return Colors.grey.shade300;
    if (v <= 2) return const Color(0xFFC0392B);
    if (v <= 3) return const Color(0xFF7D6608);
    if (v <= 4) return const Color(0xFF1A5276);
    return const Color(0xFF1E8449);
  }

  @override
  Widget build(BuildContext context) {
    final areasConDatos = areas.where((a) => a.promedio > 0).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: areasConDatos.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Sin calificaciones aún',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            : Column(
                children: areasConDatos.map((area) {
                  final prom     = area.promedio;
                  final color    = _colorBarra(prom);
                  final nProb    = area.totalProblemas;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre + badge problemas
                        Row(children: [
                          Expanded(
                            child: Text(area.nombre,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: kPrimary),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (nProb > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC0392B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.4)),
                              ),
                              child: Text('$nProb problema${nProb > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFFC0392B),
                                      fontWeight: FontWeight.w600)),
                            ),
                          const SizedBox(width: 8),
                          Text(prom.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold,
                                  color: color)),
                          Text('/5',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ]),
                        const SizedBox(height: 5),
                        // Barra
                        Stack(children: [
                          Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: prom / 5,
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                          // Marcas de 1-5
                          ...List.generate(4, (i) {
                            final x = (i + 1) / 5;
                            return FractionallySizedBox(
                              widthFactor: x,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(width: 1, height: 18, color: Colors.white.withOpacity(0.6)),
                              ),
                            );
                          }),
                        ]),
                        const SizedBox(height: 3),
                        // Leyenda 1-5
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['1', '2', '3', '4', '5'].map((n) =>
                            Text(n, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                          ).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
