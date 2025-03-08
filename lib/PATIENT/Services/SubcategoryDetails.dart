// import 'package:flutter/material.dart';

// class SubcategoryDetails extends StatelessWidget {
//   final Map<String, dynamic> subcategory;

//   const SubcategoryDetails({Key? key, required this.subcategory})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           subcategory['name'], // Display subcategory name in AppBar
//           style: TextStyle(
//             fontSize: screenWidth * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.05),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                 child: Text(
//                   "Available Services",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),

//               // Vertical List of Services
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: subcategory['services'].length,
//                 itemBuilder: (context, index) {
//                   final service = subcategory['services'][index];
//                   return GestureDetector(
//                     onTap: () {
//                       // Navigate to ServiceDetailsScreen with the service ID
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) => ServiceDetailsScreen(
//                       //       service: service, // Pass the service data
//                       //     ),
//                       //   ),
//                       // );
//                     },
//                     child: Card(
//                       margin:
//                           EdgeInsets.symmetric(vertical: screenHeight * 0.01),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 4,
//                       child: Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Service Image
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 service['image'] ??
//                                     'https://via.placeholder.com/150',
//                                 height: screenWidth * 0.2,
//                                 width: screenWidth * 0.2,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Icon(
//                                     Icons.broken_image,
//                                     size: screenWidth * 0.2,
//                                     color: Colors.grey,
//                                   );
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: screenWidth * 0.04),

//                             // Service Details
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     service['name'],
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.05,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   SizedBox(height: screenHeight * 0.005),
//                                   Text(
//                                     service['description'] ??
//                                         'No description available',
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.035,
//                                       color: Colors.grey[700],
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Action Icon
//                             Icon(
//                               Icons.arrow_forward_ios,
//                               color: Colors.teal,
//                               size: screenWidth * 0.05,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
