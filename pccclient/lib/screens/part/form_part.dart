import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../utils/plugins/files.dart';

import 'form_field.dart';

abstract class FormPart<T> extends StatelessWidget {
  const FormPart(
      {super.key, required this.data, required this.store, this.initial});

  final PluginFormFieldData data;
  final Map<String, dynamic> store;
  final T? initial;
}

FormPart formPartFromData(
    PluginFormFieldData data, Map<String, dynamic> store) {
  switch (data.type) {
    case PluginFormFieldType.string:
      return StringFormPart(
        data: data,
        store: store,
        initial: store[data.id],
      );
    case PluginFormFieldType.password:
      return PasswordFormPart(
        data: data,
        store: store,
        initial: store[data.id],
      );
    case PluginFormFieldType.file:
      return FileFormPart(
        data: data,
        store: store,
        initial: store[data.id],
      );
    case PluginFormFieldType.int:
      return IntFormPart(
        data: data,
        store: store,
        initial: store[data.id],
      );
    case PluginFormFieldType.bool:
      return BoolFormPart(
        data: data,
        store: store,
        initial: store[data.id],
      );
  }
}

List<Widget> _getBase(String? title, String? description) {
  return [
    Container(
      alignment: Alignment.centerLeft,
      child: Text(
        title ?? "",
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ),
    Container(
      alignment: Alignment.centerLeft,
      child: Text(
        description ?? "",
        textAlign: TextAlign.left,
      ),
    ),
  ];
}

class StringFormPart extends FormPart<String> {
  const StringFormPart(
      {super.key, required super.data, required super.store, super.initial});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _getBase(data.title, data.description);
    children.add(TextFormField(
      keyboardType: TextInputType.text,
      initialValue: initial ?? data.initial,
      decoration: InputDecoration(
        labelText: data.label,
        hintText: data.hint,
      ),
      onSaved: (newValue) => store[data.id] = newValue,
    ));
    return Column(
      children: children,
    );
  }
}

class PasswordFormPart extends FormPart<String> {
  const PasswordFormPart(
      {super.key, required super.data, required super.store, super.initial});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _getBase(data.title, data.description);
    children.add(TextFormField(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      initialValue: initial ?? data.initial,
      decoration: InputDecoration(
        labelText: data.label,
        hintText: data.hint,
      ),
      onSaved: (newValue) => store[data.id] = newValue,
    ));
    return Column(
      children: children,
    );
  }
}

class FileFormPart extends FormPart<String> {
  const FileFormPart(
      {super.key, required super.data, required super.store, super.initial});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _getBase(data.title, data.description);
    TextEditingController textControler = TextEditingController();
    children.add(Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: textControler,
            keyboardType: TextInputType.text,
            initialValue: initial ?? data.initial,
            decoration: InputDecoration(
              labelText: data.label,
              hintText: data.hint,
            ),
            onSaved: (newValue) => store[data.id] = newValue,
          ),
        ),
        TextButton(
            onPressed: () async {
              switch (data.filePicker) {
                case "single_file":
                default:
                  var result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.isNotEmpty) {
                    textControler.text =
                        result.files.map((e) => e.path).join(":");
                  }
                  break;
              }
            },
            child: const Icon(Icons.folder))
      ],
    ));
    return Column(
      children: children,
    );
  }
}

class IntFormPart extends FormPart<int> {
  const IntFormPart(
      {super.key, required super.data, required super.store, super.initial});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _getBase(data.title, data.description);
    children.add(IntegerFormField(
      initialValue: initial ??
          (data.initial != null ? int.tryParse(data.initial!) : null),
      decoration: InputDecoration(
        labelText: data.label,
        hintText: data.hint,
      ),
      onSaved: (newValue) => store[data.id] = newValue,
    ));
    return Column(
      children: children,
    );
  }
}

class BoolFormPart extends FormPart<bool> {
  const BoolFormPart(
      {super.key, required super.data, required super.store, super.initial});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = _getBase(data.title, data.description);
    children.add(ToggleFormField(
      initialValue: initial ?? data.initial?.toLowerCase() == "true",
      onSaved: (newValue) => store[data.id] = newValue,
    ));
    return Column(
      children: children,
    );
  }
}
