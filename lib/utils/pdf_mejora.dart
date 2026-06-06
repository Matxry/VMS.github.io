import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';


Future<void> generarPDFMejora(AppState state) async {
  final pdf       = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // PORTADA
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'PLAN DE MEJORA',
      'VMS Sports | Consultoria Deportiva',
      pBlue, state.nombreClub, state.fecha, state.consultor, logo,
    ),
  ));

  if (state.planMejora.isEmpty) {
    await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'Plan_Mejora_VMS_Sports.pdf');
    return;
  }

  // TABLA PLAN DE MEJORA
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(24, 16, 24, 16),
    build: (ctx) => pw.Stack(children: [
      marcaDeAgua(logo, watermark: watermark),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        encabezadoPagina(logo),
        pw.SizedBox(height: 8),
        sectionHeader('Plan de Mejora', pBlue),
        pw.SizedBox(height: 12),
        // Resumen badges
        pw.Row(children: [
          _badge('URGENTE',
              state.planMejora.where((f) => f.nivelImpacto <= 2).length, pUrgent),
          pw.SizedBox(width: 8),
          _badge('MEDIO',
              state.planMejora.where((f) => f.nivelImpacto == 3).length, pMed),
          pw.SizedBox(width: 8),
          _badge('BAJO',
              state.planMejora.where((f) => f.nivelImpacto >= 5).length, pLow),
        ]),
        pw.SizedBox(height: 12),
        // Tabla
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: const {
              0: pw.FlexColumnWidth(0.55),
              1: pw.FlexColumnWidth(0.55),
              2: pw.FlexColumnWidth(1.3),
              3: pw.FlexColumnWidth(1.1),
              4: pw.FlexColumnWidth(1.5),
              5: pw.FlexColumnWidth(1.0),
              6: pw.FlexColumnWidth(0.8),
              7: pw.FlexColumnWidth(0.8),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: pBlue),
              children: ['Impacto', 'Area', 'Accion',
                'Responsable', 'Tiempo', 'Dificultad']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h, style: headerStyle()),
                  )).toList(),
            ),
            ...state.planMejora.where((f) => f.incluido).map((f) {
              PdfColor impColor;
              if (f.nivelImpacto <= 2) impColor = pUrgent;
              else if (f.nivelImpacto <= 4) impColor = pMed;
              else impColor = pLow;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: impColor,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4)),
                      ),
                      child: pw.Text(f.impactoLabel,
                          style: pw.TextStyle(color: PdfColors.white,
                              fontSize: 7, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center),
                    ),
                  ),
                  _cell(f.area, bold: true),
                  _cell(f.accionRecomendada),
                  _cell(f.responsable),
                  _cell(f.tiempoEstimado),
                  _cell(f.dificultad),
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
    name: 'Plan_Mejora_VMS_Sports.pdf',
  );
}

pw.Widget _cell(String value, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.all(6),
  child: pw.Text(value.isEmpty ? '-' : value,
      style: pw.TextStyle(fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: bold ? pPrimary : PdfColors.black)),
);

pw.Widget _badge(String label, int count, PdfColor color) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  decoration: pw.BoxDecoration(
    color: color,
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  ),
  child: pw.Column(children: [
    pw.Text('$count', style: pw.TextStyle(color: PdfColors.white,
        fontSize: 18, fontWeight: pw.FontWeight.bold)),
    pw.Text(label, style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
  ]),
);