import 'package:flutter/material.dart';
import 'package:heating_control_app/common/common.dart';

class SettingsWidgetHelper {

  static Widget createSection(String title, List<Widget> children, BuildContext context) {
    /// Creates a settings section with a title and containinga list of children widgets.
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget createFieldsGroup(String title, List<Widget> children) {
    /// Creates a group of fields with a title and containing a list of children widgets.
    /// The aim is to visually group fields by category within a settings section.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[...children,],
          ),
        )
      ),
    );
  }

  static Widget createTextField(String text, {bool enabled=true}) {
    /// Creates a simple text field with the given text.
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter localSetState) {
        ThemeData theme = Theme.of(context);
        return Padding(
          padding:  const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.apply(
              color: enabled ? theme.textTheme.titleMedium?.color : theme.colorScheme.onSurface.withValues(alpha: 0.38)
            ),
          ),
        );
      }
    );
  }

  static Widget createBtnField(String text, IconData icon, VoidCallback onPressed, {bool enabled=true}) {
    /// Creates a button field with the given text, icon, and onPressed callback.
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter localSetState) {
        ThemeData theme = Theme.of(context);
        return Padding(
          padding:  const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                text,
                style: theme.textTheme.titleMedium?.apply(
                  color: enabled ? theme.textTheme.titleMedium?.color : theme.colorScheme.onSurface.withValues(alpha: 0.38)
                ),
              ),
              Expanded(child: Container()), // Spacer to push the button to the right
              Common.createCircleIconButton(
                icon,
                iconSize: 50,
                enabled: enabled,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                onPressed: onPressed,
              ),
            ]
          ),
        );
      }
    );
  }

  static Widget createTextFormField(
    /// Creates a editable text form field with the given label, initial value, and onChanged callback.
    /// The field can be enabled or disabled, and can be marked as mandatory (non empty) with a custom error message.
    /// The optional validator function can be provided to perform additional validation on the input value.
    String label,
    String initialValue,
    void Function(String) onChanged,
    { bool enabled = true,
      bool mandatory = false,
      String? requiredErrorText,
      String? Function(String?)? validator}
  ) {
    return TextFormField(
      //key: key,
      enabled: enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: initialValue,
      maxLength: 32,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        String? validationResult;
        if (mandatory && (value == null || value.isEmpty)) {
          validationResult = requiredErrorText ?? "This field is required";
        }
        else if (value != null && value.isNotEmpty && validator != null) {
            validationResult = validator(value);
        }
        if (validationResult != null) {
          if (enabled) {
            onChanged(initialValue); // Reset to initial value if validation fails
          }
        }
        return validationResult;
      },
      onChanged: (value) => onChanged(value),
    );
  }

  static Widget createPasswordFormField(
    /// Creates a editable confidential text form field with the given label, initial value, and onChanged callback.
    /// The field is obscured by default, and can be toggled to show/hide the password using a icon button.
    /// The field can be enabled or disabled, and can be marked as mandatory (non empty) with a custom error message.
    /// The optional validator function can be provided to perform additional validation on the input value.
    String label,
    String initialValue,
    void Function(String) onChanged,
    { bool enabled = true,
      bool mandatory = false,
      String? requiredErrorText,
      String? showHideTooltip,
      String? Function(String?)? validator}
  ) {
    bool obscureMqttPassword = true; // Local state to control
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter localSetState) {
        return TextFormField(
          //key: key,
          enabled: enabled,
          obscureText: obscureMqttPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: initialValue,
          maxLength: 32,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              tooltip: showHideTooltip ?? "Show/hide password",
              icon: Icon(obscureMqttPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => {
                localSetState(() {
                  obscureMqttPassword = !obscureMqttPassword;
                })
              },
            ),
          ),
          validator: (value) {
            String? validationResult;
            if (mandatory && (value == null || value.isEmpty)) {
              validationResult = requiredErrorText ?? "This field is required";
            }
            else if (value != null && value.isNotEmpty && validator != null) {
                validationResult = validator(value);
            }
            if (validationResult != null) {
              if (enabled) {
                onChanged(initialValue); // Reset to initial value if validation fails
              }
            }
            return validationResult;
          },
          onChanged: (value) => onChanged(value),
        );
      }
    );
  }

  static Widget createIntFormField(
    /// Creates a editable integer form field with the given label, initial value, and onChanged callback.
    /// The field can be enabled or disabled, and can be marked as mandatory (non empty) with a custom error message "requiredErrorText".
    /// The parameter "errorText" can be used to provide a custom error message for invalid integer input. 
    /// The optional validator function can be provided to perform additional validation on the input value.
    String label,
    int initialValue,
    void Function(int) onChanged,
    { bool enabled = true,
      bool mandatory = false,
      String? requiredErrorText,
      String? errorText,
      String? Function(int)? validator}
  ) {
    return TextFormField(
      //key: GlobalKey<FormState>(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: enabled,
      initialValue: initialValue.toString(),
      maxLength: 32,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        String? validationResult;
        if (mandatory && (value == null || value.isEmpty)) {
          validationResult = requiredErrorText ?? "This field is required";
        }
        else if (value != null && value.isNotEmpty) {
          final int? parsedValue = int.tryParse(value);
          if (parsedValue == null) {
            validationResult = errorText ?? "Please enter a valid integer";
          } else if (validator != null) {
            validationResult = validator(parsedValue);
          }
        }
        if (validationResult != null) {
          if (enabled) {
            onChanged(initialValue); // Reset to initial value if validation fails
          }
        }
        return validationResult;
      },
      // No need to call setState() here : The field updates its internal state on its own
      onChanged: (value) {
        if (enabled == false) return; // Do not call onChanged if the field is disabled
        final int? parsedValue = int.tryParse(value);
        if (parsedValue != null) {
          onChanged(parsedValue);
        }
      },
    );
  }

  static Widget createBoolFormField(
    /// Creates a boolean form field with the given label, initial value, and onChanged callback.
    /// The field can be enabled or disabled.
    /// The field is represented as a switch with optional text labels for the "no" and "yes" states.
    String label,
    bool initialValue,
    void Function(bool) onChanged,
    { bool enabled = true,
    String? noText,
    String? yesText}
  ) {
    bool localValue = initialValue; // Local copy to follow the state of the switch

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter localSetState) {
        return ListTile(
          //key: key,
          enabled: enabled,
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(noText ?? ""),
              Switch(
                value: localValue,
                onChanged: enabled ? (value) {
                  localSetState(() {
                    localValue = value; // Force the Switch to change its position visually
                  });
                  onChanged(value);
                } : null,
              ),
              Text(yesText ?? ""),
            ],
          ),
        );
      }
    );
  }

  static Widget createListPickerField(
    /// Creates a list picker with the given title, list of values, initial value, and onChanged callback.
    /// It allows the user to select a value from a list of options.
    /// The field can be enabled or disabled.
    String title,
    List values,
    dynamic initialValue,
    void Function(String) onChanged,
    { bool enabled = true}
  ) {
    final List<String> options = values.cast<String>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownMenu<String>(
        key: UniqueKey(),
        requestFocusOnTap: false,
        initialSelection: options.contains(initialValue) ? initialValue as String : null,
        enabled: enabled,
        expandedInsets: EdgeInsets.zero,
        label: Text(title),
        dropdownMenuEntries: options
            .map((value) => DropdownMenuEntry<String>(value: value, label: value))
            .toList(),
        onSelected: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}
