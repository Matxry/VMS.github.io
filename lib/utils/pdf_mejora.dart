import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

Future<void> generarPDFMejora(AppState state) async {
  final pdf       = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // ── PORTADA ──
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'PLAN DE MEJORA',
      'VMS Sports | Consultoria Deportiva',
      pPrimary, state.nombreClub, state.fecha, state.consultor, logo,
    ),
  ));

  // ── TABLA DE MEJORA CON PROBLEMAS AUTO-GENERADOS ──
  if (state.planMejora.isNotEmpty) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Stack(children: [
        pw.Positioned(top: 0, left: 0, right: 0, bottom: 0,
          child: pw.Opacity(
            opacity: watermark != null ? 0.06 : 0.05,
            child: watermark != null
                ? pw.Image(watermark, fit: pw.BoxFit.cover)
                : logo != null
                    ? pw.Center(child: pw.Transform.rotate(angle: -0.5,
                        child: pw.Image(logo, width: 280, height: 280)))
                    : pw.SizedBox(),
          ),
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          encabezadoPagina(logo),
          pw.SizedBox(height: 8),
          sectionHeader('Plan de Mejora — Problemas y Acciones', pPrimary),
          pw.SizedBox(height: 16),

          // Resumen de impactos
          pw.Row(children: [
            _resumenBadge('URGENTE',
                state.planMejora.where((f) => f.nivelImpacto <= 2).length, pUrgent),
            pw.SizedBox(width: 8),
            _resumenBadge('MEDIO',
                state.planMejora.where((f) => f.nivelImpacto == 3).length, pMed),
            pw.SizedBox(width: 8),
            _resumenBadge('BAJO',
                state.planMejora.where((f) => f.nivelImpacto >= 5).length, pLow),
          ]),
          pw.SizedBox(height: 14),

          // Tabla
          pw.Table(
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0x44000000), width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(1.1),
              2: pw.FlexColumnWidth(1.6),
              3: pw.FlexColumnWidth(1.6),
              4: pw.FlexColumnWidth(1.0),
              5: pw.FlexColumnWidth(0.8),
              6: pw.FlexColumnWidth(0.8),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pPrimary),
                children: ['Impacto', 'Area', 'Problema', 'Accion',
                  'Responsable', 'Tiempo', 'Dificultad']
                    .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(h, style: headerStyle()),
                    )).toList(),
              ),
              ...state.planMejora.asMap().entries.map((e) {
                final f  = e.value;
                const bg = PdfColor.fromInt(0x00000000);
                PdfColor impColor;
                if (f.nivelImpacto <= 2) {
                  impColor = pUrgent;
                } else if (f.nivelImpacto <= 4) impColor = pMed;
                else                          impColor = pLow;

                return pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0x00000000)),
                  children: [
                    // Impacto
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: impColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(f.impactoLabel,
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 7,
                                fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center),
                      ),
                    ),
                    // Area
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.area.isEmpty ? '—' : f.area,
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
                                color: pPrimary))),
                    // Problema
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.problema.isEmpty ? '—' : f.problema,
                            style: cellStyle())),
                    // Accion
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.accionRecomendada.isEmpty ? '—' : f.accionRecomendada,
                            style: cellStyle())),
                    // Responsable
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.responsable.isEmpty ? '—' : f.responsable,
                            style: cellStyle())),
                    // Tiempo
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.tiempoEstimado.isEmpty ? '—' : f.tiempoEstimado,
                            style: cellStyle())),
                    // Dificultad
                    pw.Padding(padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(f.dificultad.isEmpty ? '—' : f.dificultad,
                            style: cellStyle())),
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
  }

  await Printing.layoutPdf(
    onLayout: (_) async => pdf.save(),
    name: 'Plan_Mejora_VMS_Sports.pdf',
  );
}

pw.Widget _resumenBadge(String label, int count, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(children: [
      pw.Text('$count', style: pw.TextStyle(color: PdfColors.white,
          fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
    ]),
  );
}
