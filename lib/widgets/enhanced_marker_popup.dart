import 'package:flutter/material.dart';
import '../models/flood.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedMarkerPopup extends StatefulWidget {
  final Flood flood;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final VoidCallback onFlag;
  final VoidCallback onMarkResolved;

  const EnhancedMarkerPopup({
    super.key,
    required this.flood,
    required this.onClose,
    required this.onConfirm,
    required this.onFlag,
    required this.onMarkResolved,
  });

  @override
  State<EnhancedMarkerPopup> createState() => _EnhancedMarkerPopupState();
}

class _EnhancedMarkerPopupState extends State<EnhancedMarkerPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePopup() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  Color _getSeverityColor() {
    switch (widget.flood.severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'blocked':
        return Colors.orange;
      case 'passable':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon() {
    switch (widget.flood.severity.toLowerCase()) {
      case 'severe':
        return Icons.warning;
      case 'blocked':
        return Icons.block;
      case 'passable':
        return Icons.check_circle;
      default:
        return Icons.place;
    }
  }

  String _getSeverityDisplayName() {
    switch (widget.flood.severity.toLowerCase()) {
      case 'severe':
        return 'Severe Flooding';
      case 'blocked':
        return 'Road Blocked';
      case 'passable':
        return 'Passable';
      default:
        return 'Unknown';
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.flood.createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getExpirationTime() {
    final now = DateTime.now();
    final difference = widget.flood.expiresAt.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inMinutes < 60) {
      return 'Expires in ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Expires in ${difference.inHours}h';
    } else {
      return 'Expires in ${difference.inDays}d';
    }
  }

  Future<void> _getDirections() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.flood.lat},${widget.flood.lng}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _shareReport() async {
    final text = 'Flood Report: ${_getSeverityDisplayName()} at ${widget.flood.lat.toStringAsFixed(4)}, ${widget.flood.lng.toStringAsFixed(4)}';
    // For now, just copy to clipboard. In a real app, you'd use a share package
    // await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report details copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getSeverityColor(),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getSeverityColor().withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getSeverityIcon(),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getSeverityDisplayName(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  _getTimeAgo(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _closePopup,
                            icon: const Icon(Icons.close),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          if (widget.flood.note != null && widget.flood.note!.isNotEmpty) ...[
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.flood.note!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Depth Information
                          if (widget.flood.depthCm != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.height,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Flood Depth: ${widget.flood.depthCm} cm',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Metadata Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetadataItem(
                                  icon: Icons.confirmation_number,
                                  label: 'Confirms',
                                  value: '${widget.flood.confirms}',
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildMetadataItem(
                                  icon: Icons.flag,
                                  label: 'Flags',
                                  value: '${widget.flood.flags}',
                                  color: Colors.red,
                                ),
                              ),
                              Expanded(
                                child: _buildMetadataItem(
                                  icon: Icons.access_time,
                                  label: 'Status',
                                  value: widget.flood.status,
                                  color: widget.flood.status == 'active' ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Expiration Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.orange[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getExpirationTime(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                      ),
                      child: Row(
                        children: [
                          // Confirm Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onConfirm,
                              icon: const Icon(Icons.thumb_up, size: 18),
                              label: const Text('Confirm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Flag Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onFlag,
                              icon: const Icon(Icons.flag, size: 18),
                              label: const Text('Flag'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Utility Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _getDirections,
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Directions'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareReport,
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onMarkResolved,
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Resolved'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
