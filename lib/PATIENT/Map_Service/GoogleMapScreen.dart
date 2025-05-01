import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/ServiceListScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/SubcategoryScreen.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_sanar_proj/PATIENT/Services/SubcategoryServicdeScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/helper/app_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_gradiant_text_widget.dart';

class GoogleMapScreen extends StatefulWidget {
  final String serviceName;
  final String servicePhotoUrl = "assets/icons/appoint.png";
  final String serviceDescription = "This is an example service description.";

  const GoogleMapScreen({super.key, required this.serviceName});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation =
      const LatLng(37.7749, -122.4194); // Default location
  bool _loadingLocation = false;
  bool _isloadingSumbit = false;
  // Get current user location
  Future<void> _getUserLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _loadingLocation = false;
        });
        AppHelper.errorSnackBar(
            context: context,
            message:
                "Location services are disabled. Please enable them in settings.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _loadingLocation = false;
          });
          AppHelper.errorSnackBar(
              context: context,
              message: "Location permission is required to use this feature.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
        });
        AppHelper.errorSnackBar(
            context: context,
            message:
                "Location permissions are permanently denied. Please allow them in settings.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = userLocation;
        _loadingLocation = false;
      });

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation, zoom: 14.0),
        ),
      );
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      AppHelper.errorSnackBar(
          context: context, message: "Error fetching location");
    }
  }

  Future<void> _submitLocation() async {
    setState(() {
      _isloadingSumbit = true;
    });
    final url = Uri.parse('http://67.205.166.136/api/locations/add/');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access');
    int? userId = prefs.getInt('userId');
    int? serviceId = prefs.getInt('serviceId');

    if (token == null || userId == null || serviceId == null) {
      debugPrint('Token, User ID, or Service ID is null. Please log in again.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required. Please log in again.'),
        ),
      );
      return;
    }

    final requestBody = json.encode({
      "latitude": _selectedLocation.latitude,
      "longitude": _selectedLocation.longitude,
      "address": "",
      "city": "",
      "country": "",
      "location_type": "home",
      "user": userId,
      "service_id": serviceId,
    });

    debugPrint('Submitting the following data:');
    debugPrint('Latitude: ${_selectedLocation.latitude}');
    debugPrint('Longitude: ${_selectedLocation.longitude}');
    debugPrint('Location Type: home');
    debugPrint('User ID: $userId');
    debugPrint('Token: $token');

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN':
              'pLLaxt3c2AzIdLiPZZmJiSoeqZ2NJuEzooSFyFohxcpZDWvpj8o7TQWTRi1Kp1O8',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) {
        // Fetch service categories to determine navigation
        final services = await fetchServices();
        final selectedService = services.firstWhere(
          (service) => service['id'] == serviceId,
          orElse: () => {},
        );

        if (selectedService.isEmpty) {
          debugPrint('Service not found.');
          AppHelper.errorSnackBar(
              context: context, message: "Service not found.");
          return;
        }
        AppHelper.successSnackBar(
            context: context, message: "Location submited successful!");

        // Handle navigation based on subcategory_ids and service_ids
        final subcategoryIds = selectedService['subcategory_ids'] as List;
        final serviceIds = selectedService['service_ids'] as List<dynamic>;

        // Cast to List<Map<String, dynamic>>
        List<Map<String, dynamic>> serviceList = serviceIds.map((id) {
          return {
            'id': id['id'],
            'name': id['name'],
            'description': id['description'],
            'price': id['price'],
            'image': id['image'],
          };
        }).toList();

        // Fetch service categories to determine navigation
        debugPrint('subcategoryIds $subcategoryIds');
        debugPrint('serviceList $serviceList');

        if (subcategoryIds.isEmpty && serviceList.isEmpty) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ServiceDetailsScreen(
          //       service: selectedService,
          //     ),
          //   ),
          // );
          debugPrint(' subcategoryIds $subcategoryIds');
          debugPrint(' serviceList $serviceList');
        } else if (subcategoryIds.isNotEmpty && serviceList.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubcategoryScreen(
                subcategoryIds: List<Map<String, dynamic>>.from(subcategoryIds),
                // serviceIds: serviceList,
              ),
            ),
          );

          debugPrint('subcategoryIds $subcategoryIds');
          debugPrint('serviceList $serviceList');
        } else if (subcategoryIds.isEmpty && serviceList.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceListScreen(
                serviceIds: serviceList,
              ),
            ),
          );
        } else {
          AppHelper.errorSnackBar(
              context: context, message: "Unknown service configuration.");
          debugPrint('subcategoryIds $subcategoryIds');
          debugPrint('serviceList $serviceList');
        }
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['detail'] ?? 'An error occurred.';
        AppHelper.errorSnackBar(
            context: context, message: "Error: $errorMessage");
      }
    } catch (e) {
      debugPrint('Exception: $e');
      AppHelper.errorSnackBar(context: context, message: "Exception: $e");
    }
    setState(() {
      _isloadingSumbit = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final url = Uri.parse('http://67.205.166.136/api/service-categories/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final results = data['results'] as List;

      return results.map((service) {
        return {
          'id': service['id'],
          'name': service['name'] ?? 'Unknown Service',
          'description': service['description'] ?? '',
          'image': service['image'] ?? '',
          'subcategory_ids': service['subcategory_ids'] ?? [],
          'service_ids': service['service_ids'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<List<int>> _getServiceIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you stored service IDs as a string list
    List<String>? serviceIdStrings = prefs.getStringList('serviceIds');
    return serviceIdStrings?.map(int.parse).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 12.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("selected_location"),
                position: _selectedLocation,
                draggable: true,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed, // Change this to the desired color
                ),
                onDragEnd: (newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                },
              ),
            },
          ),
          if (_loadingLocation)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomGradiantTextWidget(
                      text: 'Find Your Location',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomGradiantIconWidget(icon: Icons.place),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Drag the marker to select your location.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButtonNew(
                    title: 'Confirm Location',
                    isLoading: _isloadingSumbit,
                    isBackgroundPrimary: true,
                    onPressed:
                        _submitLocation, // Call the submitLocation method
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getUserLocation,
              backgroundColor: Constant.primaryColor,
              elevation: 4,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
