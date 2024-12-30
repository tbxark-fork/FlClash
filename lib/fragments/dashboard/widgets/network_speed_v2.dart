import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkSpeed extends StatefulWidget {
  const NetworkSpeed({super.key});

  @override
  State<NetworkSpeed> createState() => _NetworkSpeedState();
}

class _NetworkSpeedState extends State<NetworkSpeed> {
  List<Point> initPoints = const [Point(0, 0), Point(1, 0)];

  List<Point> _getPoints(List<Traffic> traffics) {
    List<Point> trafficPoints = traffics
        .toList()
        .asMap()
        .map(
          (index, e) => MapEntry(
        index,
        Point(
          (index + initPoints.length).toDouble(),
          e.speed.toDouble(),
        ),
      ),
    )
        .values
        .toList();

    return [...initPoints, ...trafficPoints];
  }

  Traffic _getLastTraffic(List<Traffic> traffics) {
    if (traffics.isEmpty) return Traffic();
    return traffics.last;
  }

  Widget _getLabel({
    required String label,
    required IconData iconData,
    required TrafficValue value,
  }) {
    final showValue = value.showValue;
    final showUnit = "${value.showUnit}/s";
    final titleLargeSoftBold =
        Theme.of(context).textTheme.titleLarge?.toSoftBold;
    final bodyMedium = Theme.of(context).textTheme.bodySmall?.toLight;
    final valueText = Text(
      showValue,
      style: titleLargeSoftBold,
      maxLines: 1,
    );
    final unitText = Text(
      showUnit,
      style: bodyMedium,
      maxLines: 1,
    );
    final size = globalState.measure.computeTextSize(valueText);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
        ),
        SizedBox(
          width: 8,
        ),
        Flexible(
          child: valueText,
        ),
        SizedBox(
          width: 4,
        ),
        Flexible(
          child: unitText,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: 20,
      type: CommonCardType.filled,
      color: context.colorScheme.secondaryContainer,
      // onPressed: () {},
      child: Selector<AppFlowingState, List<Traffic>>(
        selector: (_, appFlowingState) => appFlowingState.traffics,
        builder: (_, traffics, __) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: baseInfoEdgeInsets,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CircularProgressIndicator(
                          value: 0.1,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 8,
                          backgroundColor: context.colorScheme.primary.toSoft(),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      Text(
                        "上传 100MB",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "下载 100MB",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CommonCard(
                        type: CommonCardType.filled,
                        color: context.colorScheme.surfaceContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: LineChart(
                            color: Theme.of(context).colorScheme.primary,
                            points: _getPoints(traffics),
                            height: 100,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      CommonCard(
                        onPressed: () {},
                        type: CommonCardType.filled,
                        color: context.colorScheme.surfaceContainer,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                flex: 1,
                                child: _getLabel(
                                  iconData: Icons.upload,
                                  label: appLocalizations.upload,
                                  value: _getLastTraffic(traffics).up,
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: _getLabel(
                                  iconData: Icons.download,
                                  label: appLocalizations.download,
                                  value: _getLastTraffic(traffics).down,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
