// lib/views/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_driver_app/viewmodels/auth_viewmodel.dart';
import 'package:delivery_driver_app/viewmodels/profile_viewmodel.dart';
import 'package:delivery_driver_app/views/widgets/custom_app_bar.dart';
import 'package:delivery_driver_app/views/widgets/loading_indicator.dart';
import 'package:delivery_driver_app/views/widgets/action_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Driver Profile',
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, _) {
          if (profileViewModel.isLoading) {
            return const LoadingIndicator();
          }

          final driver = profileViewModel.driver;
          if (driver == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to load profile',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileViewModel.refreshProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, driver.name, driver.profileImageUrl),
                const SizedBox(height: 24),
                _buildProfileDetails(context, driver.email, driver.phoneNumber),
                const SizedBox(height: 24),
                _buildAssignedRoutes(context, driver.assignedRoutes),
                const SizedBox(height: 24),
                _buildLastLocation(
                  context,
                  driver.lastLatitude,
                  driver.lastLongitude,
                  driver.lastLocationUpdate,
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String? imageUrl) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Delivery Driver',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, String email, String phoneNumber) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.email,
              title: 'Email',
              value: email,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: phoneNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedRoutes(BuildContext context, List<String> routes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Routes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (routes.isEmpty)
              const Text(
                'No routes assigned yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: routes.map((route) {
                  return Chip(
                    label: Text(route),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[100]!),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastLocation(
    BuildContext context,
    double? latitude,
    double? longitude,
    DateTime? lastUpdate,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Known Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (latitude == null || longitude == null)
              const Text(
                'Location not yet recorded',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.location_on,
                    title: 'Coordinates',
                    value: '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  ),
                  if (lastUpdate != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      title: 'Last Updated',
                      value: _formatDateTime(lastUpdate),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    return ActionButton(
      label: 'Log Out',
      icon: Icons.logout,
      onPressed: () => _showLogoutConfirmation(context, authViewModel),
      isFullWidth: true,
      color: Colors.red,
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('LOG OUT'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}