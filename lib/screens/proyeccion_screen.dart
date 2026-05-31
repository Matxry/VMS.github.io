import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/proyeccion_section.dart';
import '../utils/pdf_proyeccion.dart';

const kPrimary = Color(0xFF0D1B2A);
const kAccent  = Color(0xFF2C3E50);

class ProyeccionScreen extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const ProyeccionScreen({super.key, required this.state, required this.onUpdate});

  @override
  State<ProyeccionScreen> createState() => _ProyeccionScreenState();
}

class _ProyeccionScreenState extends State<ProyeccionScreen> {
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
      await generarPDFProyeccion(widget.state);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: kAccent,
        title: const Text('Proyección de Resultados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _pdf,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: kAccent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 12, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titulo('Proyección de Resultados', Icons.show_chart, kAccent),
          const SizedBox(height: 12),
          ProyeccionSection(state: widget.state, onUpdate: _upd),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF de Proyección',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent, foregroundColor: Colors.white,
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

  Widget _titulo(String t, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 20), const SizedBox(width: 8),
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );
}
