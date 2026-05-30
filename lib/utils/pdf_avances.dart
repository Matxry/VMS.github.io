import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

// Re-exportamos para que proyeccion_screen lo pueda importar desde aquí
export 'pdf_proyeccion.dart';

Future<void> generarPDFAvances(AppState state) async {
  final pdf  = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // ── PORTADA ──
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'AVANCES DE IMPLEMENTACIÓN',
      'VMS Sports — Consultoría Deportiva',
      pGreen, state.nombreClub, state.fecha, state.consultor, logo,
    ),
  ));

  // ── ESTADÍSTICAS ──
  final concluidos = state.planImplementacion.where((f) => f.estado == 'Concluido').length;
  final enProgreso = state.planImplementacion.where((f) => f.estado == 'En progreso').length;
  final pendientes = state.planImplementacion.where((f) => f.estado == 'Pendiente').length;
  final total      = state.planImplementacion.length;

  // ── PLAN DE IMPLEMENTACIÓN ──
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(24),
    build: (ctx) => pw.Stack(children: [
      pw.Positioned(
              top: 0, left: 0, right: 0, bottom: 0,
              child: pw.Opacity(
                opacity: watermark != null ? 0.06 : 0.05,
                child: watermark != null
                    ? pw.Image(watermark, fit: pw.BoxFit.cover)
                    : logo != null
                        ? pw.Center(
                            child: pw.Transform.rotate(
                              angle: -0.5,
                              child: pw.Image(logo, width: 280, height: 280),
                            ),
                          )
                        : pw.SizedBox(),
              ),
            ),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        sectionHeader('Plan de Implementación', pGreen),
        pw.SizedBox(height: 12),

        // Tarjetas de estadísticas
        pw.Row(children: [
          _statBox('Concluidos', '$concluidos', pGreen),
          pw.SizedBox(width: 8),
          _statBox('En Progreso', '$enProgreso', pMed),
          pw.SizedBox(width: 8),
          _statBox('Pendientes', '$pendientes', PdfColors.grey600),
          pw.SizedBox(width: 8),
          _statBox('Total', '$total', pPrimary),
        ]),
        pw.SizedBox(height: 10),

        // Barra de progreso
        if (total > 0) ...[
          pw.Row(children: [
            pw.Text('Progreso general:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: pPrimary)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _barraProgreso(concluidos / total)),
            pw.SizedBox(width: 8),
            pw.Text('${((concluidos / total) * 100).toStringAsFixed(0)}%',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: pGreen)),
          ]),
          pw.SizedBox(height: 12),
        ],

        // Tabla con observaciones
        pw.Table(
          border: pw.TableBorder.all(color: const PdfColor.fromInt(0x44000000), width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(0.9),
            1: pw.FlexColumnWidth(2.2),
            2: pw.FlexColumnWidth(1.1),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: pGreen),
              children: ['Período', 'Acción', 'Estado', 'Observaciones']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(h, style: headerStyle()),
                  )).toList(),
            ),
            ...state.planImplementacion.asMap().entries.map((e) {
              final f  = e.value;
              const bg = PdfColor.fromInt(0x00000000);
              PdfColor estColor;
              if (f.estado == 'Concluido') {
                estColor = pGreen;
              } else if (f.estado == 'En progreso') estColor = pMed;
              else                                estColor = PdfColors.grey500;

              return pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0x00000000)),
                children: [
                  // Período
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(f.periodo,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: pGreen)),
                  ),
                  // Acción
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(f.accion.isEmpty ? '—' : f.accion, style: cellStyle()),
                  ),
                  // Estado con chip de color
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: estColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(f.estado,
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 7,
                              fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center),
                    ),
                  ),
                  // Observaciones con fondo suave
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: f.observaciones.isEmpty
                        ? pw.Text('—', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500))
                        : pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: const PdfColor.fromInt(0xFFECF0F1),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                            ),
                            child: pw.Text(f.observaciones,
                                style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF2C3E50))),
                          ),
                  ),
                ],
              );
            }),
          ],
        ),
        pw.Spacer(),
        piePagina(state.nombreClub, state.fecha),
      ]),
    ]),
  ));

  await Printing.layoutPdf(
    onLayout: (_) async => pdf.save(),
    name: 'Avances_VMS_Sports.pdf',
  );
}

pw.Widget _barraProgreso(double factor) {
  final pct   = (factor * 100).clamp(0, 100).toInt();
  final empty = 100 - pct;
  return pw.Table(
    columnWidths: {
      0: pw.FlexColumnWidth(pct > 0 ? pct.toDouble() : 1),
      1: pw.FlexColumnWidth(empty > 0 ? empty.toDouble() : 1),
    },
    children: [
      pw.TableRow(children: [
        pw.Container(
          height: 10,
          decoration: pw.BoxDecoration(
            color: pct > 0 ? pGreen : PdfColors.grey200,
            borderRadius: pct >= 100
                ? const pw.BorderRadius.all(pw.Radius.circular(5))
                : const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(5), bottomLeft: pw.Radius.circular(5)),
          ),
        ),
        pw.Container(
          height: 10,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pct <= 0
                ? const pw.BorderRadius.all(pw.Radius.circular(5))
                : const pw.BorderRadius.only(
                    topRight: pw.Radius.circular(5), bottomRight: pw.Radius.circular(5)),
          ),
        ),
      ]),
    ],
  );
}

pw.Widget _statBox(String label, String value, PdfColor color) => pw.Expanded(
  child: pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Column(children: [
      pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 7)),
    ]),
  ),
);
