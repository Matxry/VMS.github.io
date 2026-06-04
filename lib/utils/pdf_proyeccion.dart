import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'pdf_helpers.dart';

const _t = PdfColor(0, 0, 0, 0);

Future<void> generarPDFProyeccion(AppState state) async {
  final pdf       = await crearDocumento();
  final logo      = await cargarLogo();
  final watermark = await cargarWatermark();

  // PORTADA
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => buildPortada(
      'PROYECCIÓN DE RESULTADOS',
      'VMS Sports | Consultoria Deportiva',
      const PdfColor.fromInt(0xFF2C3E50),
      state.nombreClub, state.fecha, state.consultor, logo,
      tipoOrg: state.tipoOrg,
    ),
  ));

  // TABLA PROYECCION
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(24, 16, 24, 16),
    build: (ctx) => pw.Stack(children: [
      marcaDeAgua(logo, watermark: watermark),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        encabezadoPagina(logo),
        pw.SizedBox(height: 8),
        sectionHeader('Proyección de Resultados',
            const PdfColor.fromInt(0xFF2C3E50)),
        pw.SizedBox(height: 12),
        // Resumen
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFF2C3E50),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(children: [
            pw.Container(
              width: 36, height: 36,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(18)),
              ),
              child: pw.Center(
                child: pw.Text(
                  '${state.proyeccion.where((f) => f.indicador.isNotEmpty).length}',
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF2C3E50),
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Indicadores registrados',
                  style: pw.TextStyle(color: PdfColors.white,
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('de ${state.proyeccion.length} totales',
                  style: pw.TextStyle(color: PdfColors.white70, fontSize: 8)),
            ]),
          ]),
        ),
        pw.SizedBox(height: 12),
        // Tabla
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.0),
            1: pw.FlexColumnWidth(1.5),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF2C3E50)),
              children: ['Indicador', 'Estado Actual',
                'Proyección', 'Mejora Esperada']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(h, style: headerStyle()),
                  )).toList(),
            ),
            ...state.proyeccion.map((f) => pw.TableRow(
              decoration: pw.BoxDecoration(color: _t),
              children: [
                _cell(f.indicador, bold: true),
                _cellColor(f.estadoActual, PdfColors.red50, pUrgent),
                _cellColor(f.proyeccion, PdfColors.blue50, pBlue),
                _cellColor(f.mejoraEsperada, PdfColors.green50, pLow),
              ],
            )),
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

pw.Widget _cell(String value, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.all(7),
  child: pw.Text(value.isEmpty ? '-' : value,
      style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: bold ? pPrimary : PdfColors.black)),
);

pw.Widget _cellColor(String value, PdfColor bg, PdfColor textColor) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: value.isEmpty
          ? pw.Text('-', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey))
          : pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: pw.BoxDecoration(
                color: bg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(value,
                  style: pw.TextStyle(fontSize: 8, color: textColor)),
            ),
    );
