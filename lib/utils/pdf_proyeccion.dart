import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

Future<void> generarPDFProyeccion(AppState state) async {
  final pdf  = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // ── PORTADA ──
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'PROYECCIÓN DE RESULTADOS',
      'VMS Sports — Consultoría Deportiva',
      const PdfColor.fromInt(0xFF2C3E50),
      state.nombreClub, state.fecha, state.consultor, logo,
    ),
  ));

  // ── TABLA DE PROYECCIÓN ──
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
        sectionHeader('Proyección de Resultados', const PdfColor.fromInt(0xFF2C3E50)),
        pw.SizedBox(height: 16),

        // Resumen: cuántos indicadores completados
        _resumenIndicadores(state),
        pw.SizedBox(height: 16),

        // Tabla
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromInt(0x44000000), width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1.5),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2C3E50)),
              children: ['Indicador', 'Estado Actual', 'Proyección', 'Mejora Esperada']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(h, style: headerStyle()),
                  )).toList(),
            ),
            ...state.proyeccion.asMap().entries.map((e) {
              final f  = e.value;
              final bg = const PdfColor.fromInt(0x00FFFFFF);
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0x00FFFFFF))),
                children: [
                  // Indicador
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(f.indicador.isEmpty ? '—' : f.indicador,
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: pPrimary)),
                  ),
                  // Estado actual — fondo rojo claro si hay contenido
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: f.estadoActual.isEmpty
                        ? pw.Text('—', style: cellStyle())
                        : pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromInt(0x22C0392B),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: pUrgent, width: 0.5),
                            ),
                            child: pw.Text(f.estadoActual,
                                style: pw.TextStyle(fontSize: 8, color: pUrgent)),
                          ),
                  ),
                  // Proyección — azul claro
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: f.proyeccion.isEmpty
                        ? pw.Text('—', style: cellStyle())
                        : pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromInt(0x221A3A5C),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: pBlue, width: 0.5),
                            ),
                            child: pw.Text(f.proyeccion,
                                style: pw.TextStyle(fontSize: 8, color: pBlue)),
                          ),
                  ),
                  // Mejora esperada — verde claro
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: f.mejoraEsperada.isEmpty
                        ? pw.Text('—', style: cellStyle())
                        : pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromInt(0x221E8449),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: pLow, width: 0.5),
                            ),
                            child: pw.Text(f.mejoraEsperada,
                                style: pw.TextStyle(fontSize: 8, color: pLow)),
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
    name: 'Proyeccion_VMS_Sports.pdf',
  );
}

pw.Widget _resumenIndicadores(AppState state) {
  final total     = state.proyeccion.length;
  final completos = state.proyeccion.where((f) => f.indicador.isNotEmpty).length;
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0x221A3A5C),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfColor.fromInt(0xFF2C3E50), width: 0.5),
    ),
    child: pw.Row(children: [
      pw.Container(
        width: 40, height: 40,
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFF2C3E50),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
        ),
        child: pw.Center(
          child: pw.Text('$completos',
              style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Indicadores registrados',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF2C3E50))),
        pw.Text('$completos de $total indicadores completados',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ]),
    ]),
  );
}
