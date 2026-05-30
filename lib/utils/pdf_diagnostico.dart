import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

Future<void> generarPDFDiagnostico(AppState state) async {
  final pdf  = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // ── PORTADA ──
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'INFORME DE DIAGNÓSTICO',
      'VMS Sports — Consultoría Deportiva',
      pPrimary, state.nombreClub, state.fecha, state.consultor, logo,
    ),
  ));

  // ── ÁREAS en doble columna con observaciones ──
  for (int i = 0; i < state.areas.length; i += 2) {
    final slice = state.areas.sublist(i, (i + 2).clamp(0, state.areas.length));
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Stack(children: [
        // Fondo blanco de pagina
        pw.Positioned.fill(child: pw.Container(color: const PdfColor.fromInt(0x00FFFFFF))),
        // Marca de agua encima del blanco
        marcaDeAgua(logo, watermark: watermark),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          encabezadoPagina(logo),
          pw.SizedBox(height: 8),
          sectionHeader(
            i == 0 ? 'Diagnóstico Detallado' : 'Diagnóstico Detallado (cont.)',
            pPrimary,
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: slice.asMap().entries.map((e) => pw.Expanded(
              child: pw.Padding(
                padding: pw.EdgeInsets.only(
                  right: e.key == 0 && slice.length > 1 ? 6 : 0,
                  left:  e.key == 1 ? 6 : 0,
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

  // ── GRÁFICA RESUMEN POR SECCIÓN ──
  final areasConDatos = state.areas.where((a) => a.promedio > 0).toList();
  if (areasConDatos.isNotEmpty) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Stack(children: [
        // Fondo blanco de pagina
        pw.Positioned.fill(child: pw.Container(color: const PdfColor.fromInt(0x00FFFFFF))),
        // Marca de agua encima del blanco
        marcaDeAgua(logo, watermark: watermark),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          sectionHeader('Resumen por Sección — Calificación Promedio', pPrimary),
          pw.SizedBox(height: 20),
          // Barras horizontales por área
          ...areasConDatos.map((area) {
            final prom  = area.promedio;
            final color = _calColor(prom);
            final nProb = area.totalProblemas;
            final barW  = 380.0;  // ancho máximo de barra
            final fill  = barW * (prom / 5);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                // Nombre + promedio + badge problemas
                pw.Row(children: [
                  pw.Expanded(
                    child: pw.Text(area.nombre,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pPrimary)),
                  ),
                  if (nProb > 0)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(right: 8),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: pUrgent,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text('$nProb problema${nProb > 1 ? "s" : ""}',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    ),
                  pw.Text(prom.toStringAsFixed(1),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
                  pw.Text('/5', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                ]),
                pw.SizedBox(height: 5),
                // Barra fondo
                pw.Stack(children: [
                  pw.Container(
                    width: double.infinity, height: 18,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
                    ),
                  ),
                  // Relleno coloreado
                  pw.Container(
                    width: fill, height: 18,
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
                    ),
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 6),
                        child: pw.Text(prom.toStringAsFixed(1),
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 8,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                  ),
                ]),
                pw.SizedBox(height: 3),
                // Escala 1-5
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: ['1\nMuy def.', '2\nDefic.', '3\nRegular', '4\nBueno', '5\nExcelente']
                      .map((t) => pw.Text(t,
                          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                          textAlign: pw.TextAlign.center))
                      .toList(),
                ),
              ]),
            );
          }),

          pw.SizedBox(height: 16),
          // Leyenda de colores
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0x22ECEFF1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Leyenda de calificación:',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: pPrimary)),
              pw.SizedBox(height: 6),
              pw.Row(children: [
                _leyendaBadge('1-2  Muy deficiente / Deficiente', pUrgent),
                pw.SizedBox(width: 12),
                _leyendaBadge('3  Regular', pMed),
                pw.SizedBox(width: 12),
                _leyendaBadge('4  Bueno', pBlue),
                pw.SizedBox(width: 12),
                _leyendaBadge('5  Excelente', pLow),
              ]),
            ]),
          ),
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

// ── Bloque de un área con subtemas + observaciones ──
pw.Widget _areaBlock(AreaModel area) {
  final prom      = area.promedio;
  final promColor = _calColor(prom);

  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: pPrimary,
        borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
      ),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.Text(area.nombre,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
        if (prom > 0)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Text(prom.toStringAsFixed(1),
                style: pw.TextStyle(color: promColor, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
      ]),
    ),
    pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0x44000000), width: 0.5),
      columnWidths: const {0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(0.55)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1E3A5C)),
          children: ['Subtema / Observaciones', 'Cal.'].map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(h, style: pw.TextStyle(
                color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
          )).toList(),
        ),
        ...area.subtemas.asMap().entries.map((e) {
          final sub  = e.value;
          final bg   = const PdfColor.fromInt(0x00FFFFFF);
          final calC = _calColor(sub.calificacion.toDouble());
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0x00FFFFFF)),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  // Nombre del subtema
                  pw.Text(sub.nombre,
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: pPrimary)),
                  pw.Text(sub.subarea,
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  // Observaciones
                  if (sub.observacion.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0x33ECEFF1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                        border: pw.Border.all(color: PdfColor.fromInt(0xFFBDC3C7), width: 0.5),
                      ),
                      child: pw.Text('Obs: ${sub.observacion}',
                          style: pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF2C3E50))),
                    ),
                  ],
                  // Problema detectado
                  if (sub.problemaDetectado.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0x33FFCDD2),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                        border: pw.Border.all(color: pUrgent, width: 0.5),
                      ),
                      child: pw.Text('Problema: ${sub.problemaDetectado}',
                          style: pw.TextStyle(fontSize: 7, color: pUrgent)),
                    ),
                  ],
                  // Imágenes adjuntas (miniaturas)
                  if (sub.imagenes.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Row(children: [
                      ...sub.imagenes.take(3).map((img) => pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 4),
                        child: pw.Container(
                          width: 36, height: 36,
                          decoration: pw.BoxDecoration(
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                          ),
                          child: pw.Image(pw.MemoryImage(img), fit: pw.BoxFit.cover),
                        ),
                      )),
                      if (sub.imagenes.length > 3)
                        pw.Text('+${sub.imagenes.length - 3} más',
                            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ]),
                  ],
                ]),
              ),
              // Calificación
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: sub.calificacion > 0 ? calC : PdfColors.grey300,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      sub.calificacion > 0 ? '${sub.calificacion}' : '–',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 10,
                          fontWeight: pw.FontWeight.bold),
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

pw.Widget _leyendaBadge(String label, PdfColor color) => pw.Row(children: [
  pw.Container(width: 12, height: 12,
      decoration: pw.BoxDecoration(color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
  pw.SizedBox(width: 4),
  pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
]);

PdfColor _calColor(double v) {
  if (v <= 0) return PdfColors.grey;
  if (v <= 2) return pUrgent;
  if (v <= 3) return pMed;
  if (v <= 4) return pBlue;
  return pLow;
}
