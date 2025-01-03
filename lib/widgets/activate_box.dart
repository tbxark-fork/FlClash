import 'package:fl_clash/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ActivateBox extends StatelessWidget {
  final Widget child;
  final bool active;

  const ActivateBox({
    super.key,
    required this.child,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ActivateState(
        active: active,
      ),
      child: Selector<ActivateState, bool>(
        builder: (_, active, child) {
          return IgnorePointer(
            ignoring: !active,
            child: child!,
          );
        },
        selector: (_, activate) => activate.active,
        child: child,
      ),
    );
  }
}
