import 'package:flutter/material.dart';
import '../models/models.dart';

const _kDark  = Color(0xFF0D1B2A);
const _kNavy  = Color(0xFF1A3A5C);
const _kGrey  = Color(0xFF5C6B7A);
const _kBg    = Color(0xFFF2F4F6);

Color _impColor(int nivel) {
  if (nivel <= 2) return const Color(0xFFC0392B);
  if (nivel <= 4) return const Color(0xFF7D6608);
  return const Color(0xFF1E8449);
}

Color _calColor(int cal) {
  if (cal <= 0) return Colors.grey;
  if (cal <= 2) return const Color(0xFFC0392B);
  if (cal == 3) return const Color(0xFF7D6608);
  if (cal == 4) return const Color(0xFF1A5276);
  return const Color(0xFF1E8449);
}

String _calLabel(int cal) {
  switch (cal) {
    case 1: return 'Muy deficiente';
    case 2: return 'Deficiente';
    case 3: return 'Regular';
    case 4: return 'Bueno';
    case 5: return 'Excelente';
    default: return '-';
  }
}

class PlanMejoraSection extends StatelessWidget {
  final AppState state;
  final void Function(VoidCallback) onUpdate;
  const PlanMejoraSection({super.key, required this.state, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...state.planMejora.asMap().entries.map((e) =>
          _FilaMejoraCard(
            index: e.key,
            fila: e.value,
            onUpdate: onUpdate,
            onDelete: e.value.autoGenerado
                ? null
                : () => onUpdate(() => state.planMejora.removeAt(e.key)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => onUpdate(
              () => state.planMejora.add(FilaMejora(autoGenerado: false))),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Agregar acción manual'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: const BorderSide(color: _kNavy),
          ),
        ),
      ],
    );
  }
}

class _FilaMejoraCard extends StatefulWidget {
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
  State<_FilaMejoraCard> createState() => _FilaMejoraCardState();
}

class _FilaMejoraCardState extends State<_FilaMejoraCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fila  = widget.fila;
    final color = _impColor(fila.nivelImpacto);
    final calC  = _calColor(fila.calificacion);

    return Opacity(
      opacity: fila.incluido ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Cabecera ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(children: [
              // Número
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('${widget.index + 1}',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 8),
              // Punto ref
              if (fila.puntoRef.isNotEmpty)
                Expanded(
                  child: Text(fila.puntoRef,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                )
              else
                Expanded(
                  child: Text(fila.area.isEmpty ? 'Sin área' : fila.area,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
              const SizedBox(width: 8),
              // Badge calificación
              if (fila.calificacion > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: calC, borderRadius: BorderRadius.circular(8)),
                  child: Text('${fila.calificacion} — ${_calLabel(fila.calificacion)}',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 6),
              // Badge impacto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(10)),
                child: Text(fila.impactoLabel,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              // Toggle opcional
              if (fila.autoGenerado && fila.calificacion >= 4)
                GestureDetector(
                  onTap: () => widget.onUpdate(() => fila.incluido = !fila.incluido),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: fila.incluido ? Colors.white24 : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Text(fila.incluido ? 'Incluido' : 'Opcional',
                        style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ),
              // Expandir
              IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70, size: 18,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                visualDensity: VisualDensity.compact,
              ),
              if (widget.onDelete != null)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: const Icon(Icons.close, color: Colors.white54, size: 18),
                ),
            ]),
          ),

          // ── Cuerpo: acción siempre visible ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Problema: editable + toggle imprimir ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Problema detectado',
                        style: TextStyle(fontSize: 10, color: _kGrey,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    // Toggle imprimir problema en PDF
                    GestureDetector(
                      onTap: () => widget.onUpdate(
                          () => fila.imprimirProblema = !fila.imprimirProblema),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          fila.imprimirProblema
                              ? Icons.print
                              : Icons.print_disabled,
                          size: 14,
                          color: fila.imprimirProblema ? _kNavy : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          fila.imprimirProblema ? 'Imprimir' : 'No imprimir',
                          style: TextStyle(
                            fontSize: 10,
                            color: fila.imprimirProblema ? _kNavy : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Campo editable del problema
                  TextFormField(
                    initialValue: fila.problema,
                    decoration: InputDecoration(
                      hintText: 'Describe el problema...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: color.withOpacity(0.3))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: color.withOpacity(0.3))),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      isDense: true,
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, color: _kDark),
                    onChanged: (v) => widget.onUpdate(() => fila.problema = v),
                  ),
                ]),
              ),
              const SizedBox(height: 8),

              // ── Acción recomendada SIEMPRE visible ──
              TextFormField(
                initialValue: fila.accionRecomendada,
                decoration: InputDecoration(
                  labelText: 'Acción recomendada',
                  hintText: 'Escribe la acción a tomar...',
                  labelStyle: const TextStyle(fontSize: 12, color: _kGrey),
                  filled: true,
                  fillColor: _kBg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                onChanged: (v) => widget.onUpdate(() => fila.accionRecomendada = v),
              ),
            ]),
          ),

          // ── Detalles expandibles ──
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(children: [
                const SizedBox(height: 6),
                LayoutBuilder(builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  if (isWide) {
                    return Row(children: [
                      Expanded(child: _field('Responsable', fila.responsable,
                          (v) => widget.onUpdate(() => fila.responsable = v))),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Tiempo estimado', fila.tiempoEstimado,
                          (v) => widget.onUpdate(() => fila.tiempoEstimado = v))),
                    ]);
                  }
                  return Column(children: [
                    _field('Responsable', fila.responsable,
                        (v) => widget.onUpdate(() => fila.responsable = v)),
                    const SizedBox(height: 8),
                    _field('Tiempo estimado', fila.tiempoEstimado,
                        (v) => widget.onUpdate(() => fila.tiempoEstimado = v)),
                  ]);
                }),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  if (isWide) {
                    return Row(children: [
                      Expanded(child: _dropdown('Dificultad', fila.dificultad,
                          ['Baja', 'Media', 'Alta'],
                          (v) => widget.onUpdate(() => fila.dificultad = v ?? ''))),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Impacto esperado', fila.impactoEsperado,
                          (v) => widget.onUpdate(() => fila.impactoEsperado = v))),
                    ]);
                  }
                  return Column(children: [
                    _dropdown('Dificultad', fila.dificultad,
                        ['Baja', 'Media', 'Alta'],
                        (v) => widget.onUpdate(() => fila.dificultad = v ?? '')),
                    const SizedBox(height: 8),
                    _field('Impacto esperado', fila.impactoEsperado,
                        (v) => widget.onUpdate(() => fila.impactoEsperado = v)),
                  ]);
                }),
              ]),
            ),

          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _field(String label, String value, void Function(String) onChange,
      {int maxLines = 1}) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kGrey),
        filled: true,
        fillColor: _kBg,
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

  Widget _dropdown(String label, String value, List<String> opts,
      void Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: opts.contains(value) ? value : null,
      hint: Text(label, style: const TextStyle(fontSize: 12, color: _kGrey)),
      items: opts.map((o) => DropdownMenuItem(
          value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kGrey),
        filled: true,
        fillColor: _kBg,
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
