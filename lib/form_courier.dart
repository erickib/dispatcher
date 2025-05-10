import 'package:flutter/material.dart';

import 'helper_database.dart'; // Crie um arquivo separado para o banco de dados

class FormCourier extends StatefulWidget {
  const FormCourier({super.key});

  @override
  State<FormCourier> createState() => _FormCourierState();
}

class _FormCourierState extends State<FormCourier> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourierData();
  }

  void _loadCourierData() async {
    final courier = await DatabaseHelper.instance.getCourier();
    if (courier != null) {
      setState(() {
        nameController.text = courier['name'];
        phoneController.text = courier['phone'];
        notesController.text = courier['notes'];
      });
    }
  }

  void _saveCourier() async {
    final courier = {
      'type': 'courier',
      'name': nameController.text,
      'phone': phoneController.text,
      'notes': notesController.text,
    };
    await DatabaseHelper.instance.saveCourier(courier);
    if (mounted) {
      nameController.text = '';
      phoneController.text = '';
      notesController.text = '';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Entregador salvo com sucesso')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Entregador')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: notesController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveCourier, child: Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
