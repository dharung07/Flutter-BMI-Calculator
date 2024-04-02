import 'dart:math';

import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BmiCalculator());
}

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  SharedPreferences? _sharedPreferences;
  num _weight = 0, _height = 0, _bmi = 0;
  List<String> _bmiHistory = <String>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _sharedPreferences = value;
        _weight = _sharedPreferences!.getDouble("weight") ?? 0;
        _height = _sharedPreferences!.getDouble("height") ?? 0;
        _bmi = _sharedPreferences!.getDouble("bmi") ?? 0;
        _bmiHistory = _sharedPreferences!.getStringList("bmi_history") ?? [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    if (_sharedPreferences == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Set border color
                    width: 1, // Set border width
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_bmi.toStringAsFixed(2)} BMI',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        weightInput(),
                        const SizedBox(width: 30),
                        heightInput(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    bmiCalculateButton(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'History',
                style: TextStyle(fontSize: 24),
              ),
              bmiHistoryTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget weightInput() {
    return Column(
      children: [
        const Text(
          'Weight (kg)',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5),
        InputQty(
          maxVal: double.infinity,
          minVal: 1,
          initVal: _weight,
          steps: 1,
          onQtyChanged: (value) {
            setState(() {
              _weight = value;
              _sharedPreferences!.setDouble("weight", _weight.toDouble());
            });
          },
        ),
      ],
    );
  }

  Widget heightInput() {
    return Column(
      children: [
        const Text(
          'Height (m)',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5),
        InputQty(
          maxVal: double.infinity,
          minVal: 1,
          initVal: _height,
          steps: 1,
          onQtyChanged: (value) {
            _height = value;
            _sharedPreferences!.setDouble("height", _height.toDouble());
          },
        ),
      ],
    );
  }

  Widget bmiCalculateButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _bmi = _weight * pow(_height, 2);
          _sharedPreferences!.setDouble("bmi", _bmi.toDouble());
          _bmiHistory.add(_bmi.toStringAsFixed(2));
          _sharedPreferences!.setStringList("bmi_history", _bmiHistory);
        });
      },
      child: const Text('Calculate'),
    );
  }

  Widget bmiHistoryTile() {
    return Expanded(
      child: ListView.builder(
        itemCount: _bmiHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_bmiHistory[index]),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _bmiHistory.removeAt(index);
                  _sharedPreferences!.setStringList("bmi_history", _bmiHistory);
                });
              },
              icon: const Icon(Icons.delete),
            ),
          );
        },
      ),
    );
  }
}
