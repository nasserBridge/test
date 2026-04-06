import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/statements/statement_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class StatementViewer extends StatefulWidget {
  final String month;
  final String accountID;
  final String institution;

  const StatementViewer({
    super.key,
    required this.month,
    required this.accountID,
    required this.institution,
  });

  @override
  State<StatementViewer> createState() => _StatementViewerState();
}

class _StatementViewerState extends State<StatementViewer> {
  late StatementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(StatementController(
        accountID: widget.accountID,
        month: widget.month,
        institution: widget.institution));
  }

  @override
  void dispose() {
    _controller.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 23, 23, 23),
        appBar: _appbar(),
        body: Obx(
          () => _controller.localFilePath.value != null
              ? _pdfFile()
              : const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: AppColors.white,
                  ),
                ),
        ));
  }

  AppBar _appbar() => AppBar(
          title: Text(
            "${widget.month} Statement",
            style: TextStyle(
              color: AppColors.navy,
              fontSize: Scale.x(17),
              fontWeight: FontWeight.bold,
              fontFamily: "Open Sans",
            ),
          ),
          centerTitle: true,
          actions: [
            Obx(() => IconInkResponse(
                icon: Icons.download_rounded,
                padding: EdgeInsets.only(right: Scale.x(15)),
                size: Scale.x(27),
                color: _controller.localFilePath.value != null
                    ? null //defaults to navy
                    : const Color.fromARGB(255, 159, 159, 159),
                onTap: _controller.localFilePath.value == null
                    ? null
                    : () async {
                        await _controller.downloadPDF();
                      })),
          ]);

  Widget _pdfFile() {
    return PDFView(
      filePath:
          _controller.localFilePath.value, // Load the PDF from the file path
      onError: (error) {
        debugPrint('Error rendering PDF: $error');
      },
    );
  }
}
