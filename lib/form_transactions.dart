import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helper_database_transactions.dart';

class FormTransactions extends StatefulWidget {
  @override
  State<FormTransactions> createState() => _FormTransactionsState();
}

class _FormTransactionsState extends State<FormTransactions> {
  final DatabaseHelperTransactions dbHelper = DatabaseHelperTransactions();
  List<Map<String, dynamic>> transactions = [];
  Map<String, double> summary = {'totalPickup': 0.0, 'totalCourier': 0.0};
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    // dbHelper.insertTransaction({
    //   'pickupPrice': 50.0,
    //   'courierPrice': 25.0,
    //   'sentToCourier': 1,
    //   'paydToCourier': 0,
    //   'datetime': '2025-01-20',
    // });
    // dbHelper.insertTransaction({
    //   'pickupPrice': 30.0,
    //   'courierPrice': 20.0,
    //   'sentToCourier': 1,
    //   'paydToCourier': 0,
    //   'datetime': '2025-01-12',
    // });
    // dbHelper.insertTransaction({
    //   'pickupPrice': 30.0,
    //   'courierPrice': 20.0,
    //   'sentToCourier': 1,
    //   'paydToCourier': 0,
    //   'datetime': '2025-02-12',
    // });
    // dbHelper.insertTransaction({
    //   'pickupPrice': 40.0,
    //   'courierPrice': 25.0,
    //   'sentToCourier': 1,
    //   'paydToCourier': 0,
    //   'datetime': '2025-02-12 12:15:01',
    // });
    _loadTransactions();
  }

  Future<void> _loadTransactions({String? filter}) async {
    List<Map<String, dynamic>> data = await dbHelper.getTransactions(
      filter: filter,
    );
    Map<String, double> sum = await dbHelper.getSummary(filter: filter);
    setState(() {
      transactions = data;
      summary = sum;
    });
  }

  void _applyFilter(String filterType) {
    String filter = '';
    final now = DateTime.now();
    if (filterType == 'Hoje') {
      filter = DateFormat('yyyy-MM-dd').format(now);
    } else if (filterType == 'Esta Semana') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      filter = DateFormat('yyyy-MM').format(startOfWeek);
    } else if (filterType == 'Este Mês') {
      filter = DateFormat('yyyy-MM').format(now);
    }
    setState(() {
      selectedFilter = filterType;
    });
    _loadTransactions(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              hint: Text('Filtrar por'),
              onChanged: (String? newValue) {
                if (newValue != null) _applyFilter(newValue);
              },
              items:
                  [
                    'Hoje',
                    'Esta Semana',
                    'Este Mês',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Pickup: \$${summary['totalPickup']!.toStringAsFixed(2)} | '
              'Total Courier: \$${summary['totalCourier']!.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(
                    'Pickup: \$${transaction['pickupPrice'].toStringAsFixed(2)} - '
                    'Courier: \$${transaction['courierPrice'].toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    'Date: ${transaction['datetime']} - '
                    'Sent: ${transaction['sentToCourier'] == 1 ? 'Yes' : 'No'} - '
                    'Paid: ${transaction['paydToCourier'] == 1 ? 'Yes' : 'No'}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
