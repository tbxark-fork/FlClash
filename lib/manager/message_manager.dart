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

class MessageManagerState extends State<MessageManager> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // ValueListenableBuilder(
        //   valueListenable: globalState.safeMessageOffsetNotifier,
        //   builder: (_, offset, child) {
        //     return Transform.translate(
        //       offset: offset,
        //       child: child!,
        //     );
        //   },
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Card(
        //         child: Text(
        //           "123132",
        //         ),
        //       ),
        //       Card(
        //         child: Text(
        //           "123132",
        //         ),
        //       ),
        //       Card(
        //         child: Text(
        //           "123132",
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
