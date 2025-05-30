import 'package:cloud_firestore/cloud_firestore.dart';

class CalculatorLogic {
  String _input = '';
  String _result = '0';
  String _lastExpression = '';

  String get input => _input;
  String get result => _result;
  String get lastExpression => _lastExpression;

  void addToInput(String value) {
    _input += value;
  }

  void clear() {
    _input = '';
    _result = '0';
    _lastExpression = '';
  }

  Future<void> calculate() async {
    try {
      final exp = _input;
      final eval = _evaluateExpression(_input);
      _result = eval.toString();
      _lastExpression = exp;
      _input = '';
    } catch (e) {
      _result = 'Error';
      _lastExpression = _input;
      _input = '';
    }
  }

  double _evaluateExpression(String expression) {
    // Простая реализация: поддерживает + - * /
    try {
      final sanitized = expression.replaceAll('--', '+');
      final result = _simpleEval(sanitized);
      return result;
    } catch (_) {
      throw Exception('Invalid expression');
    }
  }

  double _simpleEval(String expr) {
    final tokens = expr.split(RegExp(r'([\+\-\*/])')).map((e) => e.trim()).toList();
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final op = tokens[i];
      final num = double.parse(tokens[i + 1]);
      switch (op) {
        case '+':
          result += num;
          break;
        case '-':
          result -= num;
          break;
        case '*':
          result *= num;
          break;
        case '/':
          result /= num;
          break;
      }
    }
    return result;
  }
}
