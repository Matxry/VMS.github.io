import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ── Paleta colores empresa (azul marino, gris, negro) ──
const pDark    = PdfColor.fromInt(0xFF0D1B2A);   // azul muy oscuro / negro
const pNavy    = PdfColor.fromInt(0xFF1A3A5C);   // azul marino
const pMidBlue = PdfColor.fromInt(0xFF1E3A5F);   // azul medio
const pGrey    = PdfColor.fromInt(0xFF5C6B7A);   // gris medio
const pLightGrey = PdfColor.fromInt(0xFFB0BEC5); // gris claro
const pUrgent  = PdfColor.fromInt(0xFFC0392B);   // rojo urgente
const pMed     = PdfColor.fromInt(0xFF7D6608);   // amarillo medio
const pLow     = PdfColor.fromInt(0xFF1E8449);   // verde ok
const pBlue    = PdfColor.fromInt(0xFF1A5276);   // azul tabla
const pGreen   = PdfColor.fromInt(0xFF1E5631);   // verde avances
const pRowOdd  = PdfColor.fromInt(0xFFF4F6F8);   // gris muy claro filas

// Aliases para compatibilidad
const pPrimary = pNavy;
const pAccent  = pLightGrey;

// ── Fuente con soporte de caracteres especiales ──
Future<pw.Document> crearDocumento() async {
  try {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final font     = pw.Font.ttf(fontData);
    final fontBold = pw.Font.ttf(boldData);
    return pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );
  } catch (_) {
    return pw.Document();
  }
}

// ── Estilos ──
pw.TextStyle headerStyle() {
  return pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10);
}
pw.TextStyle cellStyle() {
  return const pw.TextStyle(fontSize: 9);
}
pw.TextStyle titleStyle() {
  return pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13);
}

// ── Cargar logo ──
Future<pw.ImageProvider?> cargarLogo() async {
  try {
    final data = await rootBundle.load('assets/logo.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) { return null; }
}

// ── Cargar watermark ──
Future<pw.ImageProvider?> cargarWatermark() async {
  try {
    final data = await rootBundle.load('assets/watermark.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) { return null; }
}

// ── Marca de agua: imagen de fondo cubriendo la pagina ──
pw.Widget marcaDeAgua(pw.ImageProvider? logo, {pw.ImageProvider? watermark}) {
  if (watermark != null) {
    return pw.Positioned.fill(
      child: pw.Opacity(
        opacity: 0.06,
        child: pw.Image(watermark, fit: pw.BoxFit.cover),
      ),
    );
  }
  if (logo != null) {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Opacity(
          opacity: 0.06,
          child: pw.Image(logo, width: 70, height: 70),
        ),
      ),
    );
  }
  return pw.Center(
    child: pw.Transform.rotate(
      angle: -0.5,
      child: pw.Opacity(
        opacity: 0.04,
        child: pw.Text('VMS',
            style: pw.TextStyle(
                color: pDark, fontSize: 100, fontWeight: pw.FontWeight.bold)),
      ),
    ),
  );
}

// ── Portada: fondo azul marino + logo sin fondo extra ──
pw.Widget buildPortada(
  String titulo,
  String subtitulo,
  PdfColor headerColor,
  String club,
  String fecha,
  String consultor,
  pw.ImageProvider? logo,
) {
  return pw.Column(children: [
    // Franja superior oscura (70% de la pagina)
    pw.Expanded(
      flex: 7,
      child: pw.Container(
        color: pDark,
        width: double.infinity,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            // Logo en circulo blanco con sombra
            pw.Container(
              width: 190, height: 190,
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
                shape: pw.BoxShape.circle,
              ),
              padding: const pw.EdgeInsets.all(22),
              child: pw.Center(
                child: logo != null
                    ? pw.Image(logo, fit: pw.BoxFit.contain)
                    : pw.Text('VMS', style: pw.TextStyle(
                        color: pDark, fontSize: 42,
                        fontWeight: pw.FontWeight.bold)),
              ),
            ),
            pw.SizedBox(height: 28),
            // Linea separadora gris
            pw.Container(
              width: 200, height: 1,
              color: pLightGrey,
            ),
            pw.SizedBox(height: 20),
            pw.Text(titulo, style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 8),
            pw.Text('VMS Sports | Consultoria Deportiva',
                style: const pw.TextStyle(color: pLightGrey, fontSize: 12)),
          ],
        ),
      ),
    ),
    // Franja inferior gris oscuro (30%)
    pw.Expanded(
      flex: 3,
      child: pw.Container(
        color: const PdfColor.fromInt(0xFF1C2833),
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (club.isNotEmpty)      _portadaRow('Club / Academia', club),
            if (fecha.isNotEmpty)     _portadaRow('Fecha', fecha),
            if (consultor.isNotEmpty) _portadaRow('Consultor', consultor),
          ],
        ),
      ),
    ),
  ]);
}

pw.Widget _portadaRow(String label, String value) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Row(children: [
    pw.Container(
        width: 3, height: 16,
        color: pLightGrey),
    pw.SizedBox(width: 8),
    pw.Text('$label: ',
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 11,
            color: pLightGrey)),
    pw.Text(value,
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.white)),
  ]),
);

// ── Encabezado de seccion ──
pw.Widget sectionHeader(String title, PdfColor color) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: pw.BoxDecoration(
    color: color,
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
  ),
  child: pw.Text(title, style: titleStyle()),
);

// ── Pie de pagina ──
pw.Widget piePagina(String club, String fecha) => pw.Column(children: [
  pw.Divider(color: PdfColors.grey400),
  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
    pw.Text('VMS Sports | Consultoria Deportiva   Telefono:00000000 correo:00000000',
        style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
    pw.Text(fecha.isEmpty ? '' : fecha,
        style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
  ]),
]);
