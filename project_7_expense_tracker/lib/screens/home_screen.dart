import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../widgets/expense_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<Expense> expenseBox = Hive.box<Expense>('expenses');
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  void _addExpense() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📝 Thêm chi tiêu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Tên chi tiêu'),
            ),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Số tiền'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                final expense = Expense(
                  title: titleCtrl.text,
                  amount: double.parse(amountCtrl.text),
                  date: DateTime.now(),
                );
                expenseBox.add(expense);
                titleCtrl.clear();
                amountCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(int index) {
    expenseBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💾 Expense Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu chi tiêu.'));
          }

          final expenses = box.values.toList();

          return Column(
            children: [
              SizedBox(height: 50),
              Expanded(flex: 2, child: ExpenseChart(expenses: expenses)),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(e.title),
                        subtitle: Text(
                          '${e.amount.toStringAsFixed(0)} đ — ${e.date.day}/${e.date.month}/${e.date.year}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteExpense(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
