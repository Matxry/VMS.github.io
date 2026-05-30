import 'package:flutter/material.dart';
import '../models/models.dart';

const _kPrimary = Color(0xFF0D1B2A);
const _kGreen   = Color(0xFF1E5631);

class PlanImplementacionSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;

  const PlanImplementacionSection(
      {super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filas de datos
            ...state.planImplementacion.asMap().entries.map(
              (e) => _FilaImplementacion(
                index: e.key,
                fila: e.value,
                onUpdate: onUpdate,
              ),
            ),
            const SizedBox(height: 12),
            // Botones agregar/eliminar
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => onUpdate(() {
                  final n = state.planImplementacion.length + 1;
                  state.planImplementacion
                      .add(FilaImplementacion(periodo: 'Mes $n'));
                }),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar mes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: const BorderSide(color: _kPrimary),
                ),
              ),
              if (state.planImplementacion.length > 1) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      onUpdate(() => state.planImplementacion.removeLast()),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Eliminar ultimo'),
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
}

// ── Cada fila como widget propio para evitar overflow ──
class _FilaImplementacion extends StatelessWidget {
  final int index;
  final FilaImplementacion fila;
  final void Function(VoidCallback) onUpdate;

  const _FilaImplementacion({
    required this.index,
    required this.fila,
    required this.onUpdate,
  });

  Color get _estadoColor {
    if (fila.estado == 'Concluido') return _kGreen;
    if (fila.estado == 'En progreso') return const Color(0xFF7D6608);
    return Colors.grey;
  }

  IconData get _estadoIcon {
    if (fila.estado == 'Concluido') return Icons.check_circle;
    if (fila.estado == 'En progreso') return Icons.pending;
    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera de la fila: período + estado ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(children: [
              // Número de mes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(fila.periodo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const Spacer(),
              // Dropdown de estado sin overflow
              Container(
                decoration: BoxDecoration(
                  color: _estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _estadoColor.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ['Pendiente', 'En progreso', 'Concluido']
                            .contains(fila.estado)
                        ? fila.estado
                        : 'Pendiente',
                    isDense: true,
                    icon: Icon(Icons.arrow_drop_down,
                        color: _estadoColor, size: 18),
                    items: [
                      _estadoItem('Pendiente', Icons.radio_button_unchecked,
                          Colors.grey),
                      _estadoItem('En progreso', Icons.pending,
                          const Color(0xFF7D6608)),
                      _estadoItem('Concluido', Icons.check_circle, _kGreen),
                    ],
                    onChanged: (v) =>
                        onUpdate(() => fila.estado = v ?? 'Pendiente'),
                    selectedItemBuilder: (ctx) => [
                      'Pendiente', 'En progreso', 'Concluido'
                    ].map((s) {
                      final c = s == 'Concluido'
                          ? _kGreen
                          : s == 'En progreso'
                              ? const Color(0xFF7D6608)
                              : Colors.grey;
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_estadoIcon, color: c, size: 14),
                        const SizedBox(width: 4),
                        Text(fila.estado,
                            style: TextStyle(
                                fontSize: 12,
                                color: c,
                                fontWeight: FontWeight.w600)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ]),
          ),
          // ── Cuerpo: acción + observaciones ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              TextFormField(
                initialValue: fila.accion,
                decoration: InputDecoration(
                  labelText: 'Accion realizada',
                  hintText: 'Describe la accion del mes...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                onChanged: (v) => onUpdate(() => fila.accion = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: fila.observaciones,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Notas adicionales...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                onChanged: (v) => onUpdate(() => fila.observaciones = v),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _estadoItem(
      String value, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(fontSize: 13, color: color)),
      ]),
    );
  }
}
