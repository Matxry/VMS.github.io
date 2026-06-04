import 'package:flutter/material.dart';
import '../models/models.dart';

const _kDark  = Color(0xFF0D1B2A);
const _kNavy  = Color(0xFF1A3A5C);
const _kGrey  = Color(0xFF5C6B7A);

Color _impColor(int nivel) {
  if (nivel <= 2) return const Color(0xFFC0392B);
  if (nivel <= 4) return const Color(0xFF7D6608);
  return const Color(0xFF1E8449);
}

class PlanMejoraSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const PlanMejoraSection({super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filas auto-generadas
        ...state.planMejora.asMap().entries.map((e) =>
          _FilaMejoraCard(index: e.key, fila: e.value, onUpdate: onUpdate,
              onDelete: e.value.autoGenerado ? null : () => onUpdate(() => state.planMejora.removeAt(e.key)))),

        const SizedBox(height: 10),
        // Boton agregar fila manual
        OutlinedButton.icon(
          onPressed: () => onUpdate(() => state.planMejora.add(FilaMejora(autoGenerado: false))),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Agregar accion manual'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: const BorderSide(color: _kNavy),
          ),
        ),
      ],
    );
  }
}

class _FilaMejoraCard extends StatelessWidget {
  final int index;
  final FilaMejora fila;
  final void Function(VoidCallback) onUpdate;
  final VoidCallback? onDelete;

  const _FilaMejoraCard({
    required this.index,
    required this.fila,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _impColor(fila.nivelImpacto);
    return Opacity(
      opacity: fila.incluido ? 1.0 : 0.45,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cabecera con area + impacto
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            // Numero
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text('${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 8),
            // Area
            Expanded(
              child: Text(fila.area.isEmpty ? 'Sin area' : fila.area,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
            // Badge impacto
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(fila.impactoLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            // Toggle incluir/excluir para problemas opcionales (cal >= 4)
            if (fila.autoGenerado && fila.nivelImpacto >= 5) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => onUpdate(() => fila.incluido = !fila.incluido),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: fila.incluido ? Colors.white24 : Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Text(
                    fila.incluido ? 'Incluido' : 'Opcional',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, color: Colors.white54, size: 18),
              ),
            ],
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Problema detectado con referencia de punto
            if (fila.problema.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Referencia del punto (ej: 4.1 Metodología definida)
                  if (fila.puntoRef.isNotEmpty) ...[
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(fila.puntoRef,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                  ],
                  Text('Problema detectado',
                      style: TextStyle(fontSize: 10, color: _kGrey,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(fila.problema,
                      style: const TextStyle(fontSize: 13, color: _kDark)),
                ]),
              ),
              const SizedBox(height: 10),
            ],

            // Campos editables
            _field('Acción recomendada', fila.accionRecomendada,
                (v) => onUpdate(() => fila.accionRecomendada = v), maxLines: 2),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(children: [
                  Expanded(child: _field('Responsable', fila.responsable,
                      (v) => onUpdate(() => fila.responsable = v))),
                  const SizedBox(width: 8),
                  Expanded(child: _field('Tiempo estimado', fila.tiempoEstimado,
                      (v) => onUpdate(() => fila.tiempoEstimado = v))),
                ]);
              }
              return Column(children: [
                _field('Responsable', fila.responsable,
                    (v) => onUpdate(() => fila.responsable = v)),
                const SizedBox(height: 8),
                _field('Tiempo estimado', fila.tiempoEstimado,
                    (v) => onUpdate(() => fila.tiempoEstimado = v)),
              ]);
            }),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(children: [
                  Expanded(child: _dropdown('Dificultad', fila.dificultad,
                      ['Baja', 'Media', 'Alta'],
                      (v) => onUpdate(() => fila.dificultad = v ?? ''))),
                  const SizedBox(width: 8),
                  Expanded(child: _field('Impacto esperado', fila.impactoEsperado,
                      (v) => onUpdate(() => fila.impactoEsperado = v))),
                ]);
              }
              return Column(children: [
                _dropdown('Dificultad', fila.dificultad, ['Baja', 'Media', 'Alta'],
                    (v) => onUpdate(() => fila.dificultad = v ?? '')),
                const SizedBox(height: 8),
                _field('Impacto esperado', fila.impactoEsperado,
                    (v) => onUpdate(() => fila.impactoEsperado = v)),
              ]);
            }),
          ]),
        ),
      ]),
    ));
  }

  Widget _field(String label, String value, void Function(String) onChange, {int maxLines = 1}) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kGrey),
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      onChanged: onChange,
    );
  }

  Widget _dropdown(String label, String value, List<String> opts, void Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: opts.contains(value) ? value : null,
      hint: Text(label, style: const TextStyle(fontSize: 12, color: _kGrey)),
      items: opts.map((o) => DropdownMenuItem(value: o,
          child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kGrey),
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
    );
  }
}
