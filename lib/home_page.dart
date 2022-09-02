import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:local_database/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'objectbox.g.dart';
import 'order_data_table.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();

  late Store _store;
  bool hasBeenInitialized = false;

  late Customer _customer;

  late Stream<List<ShopOrder>> _stream;

  @override
  void initState() {
    super.initState();
    setNewCustomer();
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(
        // This Method is from the generated file
        getObjectBoxModel(),
        directory: join(dir.path, 'objectbox'),
      );

      setState(() {
        _stream = _store
            .box<ShopOrder>()
        // The simplest possible query that just gets ALL the data out of the Box
            .query()
            .watch(triggerImmediately: true)
        // Watching the query produces a Stream<Query<ShopOrder>>
        // To get the actual data inside a List<ShopOrder>, we need to call find() on the query
            .map((query) => query.find());
        hasBeenInitialized = true;
      });
    });
    setNewCustomer();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt),
            onPressed: setNewCustomer,
          ),
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: addFakeOrderForCurrentCustomer,
          ),
        ],
      ),
      body: !hasBeenInitialized ? Center(
        child: CircularProgressIndicator(),
      )
          : StreamBuilder<List<ShopOrder>>(
        stream: _stream,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return OrderDataTable(
                orders: snapshot.data!,
                onSort: (columnIndex, asceding){

                });
          }
        }
      )
    );
  }

  void setNewCustomer() {
    // TODO: Implement properly
    //print('Name: ${faker.person.name()}');
    _customer = Customer(name: faker.person.name());
  }

  void addFakeOrderForCurrentCustomer() {
    // TODO: Implement properly
    // print('Price: ${faker.randomGenerator.integer(500, min: 10)}');
    final order = ShopOrder(
      price: faker.randomGenerator.integer(500, min: 10),
    );
    order.customer.target = _customer;
    _store.box<ShopOrder>().put(order);
  }
}