import 'package:flutter/material.dart';
import '../models/models.dart';

class ProyeccionSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;

  const ProyeccionSection({super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width > 800
                      ? MediaQuery.of(context).size.width - 120
                      : 580,
                ),
                child: Column(
                  children: [
                    _header(),
                    ...state.proyeccion.asMap().entries.map((e) => _row(e.key, e.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => onUpdate(() => state.proyeccion.add(FilaProyeccion())),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar indicador'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A3A5C),
                  side: const BorderSide(color: Color(0xFF1A3A5C)),
                ),
              ),
              if (state.proyeccion.length > 1) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => onUpdate(() => state.proyeccion.removeLast()),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Eliminar último'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    const cols = ['Indicador', 'Estado Actual', 'Proyección', 'Mejora Esperada'];
    const widths = [200.0, 180.0, 180.0, 180.0];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A5C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: List.generate(cols.length, (i) => Container(
          width: widths[i],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(cols[i],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        )),
      ),
    );
  }

  Widget _row(int idx, FilaProyeccion fila) {
    final isEven = idx % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8F9FA),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cell(200, fila.indicador, 'Indicador...', (v) => fila.indicador = v),
          _cell(180, fila.estadoActual, 'Estado actual...', (v) => fila.estadoActual = v),
          _cell(180, fila.proyeccion, 'Proyección...', (v) => fila.proyeccion = v),
          _cell(180, fila.mejoraEsperada, 'Mejora esperada...', (v) => fila.mejoraEsperada = v),
        ],
      ),
    );
  }

  Widget _cell(double width, String value, String hint, void Function(String) onChanged) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
