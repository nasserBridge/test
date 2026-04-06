import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/bridgette_ai/ai_header.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/screens/conversation_history_menu.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/repositories/history_repo.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/screen_scroll_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/bridgette_ai/send_message_navbar.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/bridgette_ai/thinking_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/ai_controller.dart';
import 'dart:io';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class BridgetteAI extends StatefulWidget {
  final GlobalKey mainNavBarKey;

  const BridgetteAI({
    super.key,
    required this.mainNavBarKey,
  });

  @override
  State<BridgetteAI> createState() => _BridgetteAIState();
}

class _BridgetteAIState extends State<BridgetteAI> with WidgetsBindingObserver {
  final _controller = Get.put(AIController());
  final _repo = Get.put(HistoryRepository());
  final _scrollController = Get.put(ScreenScrollController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _bottomNavKey = GlobalKey();
  final GlobalKey _appBarKey = GlobalKey();
  double dynamicHeight = Scale.x(
      298); // Default height to accommodate app bar, bottom nav, and main nav

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final navBarHeight = _bottomNavKey.currentContext!.size!.height;
        final appBarHeight = _appBarKey.currentContext!.size!.height;
        final mainNavHeight = widget.mainNavBarKey.currentContext!.size!.height;
        dynamicHeight = appBarHeight + navBarHeight + mainNavHeight;
      });
    });
  }

  @override
  void dispose() {
    _controller.manuallyDispose();
    _scrollController.manuallyDispose();
    _repo.manuallyDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gestureDetector = GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), // Dismiss the keyboard when tapping outside
      child: Scaffold(
        key:
            _scaffoldKey, // Optional if you need to control drawer programmatically
        onDrawerChanged: (isOpened) {
          if (!isOpened) {
            HapticFeedback
                .lightImpact(); // *immediately* when drawer begins closing
          }
        },
        backgroundColor: AppColors.customGreen,
        appBar: AIHeaderBar(key: _appBarKey),
        drawer: const ConversationHistoryMenu(),
        drawerEnableOpenDragGesture: false, // 👈 disables swipe-to-open
        body: _bodyAI(context),
        bottomNavigationBar: SendMessageNavBar(key: _bottomNavKey),
      ),
    );
    return gestureDetector;
  }

  SafeArea _bodyAI(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController.conversationScrollController,
                child: SingleChildScrollView(
                  controller: _scrollController.conversationScrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildConversationHistory(),
                      _currentQueryAndResponse(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Move this above everything in the stack
        aiIntroText(),
        scrollToBottomIcon(),
      ],
    ));
  }

  Widget _buildConversationHistory() {
    return Obx(() {
      return Column(
        children: _controller.activeMessages.expand<Widget>((msg) {
          if (msg['type'] == 'HumanMessage') {
            return [
              _usersQuery(msg),
            ];
          } else if (msg['type'] == 'AIMessage') {
            return [
              _buildStaticAIText(msg['text'], false, null),
            ];
          } else {
            return [const SizedBox.shrink()];
          }
        }).toList(),
      );
    });
  }

  Widget _usersQuery(Map<String, dynamic> msg) {
    final text = msg.containsKey('text') ? msg['text'] : null;
    List attachments = msg['attachments'];

    return Padding(
      padding: EdgeInsets.only(bottom: Scale.x(10)),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _attachmentsRow(attachments),
              _buildChatBubble(text),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticAIText(
      String text, bool textFromStream, bool? isStreaming) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Scale.x(30), vertical: Scale.x(20)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: text,
              selectable: true, // Allows users to select and copy text
              styleSheet: MarkdownStyleSheet(
                // Normal paragraph text
                p: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(18),
                  fontWeight: FontWeight.w500,
                  height: 1.5, // Line height for readability
                ),
                // Bold text (from **text**)
                strong: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(18),
                  fontWeight: FontWeight.bold,
                ),
                // Italic text (from *text*)
                em: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(18),
                  fontStyle: FontStyle.italic,
                ),
                // Bullet points
                listBullet: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(18),
                ),
                // Headers (if AI uses them)
                h1: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(24),
                  fontWeight: FontWeight.bold,
                ),
                h2: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(22),
                  fontWeight: FontWeight.bold,
                ),
                h3: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: Scale.x(10)),
            textFromStream == false ||
                    (textFromStream == true && isStreaming == false)
                ? IconInkResponse(
                    icon: Icons.filter_none,
                    size: Scale.x(18),
                    onTap: () async {
                      copyText(text);
                    },
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Obx aiIntroText() {
    return Obx(() {
      if (_controller.activeMessages.isEmpty &&
          _controller.currentMessage.isEmpty) {
        return IgnorePointer(
          child: Align(
            alignment: Alignment(0, Scale.x(-0.4)), // -1 is top, 0 is center
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Scale.x(70)),
              child: Text(
                'Say "Hello" to Bridgette AI, your personal banker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: Scale.x(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget scrollToBottomIcon() {
    return Obx(() {
      final show = _scrollController.showScrollToBottomIcon.value;

      return Positioned(
        bottom: 5,
        left: 0,
        right: 0,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: show ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 400),
              scale: show ? 1.0 : 0.0,
              alignment: Alignment.bottomCenter,
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: IconInkResponse(
                  icon: Icons.keyboard_arrow_down,
                  size: Scale.x(25),
                  onTap: () => _scrollController.scrollToBottomAnimated(),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget animatedAIReponse() {
    return Obx(() {
      final text = _controller.visibleAIResponse.value;
      final isStreaming = _controller.streamingResponse.value;

      if (text.isEmpty) return const SizedBox.shrink();

      return _buildStaticAIText(text, true, isStreaming);
    });
  }

  Widget _currentQueryAndResponse() {
    return Obx(() {
      final msg = Map<String, dynamic>.from(_controller.currentMessage);
      if (msg.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        // min hight excludes app bar and bottom nav bar
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - dynamicHeight),
        child: Column(
          children: [
            _usersQuery(msg),
            animatedAIReponse(),
            ThinkingIndicator(),
            _retryConnection()
          ],
        ),
      );
    });
  }

  Obx _retryConnection() {
    return Obx(() => _controller.webSocketError.value == false
        ? SizedBox.shrink()
        : Container(
            margin: EdgeInsets.fromLTRB(
                Scale.x(30), Scale.x(10), Scale.x(30), Scale.x(10)),
            padding: EdgeInsets.fromLTRB(
                Scale.x(10), Scale.x(10), Scale.x(10), Scale.x(10)),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.navy, width: Scale.x(.65)),
              borderRadius: BorderRadius.circular(Scale.x(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'An error occured',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    letterSpacing: Scale.x(.5),
                    fontSize: Scale.x(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _controller.retrySendMessage();
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: Scale.x(5)),
                      padding: EdgeInsets.symmetric(vertical: Scale.x(10)),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(Scale.x(15)),
                      ),
                      width: double.infinity,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          letterSpacing: Scale.x(.5),
                          fontSize: Scale.x(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      )),
                )
              ],
            ),
          ));
  }

  Widget _buildChatBubble(String? text) {
    if (text == null) {
      return SizedBox(height: Scale.x(0));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onLongPressStart: (details) async {
        HapticFeedback.heavyImpact();

        final selected = await showMenu<String>(
            context: Get.context!,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx -
                  Scale.x(120), // Shift it left just enough
              details.globalPosition.dy + Scale.x(10), // Drop it slightly below
              details.globalPosition.dx,
              0,
            ),
            items: [
              buildPopupMenuItem(label: 'Copy', icon: Icons.filter_none),
              // PopupMenuItem(
              //     height: 1,
              //     padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              //     child: Container(
              //       height: .25,
              //       color: AppColors.grey,
              //     )),
              //buildPopupMenuItem(label: 'Edit', icon: Icons.edit)
            ],
            elevation: Scale.x(8.0),
            color: AppColors.darkerGrey);

        if (selected == 'copy') {
          copyText(text);
        } else if (selected == 'edit') {
          //insert edit logic here
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
          margin: EdgeInsets.fromLTRB(
              Scale.x(0), Scale.x(0), Scale.x(30), Scale.x(0)),
          padding: EdgeInsets.all(Scale.x(15)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Scale.x(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(76),
                spreadRadius: Scale.x(5),
                blurRadius: Scale.x(7),
                offset: Offset(Scale.x(0), Scale.x(3)),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: Scale.x(18),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> buildPopupMenuItem({
    required String label,
    required IconData icon,
  }) {
    return PopupMenuItem<String>(
      height: Scale.x(25),
      value: label.toLowerCase(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Scale.x(25)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: Scale.x(14),
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              color: Colors.white,
              size: Scale.x(18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentsRow(List attachments) {
    if (attachments.isEmpty) {
      return SizedBox(height: Scale.x(20));
    }

    return Container(
      margin: EdgeInsets.only(
          top: Scale.x(20), right: Scale.x(30), bottom: Scale.x(10)),
      width: double.infinity,
      alignment: Alignment.topRight,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.end,
        spacing: Scale.x(4.0),
        runSpacing: Scale.x(4.0),
        children: List.generate(attachments.length, (index) {
          final attachment = attachments[index];
          final type = attachment['type'] as String;

          return type == 'pdf'
              ? _fileAttachmentPreview(attachment, index)
              : _imageAttachmentPreview(attachment, index);
        }),
      ),
    );
  }

  Obx _imageAttachmentPreview(Map<String, dynamic> attachment, int index) {
    return Obx(() {
      final attachments = _controller.conversationAttachments;
      for (final map in attachments!) {
        if (map['path'] == attachment['path']) {
          attachment = map;
        }
      }
      return SizedBox(
        width: Scale.x(120),
        height: Scale.x(120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Scale.x(13)),
          child: attachment['error'] == true
              ? GestureDetector(
                  onTap: () {
                    _controller.loadAttachments();
                  },
                  child: Container(
                    padding: EdgeInsets.all(Scale.x(23)),
                    color: const Color.fromARGB(255, 3, 3, 3).withAlpha(91),
                    child: Center(
                      child: Icon(
                        Icons.error,
                        size: Scale.x(24),
                        color: AppColors.customGreen,
                      ),
                    ),
                  ),
                )
              : attachment['fromStorage']
                  ? _storageImage(attachment)
                  : GestureDetector(
                      onTap: () {
                        final file = attachment['file'] as File;
                        showFileFullScreen(file, 'image', false);
                      },
                      child: Image.file(
                        attachment['file'] as File,
                        fit: BoxFit.cover,
                      ),
                    ),
        ),
      );
    });
  }

  Widget _storageImage(Map<String, dynamic> attachment) {
    return attachment['loaded'] == false
        ? Container(
            padding: EdgeInsets.all(Scale.x(23)),
            color: const Color.fromARGB(255, 3, 3, 3).withAlpha(91),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.customGreen,
                strokeWidth: Scale.x(4),
              ),
            ),
          )
        : GestureDetector(
            onTap: () => showFileFullScreen(attachment['file'], 'image', true),
            child: Image.network(
              attachment['file'],
              fit: BoxFit.cover,
            ),
          );
  }

  Obx _fileAttachmentPreview(Map<String, dynamic> attachment, int index) {
    return Obx(() {
      final attachments = _controller.conversationAttachments;

      // Reassign attachment to its latest reactive version
      for (final map in attachments!) {
        if (map['path'] == attachment['path']) {
          attachment = map;
          break;
        }
      }

      final isLoading =
          attachment['fromStorage'] == true && attachment['loaded'] == false;
      final hasError = attachment['error'] == true;
      final file = attachment['file'];

      return GestureDetector(
        onTap: hasError
            ? () =>
                _controller.loadAttachments() // same retry behavior as image
            : isLoading
                ? null
                : () =>
                    showFileFullScreen(file, 'pdf', attachment['fromStorage']),
        child: Container(
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
                _buildFileIcon(isLoading: isLoading, hasError: hasError),
                _buildFileInfo(attachment),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFileIcon({required bool isLoading, required bool hasError}) {
    Widget iconContent;
    if (hasError) {
      iconContent =
          Icon(Icons.error, color: AppColors.customGreen, size: Scale.x(24));
    } else {
      iconContent =
          Icon(Icons.text_snippet, color: AppColors.navy, size: Scale.x(24));
    }

    return Padding(
      padding: EdgeInsets.all(Scale.x(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Scale.x(13)),
        child: SizedBox(
          width: Scale.x(54),
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                color: hasError
                    ? Color.fromARGB(255, 3, 3, 3).withAlpha(91)
                    : AppColors.white,
                child: Center(child: iconContent),
              ),
              if (isLoading)
                Container(
                  padding: EdgeInsets.all(Scale.x(15)),
                  color: const Color.fromARGB(255, 3, 3, 3).withAlpha(91),
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
    );
  }

  Widget _buildFileInfo(Map<String, dynamic> attachment) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Scale.x(8.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attachment['name'],
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
    );
  }

  void copyText(String text) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));
    // Optional: Show feedback
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withAlpha(900),
      colorText: Colors.white,
      margin: EdgeInsets.all(Scale.x(12)),
      padding:
          EdgeInsets.symmetric(horizontal: Scale.x(16), vertical: Scale.x(10)),
      titleText: Text(
        'Copied',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: Scale.x(14),
          color: Colors.white,
        ),
      ),
      messageText: Text(
        'Text copied to clipboard',
        style: TextStyle(
          fontSize: Scale.x(12),
          color: Colors.white70,
        ),
      ),
      duration: const Duration(milliseconds: 1000), // 👈 stays for 1.5 seconds
      isDismissible: false, // allow swipe
    );
  }
}
