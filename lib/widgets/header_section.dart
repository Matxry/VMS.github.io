import 'package:flutter/material.dart';
import '../models/models.dart';

class HeaderSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;

  const HeaderSection({super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.info_outline, color: Color(0xFF1A3A5C)),
              const SizedBox(width: 8),
              const Text('Información del Informe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A3A5C))),
            ]),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final fields = [
                _field('Organización', state.nombreClub, (v) => state.nombreClub = v),
                _field('Fecha', state.fecha, (v) => state.fecha = v),
                _field('Consultor', state.consultor, (v) => state.consultor = v),
              ];
              if (isWide) {
                return Row(
                  children: fields
                      .map((f) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: f)))
                      .toList(),
                );
              }
              return Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 8), child: f)).toList());
            }),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, void Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(v),
    );
  }
}
