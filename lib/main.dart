import 'package:flutter/material.dart';

void main() =>
  runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  // Simple evaluation logic (for demonstration purposes)
  
  try {
    final result = _calculate(expression);
    return result.toString();
  } catch (e) {
    return 'Error';
  }
}


String _calculate(String expression) {
  // This is a very basic implementation and does not handle operator precedence or parentheses.

  final tokens = expression.split(RegExp(r'([+\-*/])')).where((token) => token.isNotEmpty).toList();
  double result = double.parse(tokens[0]);

  for (int i = 1; i < tokens.length; i += 2) {
    final operator = tokens[i];
    final nextValue = double.parse(tokens[i + 1]);

    switch (operator) {
      case '+':
        result += nextValue;
        break;
      case '-':
        result -= nextValue;
        break;
      case '*':
        result *= nextValue;
        break;
      case '/':
        if (nextValue == 0) throw Exception('Division by zero');
        result /= nextValue;
        break;
      default:
        throw Exception('Invalid operator');
    }
  }

  return result.toString();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
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
                  Text(
                    _input,
                    style: const TextStyle(fontSize: 32.0),
                  ),
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

