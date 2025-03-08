import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? provider; // Optional provider parameter

  const UserDetailsScreen({
    required this.user,
    this.provider,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${provider?['name'] ?? 'No name available'}'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserSection(),
            const SizedBox(height: 24),
            _buildProviderSection()
          ],
        ),
      ),
    );
  }

  // User Details Section
  Widget _buildUserSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user['profile_image'] != null &&
                        user['profile_image'].isNotEmpty
                    ? NetworkImage(user['profile_image'])
                    : null,
                backgroundColor: Colors.grey[200],
                child: user['profile_image'] == null ||
                        user['profile_image'].isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // User Name
            const Text(
              'User Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            // User Type
            _buildDetailRow(
                'Full Name', user['full_name'] ?? 'No email available'),
            _buildDetailRow('Email', user['email'] ?? 'No email available'),
            _buildDetailRow(
                'Phone', user['phone_number'] ?? 'No phone number available'),
          ],
        ),
      ),
    );
  }

  // Provider Details Section
  Widget _buildProviderSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            // Provider Name
            _buildDetailRow('Name', provider?['name'] ?? 'No name available'),
            _buildDetailRow(
                'Address', provider?['address'] ?? 'No address available'),
            _buildDetailRow('Phone',
                provider?['phone_number'] ?? 'No phone number available'),
            _buildDetailRow(
                'Email', provider?['email'] ?? 'No email available'),
            _buildDetailRow('Bio', provider?['bio'] ?? 'No bio available'),
            _buildDetailRow('Verification Status',
                provider?['verification_status'] ?? 'Not verified'),
            if (provider?['services'] != null &&
                provider?['services'].isNotEmpty)
              _buildDetailRow(
                'Services',
                provider?['services'].join(', ') ?? 'No services available',
              ),
          ],
        ),
      ),
    );
  }

  // Utility Method for Building Rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.teal.shade300,
          ),
          const SizedBox(width: 8),
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.teal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
