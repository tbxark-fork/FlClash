import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class MessageManager extends StatefulWidget {
  final Widget child;

  const MessageManager({
    super.key,
    required this.child,
  });

  @override
  State<MessageManager> createState() => MessageManagerState();
}

class MessageManagerState extends State<MessageManager>
    with SingleTickerProviderStateMixin {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: commonDuration,
    );
  }

  message(
    String text, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final commonMessage = CommonMessage(id: other.uuidV4, text: text);
    _messagesNotifier.value = List.from(_messagesNotifier.value)
      ..add(commonMessage);
    Future.delayed(duration, () {
      _messagesNotifier.value = List.from(_messagesNotifier.value)
        ..remove(commonMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        LayoutBuilder(
          builder: (context, container) {
            return SizedBox(
              width: container.maxWidth / 2 + 16,
              child: ValueListenableBuilder(
                valueListenable: globalState.safeMessageOffsetNotifier,
                builder: (_, offset, child) {
                  if (offset == Offset.zero) {
                    return SizedBox();
                  }
                  return Transform.translate(
                    offset: offset,
                    child: child!,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: ValueListenableBuilder(
                      valueListenable: _messagesNotifier,
                      builder: (_, messages, ___) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            for (final message in messages)
                              Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(8),
                                color: context.colorScheme.surfaceContainer,
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    message.text,
                                    style: context.textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
