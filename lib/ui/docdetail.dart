// ignore_for_file: prefer_const_declarations, must_be_immutable, unused_element, unused_field, await_only_futures, use_build_context_synchronously, unused_local_variable, prefer_const_constructors, non_constant_identifier_names, unnecessary_import

import 'dart:async';
import 'package:flutter/material.dart' hide DateUtils, DatePickerTheme;
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../model/model.dart';
import '../util/utils.dart';
import '../util/dbhelper.dart';

// Menu item
const menuDelete = "Delete";
final List<String> menuOptions = const <String> [
 menuDelete
];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();
  DocDetail(this.doc, {super.key});
  
  @override
  State<StatefulWidget> createState() => DocDetailState();
}

class DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final int daysAhead = 5475; // 15 years in the future.
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController expirationCtrl = MaskedTextController(
  mask: '2000-00-00');
  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;
  void _initCtrls() {
    titleCtrl.text = widget.doc.title ?? "";
    expirationCtrl.text = widget.doc.expiration ?? "";
    if (widget.doc.fqYear != null) {
      fqYearCtrl = Val.IntToBool(widget.doc.fqYear!);
    } else {
      fqYearCtrl = false;
    }
    if (widget.doc.fqHalfYear != null) {
      fqHalfYearCtrl = Val.IntToBool(widget.doc.fqHalfYear!);
    } else {
      fqHalfYearCtrl = false;
    }
    if (widget.doc.fqQuarter != null) {
      fqQuarterCtrl = Val.IntToBool(widget.doc.fqQuarter!);
    } else {
      fqQuarterCtrl = false;
    }
    if (widget.doc.fqMonth != null) {
      fqMonthCtrl = Val.IntToBool(widget.doc.fqMonth!);
    } else {
      fqMonthCtrl = false;
    }
  }

  // Date Picker & Date function
  Future _chooseDate(BuildContext context, String initialDateString) 
    async {
      var now = new DateTime.now();
      var initialDate = DateUtils.convertToDate(initialDateString) ?? now;
      initialDate = (initialDate.year >= now.year &&
      initialDate.isAfter(now) ? initialDate : now);
      DatePicker.showDatePicker(context, showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          DateTime dt = date;
          String r = DateUtils.ftDateAsStr(dt);
          expirationCtrl.text = r;
        });
      },
      currentTime: initialDate);
    }

  // Upper Menu
  void _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc.id == -1) {
          return;
        }
      await _deleteDoc;
    }
  }
  // Delete doc
  void _deleteDoc(int id) async {
    int? r = await widget.dbh.deleteDoc(widget.doc.id!);
    Navigator.pop(context, true);
  }

  // Save doc
  void _saveDoc() {
    widget.doc.title = titleCtrl.text;
    widget.doc.expiration = expirationCtrl.text;
    widget.doc.fqYear = Val.BoolToInt(fqYearCtrl);
    widget.doc.fqHalfYear = Val.BoolToInt(fqHalfYearCtrl);
    widget.doc.fqQuarter = Val.BoolToInt(fqQuarterCtrl);
    widget.doc.fqMonth = Val.BoolToInt(fqMonthCtrl);
    if (widget.doc.id! > -1) {
      debugPrint("_update->Doc Id: ${widget.doc.id}");
      widget.dbh.updateDoc(widget.doc);
      Navigator.pop(context, true);
    }
    else {
      Future<int?> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insert->Doc Id: ${widget.doc.id}");
        widget.doc.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertDoc(widget.doc);
        Navigator.pop(context, true);
      });
    }
  }

  // Submit form
  void _submitForm() {
    final FormState? form = _formKey.currentState;
    if (!form!.validate()) {
      showMessage(context, 'Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }
  void showMessage(BuildContext context, String message, [MaterialColor color = Colors.red]) { 
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar( 
        backgroundColor: color, content: Text(message), 
      ), 
    );
  }
  
  @override
  void initState() {
    super.initState();
    _initCtrls();
  }
  
  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle? tStyle = Theme.of(context).textTheme.titleLarge;
    String ttl = widget.doc.title!;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(ttl != "" ? widget.doc.title! : "New Document"),
        actions: (ttl == "") ? <Widget>[]: <Widget>[
          PopupMenuButton(
            onSelected: _selectMenu,
            itemBuilder: (BuildContext context) {
              return menuOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ]
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter(
                    RegExp("[a-zA-Z0-9 ]"))
                ],
                controller: titleCtrl,
                style: tStyle,
                validator: (val) => Val.ValidateTitle(val!),
                decoration: InputDecoration(
                  icon: const Icon(Icons.title),
                  hintText: 'Enter the document name',
                  labelText: 'Document Name',
                ),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: expirationCtrl,
                    maxLength: 10,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      hintText: 'Expiry date (i.e. ${DateUtils.daysAheadAsStr(daysAhead)})',
                      labelText: 'Expiry Date'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => DateUtils.isValidDate(val!) 
                      ? null : 'Not a valid future date',
                )),
                IconButton(
                  icon: new Icon(Icons.more_horiz),
                  tooltip: 'Choose date',
                  onPressed: (() {
                    _chooseDate(context, expirationCtrl.text);
                  }),
                )
              ]),
              Row(children: const <Widget>[
                Expanded(child: Text(' '))
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('a: Alert @ 1.5 & 1 year(s)')),
                Switch(
                  value: fqYearCtrl,
                  onChanged: (bool value) {
                    setState(() {
                      fqYearCtrl = value;
                    });  
                  }
                ),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('b: Alert @ 6 months')),
                Switch(
                  value: fqHalfYearCtrl,
                  onChanged: (bool value) {
                    setState(() {
                      fqHalfYearCtrl = value;
                    });
                  }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('c: Alert @ 3 months')),
                Switch(
                  value: fqQuarterCtrl,
                  onChanged: (bool value) {
                    setState(() {
                      fqQuarterCtrl = value;
                    });
                  }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('d: Alert @ 1 month or less')),
                Switch(
                  value: fqMonthCtrl,
                  onChanged: (bool value) {
                    setState(() {
                      fqMonthCtrl = value;
                    });
                  }),
              ]),
              Container(
                padding: const EdgeInsets.only(
                  left: 40.0, top: 20.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text("Save"),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  WhitelistingTextInputFormatter(RegExp regExp) {}
}