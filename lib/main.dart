import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _evaluateExpression(_input);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _input += value;
      }
    });
  }

  String _evaluateExpression(String expression) {
    final answer = _calculate(expression);

    final text = answer.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  double _calculate(String expression) {
    final input = expression.replaceAll(RegExp(r'\s+'), '');
    int position = 0;

    if (input.isEmpty) {
      throw const FormatException('Enter a valid expression');
    }

    double readNumber() {
      final start = position;
      bool hasDecimal = false;
      bool hasDigit = false;

      while (position < input.length) {
        final char = input[position];
        if ('0123456789'.contains(char)) {
          hasDigit = true;
          position++;
        } else if (char == '.' && !hasDecimal) {
          hasDecimal = true;
          position++;
        } else {
          break;
        }
      }

      if (!hasDigit) {
        throw const FormatException('Invalid number format');
      }
      final number = double.parse(input.substring(start, position));

      if (!number.isFinite) {
        throw const FormatException('Number is too large or too small');
      }

      return number;
    }

    double readTerm() {
      double value = readNumber();

      while (position < input.length &&
          (input[position] == '*' || input[position] == '/')) {
        final operator = input[position];
        position++;
        final nextValue = readNumber();

        if (operator == '*') {
          value *= nextValue;
        } else if (operator == '/') {
          if (nextValue == 0) {
            throw const FormatException('Division by zero');
          }
          value /= nextValue;
        }
      }
      return value;
    }

    double answer = readTerm();

    while (position < input.length) {
      final operator = input[position];

      if (operator != '+' && operator != '-') {
        throw const FormatException('Invalid operator');
      }
      position++;
      final nextValue = readTerm();

      if (operator == '+') {
        answer += nextValue;
      } else if (operator == '-') {
        answer -= nextValue;
      }
    }

    if (!answer.isFinite) {
      throw const FormatException('Result is too large or too small');
    }

    return answer == 0 ? 0.0 : answer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: const TextStyle(fontSize: 32.0)),
                  const SizedBox(height: 8.0),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 24.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildButtonRow(['7', '8', '9', '/']),
          _buildButtonRow(['4', '5', '6', '*']),
          _buildButtonRow(['1', '2', '3', '-']),
          _buildButtonRow(['C', '0', '=', '+']),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              onPressed: () => _onButtonPressed(button),
              child: Text(button, style: const TextStyle(fontSize: 24.0)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
