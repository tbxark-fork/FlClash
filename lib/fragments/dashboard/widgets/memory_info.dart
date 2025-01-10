import 'dart:async';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

final _memoryInfoStateNotifier =
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
    clashCore.getMemory().then((memory) {
      _memoryInfoStateNotifier.value = TrafficValue(value: memory);
    });
    _updateMemoryData();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _updateMemoryData() {
    timer = Timer(Duration(seconds: 2), () async {
      final memory = await clashCore.getMemory();
      _memoryInfoStateNotifier.value = TrafficValue(value: memory);
      _updateMemoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          iconData: Icons.memory,
          label: appLocalizations.memoryInfo,
        ),
        onPressed: () {
          clashCore.requestGc();
        },
        child: ValueListenableBuilder(
          valueListenable: _memoryInfoStateNotifier,
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
                        style: context.textTheme.titleLarge?.toLight,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        trafficValue.showUnit,
                        style: context.textTheme.titleLarge?.toLight,
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
                          waveColor: context.colorScheme.secondaryContainer
                              .blendDarken(context, factor: 0.1)
                              .toLighter,
                        ),
                      ),
                      Positioned.fill(
                        child: WaveView(
                          waveAmplitude: 12.0,
                          waveFrequency: 0.9,
                          waveColor: context.colorScheme.secondaryContainer
                              .blendDarken(context, factor: 0.1),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
