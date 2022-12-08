import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pccclient/utils/general.dart';

class ToggleFormField extends FormField<bool> {
  ToggleFormField({
    super.key,
    FormFieldSetter<bool?>? onSaved,
    FormFieldValidator<bool?>? validator,
    bool initialValue = false,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
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
    FormFieldSetter<int?>? onSaved,
    FormFieldValidator<int?>? validator,
    int initialValue = 0,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
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
              decoration: InputDecoration(
                hintText: str.plugin_form_field_hint_int,
              ),
            );
          },
        );
}
