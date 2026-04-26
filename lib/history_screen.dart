import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    final data = await DatabaseHelper.instance.getHistory();
    setState(() {
      history = data;
    });
  }

  void deleteItem(int id) async {
    await DatabaseHelper.instance.delete(id);
    loadHistory();
  }

  void clearHistory() async {
    await DatabaseHelper.instance.clearAll();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: clearHistory,
          )
        ],
      ),
      body: history.isEmpty
          ? Center(child: Text("No History"))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                item['calculation'],
                style: TextStyle(fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteItem(item['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}