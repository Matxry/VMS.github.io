import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

// Color transparente reutilizable
const _t = PdfColor(0, 0, 0, 0);

Future<void> generarPDFDiagnostico(AppState state) async {
  final pdf       = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // PORTADA
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'INFORME DE DIAGNÓSTICO',
      'VMS Sports | Consultoria Deportiva',
      pPrimary, state.nombreClub, state.fecha, state.consultor, logo,
      tipoOrg: state.tipoOrg,
    ),
  ));

  // AREAS en doble columna
  for (int i = 0; i < state.areas.length; i += 2) {
    final slice = state.areas.sublist(i, (i + 2).clamp(0, state.areas.length));
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 16, 24, 16),
      build: (ctx) => pw.Stack(children: [
        marcaDeAgua(logo, watermark: watermark),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          encabezadoPagina(logo),
          pw.SizedBox(height: 8),
          sectionHeader(
            i == 0 ? 'Diagnostico Detallado — ${state.tipoOrg}' : 'Diagnostico Detallado (cont.)',
            pPrimary,
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: slice.asMap().entries.map((e) => pw.Expanded(
              child: pw.Padding(
                padding: pw.EdgeInsets.only(
                  right: e.key == 0 && slice.length > 1 ? 5 : 0,
                  left:  e.key == 1 ? 5 : 0,
                ),
                child: _areaBlock(e.value),
              ),
            )).toList(),
          ),
          pw.Spacer(),
          piePagina(state.nombreClub, state.fecha),
        ]),
      ]),
    ));
  }

  // GRAFICA RESUMEN
  final areasConDatos = state.areas.where((a) => a.promedio > 0).toList();
  if (areasConDatos.isNotEmpty) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 16, 24, 16),
      build: (ctx) => pw.Stack(children: [
        marcaDeAgua(logo, watermark: watermark),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          encabezadoPagina(logo),
          pw.SizedBox(height: 8),
          sectionHeader('Resumen por Sección', pPrimary),
          pw.SizedBox(height: 16),
          ...areasConDatos.map((area) {
            final prom  = area.promedio;
            final color = _calColor(prom);
            final nProb = area.totalProblemas;
            final fill  = 360.0 * (prom / 5);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Row(children: [
                  pw.Expanded(
                    child: pw.Text(area.nombre,
                        style: pw.TextStyle(fontSize: 10,
                            fontWeight: pw.FontWeight.bold, color: pPrimary)),
                  ),
                  if (nProb > 0)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(right: 8),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                          color: pUrgent,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                      child: pw.Text('$nProb problema${nProb > 1 ? "s" : ""}',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 7,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  pw.Text(prom.toStringAsFixed(1),
                      style: pw.TextStyle(fontSize: 12,
                          fontWeight: pw.FontWeight.bold, color: color)),
                  pw.Text('/5',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                ]),
                pw.SizedBox(height: 5),
                pw.Stack(children: [
                  pw.Container(width: double.infinity, height: 16,
                      decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)))),
                  pw.Container(width: fill, height: 16,
                      decoration: pw.BoxDecoration(
                          color: color,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)))),
                ]),
              ]),
            );
          }),
          pw.Spacer(),
          piePagina(state.nombreClub, state.fecha),
        ]),
      ]),
    ));
  }

  await Printing.layoutPdf(
    onLayout: (_) async => pdf.save(),
    name: 'Diagnostico_VMS_Sports.pdf',
  );
}

pw.Widget _areaBlock(AreaModel area) {
  final prom      = area.promedio;
  final promColor = _calColor(prom);

  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    // Cabecera área
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: pPrimary,
        borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
      ),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.Text(area.nombre,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 9,
                  fontWeight: pw.FontWeight.bold)),
        ),
        if (prom > 0)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Text(prom.toStringAsFixed(1),
                style: pw.TextStyle(color: promColor, fontSize: 9,
                    fontWeight: pw.FontWeight.bold)),
          ),
      ]),
    ),
    // Tabla subtemas
    pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(0.55),
      },
      children: [
        // Cabecera tabla
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pNavy),
          children: ['Subtema / Observaciones', 'Cal.'].map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(h, style: pw.TextStyle(
                color: PdfColors.white, fontSize: 7,
                fontWeight: pw.FontWeight.bold)),
          )).toList(),
        ),
        // Filas subtemas
        ...area.subtemas.asMap().entries.map((e) {
          final sub  = e.value;
          final calC = _calColor(sub.calificacion.toDouble());
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: _t), // TRANSPARENTE
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  pw.Text(sub.nombre,
                      style: pw.TextStyle(fontSize: 8,
                          fontWeight: pw.FontWeight.bold, color: pPrimary)),
                  pw.Text(sub.subarea,
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  if (sub.observacion.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(3)),
                      ),
                      child: pw.Text('Obs: ${sub.observacion}',
                          style: pw.TextStyle(fontSize: 7,
                              color: PdfColors.grey700)),
                    ),
                  ],
                  if (sub.problemaDetectado.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red50,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(3)),
                        border: pw.Border.all(color: pUrgent, width: 0.5),
                      ),
                      child: pw.Text('Problema: ${sub.problemaDetectado}',
                          style: pw.TextStyle(fontSize: 7, color: pUrgent)),
                    ),
                  ],
                  if (sub.imagenes.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Row(children: [
                      ...sub.imagenes.take(3).map((img) => pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 3),
                        child: pw.Container(
                          width: 30, height: 30,
                          decoration: pw.BoxDecoration(
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(2)),
                            border: pw.Border.all(
                                color: PdfColors.grey400, width: 0.5),
                          ),
                          child: pw.Image(pw.MemoryImage(img),
                              fit: pw.BoxFit.cover),
                        ),
                      )),
                    ]),
                  ],
                ]),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: sub.calificacion > 0 ? calC : PdfColors.grey300,
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      sub.calificacion > 0 ? '${sub.calificacion}' : '-',
                      style: pw.TextStyle(color: PdfColors.white,
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    ),
    pw.SizedBox(height: 8),
  ]);
}

PdfColor _calColor(double v) {
  if (v <= 0) return PdfColors.grey;
  if (v <= 2) return pUrgent;
  if (v <= 3) return pMed;
  if (v <= 4) return pBlue;
  return pLow;
}
