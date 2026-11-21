import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/tickets_repository.dart';
import '../cubit/tickets/tickets_cubit.dart';
import '../cubit/tickets/tickets_state.dart';

class CreateTicketPage extends StatelessWidget {
  const CreateTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketsCubit(TicketsRepository(dio: di<Dio>())),
      child: const _CreateTicketView(),
    );
  }
}

class _CreateTicketView extends StatefulWidget {
  const _CreateTicketView();

  @override
  State<_CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<_CreateTicketView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// Loaded from the backend when the page opens - never hardcoded, so the
  /// list always matches what the help desk actually accepts.
  List<Map<String, dynamic>> _categories = const [];
  bool _loadingCategories = true;
  String? _categoriesError;

  Map<String, dynamic>? _selectedCategory;
  String? _selectedFilePath;
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cubit = context.read<TicketsCubit>();
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await cubit.fetchTicketCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isEmpty ? null : categories.first;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _categoriesError = 'Failed to load categories'.tran;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Pick Image'.tran),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedFilePath = pickedFile.path;
                      _isImage = true;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text('Pick Document'.tran),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.pickFiles();
                  if (result.isNotEmpty && result.first.path != null) {
                    setState(() {
                      _selectedFilePath = result.first.path;
                      _isImage = false;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitTicket(BuildContext context) {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a category'.tran)));
      return;
    }

    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields'.tran)));
      return;
    }

    // An attachment never travels on its own - it is filed against the
    // description, so the description is required as soon as one is picked.
    if (_selectedFilePath != null && _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a description for the attachment.'.tran),
        ),
      );
      return;
    }

    context.read<TicketsCubit>().createTicket(
      category: _selectedCategory!,
      title: _titleController.text.trim(),
      desc: _descController.text.trim(),
      filePath: _selectedFilePath,
      isImage: _isImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: context.pop,
        ),
        title: Text(
          'Create Ticket'.tran,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.s,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryColor,
              size: 24.s,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          state.maybeWhen(
            createSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ticket created successfully!'.tran)),
              );
              context.pop(true); // Return true to signal refresh
            },
            createError: (msg) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            createLoading: () => true,
            orElse: () => false,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?'.tran,
                  style: TextStyle(
                    fontSize: 22.s,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8.s),
                Text(
                  'Describe your issue in detail and our premium support team will get back to you shortly.'
                      .tran,
                  style: TextStyle(
                    fontSize: 14.s,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.s),

                _buildLabel('Category'.tran),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.s),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildCategoryDropdown(),
                ),
                if (_categoriesError != null) ...[
                  SizedBox(height: 8.s),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoriesError!,
                          style: TextStyle(
                            fontSize: 12.s,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadCategories,
                        child: Text('Retry'.tran),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20.s),

                _buildLabel('Ticket Title'.tran),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Summary of your issue'.tran,
                ),
                SizedBox(height: 20.s),

                _buildLabel('Detailed Description'.tran),
                _buildTextField(
                  controller: _descController,
                  hint: 'Please provide as much detail as possible...'.tran,
                  maxLines: 5,
                ),
                SizedBox(height: 24.s),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Attachments'.tran, bottomPadding: 0),
                    Text(
                      'Max 5MB'.tran,
                      style: TextStyle(
                        fontSize: 12.s,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.s),

                if (_selectedFilePath == null)
                  GestureDetector(
                    onTap: () => _pickAttachment(context),
                    child: _buildDottedBorderContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.s),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 24.s,
                            ),
                          ),
                          SizedBox(height: 12.s),
                          Text(
                            'Click to upload screenshot'.tran,
                            style: TextStyle(
                              fontSize: 14.s,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildAttachmentPreview(),

                SizedBox(height: 32.s),

                SizedBox(
                  width: double.infinity,
                  height: 50.s,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitTicket(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.s),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit Ticket'.tran,
                                style: TextStyle(
                                  fontSize: 16.s,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.s),
                              Icon(Icons.send, size: 18.s, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 16.s),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Usually responds within '.tran,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.s,
                          ),
                        ),
                        TextSpan(
                          text: '2-4 hours'.tran,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.s,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.s),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return SizedBox(
        height: 48.s,
        child: Row(
          children: [
            SizedBox(
              height: 16.s,
              width: 16.s,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.s),
            Text(
              'Loading categories...'.tran,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14.s),
            ),
          ],
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<Map<String, dynamic>>(
        value: _selectedCategory,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        isExpanded: true,
        hint: Text(
          'Select a category'.tran,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        items: _categories.map((cat) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: cat,
            child: Text(cat['name'].toString()),
          );
        }).toList(),
        onChanged: _categories.isEmpty
            ? null
            : (val) {
                setState(() {
                  if (val != null) _selectedCategory = val;
                });
              },
      ),
    );
  }

  Widget _buildLabel(String text, {double bottomPadding = 8}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding.s),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.s,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.s),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.s),
        ),
      ),
    );
  }

  Widget _buildDottedBorderContainer({required Widget child}) {
    // Basic CustomPaint for dashed border if dotted_border package is not available
    return Container(
      width: double.infinity,
      height: 120.s,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.s),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _DashedBorderPainter(
              color: Colors.grey.shade400,
              radius: 12.s,
            ),
            child: Container(),
          ),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    final fileName = _selectedFilePath!.split(Platform.pathSeparator).last;
    return Container(
      width: 100.s,
      height: 120.s,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.s),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          if (_isImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.s),
                child: Image.file(File(_selectedFilePath!), fit: BoxFit.cover),
              ),
            )
          else
            Center(
              child: Icon(
                Icons.picture_as_pdf,
                color: Theme.of(context).primaryColor,
                size: 40.s,
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.s, horizontal: 8.s),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.s),
                  bottomRight: Radius.circular(12.s),
                ),
              ),
              child: Text(
                fileName,
                style: TextStyle(color: Colors.white, fontSize: 10.s),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4.s),
                child: Icon(Icons.close, color: Colors.white, size: 12.s),
              ),
              onPressed: () {
                setState(() {
                  _selectedFilePath = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    // A simple dashed path effect (can be refined or replaced with a package)
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    double distance = 0.0;

    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
