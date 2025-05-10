import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared_preferences_helper.dart';

class FormSettings extends StatefulWidget {
  const FormSettings({super.key});

  @override
  State<FormSettings> createState() => _FormSettingsState();
}

class _FormSettingsState extends State<FormSettings> {
  final TextEditingController pickupPriceController = TextEditingController();
  final TextEditingController courierPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSettings(); // 🔹 Chama a função ao iniciar
  }

  void _getSettings() async {
    final String? pickupPrice = await SharedPreferencesHelper.instance
        .getSetting('pickupPrice');
    if (pickupPrice != null && pickupPrice.isNotEmpty) {
      setState(() {
        pickupPriceController.text = pickupPrice;
      });
    }
    final String? courierPrice = await SharedPreferencesHelper.instance
        .getSetting('courierPrice');
    if (courierPrice != null && courierPrice.isNotEmpty) {
      setState(() {
        courierPriceController.text = courierPrice;
      });
    }
  }

  void _saveSettings() async {
    await SharedPreferencesHelper.instance.saveSetting(
      'pickupPrice',
      pickupPriceController.text,
    );
    await SharedPreferencesHelper.instance.saveSetting(
      'courierPrice',
      courierPriceController.text,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Configurações salvas com sucesso')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        print("onPopInvokedWithResult: $didPop, $result");
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Configurações')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Preço para a Retirada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pickupPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  labelText: 'Retirada',
                  prefixText: 'R\$',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Preço para o Entregador',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: courierPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  labelText: 'Entregador',
                  prefixText: 'R\$',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[200],
                ),
                child: Text('Salvar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
