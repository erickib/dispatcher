import 'package:dispatcher3/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dispatcher3/helper_database.dart';
import 'form_pickup.dart';
import 'form_courier.dart';
import 'form_transactions.dart';
import 'form_settings.dart';
import 'page_about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController areaCodeController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController pickupPriceController = TextEditingController();
  final TextEditingController courierPriceController = TextEditingController();
  final TextEditingController courierNotesController = TextEditingController();

  Future<List<String>> _getPickups(String query) async {
    final List<String> results = await DatabaseHelper.instance.getPickups();

    return results
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    //print('initState');
    final String? pickupPrice = await SharedPreferencesHelper.instance
        .getSetting('pickupPrice');
    if (pickupPrice != null && pickupPrice.isNotEmpty) {
      pickupPriceController.text = pickupPrice;
    }
    final String? courierPrice = await SharedPreferencesHelper.instance
        .getSetting('courierPrice');
    if (courierPrice != null && courierPrice.isNotEmpty) {
      courierPriceController.text = courierPrice;
    }
  }

  Future<void> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    // A URL deve estar no formato internacional, sem espaços ou caracteres especiais.
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    // Verifica se é possível lançar a URL
    if (await canLaunchUrl(whatsappUrl)) {
      // Lança a URL no aplicativo externo (neste caso, o WhatsApp)
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // Caso não seja possível abrir o WhatsApp, lança um erro
      print(
        'Não foi possível abrir o WhatsApp. Verifique se o número está correto e se o aplicativo está instalado.',
      );
    }
  }

  void _showMenu(BuildContext context, TapDownDetails details) {
    final offset = details.globalPosition;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + 1,
        offset.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'form-pickup',
          child: Text('Cadastro de Retiradas'),
        ),
        PopupMenuItem(
          value: 'form-courier',
          child: Text('Cadastro de Entregadores'),
        ),
        PopupMenuItem(value: 'form-transactions', child: Text('Transações')),
        PopupMenuItem(value: 'settings', child: Text('Configurações')),
        PopupMenuItem(value: 'about', child: Text('Sobre')),
      ],
    ).then((value) {
      if (value == 'form-pickup') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormPickup()),
          );
        }
      }
      if (value == 'form-courier') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormCourier()),
          );
        }
      }
      if (value == 'form-transactions') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormTransactions()),
          );
        }
      }
      if (value == 'settings') {
        Future.delayed(Duration.zero, () async {
          if (context.mounted) {
            String? resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormSettings()),
            );
            //returnin from navigator-back button
            final String? pickupPrice = await SharedPreferencesHelper.instance
                .getSetting('pickupPrice');
            if (pickupPrice != null && pickupPrice.isNotEmpty) {
              pickupPriceController.text = pickupPrice;
            }
            final String? courierPrice = await SharedPreferencesHelper.instance
                .getSetting('courierPrice');
            if (courierPrice != null && courierPrice.isNotEmpty) {
              courierPriceController.text = courierPrice;
            }
          }
        });
      } // if
      if (value == 'about') {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PageAbout()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entregador 1.0',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTapDown: (details) => _showMenu(context, details),
          child: Padding(padding: EdgeInsets.all(16), child: Icon(Icons.menu)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                size: 40,
                Icons.sports_motorsports,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: Column(
            children: [
              Text(
                'Welcome to Delivery App!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              FloatingActionButton(
                onPressed: () {
                  launchWhatsApp(
                    phone: '5541996177770', // exemplo: Brasil (55) e DDD 11
                    message: 'Olá, tudo bem?',
                  );
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 16),
              SupplierSearchable(
                supplierController: supplierController,
                fetchSuppliers: _getPickups,
              ),
              PhoneInput(
                areaCodeController: areaCodeController,
                phoneNumberController: phoneNumberController,
              ),
              SizedBox(height: 10),
              TextField(
                controller: courierNotesController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Observação',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20), // Adds spacing
              Row(
                children: [
                  // Coluna para "Preço da Retirada"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preço para a Retirada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: null, // pickupPriceDecrement
                            ),
                            Expanded(
                              child: TextField(
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: null, // pickupPriceIncrement
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16), // Espaçamento entre as colunas
                  // Coluna para "Preço para o Entregador"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preço para o Entregador',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: null, // courierPriceDecrement
                            ),
                            Expanded(
                              child: TextField(
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: null, // courierPriceIncrement
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Custom Widget - Phone Input

class PhoneInput extends StatelessWidget {
  final TextEditingController areaCodeController;
  final TextEditingController phoneNumberController;

  const PhoneInput({
    Key? key,
    required this.areaCodeController,
    required this.phoneNumberController,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ), // Adiciona margem lateral
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Evita que ocupe toda a altura
        children: [
          const Text(
            'Entregador: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '+55',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // SizedBox(
              //   width: 60, // Define um tamanho fixo para o código de área
              //   child: TextField(
              //     controller: areaCodeController,
              //     keyboardType: TextInputType.number,
              //     maxLength: 2,
              //     style: TextStyle(
              //       fontSize: 18,
              //     ), // Permite ajustar o tamanho da fonte
              //     decoration: const InputDecoration(
              //       counterText: '',
              //       hintText: 'XX',
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12), // Espaço entre os campos
              Expanded(
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  style: TextStyle(fontSize: 18), // Permite aumentar a fonte
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          // return Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          // Row(
          //   children: [
          //     const Text(
          //       '+55',
          //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //     ),
          //     const SizedBox(width: 8),
          // SizedBox(
          //   width: 40,
          //   child: TextField(
          //     controller: areaCodeController,
          //     keyboardType: TextInputType.number,
          //     maxLength: 2,
          //     decoration: const InputDecoration(
          //       counterText: '',
          //       hintText: 'XX',
          //       border: OutlineInputBorder(),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 8),
          // Expanded(
          //   child: TextField(
          //     controller: phoneNumberController,
          //     keyboardType: TextInputType.number,
          //     maxLength: 9,
          //     decoration: const InputDecoration(
          //       counterText: '',
          //       hintText: 'Phone Number',
          //       border: OutlineInputBorder(),
          //     ),
          //   ),
          // ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

//Custom Widget - Supplier

class SupplierSearchable extends StatefulWidget {
  final TextEditingController supplierController;
  // final Future<List<String>> Function(String) fetchSuppliers;
  final Future<List<String>> Function(String) fetchSuppliers;

  const SupplierSearchable({
    super.key,
    required this.supplierController,
    required this.fetchSuppliers,
  });

  @override
  _SupplierSearchableState createState() => _SupplierSearchableState();
}

class _SupplierSearchableState extends State<SupplierSearchable> {
  List<String> suggestions = [];

  void updateSuggestions(String query) async {
    final results = await widget.fetchSuppliers(query);
    setState(() {
      suggestions = results;
    });
  }

  final FocusNode _focusNode = FocusNode();
  bool _showListView = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showListView = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ), // Adiciona margem lateral
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nome do Fornecedor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            focusNode: _focusNode,
            controller: widget.supplierController,
            onChanged: updateSuggestions,
            decoration: const InputDecoration(
              hintText: 'Buscar fornecedor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if ((suggestions).isNotEmpty)
            _showListView
                ? SizedBox(
                  height: 200, // Prevent overflow
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (suggestions).length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text((suggestions)[index]),
                        onTap: () {
                          widget.supplierController.text = (suggestions)[index];
                          setState(() {
                            (suggestions).clear();
                          });
                        },
                      );
                    },
                  ),
                )
                : SizedBox.shrink(),
        ],
      ),
    );
  }
}


















































// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dispatcher',
//       theme: ThemeData(
//         //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         primaryColor: Colors.grey[300],
//         scaffoldBackgroundColor: Colors.grey[200],
//         colorScheme: ColorScheme.light(
//           primary: Colors.black!,
//           secondary: Colors.blueGrey[300]!,
//           //background: Colors.grey[100]!,
//           surface: Colors.blueGrey[400]!,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blueGrey[300],
//             foregroundColor: Colors.white,
//           ),
//         ),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   late TextEditingController pickupController;
//   late TextEditingController deliveryController;
//   late TextEditingController supplierPriceController;
//   late TextEditingController driverPriceController;
//   int supplierPrice = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     pickupController = TextEditingController();
//     deliveryController = TextEditingController();
//     supplierPriceController = TextEditingController();
//     driverPriceController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     pickupController.dispose();
//     deliveryController.dispose();
//     supplierPriceController.dispose();
//     driverPriceController.dispose();
//     super.dispose();
//   }

//   void supplierPriceIncrement() {
//     setState(() {
//       if (supplierPrice <= 94) {
//         supplierPrice = supplierPrice + 5;
//       }
//       // if (supplierPrice >= 100) {
//       //   supplierPrice = 100;
//       // }
//       supplierPriceController.text = supplierPrice.toString();
//     });
//   }

//   void supplierPriceDecrement() {
//     setState(() {
//       if (supplierPrice >= 5) {
//         supplierPrice = supplierPrice - 5;
//         supplierPriceController.text = supplierPrice.toString();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(height: 16),
//             TextField(
//               controller: deliveryController,
//               decoration: InputDecoration(
//                 labelText: 'Nome Entrega',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: deliveryController,
//               decoration: InputDecoration(
//                 labelText: 'Endereço Entrega',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: pickupController,
//               decoration: InputDecoration(
//                 labelText: 'Nome Retirada',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: pickupController,
//               decoration: InputDecoration(
//                 labelText: 'Endereço Retirada',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.remove),
//                   onPressed: supplierPriceDecrement,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: supplierPriceController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(2),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Preço do Fornecedor',
//                       prefixText: 'R\$',
//                       border: OutlineInputBorder(),
//                     ),
//                     textAlign: TextAlign.center,
//                     onChanged: (value) {
//                       if (value.isEmpty ||
//                           int.tryParse(value) == null ||
//                           int.tryParse(value) == 0) {
//                         supplierPrice = 0;
//                         //supplierPriceController.text = supplierPrice.toString();
//                       } else {
//                         if (int.parse(value) >= 100) {
//                           supplierPrice = 100;
//                           supplierPriceController.text =
//                               supplierPrice.toString();
//                         } else {
//                           supplierPrice = int.parse(value);
//                         }
//                       }
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   color: Colors.blue,
//                   icon: Icon(Icons.add, color: Colors.blue),
//                   onPressed: supplierPriceIncrement,
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: driverPriceController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Price for Driver',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 child: Text('Dispatch Route'),
//               ),
//             ),
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }





























































// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
