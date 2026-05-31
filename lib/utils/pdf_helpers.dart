import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ── Paleta marca ──
const pDark      = PdfColor.fromInt(0xFF0D1B2A);
const pNavy      = PdfColor.fromInt(0xFF1A3A5C);
const pGrey      = PdfColor.fromInt(0xFF5C6B7A);
const pLightGrey = PdfColor.fromInt(0xFFB0BEC5);
const pUrgent    = PdfColor.fromInt(0xFFC0392B);
const pMed       = PdfColor.fromInt(0xFF7D6608);
const pLow       = PdfColor.fromInt(0xFF1E8449);
const pBlue      = PdfColor.fromInt(0xFF1A5276);
const pGreen     = PdfColor.fromInt(0xFF1E5631);
const pRowOdd    = PdfColor.fromInt(0xFFF4F6F8);
const pPrimary   = pNavy;
const pAccent    = pLightGrey;

// ── Datos de contacto para pie de pagina (igual que el docx) ──
const kTelefono = '09644133472 - 0998790380';
const kEmail    = 'vmssportsecuador@gmail.com';

Future<pw.Document> crearDocumento() async {
  try {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(fontData),
        bold: pw.Font.ttf(boldData),
      ),
    );
  } catch (_) {
    return pw.Document();
  }
}

pw.TextStyle headerStyle() {
  return pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10);
}
pw.TextStyle cellStyle() {
  return pw.TextStyle(fontSize: 9);
}
pw.TextStyle titleStyle() {
  return pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13);
}

Future<pw.ImageProvider?> cargarLogo() async {
  try {
    final data = await rootBundle.load('assets/logo_pdf.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {
    try {
      final data = await rootBundle.load('assets/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) { return null; }
  }
}

Future<pw.ImageProvider?> cargarWatermark() async {
  try {
    final data = await rootBundle.load('assets/watermark.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) { return null; }
}

// ── Marca de agua SIN rotacion ──
pw.Widget marcaDeAgua(pw.ImageProvider? logo, {pw.ImageProvider? watermark}) {
  // Imagen de watermark: centrada, sin inclinacion, ajustada al ancho de la pagina
  if (watermark != null) {
    return pw.Center(
      child: pw.Opacity(
        opacity: 0.09,
        // La imagen es 846x253 (ratio ~3.3:1), ajustamos al ancho de la pagina A4 menos margenes
        child: pw.Image(watermark, width: 400, height: 120, fit: pw.BoxFit.contain),
      ),
    );
  }
  if (logo != null) {
    return pw.Center(
      child: pw.Opacity(
        opacity: 0.09,
        child: pw.Image(logo, width: 220, height: 220, fit: pw.BoxFit.contain),
      ),
    );
  }
  return pw.SizedBox();
}

// ── Portada: fondo blanco predominante ──
pw.Widget buildPortada(String titulo, String subtitulo, PdfColor headerColor,
    String club, String fecha, String consultor, pw.ImageProvider? logo) {
  return pw.Column(children: [
    // Franja superior delgada azul marino (20%)
    pw.Container(
      height: 8,
      color: pDark,
      width: double.infinity,
    ),
    // Cuerpo principal blanco (70%)
    pw.Expanded(
      flex: 8,
      child: pw.Container(
        color: PdfColors.white,
        width: double.infinity,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            // Logo sin fondo extra - directo
            if (logo != null)
              pw.Image(logo, width: 180, height: 180, fit: pw.BoxFit.contain)
            else
              pw.Text('VMS', style: pw.TextStyle(
                  color: pDark, fontSize: 52, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 32),
            // Linea separadora azul marino
            pw.Container(width: 280, height: 2, color: pDark),
            pw.SizedBox(height: 24),
            // Titulo
            pw.Text(titulo, style: pw.TextStyle(
                color: pDark, fontSize: 24, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 8),
            pw.Text('VMS Sports | Consultoria Deportiva',
                style: pw.TextStyle(color: pGrey, fontSize: 12)),
            pw.SizedBox(height: 32),
            // Datos del informe
            if (club.isNotEmpty || fecha.isNotEmpty || consultor.isNotEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (club.isNotEmpty)      _portadaRow('Club / Academia', club),
                    if (fecha.isNotEmpty)     _portadaRow('Fecha', fecha),
                    if (consultor.isNotEmpty) _portadaRow('Consultor', consultor),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    // Franja inferior azul oscuro (15%) — igual al pie del docx
    pw.Container(
      color: pDark,
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(kTelefono,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
          pw.Text(kEmail,
              style: pw.TextStyle(color: pLightGrey, fontSize: 9)),
        ],
      ),
    ),
  ]);
}

pw.Widget _portadaRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(children: [
      pw.Container(width: 3, height: 16, color: pDark),
      pw.SizedBox(width: 8),
      pw.Text('$label: ', style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 11, color: pGrey)),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, color: pDark)),
    ]),
  );
}

// ── Encabezado de seccion ──
pw.Widget sectionHeader(String title, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Text(title, style: titleStyle()),
  );
}

// ── Encabezado de pagina mas grande ──
pw.Widget encabezadoPagina(pw.ImageProvider? logo) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: pDark, width: 1.5),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Logo mas grande a la izquierda
        if (logo != null)
          pw.Image(logo, width: 80, height: 44, fit: pw.BoxFit.contain),
        pw.Spacer(),
        // Lineas diagonales esquina superior derecha (como el Word)
        pw.CustomPaint(
          size: const PdfPoint(90, 48),
          painter: (canvas, size) {
            // Linea gris claro
            canvas
              ..setStrokeColor(pLightGrey)
              ..setLineWidth(1.2)
              ..moveTo(50, 48)
              ..lineTo(90, 4)
              ..strokePath();
            // Linea azul marino gruesa
            canvas
              ..setStrokeColor(pDark)
              ..setLineWidth(3.5)
              ..moveTo(64, 48)
              ..lineTo(90, 16)
              ..strokePath();
            // Linea azul claro (cyan)
            canvas
              ..setStrokeColor(const PdfColor.fromInt(0xFF00AEEF))
              ..setLineWidth(1.5)
              ..moveTo(78, 48)
              ..lineTo(90, 30)
              ..strokePath();
          },
        ),
      ],
    ),
  );
}

// ── Pie de pagina (igual al docx: telefono + email) ──
pw.Widget piePagina(String club, String fecha) {
  return pw.Column(children: [
    pw.Container(height: 1, color: pDark),
    pw.SizedBox(height: 4),
    pw.Row(children: [
      // Telefono izquierda
      pw.Text(kTelefono,
          style: pw.TextStyle(color: pGrey, fontSize: 7)),
      pw.Spacer(),
      // Club + fecha centro
      if (club.isNotEmpty)
        pw.Text(club, style: pw.TextStyle(color: pGrey, fontSize: 7)),
      pw.Spacer(),
      // Email derecha
      pw.Text(kEmail,
          style: pw.TextStyle(color: pGrey, fontSize: 7)),
    ]),
  ]);
}
