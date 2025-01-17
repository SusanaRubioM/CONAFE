import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> agregarTextoYFirmaEnCoordenadas(
  String assetPath, // Ruta del PDF dentro de los assets
  Map<String, Offset> textosConCoordenadas, // Mapa con texto y coordenadas
  Uint8List? firmaBytes, // Imagen de la firma (de tipo Uint8List)
  Map<Uint8List, Offset>? imagenesConCoordenadas, // Mapa con imágenes y coordenadas proporcionadas por el usuario
) async {
  // Cargar el archivo PDF desde los assets
  final originalBytes = await rootBundle.load(assetPath);
  final pdfDocument = PdfDocument(inputBytes: originalBytes.buffer.asUint8List());

  // Acceder a las páginas del PDF
  for (var pageIndex = 0; pageIndex < pdfDocument.pages.count; pageIndex++) {
    final page = pdfDocument.pages[pageIndex];

    // Agregar textos en las coordenadas especificadas
    for (var entry in textosConCoordenadas.entries) {
      final texto = entry.key;
      final coordenadas = entry.value;
      page.graphics.drawString(
        texto,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(coordenadas.dx, coordenadas.dy, 200, 20),
        brush: PdfBrushes.black,
      );
    }

    // Agregar la firma si está disponible
    if (firmaBytes != null) {
      final firmaImagen = PdfBitmap(firmaBytes);
      page.graphics.drawImage(
        firmaImagen,
        Rect.fromLTWH(200, 400, 150, 50), // Ajusta las coordenadas y el tamaño según sea necesario
      );
    }

    // Agregar imágenes si se proporcionan y si el usuario definió las coordenadas
    if (imagenesConCoordenadas != null) {
      for (var entry in imagenesConCoordenadas.entries) {
        final imagenBytes = entry.key;  // Asumimos que la clave es la imagen en bytes
        final coordenadas = entry.value;

        final image = PdfBitmap(imagenBytes); // Crear la imagen desde los bytes proporcionados
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(coordenadas.dx, coordenadas.dy, 100, 100), // Ajusta el tamaño según sea necesario
        );
      }
    }
  }

  // Guardar el archivo PDF modificado en la carpeta de "Descargas"
  final dir = Directory('/storage/emulated/0/Download'); // Ruta de la carpeta de "Descargas"
  
  if (await dir.exists()) {
    final nuevoPdfPath = '${dir.path}/pdf_modificado.pdf';
    final nuevoPdf = File(nuevoPdfPath);
    await nuevoPdf.writeAsBytes(pdfDocument.saveSync());

    print('PDF modificado guardado en: $nuevoPdfPath');
  } else {
    print('La carpeta "Descargas" no existe o no se puede acceder.');
  }

  // Liberar recursos del documento
  pdfDocument.dispose();
}
