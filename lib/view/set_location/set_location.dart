import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/set_location_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class SetLocation extends StatelessWidget {
  const SetLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Consumer<LocationProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Top Image Section
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/login.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Select Your Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Switch on your location to stay in tune with\nwhat’s happening in your area",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Zone Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Your Zone",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: provider.selectedZone,
                    items:
                        provider.zones.map((zone) {
                          return DropdownMenuItem(
                            value: zone,
                            child: Text(zone),
                          );
                        }).toList(),
                    onChanged: (value) {
                      provider.updateZone(value);
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Area Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Your Area",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: provider.selectedArea,
                    items:
                        provider.areas.map((area) {
                          return DropdownMenuItem(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                    onChanged: (value) {
                      provider.updateArea(value);
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Pincode Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter Pincode",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      provider.updatePincode(value);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                      log(
                        "Zone: ${provider.selectedZone}, Area: ${provider.selectedArea}, Pincode: ${provider.pincode}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
