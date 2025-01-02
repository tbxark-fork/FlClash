import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key});

  Widget getTrafficDataItem(
    BuildContext context,
    IconData iconData,
    TrafficValue trafficValue,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                iconData,
                size: 14,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                flex: 1,
                child: Text(
                  trafficValue.showValue,
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          trafficValue.showUnit,
          style: context.textTheme.bodySmall?.toLighter,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard.info(
        info: Info(
          label: appLocalizations.trafficUsage,
          iconData: Icons.data_saver_off,
        ),
        onPressed: () {},
        child: Selector<AppFlowingState, Traffic>(
          selector: (_, appFlowingState) => appFlowingState.totalTraffic,
          builder: (_, totalTraffic, __) {
            final upTotalTrafficValue = totalTraffic.up;
            final downTotalTrafficValue = totalTraffic.down;
            return Padding(
              padding: baseInfoEdgeInsets.copyWith(
                top: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: SizedBox(),
                  ),
                  getTrafficDataItem(
                    context,
                    Icons.arrow_upward,
                    upTotalTrafficValue,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  getTrafficDataItem(
                    context,
                    Icons.arrow_downward,
                    downTotalTrafficValue,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
