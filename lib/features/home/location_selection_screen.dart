import 'package:flutter/material.dart';
import '../../common/styles/ElevatedButton.dart';
import '../../data/db/app_preferences.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? selectedCity;
  String? selectedArea;

  // Sample data - replace with your actual data
  final Map<String, List<String>> cityAreas = {
    'Channai': ['Airhant 8th Floor', 'AMB 6', 'Ambattur 5', 'Elcot Sez Cafe', 'EAT3 B1', 'Ozone 5th Floor', 'Ozone 6th Floor'],
    'Bangalore': ['Koramangala', 'Electronic City', 'Whitefield', 'HSR Layout'],
    'Mumbai': ['Powai', 'Bandra', 'Andheri', 'Goregaon'],
    'Delhi': ['Connaught Place', 'Gurgaon', 'Noida', 'Saket'],
  };

  bool setAsDefault = false;

  @override
  void initState() {
    super.initState();
    // _loadSavedLocation();
  }

  // // Load the previously saved location
  // Future<void> _loadSavedLocation() async {
  //   final savedLocation = await LocationPaymentPreference.getSelectedLocation();
  //   setState(() {
  //     selectedCity = savedLocation['city'];
  //     selectedArea = savedLocation['area'];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'assets/images/location_illustration.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_city, size: 80, color: Colors.black),
                        SizedBox(height: 16),
                        Text('Select your location',
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight:FontWeight.w600),),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select your city & cafeteria',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'City',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCityDropdown(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cafeteria',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAreaDropdown(),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Checkbox(
                            value: setAsDefault,
                            onChanged: (value) {
                              setState(() {
                                setAsDefault = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF4A148C),
                          ),
                          const Expanded(
                            child: Text(
                              'Set this location as your default cafeteria.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      CustomElevatedButton(
                        text: 'Proceed',
                        color: selectedCity != null && selectedArea != null
                            ? const Color(0xFF4A148C)
                            : Colors.grey,
                        height: 50,
                        onPressed: () async {
                          if (selectedCity != null && selectedArea != null) {
                            // Save location if set as default or always save for persistence
                            if (setAsDefault || true) {
                              await AppPreference.saveSelectedLocation(
                                selectedCity!,
                                selectedArea!,
                              );
                            }

                            // Return selected location to previous screen
                            Navigator.pop(
                              context,
                              {
                                'city': selectedCity,
                                'area': selectedArea,
                                'isDefault': setAsDefault,
                              },
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        icon: const Icon(Icons.keyboard_arrow_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        hint: const Text('Select a city',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            selectedCity = newValue;
            selectedArea = null; // Reset area when city changes
          });
        },
        items: cityAreas.keys.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAreaDropdown() {
    final areas = cityAreas[selectedCity] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedArea,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        icon: const Icon(Icons.keyboard_arrow_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        hint: const Text('Select a cafeteria',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        isExpanded: true,
        onChanged: selectedCity == null
            ? null
            : (String? newValue) {
          setState(() {
            selectedArea = newValue;
          });
        },
        items: areas.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}