 import 'package:flutter/material.dart';

/// Get marker icon based on severity
  Widget getMarkerIcon(String severity) {
    Color color;
    IconData icon;
    
    switch (severity.toLowerCase()) {
      case 'severe':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'blocked':
        color = Colors.orange;
        icon = Icons.block;
        break;
      case 'passable':
      default:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }