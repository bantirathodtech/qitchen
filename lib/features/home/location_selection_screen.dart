// import 'package:flutter/material.dart';
//
// import '../../../../../common/styles/app_text_styles.dart';
//
// class LocationSelectionScreen extends StatefulWidget {
//   const LocationSelectionScreen({super.key});
//
//   @override
//   State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
// }
//
// class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
//   String? selectedCity;
//   String? selectedArea;
//
//   // Sample data - replace with your actual data
//   final Map<String, List<String>> cityAreas = {
//     'New York': ['Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island'],
//     'Los Angeles': ['Downtown', 'Hollywood', 'Santa Monica', 'Venice', 'Pasadena'],
//     'Chicago': ['Loop', 'Lincoln Park', 'Wicker Park', 'River North', 'Hyde Park'],
//     'Houston': ['Downtown', 'Midtown', 'Museum District', 'Heights', 'Montrose'],
//     'Phoenix': ['Downtown', 'Scottsdale', 'Tempe', 'Mesa', 'Glendale'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text('Select Location',
//             style: AppTextStyles.appBarTitle),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // City dropdown section
//             Text(
//               'Select City',
//               style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             _buildCityDropdown(),
//
//             const SizedBox(height: 24),
//
//             // Area dropdown section (visible only when a city is selected)
//             if (selectedCity != null) ...[
//               Text(
//                 'Select Area in $selectedCity',
//                 style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               _buildAreaDropdown(),
//             ],
//
//             // Spacer to push the Apply button to the bottom
//             const Spacer(),
//
//             // Apply button
//             if (selectedArea != null) ...[
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Return selected location to previous screen
//                     Navigator.pop(
//                         context,
//                         {'city': selectedCity, 'area': selectedArea}
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Apply'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCityDropdown() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: selectedCity,
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           border: InputBorder.none,
//         ),
//         icon: const Icon(Icons.arrow_drop_down),
//         iconSize: 24,
//         elevation: 16,
//         style: AppTextStyles.mediumText,
//         hint: Text('Select a city', style: AppTextStyles.mediumText.copyWith(color: Colors.grey)),
//         isExpanded: true,
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedCity = newValue;
//             selectedArea = null; // Reset area when city changes
//           });
//         },
//         items: cityAreas.keys.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildAreaDropdown() {
//     // Get areas for the selected city
//     final areas = cityAreas[selectedCity] ?? [];
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: selectedArea,
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           border: InputBorder.none,
//         ),
//         icon: const Icon(Icons.arrow_drop_down),
//         iconSize: 24,
//         elevation: 16,
//         style: AppTextStyles.mediumText,
//         hint: Text('Select an area', style: AppTextStyles.mediumText.copyWith(color: Colors.grey)),
//         isExpanded: true,
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedArea = newValue;
//           });
//         },
//         items: areas.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import '../../common/styles/ElevatedButton.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: const Color(0xFF4A148C), // Deep purple color like in the reference
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // title: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     const Icon(Icons.business, color: Colors.orange), // Building icon in orange
        //     const SizedBox(width: 8),
        //     Text('HCL', // or your company name
        //         style: AppTextStyles.appBarTitle.copyWith(color: Colors.white)),
        //     const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        //   ],
        // ),
        // centerTitle: true,
        // elevation: 0,
      ),
      body: Column(
        children: [
          // Background with illustration
          Container(
            height: 260,
            width: double.infinity,
            // color: const Color(0xFF4A148C), // Same purple as AppBar
            color:  Colors.white, // Same purple as AppBar
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'assets/images/location_illustration.png', // You'll need to add this image
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is missing
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

          // Selection area (white background) - FIXED NEGATIVE MARGIN
          Expanded(
            child: Stack(
              children: [
                // This creates the curved white container that overlaps the purple background
                Positioned(
                  top: -20, // Overlap with the purple area
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

                // Content inside the white container
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

                      // City dropdown
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

                      // Area dropdown
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

                      // Default location checkbox
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

                      // Proceed button using CustomElevatedButton
                      CustomElevatedButton(
                        text: 'Proceed',
                        color: selectedCity != null && selectedArea != null
                            ? const Color(0xFF4A148C)
                            : Colors.grey, // Use grey for disabled state
                        height: 50,
                        onPressed: () {
                          // In LocationSelectionScreen, ensure the returned values are not null
                          if (selectedCity != null && selectedArea != null) {
                            print('Returning data: City: $selectedCity, Area: $selectedArea');

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
                          // Do nothing if selections are incomplete
                        },
                      ),

                      const SizedBox(height: 16), // Bottom spacing
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
    // Get areas for the selected city
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


//TODO: This is without dropdown normal button type all city with all area
// import 'package:flutter/material.dart';
//
// import '../../../../../common/styles/app_text_styles.dart';
//
// class LocationSelectionScreen extends StatefulWidget {
//   const LocationSelectionScreen({super.key});
//
//   @override
//   State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
// }
//
// class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
//   String? selectedCity;
//   String? selectedArea;
//
//   // Sample data - replace with your actual data
//   final Map<String, List<String>> cityAreas = {
//     'New York': ['Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island'],
//     'Los Angeles': ['Downtown', 'Hollywood', 'Santa Monica', 'Venice', 'Pasadena'],
//     'Chicago': ['Loop', 'Lincoln Park', 'Wicker Park', 'River North', 'Hyde Park'],
//     'Houston': ['Downtown', 'Midtown', 'Museum District', 'Heights', 'Montrose'],
//     'Phoenix': ['Downtown', 'Scottsdale', 'Tempe', 'Mesa', 'Glendale'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       // backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text('Select Location',
//         style: AppTextStyles.appBarTitle),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select City',
//               style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//
//             // City selection grid
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 2.5,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: cityAreas.keys.length,
//                 itemBuilder: (context, index) {
//                   final city = cityAreas.keys.elementAt(index);
//                   return _buildCityCard(city);
//                 },
//               ),
//             ),
//
//             // Area selection section (visible only when a city is selected)
//             if (selectedCity != null) ...[
//               const SizedBox(height: 24),
//               Text(
//                 'Select Area in $selectedCity',
//                 style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: cityAreas[selectedCity]?.length ?? 0,
//                   itemBuilder: (context, index) {
//                     final area = cityAreas[selectedCity]![index];
//                     return _buildAreaCard(area);
//                   },
//                 ),
//               ),
//             ],
//
//             // Apply button
//             if (selectedArea != null) ...[
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Return selected location to previous screen
//                     Navigator.pop(
//                         context,
//                         {'city': selectedCity, 'area': selectedArea}
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Apply'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCityCard(String city) {
//     final isSelected = city == selectedCity;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedCity = city;
//           selectedArea = null;
//         });
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(
//             color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
//             width: 2,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             city,
//             style: AppTextStyles.h5.copyWith(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAreaCard(String area) {
//     final isSelected = area == selectedArea;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedArea = area;
//         });
//       },
//       child: Card(
//         elevation: 1,
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(
//             color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
//             width: 2,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Text(
//             area,
//             style: AppTextStyles.h6.copyWith(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }