import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show Rect, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfHandler {
  /// Inyecta datos en un PDF desde los assets, guarda una copia local del PDF y guarda el nuevo PDF con los datos inyectados.
  Future<void> inyectarDatosEnPdf(
      String assetPath, Map<String, dynamic> datos) async {
    try {
      // Cargar el PDF base desde los assets
      final pdfData = await rootBundle.load(assetPath);
      final Uint8List pdfBytes = pdfData.buffer.asUint8List();

      // Cargar el archivo PDF existente
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);

      // Obtener la primera página del PDF (o crea nuevas si es necesario)
      final PdfPage page = document.pages[0];

      // Obtener el lienzo de la página para dibujar
      final PdfGraphics graphics = page.graphics;

      // Agregar textos al PDF
      if (datos['textos'] != null && datos['textos'] is Map) {
        datos['textos'].forEach((texto, coordenadas) {
          graphics.drawString(
            texto,
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: Rect.fromLTWH(
              coordenadas['x'].toDouble(),
              coordenadas['y'].toDouble(),
              500,
              500,
            ),
          );
          print(
              'Texto agregado: $texto en (${coordenadas['x']}, ${coordenadas['y']})');
        });
      }

      // Agregar imágenes al PDF
      if (datos['imagen'] != null &&
          datos['imagen'] is Map<String, dynamic>) {
        datos['imagen'].forEach((key, imagen) {
          if (imagen['image'] != null &&
              imagen['x'] != null &&
              imagen['y'] != null) {
            final PdfBitmap bitmap = PdfBitmap(imagen['image']);
            graphics.drawImage(
              bitmap,
              Rect.fromLTWH(
                imagen['x'].toDouble(),
                imagen['y'].toDouble(),
                1000, // Ancho de la imagen
                1000, // Alto de la imagen
              ),
            );
            print('Imagen agregada en (${imagen['x']}, ${imagen['y']})');
          } else {
            print('Datos incompletos para la imagen: $key');
          }
        });
      }

      // Guardar el archivo PDF actualizado
      final outputDir = await getApplicationDocumentsDirectory();
      final String outputFilePath = '${outputDir.path}/nuevo_recibo.pdf';
      final File outputFile = File(outputFilePath);
      await outputFile.writeAsBytes(document.saveSync());
      document.dispose();

      print('PDF actualizado guardado en $outputFilePath');

      // Verificar el tamaño del archivo
      if (await outputFile.length() > 0) {
        print(
            'PDF generado correctamente. Tamaño: ${await outputFile.length()} bytes');
      } else {
        print('El PDF está vacío.');
      }
    } catch (e) {
      print('Error al inyectar datos en el PDF: $e');
    }
  }
}
