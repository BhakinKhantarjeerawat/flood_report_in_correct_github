import 'package:flutter/material.dart';
import '../models/flood.dart';

class MarkerSearchFilter extends StatefulWidget {
  final List<Flood> allMarkers;
  final Function(List<Flood>) onFilterChanged;
  final VoidCallback onClearFilters;

  const MarkerSearchFilter({
    super.key,
    required this.allMarkers,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<MarkerSearchFilter> createState() => _MarkerSearchFilterState();
}

class _MarkerSearchFilterState extends State<MarkerSearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSeverity;
  String? _selectedDateFilter;
  String? _selectedDepthFilter;
  bool _isExpanded = false;

  final List<String> _severityOptions = ['passable', 'blocked', 'severe'];
  final List<String> _dateFilterOptions = ['All Time', 'Last Hour', 'Last 6 Hours', 'Today', 'This Week'];
  final List<String> _depthFilterOptions = ['Any Depth', 'Shallow (< 10cm)', 'Medium (10-30cm)', 'Deep (> 30cm)'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<Flood> filteredMarkers = widget.allMarkers.where((marker) {
      // Text search
      if (_searchController.text.isNotEmpty) {
        bool textMatch = marker.note?.toLowerCase().contains(_searchController.text.toLowerCase()) == true ||
                        _getLocationName(marker.lat, marker.lng).toLowerCase().contains(_searchController.text.toLowerCase());
        if (!textMatch) return false;
      }

      // Severity filter
      if (_selectedSeverity != null && marker.severity != _selectedSeverity) {
        return false;
      }

      // Date filter
      if (_selectedDateFilter != null) {
        if (!_matchesDateFilter(marker.createdAt, _selectedDateFilter!)) {
          return false;
        }
      }

      // Depth filter
      if (_selectedDepthFilter != null && marker.depthCm != null) {
        if (!_matchesDepthFilter(marker.depthCm!, _selectedDepthFilter!)) {
          return false;
        }
      }

      return true;
    }).toList();

    widget.onFilterChanged(filteredMarkers);
  }

  bool _matchesDateFilter(DateTime createdAt, String filter) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    switch (filter) {
      case 'Last Hour':
        return difference.inHours < 1;
      case 'Last 6 Hours':
        return difference.inHours < 6;
      case 'Today':
        return createdAt.day == now.day && createdAt.month == now.month && createdAt.year == now.year;
      case 'This Week':
        return difference.inDays < 7;
      default:
        return true;
    }
  }

  bool _matchesDepthFilter(int depthCm, String filter) {
    switch (filter) {
      case 'Shallow (< 10cm)':
        return depthCm < 10;
      case 'Medium (10-30cm)':
        return depthCm >= 10 && depthCm <= 30;
      case 'Deep (> 30cm)':
        return depthCm > 30;
      default:
        return true;
    }
  }

  String _getLocationName(double lat, double lng) {
    // Simple location names for Bangkok area
    if (lat >= 13.7 && lat <= 13.8 && lng >= 100.5 && lng <= 100.6) {
      return 'Bangkok City Center';
    } else if (lat >= 13.6 && lat <= 13.7 && lng >= 100.4 && lng <= 100.5) {
      return 'Bangkok South';
    } else if (lat >= 13.8 && lat <= 13.9 && lng >= 100.5 && lng <= 100.6) {
      return 'Bangkok North';
    } else {
      return 'Bangkok Area';
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedSeverity = null;
      _selectedDateFilter = null;
      _selectedDepthFilter = null;
    });
    widget.onClearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by location or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          // Expand/Collapse Button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Filters',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          // Advanced Filters
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Severity Filter
                  _buildFilterDropdown(
                    label: 'Severity',
                    value: _selectedSeverity,
                    items: _severityOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeverity = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8.0),

                  // Date Filter
                  _buildFilterDropdown(
                    label: 'Date',
                    value: _selectedDateFilter,
                    items: _dateFilterOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedDateFilter = value;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8.0),

                  // Depth Filter
                  _buildFilterDropdown(
                    label: 'Depth',
                    value: _selectedDepthFilter,
                    items: _depthFilterOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepthFilter = value;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),
          ],

          // Clear Filters Button
          if (_searchController.text.isNotEmpty || _selectedSeverity != null || _selectedDateFilter != null || _selectedDepthFilter != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Filters'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
            hint: Text('Any $label'),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Any $label'),
              ),
              ...items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              )),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
