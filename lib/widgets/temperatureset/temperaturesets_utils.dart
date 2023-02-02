import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import 'temperatureset.dart';

class TemperatureSetsUtils {
  static Future<void> pickTemperatureSet(BuildContext context, String scheduleName, String defaultTempSetName,
      {required void Function(String selTempSet)? onValidate}) async {
    // TBD : concatenate tempsets from schedule and from global context
    List tempSet = ModelCtrl().getTemperatureSets('');
    String selectedAlias = defaultTempSetName;
    await Common.showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: "Sélection d'un jeu de température",
        onValidate: () => onValidate!(selectedAlias),
        content: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: tempSet.map((tempSetData) {
              return RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.all(0),
                value: tempSetData['alias'],
                dense: true,
                groupValue: selectedAlias,
                title: TemperatureSet.temperatureSetTileBuilder(context, tempSetData, scheduleName,
                    dense: true, titleColor: (selectedAlias == tempSetData['alias']) ? AppTheme().normalTextColor : AppTheme().specialTextColor) ,
                onChanged: (selected) {
                  setState(() {
                    selectedAlias = selected;
                  });
                },
                selected: tempSetData['alias'] == selectedAlias,
                activeColor: AppTheme().normalTextColor,
              );
            }).toList(),
          );
        }));
  }
}
