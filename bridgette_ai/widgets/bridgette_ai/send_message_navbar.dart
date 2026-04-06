import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_text_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/attachments_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/stt_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_controller.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class SendMessageNavBar extends StatefulWidget {
  const SendMessageNavBar({super.key});

  @override
  State<SendMessageNavBar> createState() => _SendMessageNavBarState();
}

class _SendMessageNavBarState extends State<SendMessageNavBar> {
  final _aiController = Get.put(AIController());
  final _textController = Get.put(AITextController());
  final _attachmentsController = Get.put(AttachmentsController());
  final _sttController = Get.put(SpeechToTextController());

  @override
  void dispose() {
    _textController.manuallyDispose();
    _attachmentsController.manuallyDispose();
    _sttController.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(Scale.x(15), Scale.x(10), Scale.x(15), 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _attachmentsRow(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _textFieldInput(),
                  sendOrStopIcon(context),
                ],
              ),
              Obx(() {
                return SizedBox(
                  height: Scale.x(50),
                  child: _sttController.preLoadRecorder.value == true
                      ? _audioRecording()
                      : _iconsRow(),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Center _iconsRow() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _cameraIcon(),
          SizedBox(width: 8),
          _imageIcon(),
          SizedBox(width: 8),
          _filesIcon(),
          Spacer(),
          _audioIcon(),
        ],
      ),
    );
  }

  Widget _attachmentsRow() {
    return Obx(() {
      if (_attachmentsController.attachments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(bottom: Scale.x(10)),
        width: double.infinity, // Ensures Wrap uses full available width
        alignment: Alignment.topLeft, // Aligns content to the top-left
        child: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          textDirection: TextDirection.ltr,
          spacing: Scale.x(10.0), // Horizontal space between items
          runSpacing: Scale.x(8.0), // Vertical space between rows
          children:
              List.generate(_attachmentsController.attachments.length, (index) {
            final attachment = _attachmentsController.attachments[index];
            final type = attachment.type;
            final fileName = attachment.name;
            final file = attachment.file;
            final converted = attachment.converted;

            return type == 'pdf'
                ? _fileAttachmentPreview(file, fileName, index, converted)
                : _imageAttachmentPreview(file, index, converted);
          }),
        ),
      );
    });
  }

  Widget _fileAttachmentPreview(
      File file, String fileName, int index, bool converted) {
    return GestureDetector(
      onTap: () => showFileFullScreen(file, 'pdf',
          false), // Optional: omit 'pdf' if your function infers it
      child: Container(
        //margin: const EdgeInsets.only(bottom: 10, right: 10),
        width: Scale.x(265),
        height: Scale.x(70),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(Scale.x(13)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Scale.x(13)),
          child: Row(
            children: [
              // Left icon and loading overlay with rounded corners
              Padding(
                padding: EdgeInsets.all(Scale.x(8)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Scale.x(13)),
                  child: SizedBox(
                    width: Scale.x(54),
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          color: AppColors.white,
                          child: Center(
                            child: Icon(
                              Icons.text_snippet,
                              color: AppColors.navy,
                              size: Scale.x(24.0),
                            ),
                          ),
                        ),
                        if (!converted)
                          Container(
                            padding: EdgeInsets.all(Scale.x(15)),
                            color: const Color.fromARGB(255, 3, 3, 3)
                                .withAlpha(91),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.customGreen,
                                strokeWidth: Scale.x(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Center: File name and type
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Scale.x(8.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: Scale.x(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PDF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: Scale.x(13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right: Cancel icon
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(Scale.x(5.0)),
                  child: IconInkResponse(
                    icon: Icons.cancel,
                    onTap: () {
                      _attachmentsController.deleteAttachment(index);
                    },
                    color: AppColors.white,
                    size: Scale.x(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageAttachmentPreview(File file, int index, bool converted) {
    return SizedBox(
      width: Scale.x(70),
      height: Scale.x(70),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Scale.x(13)),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => showFileFullScreen(file, null, false),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: Scale.x(70),
                height: Scale.x(70),
              ),
            ),
            !converted
                ? Container(
                    width: Scale.x(70),
                    height: 70,
                    padding: EdgeInsets.all(Scale.x(23)),
                    color: const Color.fromARGB(255, 3, 3, 3).withAlpha(91),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.customGreen,
                        strokeWidth: Scale.x(4),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            Positioned(
              top: Scale.x(3),
              right: Scale.x(3),
              child: IconInkResponse(
                icon: Icons.cancel,
                onTap: () => _attachmentsController.deleteAttachment(index),
                color: AppColors.white,
                size: Scale.x(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFieldInput() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: Scale.x(3.0)),
        child: Scrollbar(
          controller: _textController.scroller,
          thumbVisibility: true,
          child: TextField(
            controller: _textController.editor,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: Scale.x(14),
            ),
            cursorColor: AppColors.navy,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 8,
            scrollController: _textController.scroller,
            decoration: InputDecoration(
              hintText: 'Ask Bridgette...',
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 145, 145, 145),
                fontSize: Scale.x(16),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(right: Scale.x(10)),
            ),
          ),
        ),
      ),
    );
  }

  Widget sendOrStopIcon(BuildContext context) {
    return Obx(() {
      final isInputEmpty = _textController.isInputEmpty.value;
      final isStreaming = _aiController.streamingResponse.value;
      final isAttachmentsEmpty = _attachmentsController.attachments.isEmpty;
      final isRecording = _sttController.preLoadRecorder.value;

      if (isInputEmpty && isAttachmentsEmpty && !isStreaming) {
        return const SizedBox.shrink();
      }

      return IconInkResponse(
        icon: isStreaming
            ? Icons.stop_circle
            : isRecording == true
                ? null
                : Icons.send,
        onTap: () {
          if (isStreaming) {
            _aiController.stopStreaming();
          } else if (isRecording) {
          } else {
            FocusScope.of(context).unfocus(); // Dismiss keyboard
            _aiController.sendMessage();
          }
        },
      );
    });
  }

  Widget _cameraIcon() {
    return IconInkResponse(
        icon: Icons.photo_camera_rounded,
        onTap: () {
          _attachmentsController.pickFromCamera();
        });
  }

  Widget _imageIcon() {
    return IconInkResponse(
        icon: Icons.panorama,
        onTap: () {
          _attachmentsController.pickImages();
        });
  }

  Widget _filesIcon() {
    return IconInkResponse(
        icon: Icons.attachment_outlined,
        onTap: () {
          _attachmentsController.pickPDFs();
        });
  }

  Widget _audioIcon() {
    return IconInkResponse(
      icon: Icons.mic,
      onTap: () {
        _sttController.toggleRecordingAudio();
      },
    );
  }

  Widget _audioRecording() {
    return Row(
      children: [
        IconInkResponse(
          icon: Icons.close,
          color: const Color.fromARGB(255, 205, 11, 11),
          onTap: () {
            _sttController.toggleRecordingAudio(cancel: true);
          },
        ),
        Obx(() => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Scale.x(2.5)),
                child: _sttController.recordingAudio.value
                    ? AudioWaveforms(
                        enableGesture: false,
                        size: Size(double.infinity, Scale.x(50.0)),
                        recorderController: _sttController.waveController!,
                        waveStyle: const WaveStyle(
                          waveColor: AppColors.navy,
                          extendWaveform: true,
                          showMiddleLine: false,
                        ),
                      )
                    : SizedBox(height: Scale.x(50)),
              ),
            )),
        Obx(() {
          final duration = _sttController.recordingDuration.value;
          final minutes =
              duration.inMinutes.remainder(60).toString().padLeft(1, '0');
          final seconds =
              duration.inSeconds.remainder(60).toString().padLeft(2, '0');
          return Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontSize: Scale.x(13),
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 50, 172, 146),
            ),
          );
        }),
        SizedBox(
          width: Scale.x(10),
        ),
        IconInkResponse(
          icon: Icons.check,
          onTap: () {
            _sttController.toggleRecordingAudio();
          },
        ),
      ],
    );
  }
}

void showFileFullScreen(dynamic file, String? type, bool fromStorage) {
  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Close button pinned to top-right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: Scale.x(10),
                  right: Scale.x(10),
                ),
                child: IconButton(
                  icon:
                      Icon(Icons.close, color: Colors.white, size: Scale.x(28)),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            // Viewer fills the rest of the space
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: Scale.x(30)),
                child: type?.toLowerCase() == 'pdf' && fromStorage == false
                    ? PDFView(
                        backgroundColor: Colors.black,
                        filePath: file.path,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        pageSnap: true,
                        nightMode: false,
                        fitPolicy: FitPolicy.BOTH,
                      )
                    : type?.toLowerCase() == 'pdf' && fromStorage
                        ? cachedNetworkPdfViewer(file)
                        : type?.toLowerCase() == 'image' && fromStorage
                            ? InteractiveViewer(
                                child: Center(child: Image.network(file)),
                              )
                            : InteractiveViewer(
                                child: Center(child: Image.file(file)),
                              ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
    barrierColor: Colors.black.withAlpha(900),
  );
}

Widget cachedNetworkPdfViewer(String url) {
  return PDF(
    backgroundColor: Colors.black,
    enableSwipe: true,
    swipeHorizontal: false,
    autoSpacing: true,
    pageFling: true,
    pageSnap: true,
    nightMode: false,
    fitPolicy: FitPolicy.BOTH,
  ).cachedFromUrl(
    url,
    placeholder: (progress) {
      return Center(
        child: Text(
          '$progress %',
          style: TextStyle(color: Colors.white, fontSize: Scale.x(14)),
        ),
      );
    },
    errorWidget: (error) {
      return Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: Scale.x(24),
        ),
      );
    },
  );
}
