import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'database_helper.dart';
import 'history_screen.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = "0";
  String expression = "";

  void buttonPressed(String value) async {
    setState(() {
      // CLEAR
      if (value == "C") {
        display = "0";
        expression = "";
        return;
      }
      // DELETE (⌫)
      if (value == "⌫") {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
          display = expression.isEmpty ? "0" : expression;
        }
        return;
      }

      // EQUALS
      if (value == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double result = exp.evaluate(EvaluationType.REAL, cm);

          String resultStr = result % 1 == 0
              ? result.toInt().toString()
              : result.toString();

          String calc = "$expression = $resultStr";

          display = resultStr;
          expression = resultStr;

          DatabaseHelper.instance.insert(calc);

        } catch (e) {
          display = "Error";
          expression = "";
        }
        return;
      }

      // OPERATORS
      if (value == "+" || value == "-" || value == "*" || value == "/") {
        if (expression.isEmpty) return;

        if ("+-*/".contains(expression[expression.length - 1])) {
          expression = expression.substring(0, expression.length - 1);
        }

        expression += value;
        display = expression;
        return;
      }

      // NUMBERS
      if (display == "0") {
        display = value;
        expression = value;
      } else {
        display += value;
        expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          )
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Text(
              display,
              style: TextStyle(fontSize: 32),
              textAlign: TextAlign.right,
            ),
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                '7','8','9','/',
                '4','5','6','*',
                '1','2','3','-',
                'C','0','.','+',
                '⌫','='
              ].map((text) {
                return Padding(
                  padding: EdgeInsets.all(5),
                  child: ElevatedButton(
                    onPressed: () => buttonPressed(text),
                    child: Text(text, style: TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
