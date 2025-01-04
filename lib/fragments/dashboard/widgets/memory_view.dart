import 'dart:async';
import 'dart:math';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

final _MemoryInfoStateNotifier =
    ValueNotifier<TrafficValue>(TrafficValue(value: 0));

class MemoryInfo extends StatefulWidget {
  const MemoryInfo({super.key});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _updateMemoryData(int maxLength) {
    timer = Timer(Duration(seconds: 1), () async {
      final memory = await clashCore.getMemory();
      _MemoryInfoStateNotifier.value = TrafficValue(value: memory);
      _updateMemoryData(maxLength);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(2),
      child: LayoutBuilder(
        builder: (_, container) {
          final maxLength = max((container.maxWidth / 30).floor(), 5);
          timer?.cancel();
          _updateMemoryData(maxLength);
          return CommonCard(
            info: Info(
              iconData: Icons.memory,
              label: appLocalizations.memoryInfo,
            ),
            onPressed: () {},
            child: ValueListenableBuilder(
              valueListenable: _MemoryInfoStateNotifier,
              builder: (_, trafficValue, __) {
                return Column(
                  children: [
                    Padding(
                      padding: baseInfoEdgeInsets.copyWith(
                        bottom: 0,
                        top: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            trafficValue.showValue,
                            style: context.textTheme.titleLarge,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            trafficValue.showUnit,
                            style: context.textTheme.titleLarge,
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WaveView(
                              waveAmplitude: 12.0,
                              waveFrequency: 0.35,
                              waveColor:
                                  context.colorScheme.secondary.toLight(),
                            ),
                          ),
                          Positioned.fill(
                            child: WaveView(
                              waveAmplitude: 12.0,
                              waveFrequency: 0.9,
                              waveColor: context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
