import 'package:flutter/material.dart';

enum CustomerDestination { home, services, requests, profile }

extension CustomerDestinationPresentation on CustomerDestination {
  String get label => switch (this) {
    CustomerDestination.home => 'Home',
    CustomerDestination.services => 'Services',
    CustomerDestination.requests => 'Requests',
    CustomerDestination.profile => 'Profile',
  };

  IconData get icon => switch (this) {
    CustomerDestination.home => Icons.home_outlined,
    CustomerDestination.services => Icons.grid_view_outlined,
    CustomerDestination.requests => Icons.list_alt_outlined,
    CustomerDestination.profile => Icons.person_outline,
  };

  String get placeholderTitle => switch (this) {
    CustomerDestination.home => 'Home content is being prepared',
    CustomerDestination.services => 'Services content is being prepared',
    CustomerDestination.requests => 'No requests yet',
    CustomerDestination.profile => 'Profile content is being prepared',
  };

  String get placeholderMessage => switch (this) {
    CustomerDestination.requests => 'Your service requests will appear here.',
    _ => 'This destination is ready for its feature owner.',
  };
}
