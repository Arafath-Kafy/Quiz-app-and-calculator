import 'package:flutter/material.dart';
import 'package:flutterapp1/colors.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    ),
  );
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';

  void _handleButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == '=') {
        _input = _calculateResult();
      } else if (buttonText == 'C') {
        _input = '';
      } else if (buttonText == '√') {
        _input = _calculateSquareRoot();
      } else if (buttonText == 'sin' || buttonText == 'cos' || buttonText == 'tan' || buttonText == 'log') {
        _input = _calculateFunction(buttonText);
      } else {
        _input += buttonText;
      }
    });
  }

  String _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_input);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result.toStringAsFixed(2);
    } catch (e) {
      return 'Error';
    }
  }

  String _calculateSquareRoot() {
    try {
      Parser p = Parser();
      Expression exp = p.parse('sqrt($_input)');
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN) {
        return 'Error';
      }
      return result.toStringAsFixed(2);
    } catch (e) {
      return 'Error';
    }
  }
  


  String _calculateFunction(String func) {
    try {
      Parser p = Parser();
      String function = '$func($_input)';
      Expression exp = p.parse(function);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return '$function = ${result.toStringAsFixed(2)}';
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(32),
              alignment: Alignment.bottomRight,
              child: Text(
                _input,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: txtcolor2,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: buttoncolor1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  _buildButtonRow(['C', '√', '%', '/']),
                  _buildButtonRow(['sin', 'cos', 'tan', 'log']),
                  _buildButtonRow(['7', '8', '9', 'x']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['0', '.', '=']),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttonLabels) {
    return Expanded(
      child: Row(
        children: buttonLabels
            .map((label) => Expanded(child: _buildButton(label)))
            .toList(),
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    return Container(
      margin: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () => _handleButtonPressed(buttonText),
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF4D5058),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: txtcolor1,
          ),
        ),
      ),
    );
  }
}
