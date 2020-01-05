import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class EmailInput extends StatefulWidget {
  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  List<EmailChips> emails = [];

  /// To update the UI if there is any change in input
  StreamController<bool> changeListener = StreamController<bool>.broadcast();

  /// To update the width of [_emailTextField] with input
  StreamController<double> widthController =
      StreamController<double>.broadcast();

  // Default width of TextField if there is no values
  final double defaultTextFieldWidth = 50.0;

  // To store the screenWidth
  double screenWidth;

  TextEditingController textController;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Save screen with and add TextField in UI on UI rendered.
    SchedulerBinding.instance.addPostFrameCallback((Duration time) {
      screenWidth = MediaQuery.of(context).size.width;
      emails.add(EmailChips(inputType: INPUT_TYPE.TEXT_FIELD.index));
      changeListener.add(true);
    });
    textController = TextEditingController();

    // Listening text change values to update the width of email-TextField
    textController.addListener(() {
      updateTextFieldWidth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: changeListener.stream,
        builder: (context, snapshot) {
          return Wrap(
            spacing: 5.0,
            direction: Axis.horizontal,
            children: emails.map((email) {
              if (email.inputType == INPUT_TYPE.TEXT_FIELD.index) {
                return _emailTextField();
              } else {
                return Chip(
                  label: Text(email.address),
                  onDeleted: () {
                    emails.remove(email);
                    changeListener.add(true);
                  },
                );
              }
            }).toList(),
          );
        },
      ),
    );
  }

  /// Email TextField to get the email Input,
  /// Wrapped with StreamBuilder to update width of Widget
  Widget _emailTextField() {
    return StreamBuilder<double>(
      stream: widthController.stream,
      builder: (context, snapshot) {
        double width = snapshot.data ?? defaultTextFieldWidth;
        return Container(
          width: width,
          child: TextField(
            controller: textController,
            maxLines: null,
            autofocus: true,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              // Convert into chip if detect any ',' in value
              if (value.length > 0 &&
                  value.substring(value.length - 1) == ",") {
                // Replace all ',' => '' and convert to chip
                addAsChip(value.replaceAll(",", ""), false);
              }
            },
            onSubmitted: (value) {
              // Convert to chip, And request focus again
              addAsChip(value, true);
            },
          ),
        );
      },
    );
  }

  /// Convert string value into Chip, and add to list [emails]
  /// fromSubmit, If called from submit then requestFocus again to continue with adding new email
  void addAsChip(String value, bool fromSubmit) {
    if (value.trim().isNotEmpty) {
      emails.add(
          EmailChips(inputType: INPUT_TYPE.CHIP.index, address: value.trim()));
      emails.sort((a, b) => a.inputType.compareTo(b.inputType));

      changeListener.add(true);
      textController.clear();
    }

    if (fromSubmit) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  /// Which, calculate the width for TextField based on input string value
  /// And updating the value through [widthController] by adding latest width
  void updateTextFieldWidth() {
    String value = textController.value.text;

    double width = defaultTextFieldWidth;
    if (value.length > 0) {
      width = (value.length * 10.0) + defaultTextFieldWidth;
      if (width > screenWidth) {
        width = screenWidth;
      }
    }

    widthController.add(width);
  }

  @override
  void dispose() {
    super.dispose();
    changeListener?.close();
    widthController?.close();
  }
}

class EmailChips {
  final int inputType;
  final String address;
  final String name;

  const EmailChips({this.inputType, this.name, this.address});
}

enum INPUT_TYPE { CHIP, TEXT_FIELD }
