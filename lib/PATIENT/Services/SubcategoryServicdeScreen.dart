// import 'dart:convert';
// import 'package:flutter_sanar_proj/PATIENT/Services/SubcategoryDetails.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class SubcategoryServiceScreen extends StatelessWidget {
//   final int serviceId;

//   const SubcategoryServiceScreen({
//     Key? key,
//     required this.serviceId,
//   }) : super(key: key);

//   Future<List<Map<String, dynamic>>> fetchSubcategories() async {
//     final url = Uri.parse(
//         'http://164.92.111.149/api/categories/$serviceId/subcategories/?page=1');
//     final response = await http.get(
//       url,
//       headers: {
//         'accept': 'application/json',
//         'X-CSRFTOKEN':
//             'r5Uzlk2Ot2KURxZjmQklJFSwP0zPyq3GqI14mwnTYEAbhIcTGZmJkDqbgjyMeXdf',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final results = data['results'] as List;

//       return results.map((subcategory) {
//         return {
//           'id': subcategory['id'],
//           'name': subcategory['name'],
//           'description': subcategory['description'],
//           'image': subcategory['image'],
//           'services': subcategory['service_ids'].map((service) {
//             return {
//               'id': service['id'],
//               'name': service['name'],
//               'description': service['description'],
//               'price': service['price'],
//               'duration': service['duration'],
//               'image': service['image'],
//             };
//           }).toList(),
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load subcategories');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Laboratory Services'),
//         backgroundColor: Colors.white,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchSubcategories(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildShimmerEffect(
//                 screenWidth, screenHeight); // Show shimmer effect
//           } else if (snapshot.hasError) {
//             return const Center(
//                 child: Text('Failed to load subcategories',
//                     style: TextStyle(color: Colors.red)));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No subcategories available'));
//           }

//           final subCategories = snapshot.data!;
//           return ListView.builder(
//             itemCount: subCategories.length,
//             itemBuilder: (context, index) {
//               final subCategory = subCategories[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(
//                   vertical: screenHeight * 0.01,
//                   horizontal: screenWidth * 0.04,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: EdgeInsets.all(screenWidth * 0.04),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Subcategory Title with "See All"
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     subCategory['name'].split(
//                                         ' ')[0], // First part of the name
//                                     style: TextStyle(
//                                       fontSize: screenWidth *
//                                           0.035, // Adjusted font size
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.teal,
//                                     ),
//                                   ),
//                                   Text(
//                                     subCategory['name'].split(
//                                         ' ')[1], // Second part of the name
//                                     style: TextStyle(
//                                       fontSize: screenWidth *
//                                           0.035, // Adjusted font size
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.teal,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 subCategory['name']
//                                     .split(' ')
//                                     .sublist(2)
//                                     .join(' '), // Remaining part of the name
//                                 style: TextStyle(
//                                   fontSize:
//                                       screenWidth * 0.035, // Adjusted font size
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.teal,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SubcategoryDetails(
//                                     subcategory: subCategory,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'See All',
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.04,
//                                 color: Colors.blue,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: screenHeight * 0.01),

//                       // Horizontal List of Service Items
//                       Container(
//                         height: screenHeight *
//                             0.15, // Adjusted height for the row of services
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: subCategory['services'].length,
//                           itemBuilder: (context, serviceIndex) {
//                             final service =
//                                 subCategory['services'][serviceIndex];
//                             return GestureDetector(
//                               onTap: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //     builder: (context) => ServiceDetailsScreen(
//                                 //       service: service,
//                                 //     ),
//                                 //   ),
//                                 // );
//                               },
//                               child: Padding(
//                                 padding:
//                                     EdgeInsets.only(right: screenWidth * 0.04),
//                                 child: Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 4,
//                                   color: Colors.white,
//                                   child: Container(
//                                     width: screenWidth *
//                                         0.4, // Increased width for each service item
//                                     padding: EdgeInsets.all(
//                                         screenWidth * 0.03), // Adjusted padding
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons
//                                               .medical_services, // Placeholder icon
//                                           size: screenWidth *
//                                               0.1, // Adjusted icon size
//                                           color: Colors.teal,
//                                         ), // Icon for service
//                                         SizedBox(
//                                             height: screenHeight *
//                                                 0.015), // Adjusted spacing
//                                         Text(
//                                           service['name'],
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: screenWidth *
//                                                 0.025, // Adjusted font size
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // Shimmer effect for loading subcategories
//   Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView.builder(
//         itemCount: 4, // Number of shimmer items
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Card(
//               margin: EdgeInsets.symmetric(
//                 vertical: screenHeight * 0.01,
//                 horizontal: screenWidth * 0.04,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.04),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Shimmer for subcategory title
//                     Container(
//                       height: 20,
//                       width: screenWidth * 0.5,
//                       color: Colors.white,
//                     ),
//                     SizedBox(height: screenHeight * 0.01),
//                     // Shimmer for horizontal list of services
//                     Container(
//                       height: screenHeight * 0.15,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: 3, // Number of shimmer services
//                         itemBuilder: (context, serviceIndex) {
//                           return Container(
//                             width: screenWidth * 0.4,
//                             margin: EdgeInsets.only(right: screenWidth * 0.04),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   height: 40,
//                                   width: 40,
//                                   color: Colors.white,
//                                 ),
//                                 SizedBox(height: screenHeight * 0.015),
//                                 Container(
//                                   height: 14,
//                                   width: screenWidth * 0.3,
//                                   color: Colors.white,
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
