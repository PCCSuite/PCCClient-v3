import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pccclient/utils/general.dart';

enum PluginFormFieldType {
  string,
  password,
  file,
  int,
  bool;
}

class ToggleFormField extends FormField<bool> {
  ToggleFormField({
    super.key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    bool initialValue = false,
    FormFieldSetter<bool?>? onSaved,
    FormFieldValidator<bool?>? validator,
  }) : super(
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<bool> state) {
            return Row(
              children: [
                Switch(
                  value: state.value!,
                  onChanged: state.didChange,
                ),
                state.hasError
                    ? SelectableText(
                        state.errorText.toString(),
                        style: TextStyle(
                            color: Theme.of(state.context).errorColor),
                      )
                    : SelectableText(state.value.toString())
              ],
            );
          },
        );
}

class IntegerFormField extends FormField<int> {
  IntegerFormField({
    super.key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    int? initialValue,
    InputDecoration? decoration,
    FormFieldSetter<int?>? onSaved,
    FormFieldValidator<int?>? validator,
  }) : super(
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<int> state) {
            return TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp("[0-9-]*"), allow: true)
              ],
              validator: (val) {
                if (val == null) {
                  return str.input_integer_error;
                }
                return state.errorText;
              },
              onChanged: (val) => state.didChange(int.tryParse(val)),
              decoration: decoration,
            );
          },
        );
}
