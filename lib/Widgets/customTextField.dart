import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData data;
  final String hintText;
  bool isObsecure = true;
  TextInputType inputType = TextInputType.text;
  Function validator;
  int maxLength;
  FocusNode focusNode;
  List<TextInputFormatter> formatters;

  CustomTextField({
    Key key,
    this.controller,
    this.data,
    this.hintText,
    this.isObsecure,
    this.inputType,
    this.validator,
    this.maxLength,
    this.focusNode,
    this.formatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(
            10.0,
          ),
        ),
      ),
      padding: EdgeInsets.all(
        8.0,
      ),
      margin: EdgeInsets.all(
        10.0,
      ),
      child: TextFormField(
        inputFormatters: formatters != null ? formatters : null,
        validator: validator,
        keyboardType: inputType,
        controller: controller,
        obscureText: isObsecure,
        maxLength: maxLength != null ? maxLength : null,
        focusNode: focusNode != null ? focusNode : null,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: Theme.of(context).primaryColor,
          ),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
        ),
      ),
    );
  }
}
