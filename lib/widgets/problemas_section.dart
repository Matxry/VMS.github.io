import 'package:flutter/material.dart';
import '../models/models.dart';

Color _impactoColor(int impacto) {
  if (impacto <= 2) return const Color(0xFFD32F2F);
  if (impacto <= 4) return const Color(0xFFF57C00);
  return const Color(0xFF388E3C);
}

class ProblemasSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;

  const ProblemasSection({super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escala de Impacto:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _badge('1-2', 'URGENTE', const Color(0xFFD32F2F)),
                      _badge('3-4', 'MEDIO', const Color(0xFFF57C00)),
                      _badge('5', 'BAJO', const Color(0xFF388E3C)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...state.problemas.asMap().entries.map((entry) {
              final idx = entry.key;
              final prob = entry.value;
              return _ProblemaCard(
                problema: prob,
                index: idx,
                onUpdate: onUpdate,
                onDelete: () => onUpdate(() => state.problemas.removeAt(idx)),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => onUpdate(
                () => state.problemas.add(ProblemaDetectado(descripcion: '')),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Problema'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A3A5C),
                side: const BorderSide(color: Color(0xFF1A3A5C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String range, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(range,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    ]);
  }
}

class _ProblemaCard extends StatelessWidget {
  final ProblemaDetectado problema;
  final int index;
  final void Function(VoidCallback) onUpdate;
  final VoidCallback onDelete;

  const _ProblemaCard({
    required this.problema,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final impColor = _impactoColor(problema.impacto);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: impColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
        color: impColor.withOpacity(0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A5C),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: impColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(problema.impactoLabel,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: problema.descripcion,
            decoration: const InputDecoration(
              labelText: 'Descripción del problema',
              hintText: 'Describe el problema detectado...',
            ),
            maxLines: 2,
            onChanged: (v) => onUpdate(() => problema.descripcion = v),
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Impacto:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: List.generate(5, (i) {
                  final val = i + 1;
                  final selected = problema.impacto == val;
                  final btnColor = _impactoColor(val);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onUpdate(() => problema.impacto = val),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected ? btnColor : btnColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: selected ? btnColor : btnColor.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text('$val',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : btnColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: problema.consecuencias,
            decoration: const InputDecoration(
              labelText: 'Consecuencias del problema',
              hintText: 'Describe las consecuencias si no se resuelve...',
            ),
            maxLines: 3,
            onChanged: (v) => onUpdate(() => problema.consecuencias = v),
          ),
        ],
      ),
    );
  }
}
