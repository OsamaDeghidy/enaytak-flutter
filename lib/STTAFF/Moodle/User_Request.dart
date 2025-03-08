class UserRequest {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String status; // 'accepted', 'refused', 'pending'

  UserRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });
}


List<UserRequest> userRequests = [
  UserRequest(
    id: '1',
    title: 'Meeting with Doctor',
    description: 'Request for a consultation appointment.',
    date: DateTime(2024, 11, 25, 10, 0),
    status: 'pending', // Or 'accepted' or 'refused'
  ),
  UserRequest(
    id: '2',
    title: 'Follow-up Appointment',
    description: 'Follow-up after surgery.',
    date: DateTime(2024, 11, 26, 14, 30),
    status: 'accepted',
  ),
  // Add more requests here
];
