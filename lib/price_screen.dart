import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_data.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'AUD';

  String btcExchangeRate = '0.0';
  String ethExchangeRate = '0.0';
  String ltcExchangeRate = '0.0';

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      DropdownMenuItem newItem = DropdownMenuItem<String>(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) {
        updateUI(value);
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        updateUI(selectedIndex);
      },
      children: pickerItems,
    );
  }

  // TODO: use if there is more than two options for widgets!!
  // Widget getPicker() {
  //   if (Platform.isIOS) {
  //     return iOSPicker();
  //   } else if (Platform.isAndroid) {
  //     return androidDropdown();
  //   }
  //   return Text("Couldn't load currencies");
  // }

  Future<double> getCoinData() async {
    // repeat this 3 times for each crypto-currency
    String url = '$coinApiURL/BTC/$selectedCurrency?apikey=$kApiKey';
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;

      var decodedData =
          jsonDecode(data); //TODO: you only need to call jsonDecode() once!!

      return decodedData['rate'];
    } else {
      print("HTTP Error: ${response.statusCode}");
      return 0.0;
    }
  }

  void updateUI(var userSelection) async {
    double newRate = await getCoinData();

    setState(() {
      //determine platform to see what type of data userSelection is
      if (Platform.isIOS) {
        selectedCurrency = currenciesList[userSelection];
      } else {
        selectedCurrency = userSelection;
      }

      btcExchangeRate = (newRate).toStringAsFixed(2);
    });
  }

// Lifecycle Methods
  @override
  void initState() {
    super.initState();
    // set the starting state for the app, use Platform to determine what to use as initalSelection
    var initialSelection = Platform.isIOS ? 0 : 'AUD';
    updateUI(initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CurrencyCard(
                  displayText: '1 BTC = $btcExchangeRate $selectedCurrency'),
              CurrencyCard(
                  displayText: '1 ETH = $ethExchangeRate $selectedCurrency'),
              CurrencyCard(
                  displayText: '1 LTC = $ltcExchangeRate $selectedCurrency'),
            ],
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CurrencyCard extends StatelessWidget {
  String displayText;

  CurrencyCard({@required this.displayText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
