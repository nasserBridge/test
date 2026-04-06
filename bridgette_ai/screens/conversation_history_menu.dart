import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/repositories/history_repo.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConversationHistoryMenu extends StatefulWidget {
  const ConversationHistoryMenu({
    super.key,
  });

  @override
  State<ConversationHistoryMenu> createState() =>
      _ConversationHistoryMenuState();
}

class _ConversationHistoryMenuState extends State<ConversationHistoryMenu> {
  final _repo = Get.put(HistoryRepository());
  final _controller = Get.put(AIController());

  @override
  void initState() {
    super.initState();
    _repo.retrieveConversationHistory();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _newConversationPreview(context),
              Expanded(
                child: _repo.errorOccurred.value
                    ? _tryAgain()
                    : _repo.conversationHistoryLoading.value &&
                            _repo.conversationHistory.isEmpty
                        ? _loading()
                        : _conversationHistory(context),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _newConversationPreview(BuildContext context) {
    return Obx(() => Padding(
          padding: EdgeInsets.only(
            top: Scale.x(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _controller.clearActiveConversation();
                    //delay a bit to ensure the conversation is set before closing the drawer
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      Scale.x(12),
                      Scale.x(0),
                      Scale.x(12),
                      Scale.x(0),
                    ),
                    decoration: _controller.conversationId.value == null
                        ? BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(Scale.x(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(76),
                                spreadRadius: Scale.x(1),
                                blurRadius: Scale.x(3),
                                offset: Offset(Scale.x(0), Scale.x(1)),
                              ),
                            ],
                          )
                        : null,
                    child: ListTile(
                      title: Text(
                        'New Conversation',
                        style: TextStyle(
                          fontSize: Scale.x(FontSizes.statements),
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.edit_note,
                        size: Scale.x(30),
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _loading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Scale.x(20)),
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Widget _tryAgain() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _repo.retrieveConversationHistory();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.refresh, size: Scale.x(27), color: AppColors.darkerGrey),
          SizedBox(height: Scale.x(5)),
          Text(
            'Try Again',
            style: TextStyle(
              fontSize: Scale.x(14),
              color: AppColors.darkerGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationHistory(BuildContext context) {
    return Obx(() => ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final groupEntry in _repo.conversationHistory.entries)
              if ((groupEntry.value as Map<String, dynamic>).isNotEmpty) ...[
                _lastUpdatedHeader(groupEntry.key),
                if (groupEntry.key == 'Today') _buildPlaceholders(),
                ...((groupEntry.value as Map<String, dynamic>)
                    .entries
                    .map((entry) => _conversationPreview(entry, context))),
                SizedBox(height: Scale.x(10)),
                Divider(
                  thickness: Scale.x(.25),
                  color: Color.fromARGB(255, 103, 103, 103),
                  height: Scale.x(0),
                ),
              ],
          ],
        ));
  }

  Widget _lastUpdatedHeader(String lastUpdated) {
    return Padding(
      padding: EdgeInsets.only(
          top: Scale.x(15), left: Scale.x(20), bottom: Scale.x(5)),
      child: Text(
        lastUpdated,
        style: TextStyle(
          fontSize: Scale.x(14),
          color: const Color.fromARGB(255, 56, 56, 56),
        ),
      ),
    );
  }

  Widget _buildPlaceholders() {
    return Obx(() {
      return Column(
        children: List.generate(
          _repo.newConversationCount.value,
          (index) {
            return Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    Scale.x(12), Scale.x(0), Scale.x(12), Scale.x(0)),
                decoration:
                    index == 0 && _controller.conversationId.value != null
                        ? BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(Scale.x(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(76),
                                spreadRadius: Scale.x(1),
                                blurRadius: Scale.x(3),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          )
                        : null,
                child: ListTile(
                  title: Text(
                    ' ',
                    style: TextStyle(
                      fontSize: Scale.x(15),
                      color: Color.fromARGB(255, 35, 175, 145),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _conversationPreview(MapEntry<String, dynamic> conversation, context) {
    final key = GlobalKey();
    final title = conversation.value['title'] ?? 'Untitled';

    return Obx(() {
      final isDeleting =
          _repo.deletedConversationId.value == conversation.key &&
              _repo.conversationIsDeleted.value == true;
      final isActive = _controller.conversationId.value == conversation.key;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: () {
            HapticFeedback.lightImpact();
            _controller.setAsActiveConversation(conversation);
            //delay a bit to ensure the conversation is set before closing the drawer
            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.of(context).pop();
            });
          },
          onLongPress: () async {
            HapticFeedback.lightImpact();
            final RenderBox renderBox =
                key.currentContext!.findRenderObject() as RenderBox;
            final Offset position = renderBox.localToGlobal(Offset.zero);
            final Size size = renderBox.size;
            await _showDeletePopupMenu(context, conversation, position, size);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(
              Scale.x(12),
              Scale.x(0),
              Scale.x(12),
              Scale.x(0),
            ),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(Scale.x(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
                        spreadRadius: Scale.x(1),
                        blurRadius: Scale.x(3),
                        offset: Offset(Scale.x(0), Scale.x(1)),
                      ),
                    ],
                  )
                : null,
            child: ListTile(
              title: isDeleting
                  ? SizedBox(
                      height: Scale.x(18),
                      width: Scale.x(18),
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        fontSize: Scale.x(15),
                        color: Color.fromARGB(255, 35, 175, 145),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showDeletePopupMenu(
    BuildContext context,
    MapEntry<String, dynamic> conversation,
    Offset position,
    Size size,
  ) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + size.width, // shift to the right
        position.dy,
        position.dx,
        position.dy + size.height,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(
                color: Color.fromARGB(255, 146, 33, 33), fontSize: Scale.x(14)),
          ),
        ),
        PopupMenuItem(
          value: 'cancel',
          child: Text('Cancel',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: Scale.x(14),
              )),
        ),
      ],
      color: Colors.white,
    );

    if (result == 'delete') {
      try {
        final String? currentConversationId = _controller.conversationId.value;
        await _repo.deleteConversation(conversation.key, currentConversationId,
            conversation.value['attachment_paths']);
      } catch (e, stackTrace) {
        // Log error with context for debugging and crash reporting.

        LogUtil.error('Error deleting conversation',
            error: e, stackTrace: stackTrace);
      }
    }
  }
}
