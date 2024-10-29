import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/festival_api.dart';

class FestivalQrPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;

  FestivalQrPaymentPage({required this.productId, required this.festivalId});

  @override
  _FestivalQrPaymentPageState createState() => _FestivalQrPaymentPageState();
}

class _FestivalQrPaymentPageState extends State<FestivalQrPaymentPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String message = 'Please scan your QR code';
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      final userId = int.tryParse(scanData.code ?? '');

      if (userId == null) {
        setState(() {
          message = 'Invalid QR code';
        });
      } else {
        setState(() {
          isProcessing = true;
          message = 'Processing payment...';
        });

        final result = await FestivalApi.processQrPayment(userId, widget.productId, widget.festivalId);

        setState(() {
          message = result['message'];
          isProcessing = false;
        });
      }
      controller.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Payment')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isProcessing
                  ? CircularProgressIndicator()
                  : Text(
                message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
