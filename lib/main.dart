import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'logic.dart';
import 'history.dart';
import 'converter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Calculator',
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
  final CalculatorLogic logic = CalculatorLogic();
  String displayText = '0';

  final List<String> buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
  ];

  void _onButtonPressed(String text) async {
    if (text == 'C') {
      setState(() {
        logic.clear();
        displayText = '0';
      });
    } else if (text == '=') {
      await logic.calculate(); // Вычисления (async)
      setState(() {
        displayText = logic.result;
      });

      // Сохраняем результат в историю, если всё корректно
      if (logic.result != 'Error' && logic.lastExpression.isNotEmpty) {
        final expression = '${logic.lastExpression} = ${logic.result}';
        await HistoryManager().addHistory(expression);
      }
    } else {
      setState(() {
        logic.addToInput(text);
        displayText = logic.input;
      });
    }
  }

  void _openHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _openConverterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConverterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistoryScreen,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _openConverterScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (context, index) {
                final buttonText = buttons[index];
                return ElevatedButton(
                  onPressed: () => _onButtonPressed(buttonText),
                  child: Text(buttonText, style: const TextStyle(fontSize: 24)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
