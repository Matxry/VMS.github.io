import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';

// ── Paleta azul oscuro / gris / negro ──
const kPrimary  = Color(0xFF0D1B2A);   // azul muy oscuro
const kAccent   = Color(0xFF1E3A5F);   // azul medio
const kBorder   = Color(0xFF2E4A6A);   // azul borde
const kGrey     = Color(0xFF5C6B7A);   // gris medio
const kLightBg  = Color(0xFFF4F6F8);   // fondo claro

Color _calColor(int cal) {
  if (cal == 0) return Colors.grey.shade300;
  if (cal <= 2) return const Color(0xFFC0392B);
  if (cal <= 3) return const Color(0xFF7D6608);
  if (cal == 4) return const Color(0xFF1A5276);
  return const Color(0xFF1E8449);
}

String _calLabel(int cal) {
  if (cal == 0) return '–';
  if (cal == 1) return '1 – Muy deficiente';
  if (cal == 2) return '2 – Deficiente';
  if (cal == 3) return '3 – Regular';
  if (cal == 4) return '4 – Bueno';
  return '5 – Excelente';
}

class AreaCard extends StatefulWidget {
  final AreaModel area;
  final void Function(VoidCallback) onUpdate;
  const AreaCard({super.key, required this.area, required this.onUpdate});

  @override
  State<AreaCard> createState() => _AreaCardState();
}

class _AreaCardState extends State<AreaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final prom = area.promedio;
    final promColor = prom == 0 ? kGrey : _calColor(prom.round());

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kBorder.withOpacity(0.3)),
      ),
      child: Column(children: [
        // ── Header ──
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Text(area.nombre,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              if (prom > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(prom.toStringAsFixed(1),
                      style: TextStyle(
                          color: promColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                const SizedBox(width: 8),
              ],
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70),
            ]),
          ),
        ),
        // ── Subtemas ──
        if (_expanded)
          Container(
            color: kLightBg,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: area.subtemas
                  .map((sub) => _SubtemaRow(subtema: sub, onUpdate: widget.onUpdate))
                  .toList(),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────
class _SubtemaRow extends StatefulWidget {
  final SubtemaModel subtema;
  final void Function(VoidCallback) onUpdate;
  const _SubtemaRow({required this.subtema, required this.onUpdate});

  @override
  State<_SubtemaRow> createState() => _SubtemaRowState();
}

class _SubtemaRowState extends State<_SubtemaRow> {
  bool _showObs = false;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    widget.onUpdate(() => widget.subtema.imagenes.add(bytes));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subtema;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Fila principal
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sub.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                Text(sub.subarea,
                    style: const TextStyle(fontSize: 11, color: kGrey)),
              ]),
            ),
            // Calificación 1-5
            Row(
              children: List.generate(5, (i) {
                final val = i + 1;
                final sel = sub.calificacion == val;
                final c   = _calColor(val);
                return GestureDetector(
                  onTap: () => widget.onUpdate(() => sub.calificacion = val),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 28, height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: sel ? c : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sel ? c : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text('$val',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold,
                              color: sel ? Colors.white : kGrey)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 4),
            // Toggle observaciones
            IconButton(
              icon: Icon(
                _showObs ? Icons.edit_note : Icons.edit_note_outlined,
                color: kAccent, size: 20,
              ),
              onPressed: () => setState(() => _showObs = !_showObs),
              visualDensity: VisualDensity.compact,
              tooltip: 'Observaciones',
            ),
          ]),
        ),

        // Badge calificación
        if (sub.calificacion > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _calColor(sub.calificacion).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(_calLabel(sub.calificacion),
                  style: TextStyle(
                      fontSize: 11,
                      color: _calColor(sub.calificacion),
                      fontWeight: FontWeight.w500)),
            ),
          ),

        // ── Panel de observaciones ──
        if (_showObs)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kLightBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Campo único de observaciones
              TextFormField(
                initialValue: sub.observacion,
                decoration: InputDecoration(
                  labelText: 'Observaciones / Evidencia',
                  hintText: 'Describe lo observado, evidencias, notas...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                maxLines: 3,
                onChanged: (v) => widget.onUpdate(() => sub.observacion = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: sub.problemaDetectado,
                decoration: InputDecoration(
                  labelText: 'Problema detectado',
                  hintText: 'Describe el problema encontrado...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                maxLines: 2,
                onChanged: (v) => widget.onUpdate(() => sub.problemaDetectado = v),
              ),
              const SizedBox(height: 10),

              // ── Imágenes adjuntas ──
              Row(children: [
                const Text('Imágenes adjuntas:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate, size: 16),
                  label: const Text('Agregar imagen', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: kAccent),
                ),
              ]),
              if (sub.imagenes.isNotEmpty) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sub.imagenes.length,
                    itemBuilder: (ctx, i) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: MemoryImage(sub.imagenes[i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2, right: 10,
                          child: GestureDetector(
                            onTap: () => widget.onUpdate(() => sub.imagenes.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ]),
          ),
      ]),
    );
  }
}
