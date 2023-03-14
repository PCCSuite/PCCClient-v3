import 'package:flutter/material.dart';

import '../utils/general.dart';
import '../utils/samba.dart';
import 'part/error.dart';
import 'part/tips.dart';

class SambaScreen extends StatelessWidget {
  const SambaScreen({Key? key}) : super(key: key);

  static const routeName = "/samba";

  static final screenName = str.samba_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SambaScreen.screenName),
      ),
      bottomNavigationBar: getTipsBar(),
      body: const _SambaWidget(),
    );
  }
}

class _SambaWidget extends StatefulWidget {
  const _SambaWidget({Key? key}) : super(key: key);

  @override
  State<_SambaWidget> createState() => _SambaWidgetState();
}

class _SambaWidgetState extends State<_SambaWidget> {
  int _sambaMode = sambaMode;
  late TextEditingController _sambaPasswordController;
  late TextEditingController _sambaPasswordConfirmController;
  bool _passwordVisible = false;

  bool _sending = false;

  String? _error;

  void _verifyer() {
    if (_sambaMode == 1) {
      setState(() {
        _error = null;
      });
    } else if (_sambaPasswordController.text !=
        _sambaPasswordConfirmController.text) {
      setState(() {
        _error = str.samba_password_not_match;
      });
    } else if (_sambaPasswordController.text == "") {
      setState(() {
        _error = str.samba_password_empty;
      });
    } else {
      setState(() {
        _error = null;
      });
    }
  }

  @override
  void initState() {
    _sambaPasswordController = TextEditingController();
    _sambaPasswordConfirmController = TextEditingController();

    _sambaPasswordController.addListener(_verifyer);
    _sambaPasswordConfirmController.addListener(_verifyer);
    super.initState();
    _verifyer();
  }

  @override
  void dispose() {
    _sambaPasswordController.dispose();
    _sambaPasswordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    try {
      await setSambaPass(_sambaMode, _sambaPasswordController.text);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (err, trace) {
      showError(context, err, trace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text(str.samba_password),
        ),
        RadioListTile<int>(
          title: Text(str.samba_password_dynamic),
          subtitle: Text(str.samba_password_dynamic_description),
          value: 1,
          groupValue: _sambaMode,
          onChanged: (val) {
            setState(() {
              _sambaMode = val!;
            });
            _verifyer();
          },
        ),
        RadioListTile<int>(
          title: Text(str.samba_password_static_plain),
          subtitle: Text(str.samba_password_static_plain_description),
          value: 2,
          groupValue: _sambaMode,
          onChanged: (val) {
            setState(() {
              _sambaMode = val!;
            });
            _verifyer();
          },
        ),
        RadioListTile<int>(
          title: Text(str.samba_password_static_encrypted),
          subtitle: Text(str.samba_password_unimplemented),
          value: 3,
          groupValue: _sambaMode,
          onChanged: null,
        ),
        RadioListTile<int>(
          title: Text(str.samba_password_static_unstored),
          subtitle: Text(str.samba_password_unimplemented),
          value: 4,
          groupValue: _sambaMode,
          onChanged: null,
        ),
        _sambaMode == 1
            ? Container()
            : Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      var password = generateRandomString(16);
                      _sambaPasswordController.text = password;
                      _sambaPasswordConfirmController.text = password;
                    },
                    child: Text(str.samba_password_randomize),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _sambaPasswordController,
                      autocorrect: false,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        label: Text(str.samba_password_input),
                      ),
                    ),
                    trailing: IconButton(
                      icon: _passwordVisible
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () => setState(() {
                        _passwordVisible = !_passwordVisible;
                      }),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _sambaPasswordConfirmController,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text(str.samba_password_input_confirm),
                      ),
                    ),
                  ),
                ],
              ),
        _error != null
            ? ListTile(
                title: Text(
                  _error!,
                ),
              )
            : ElevatedButton(
                onPressed: _sending
                    ? null
                    : () {
                        setState(() {
                          _sending = true;
                        });
                        _send();
                      },
                child: Text(str.samba_password_submit),
              ),
      ],
    );
  }
}
