import 'package:flutter/material.dart';

import 'helper_database.dart';

class FormPickup extends StatefulWidget {
  const FormPickup({super.key});

  @override
  State<FormPickup> createState() => _FormPickupState();
}

class _FormPickupState extends State<FormPickup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPickupData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPickupData() async {
    final pickup = await DatabaseHelper.instance.getPickup();
    if (pickup != null && pickup.isNotEmpty) {
      setState(() {
        nameController.text = pickup['name'];
        addressController.text = pickup['address'];
        numberController.text = pickup['number'];
        complementController.text = pickup['complement'];
        phoneController.text = pickup['phone'];
        notesController.text = pickup['notes'];
      });
    }
  }

  void _savePickup() async {
    final pickup = {
      'type': 'pickup',
      'name': nameController.text,
      'address': addressController.text,
      'number': numberController.text,
      'complement': complementController.text,
      'phone': phoneController.text,
      'notes': notesController.text,
    };
    await DatabaseHelper.instance.savePickup(pickup);
    if (mounted) {
      nameController.text = '';
      addressController.text = '';
      numberController.text = '';
      complementController.text = '';
      phoneController.text = '';
      notesController.text = '';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Retirada salvo com sucesso')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Retirada')),
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
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: complementController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Complemento',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _savePickup, child: Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
