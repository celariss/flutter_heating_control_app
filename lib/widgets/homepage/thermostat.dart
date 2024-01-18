import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heating_control_app/common/settings.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';

class Thermostat {
  static Widget heaterWidgetBuilder(Device device, void Function(String deviceName, double setpoint) onSetpoint) {
    double minValue = device.minTemperature>=0 ? device.minTemperature : Settings().minSetpoint.toDouble();
    double maxValue = device.maxTemperature>=0 ? device.maxTemperature : Settings().maxSetpoint.toDouble();
    double? activeSetpoint = ModelCtrl().getActiveSetpoint(device.name);
    bool pending = device.pendingSetpoint != null;
    bool manualMode = activeSetpoint != null && activeSetpoint != device.actualSetpoint;
    bool autoMode = activeSetpoint != null && !manualMode;
    bool showResetButton = device.isAvailable &&
        manualMode &&
        (device.pendingSetpoint == null || device.pendingSetpoint != activeSetpoint);
    Color manualColor = AppTheme().heaterWidgetManuelStateColor;
    Color autoColor = AppTheme().heaterWidgetAutoStateColor;
    Color normalColor = AppTheme().heaterWidgetNoScheduleStateColor;
    Color titleColor = AppTheme().heaterWidgetTitleColor;
    bool bActive = device.actualSetpoint > 0.0 && device.currentTemperature > 0.0;

    List<Widget> createFirstLine() {
      List<Widget> line = [];
      if (!bActive || (!manualMode && !autoMode && !showResetButton && device.isAvailable)) {
        line.add(const Spacer());
      } else {
        line.add(manualMode
            ? Icon(Common.getManualModeIconData(), color: manualColor)
            : autoMode
                ? Icon(Icons.brightness_auto_rounded, color: autoColor)
                : const Spacer());
        line.add(const Spacer());
        if (showResetButton) {
          line.add(Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Common.createCircleIconButton(Icons.replay, iconSize: 10, onPressed: () {
              onSetpoint(device.name, activeSetpoint);
            }),
          ]));
          line.add(const Spacer());
          line.add(const Spacer());
        } else if (!device.isAvailable) {
          line.add(Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(Icons.warning, color: AppTheme().warningColor, size: 38)]));
          line.add(const Spacer());
          line.add(const Spacer());
        }
      }
      return line;
    }

    return Column(children: [
      Text(device.name, style: TextStyle(fontSize: 16, color: titleColor, fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      SleekCircularSlider(
        innerWidget: (value) {
          if (!bActive) {
            return const SizedBox(height: 10);
          }
          return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(
                height: 45,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: createFirstLine())),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: device.isAvailable
                    ? [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.keyboard_double_arrow_left, color: AppTheme().focusColor),
                          onPressed: () {
                            double newValue = floor(value - Settings().thermostatResolution, Settings().thermostatResolution, minValue:minValue, maxValue:maxValue);
                            if (newValue != value) {
                              onSetpoint(device.name, newValue);
                            }
                          },
                        ),
                        Text('${min(maxValue, max(minValue, value)).toStringAsFixed(1)}°',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.keyboard_double_arrow_right, color: AppTheme().focusColor),
                          onPressed: () {
                            double newValue = floor(value + Settings().thermostatResolution, Settings().thermostatResolution, minValue:minValue, maxValue:maxValue);
                            if (newValue != value) {
                              onSetpoint(device.name, newValue);
                            }
                          },
                        ),
                      ]
                    : [
                        Text('${min(maxValue, max(minValue, value)).toStringAsFixed(1)}°',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ]),
            Text('(${device.currentTemperature.toStringAsFixed(1)}°)',
                style: TextStyle(fontSize: 22, color: AppTheme().specialTextColor)),
          ]);
        },
        appearance: CircularSliderAppearance(
          animationEnabled: false,
          customColors: CustomSliderColors(
            progressBarColors: null,
            progressBarColor: !bActive
                ? AppTheme().background1Color
                : pending
                    ? AppTheme().heaterWidgetPendingStateColor
                    : manualMode
                        ? manualColor
                        : autoMode
                            ? autoColor
                            : normalColor,
            trackColor: bActive ? AppTheme().heaterWidgetTrackColor : AppTheme().background1Color,
          ),
          customWidths: CustomSliderWidths(progressBarWidth: 10, handlerSize: 5),
          /*infoProperties: InfoProperties(
              topLabelText: device.name,
              bottomLabelText: '(${device.currentTemperature.toStringAsFixed(1)}°)',
              bottomLabelStyle: const TextStyle(color: Colors.black),
              modifier: (double value) {
                return '${min(maxValue, max(minValue, value)).toStringAsFixed(1)} °';
              },
            )*/
        ),
        min: minValue,
        max: maxValue,
        initialValue: min(maxValue, max(minValue, device.pendingSetpoint ?? device.actualSetpoint)),
        /*onChangeEnd: (double value) {
          setState(() => ModelCtrl().setDeviceSetpoint(device.name, value));
        },*/
      )
    ]);
  }
}

