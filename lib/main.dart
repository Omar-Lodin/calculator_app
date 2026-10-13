import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = false;

  ThemeData _buildTheme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              minimumSize: const Size(0, 56),
            ).copyWith(
              animationDuration: const Duration(milliseconds: 120),
              splashFactory: InkRipple.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return colors.onPrimaryContainer.withValues(alpha: 0.16);
                }

                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)) {
                  return colors.onPrimaryContainer.withValues(alpha: 0.08);
                }

                return null;
              }),
              elevation: WidgetStateProperty.resolveWith<double>((states) {
                return states.contains(WidgetState.pressed) ? 0 : 2;
              }),
            ),
      ),
      dividerTheme: DividerThemeData(color: colors.outlineVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      home: CalculatorScreen(
        isDark: _isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '0';
  String _result = '';
  String _expression = '';
  double? _accumulator;
  String? _pendingOperator;
  bool _waitingForOperand = true;
  bool _finish = false;
  bool _hasError = false;

  void _onButtonPressed(String value) {
    setState(() {
      try {
        if (value == 'C') {
          _clear();
        } else if (RegExp(r'^[0-9]$').hasMatch(value)) {
          _enterDigit(value);
        } else if (value == '=') {
          _finishCalculation();
        } else if (['+', '-', '*', '/'].contains(value)) {
          if (!_hasError) {
            _chooseOperator(value);
          }
        }
      } on FormatException catch (e) {
        _clear();
        _input = 'Error';
        _result =
            '${e.message}. Enter a number to restart or press C to clear.';
        _hasError = true;
      }
    });
  }

  void _clear() {
    _input = '0';
    _result = '';
    _expression = '';
    _accumulator = null;
    _pendingOperator = null;
    _waitingForOperand = true;
    _finish = false;
    _hasError = false;
  }

  void _enterDigit(String digit) {
    if (_finish || _hasError) {
      _clear();
    }
    _result = '';

    if (_waitingForOperand || _input == '0') {
      _input = digit;
    } else {
      _input += digit;
    }

    _waitingForOperand = false;

    if (_pendingOperator != null && _accumulator != null) {
      _expression = '${_formatNumber(_accumulator!)} $_pendingOperator $_input';
    } else {
      _expression = _input;
    }
  }

  void _chooseOperator(String operator) {
    if (_waitingForOperand) {
      _accumulator ??= double.parse(_input);
      _pendingOperator = operator;
      _expression = '${_formatNumber(_accumulator!)} $operator';
      return;
    }

    final operand = double.parse(_input);

    if (!operand.isFinite) {
      throw const FormatException('Number is too large or too small');
    }

    if (_accumulator != null && _pendingOperator != null) {
      _accumulator = _applyOperator(_accumulator!, operand, _pendingOperator!);
    } else {
      _accumulator = operand;
    }

    _input = _formatNumber(_accumulator!);
    _result = 'Running total: $_input';

    _pendingOperator = operator;
    _expression = '$_input $operator';
    _waitingForOperand = true;
    _finish = false;
  }

  void _finishCalculation() {
    if (_finish || _hasError) {
      return;
    }

    if (_waitingForOperand) {
      _result = _pendingOperator != null
          ? 'Enter the next number, followed by =. Press C to clear.'
          : 'Please enter a number first. Press C to clear.';
      return;
    }

    _expression = '$_expression =';
    final operand = double.parse(_input);

    if (!operand.isFinite) {
      throw const FormatException('Number is too large or too small');
    }

    if (_accumulator != null && _pendingOperator != null) {
      _accumulator = _applyOperator(_accumulator!, operand, _pendingOperator!);
    } else {
      _accumulator = operand;
    }

    _input = _formatNumber(_accumulator!);
    _result = 'Result: $_input';
    _pendingOperator = null;
    _waitingForOperand = true;
    _finish = true;
  }

  double _applyOperator(double first, double second, String operator) {
    double answer;

    switch (operator) {
      case '+':
        answer = first + second;
        break;
      case '-':
        answer = first - second;
        break;
      case '*':
        answer = first * second;
        break;
      case '/':
        if (second == 0) {
          throw const FormatException('Division by zero');
        }
        answer = first / second;
        break;
      default:
        throw const FormatException('Invalid operator');
    }
    if (!answer.isFinite) {
      throw const FormatException('Result is too large or too small');
    }
    return answer;
  }

  String _formatNumber(double number) {
    final text = number.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
          Switch(
            value: widget.isDark,
            onChanged: widget.onThemeChanged,
            activeThumbColor: colors.primary,
            activeTrackColor: colors.primaryContainer,
            inactiveThumbColor: colors.outline,
            inactiveTrackColor: colors.surfaceContainerHighest,
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
              (states) =>
                  Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
                    _expression,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _input,
                    style: TextStyle(fontSize: 32, color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: TextStyle(
                      fontSize: 24,
                      color: colors.onSurfaceVariant,
                    ),
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
