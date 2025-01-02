import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuickOptions extends StatelessWidget {
  const QuickOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          label: "快捷选项",
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TooltipText(
                          text: Text(
                            appLocalizations.systemProxy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.adjustSize(-1)
                                .toLight,
                          ),
                        ),
                      ),
                      Selector<Config, bool>(
                        selector: (_, config) =>
                            config.networkProps.systemProxy,
                        builder: (_, systemProxy, __) {
                          return Switch(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: systemProxy,
                            onChanged: (value) {
                              final config = globalState.appController.config;
                              config.networkProps = config.networkProps
                                  .copyWith(systemProxy: value);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TooltipText(
                          text: Text(
                            appLocalizations.tun,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.adjustSize(-1)
                                .toLight,
                          ),
                        ),
                      ),
                      Selector<ClashConfig, bool>(
                        selector: (_, clashConfig) => clashConfig.tun.enable,
                        builder: (_, enable, __) {
                          return Switch(
                            value: enable,
                            onChanged: (value) {
                              final clashConfig =
                                  globalState.appController.clashConfig;
                              clashConfig.tun = clashConfig.tun.copyWith(
                                enable: value,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
