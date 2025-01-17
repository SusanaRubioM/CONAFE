import 'dart:ui';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/prueba/pdf_generador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart'; // Paquete para la firma
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class FormularioEntrega extends StatefulWidget {
  static const String routeName = '/screen_pantalla_eq02_02';
  const FormularioEntrega({super.key});

  @override
  _FormularioEntregaState createState() => _FormularioEntregaState();
}

class _FormularioEntregaState extends State<FormularioEntrega> {
  final Map<String, dynamic> formData = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<SignatureState> _firma1Key = GlobalKey();
  final GlobalKey<SignatureState> _firma2Key = GlobalKey();
  final GlobalKey<SignatureState> _firma3Key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        title: const Text('Formulario de Entrega'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Num Recibo', 'numRecibo'),
              _buildTextField('Clave de Centros de Trabajo', 'claveCentro'),
              _buildTextField('Entidad', 'entidad'),
              _buildTextField('Municipio', 'municipio'),
              _buildTextField('Comunidad', 'comunidad'),
              const SizedBox(height: 16),
              _buildSignatureSection1(),
              const Divider(),
              _buildSignatureSection2(),
              const Divider(),
              _buildSignatureSection3(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Guardar y Generar PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: (value) {
        formData[key] = value;
      },
    );
  }

  Widget _buildSignatureSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sesión de Firma 1', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre Completo'),
          onSaved: (value) {
            formData['firma1Nombre'] = value;
          },
        ),
        Container(
          width: double.infinity, 
          height: 200, 
          child: Signature(key: _firma1Key, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSignatureSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sesión de Firma 2', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre Completo'),
          onSaved: (value) {
            formData['firma2Nombre'] = value;
          },
        ),
        Container(
          width: double.infinity, 
          height: 200, 
          child: Signature(key: _firma2Key, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSignatureSection3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sesión de Firma 3', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre Completo'),
          onSaved: (value) {
            formData['firma3Nombre'] = value;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Cargo que Ocupa'),
          onSaved: (value) {
            formData['firma3Cargo'] = value;
          },
        ),
        Container(
          width: double.infinity, 
          height: 200, 
          child: Signature(key: _firma3Key, color: Colors.black),
        ),
      ],
    );
  }

  Future<void> _saveData() async {
  _formKey.currentState?.save();

  // Verificar si las firmas no son null antes de procesarlas
  final firma1Bytes = await _getFirmaBytes(_firma1Key);
  final firma2Bytes = await _getFirmaBytes(_firma2Key);
  final firma3Bytes = await _getFirmaBytes(_firma3Key);

  // Definir los textos con coordenadas en el PDF
  final textosConCoordenadas = {
    'Num Recibo: ${formData['numRecibo']}': {'x': 100, 'y': 100},
    'Clave de Centros de Trabajo: ${formData['claveCentro']}': {'x': 100, 'y': 150},
    'Entidad: ${formData['entidad']}': {'x': 100, 'y': 200},
    'Municipio: ${formData['municipio']}': {'x': 100, 'y': 250},
    'Comunidad: ${formData['comunidad']}': {'x': 100, 'y': 300},
  };

  // Definir las coordenadas para las firmas
  final imagenesConCoordenadas = {
    firma2Bytes: {'x': 400, 'y': 400},
    firma3Bytes: {'x': 400, 'y': 400},
  };

  // Llamar a la función para agregar texto y firma al PDF
  await PdfHandler().inyectarDatosEnPdf(
    'lib/assets/ReciboMateriales.pdf', // Ruta del PDF base
    {'textos': textosConCoordenadas, 'imagenes': imagenesConCoordenadas},
  );

  // Obtener la ruta del PDF generado
  final outputDir = await getApplicationDocumentsDirectory();
  final pdfPath = '${outputDir.path}/nuevo_recibo.pdf';

  // Mostrar el PDF en un Dialog
  await _mostrarPdfEnDialog(pdfPath);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Formulario guardado exitosamente')),
  );
}


  // Obtener los bytes de la firma, asegurándose de que no sean null
  Future<Uint8List> _getFirmaBytes(GlobalKey<SignatureState> signatureKey) async {
    final signatureState = signatureKey.currentState;
    if (signatureState != null) {
      // Obtener el path de la firma
      final path = signatureState.points;

      if (path.isEmpty) {
        throw Exception("La firma está vacía.");
      }

      // Crear un objeto PictureRecorder para dibujar sobre un lienzo
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(400, 400)));

      // Dibujar la firma en el lienzo
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final point in path) {
  if (point != null) { // Verificar si el punto no es null
    canvas.drawCircle(point, 2.0, paint);
  }
}

      // Crear una imagen a partir del dibujo realizado en el lienzo
      final picture = recorder.endRecording();
      final img = await picture.toImage(1000, 1000); // Tamaño de la imagen

      // Convertir la imagen en un Uint8List
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      } else {
        throw Exception("No se pudo obtener la imagen de la firma.");
      }
    } else {
      throw Exception("No se encontró el estado de la firma.");
    }
  }

  Future<void> _mostrarPdfEnDialog(String pdfPath) async {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        height: 1000, // Ajusta el tamaño según lo necesites
        child: PDFView(
          filePath: pdfPath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageFling: true,
          onRender: (pages) {
            print('PDF renderizado con $pages páginas.');
          },
          onError: (error) {
            print('Error al cargar el PDF: $error');
          },
          onPageError: (page, error) {
            print('Error en la página $page: $error');
          },
        ),
      ),
    ),
  );
}
}

