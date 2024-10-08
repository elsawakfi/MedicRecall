import 'package:flutter/material.dart';

/*
This package is how the option and the answer is displayed for the user
Currently, it is based on the 'appropriateness' questions
This can be easily changed to adapt to other forms of questions if needed

It takes in as parameters optionText, optionChoice and onChanged

optionText is a final string which is the questions to be displayed to the user

optionChoice is a string that is the default choice for the user. Here it is select.

onChanged is a 'valuechanged', essentially, this means that when the user selects their
choice, this is reflected back to the calling program, meaning the string they
select is returned.

The reflection allows the score to be generated.

 */

class Option extends StatefulWidget {
  //variables to be input to the user
  final String optionText;
  final String? optionChoice;
  final ValueChanged<String> onChanged;
  final List<String> items;

  const Option(
      // initialising the parameters
      {Key? key,
      required this.optionText,
      required this.optionChoice,
      required this.onChanged,
      required this.items})
      : super(key: key);

  @override
  State<Option> createState() =>
      _OptionState(); // creation of the state of the program
}

class _OptionState extends State<Option> {
  //late String _value;

  late List<String> items = widget.items;

  late String? value = items[0];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            // allow for scrolling if its a long question
            child: Center(
                child: Text(widget.optionText, // text displayed here
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ))),
          )),

      // this is the drop down menu for the user selection
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: DropdownButtonHideUnderline(
          // hides the line in the drop down menu
          child: DropdownButton<String>(
              // Creates a button, with a drop down menu inside
              iconSize: 36,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              isExpanded: true,
              // expands it to the width of the page
              value: value,
              // default value is select
              items: items.map(buildMenuItem).toList(),
              // maps the items into a list
              onChanged: (value) {
                setState(() {
                  //this.value = value,
                  // _value = value!;
                  this.value = value;
                }); // when they select a new value, this is reflected in the drop down menu
                widget.onChanged(value!);
              }),
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }

  //function which builds a menu item from a string.
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));

  String? get optionValue => value;
}
