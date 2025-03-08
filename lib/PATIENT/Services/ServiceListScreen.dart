// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'ServiceDetailScreen.dart';

class ServiceListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> serviceIds;

  const ServiceListScreen({Key? key, required this.serviceIds})
      : super(key: key);

  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    // fetchServices();
  }

  // Future<void> fetchServices() async {
  //   const url = 'http://164.92.111.149/api/service-categories/';
  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'accept': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final List<dynamic> allServices = data['service_ids'] ?? [];

  //     setState(() {
  //       services = allServices
  //           .map((service) => service as Map<String, dynamic>)
  //           .toList();
  //     });
  //   } else {
  //     print("Failed to load services: ${response.statusCode}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final cardHeight =
        screenHeight * 0.45; // Increased height to 45% of screen height
    final imageHeight = cardHeight * 0.6; // 60% of card height
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    final fontSize = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Our Services',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.06, // 6% of screen width
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(horizontalPadding),
        itemCount: (widget.serviceIds.length / 2).ceil(),
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                child: ServiceCard(
                  service: widget.serviceIds[index * 2],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailScreen(
                        serviceId: widget.serviceIds[index * 2]['id'],
                      ),
                    ),
                  ),
                  cardHeight: cardHeight,
                  imageHeight: imageHeight,
                  fontSize: fontSize,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: horizontalPadding),
              Expanded(
                child: index * 2 + 1 < widget.serviceIds.length
                    ? ServiceCard(
                        service: widget.serviceIds[index * 2 + 1],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailScreen(
                              serviceId: widget.serviceIds[index * 2 + 1]['id'],
                            ),
                          ),
                        ),
                        cardHeight: cardHeight,
                        imageHeight: imageHeight,
                        fontSize: fontSize,
                        isSmallScreen: isSmallScreen,
                      )
                    : const SizedBox(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;
  final double cardHeight;
  final double imageHeight;
  final double fontSize;
  final bool isSmallScreen;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
    required this.cardHeight,
    required this.imageHeight,
    required this.fontSize,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: fontSize),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(fontSize),
            border: Border.all(
              color: Colors.teal.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: fontSize / 2,
                offset: Offset(0, fontSize / 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(fontSize),
                    topRight: Radius.circular(fontSize),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      service['image'] != null
                          ? 'http://67.205.166.136${service['image']}'
                          : 'https://via.placeholder.com/150',
                    ),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.all(fontSize * 0.75),
                    padding: EdgeInsets.symmetric(
                      horizontal: fontSize * 0.75,
                      vertical: fontSize * 0.375,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(fontSize * 1.25),
                    ),
                    child: Text(
                      "\$${(service['price'] as num).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? fontSize * 0.8 : fontSize,
                      ),
                    ),
                  ),
                ),
              ),
              // Content Container
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(fontSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Service Name
                      Text(
                        service['name'] ?? '',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? fontSize * 1.1 : fontSize * 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Book Now Button
                      Container(
                        width: double.infinity,
                        height: fontSize * 2.5,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(fontSize * 0.75),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Book Now',
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontSize:
                                    isSmallScreen ? fontSize : fontSize * 1.1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: fontSize * 0.5),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.teal.shade700,
                              size: isSmallScreen
                                  ? fontSize * 1.2
                                  : fontSize * 1.4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
