import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:local_guru_all/src/core/data/local/shared_prefs.dart';
import 'package:local_guru_all/src/features/greetings/data/model/greetingsModel.dart';

class GreetingCustomizationScreen extends ConsumerStatefulWidget {
  final GreetingsModel greeting;

  const GreetingCustomizationScreen({
    Key? key,
    required this.greeting,
  }) : super(key: key);

  @override
  ConsumerState<GreetingCustomizationScreen> createState() =>
      _GreetingCustomizationScreenState();
}

class _GreetingCustomizationScreenState
    extends ConsumerState<GreetingCustomizationScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey _stackKey = GlobalKey();

  // Default position: right-bottom with 16 padding
  Offset _textPosition = Offset(0.0, 0.0); // Will be calculated on first build
  double _textSize = 36.0; // Default size 36
  Color _textColor = Colors.white;
  bool _showTextShadow = true;
  bool _isLoading = false;
  bool _isDragging = false;
  bool _isDefaultPosition = true; // Track if using default position

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userName = await SharedPrefs.getUserName();
    if (userName != null && userName.isNotEmpty) {
      _nameController.text = userName;
    } else if (widget.greeting.userName != null &&
        widget.greeting.userName!.isNotEmpty) {
      _nameController.text = widget.greeting.userName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onTextPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onTextPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Convert global position to normalized position (0-1)
      final RenderBox? renderBox =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        final size = renderBox.size;
        
        // Normalize position (0-1) based on image dimensions
        // Keep text within bounds (leave some margin)
        final normalizedX = (localPosition.dx / size.width).clamp(0.1, 0.9);
        final normalizedY = (localPosition.dy / size.height).clamp(0.1, 0.9);
        
        _textPosition = Offset(normalizedX, normalizedY);
        _isDefaultPosition = false; // User has moved it, no longer default
      }
    });
  }

  void _onTextPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  Future<void> _shareGreeting() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Capture screenshot
      final image = await _screenshotController.capture();
      if (image == null) {
        throw Exception('Failed to capture image');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/greeting_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this greeting card!',
        subject: 'Greeting Card',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing greeting: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        title: Text(
          'Customize Greeting',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        elevation: 0,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(FontAwesomeIcons.shareAlt),
              onPressed: _shareGreeting,
              tooltip: 'Share',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Customization controls
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name input
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade700 : Colors.white,
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 12),
                  
                  // Text size slider
                  Row(
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Text Size: ${_textSize.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                            Slider(
                              value: _textSize,
                              min: 24.0,
                              max: 96.0,
                              divisions: 18,
                              onChanged: (value) {
                                setState(() {
                                  _textSize = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Text color and shadow options
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.color_lens),
                          label: Text('Color'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Choose Text Color'),
                                content: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _buildColorOption(Colors.white),
                                    _buildColorOption(Colors.black),
                                    _buildColorOption(Colors.red),
                                    _buildColorOption(Colors.blue),
                                    _buildColorOption(Colors.green),
                                    _buildColorOption(Colors.orange),
                                    _buildColorOption(Colors.purple),
                                    _buildColorOption(Colors.yellow),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            _showTextShadow ? Icons.format_bold : Icons.format_bold_outlined,
                          ),
                          label: Text(_showTextShadow ? 'Shadow On' : 'Shadow Off'),
                          onPressed: () {
                            setState(() {
                              _showTextShadow = !_showTextShadow;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Preview area with draggable text
            Expanded(
              child: Center(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    key: _stackKey,
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final imageWidth = constraints.maxWidth;
                          final imageHeight = constraints.maxHeight;
                          
                          // Calculate text position
                          double textLeft;
                          double textTop;
                          
                          if (_isDefaultPosition && imageWidth > 0 && imageHeight > 0) {
                            // Default position: right-bottom with 16px padding
                            // Estimate text dimensions
                            final text = _nameController.text.trim().isEmpty 
                                ? 'Tap to add name' 
                                : _nameController.text;
                            final estimatedTextWidth = _textSize * text.length * 0.55 + 32; // +32 for container padding
                            final estimatedTextHeight = _textSize * 1.3 + 24; // +24 for container padding
                            
                            // Position from right-bottom with 16px padding
                            textLeft = imageWidth - estimatedTextWidth - 16;
                            textTop = imageHeight - estimatedTextHeight - 16;
                            
                            // Clamp to ensure it's within bounds
                            textLeft = textLeft.clamp(16.0, imageWidth - 16);
                            textTop = textTop.clamp(16.0, imageHeight - 16);
                          } else {
                            // User-customized position (normalized 0-1)
                            textLeft = _textPosition.dx * imageWidth;
                            textTop = _textPosition.dy * imageHeight;
                          }
                          
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background image
                              Image.network(
                                widget.greeting.image ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              ),

                              // Draggable text overlay
                              Positioned(
                                left: textLeft.clamp(0.0, imageWidth * 0.9),
                                top: textTop.clamp(0.0, imageHeight * 0.9),
                                child: GestureDetector(
                                  onPanStart: _onTextPanStart,
                                  onPanUpdate: _onTextPanUpdate,
                                  onPanEnd: _onTextPanEnd,
                                  onTap: () {
                                    // Focus on text input when tapped (but not during drag)
                                    if (!_isDragging) {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    }
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: imageWidth * 0.8,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        // Visual feedback during drag
                                        borderRadius: BorderRadius.circular(8),
                                        border: _isDragging
                                            ? Border.all(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _nameController.text.trim().isEmpty
                                              ? 'Tap to add name'
                                              : _nameController.text,
                                          style: TextStyle(
                                            fontSize: _textSize,
                                            color: _textColor,
                                            fontWeight: FontWeight.bold,
                                            shadows: _showTextShadow
                                                ? [
                                                    Shadow(
                                                      offset: Offset(2, 2),
                                                      blurRadius: 4,
                                                      color: Colors.black.withOpacity(0.8),
                                                    ),
                                                    Shadow(
                                                      offset: Offset(-1, -1),
                                                      blurRadius: 2,
                                                      color: Colors.black.withOpacity(0.5),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Hint overlay (only when no text entered)
                              if (_nameController.text.trim().isEmpty)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Enter your name above\nThen drag it to position on the image',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _textColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color == Colors.white || color == Colors.yellow
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

