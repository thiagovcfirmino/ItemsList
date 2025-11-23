import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/items_provider.dart';
import '../../models/enums.dart';
import '../../utils/constants/strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';

class ItemFormScreen extends StatefulWidget {
  final String listId;
  final String? itemId; // null for create, non-null for edit

  const ItemFormScreen({
    super.key,
    required this.listId,
    this.itemId,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _yearController = TextEditingController();
  final _valueController = TextEditingController();

  AcquisitionType _acquisitionType = AcquisitionType.bought;
  List<String> _imagePaths = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
    
    if (widget.itemId != null) {
      _loadItemData();
    }
  }

  void _loadItemData() {
    final itemsProvider = context.read<ItemsProvider>();
    final item = itemsProvider.getItemById(widget.itemId!);
    
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description ?? '';
      _typeController.text = item.type;
      _yearController.text = item.year.toString();
      _valueController.text = item.value?.toString() ?? '';
      _acquisitionType = item.acquisitionType;
      _imagePaths = List.from(item.imagePaths);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _yearController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.formEditTitle : AppStrings.formAddTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          children: [
            // Images Section
            _buildImagesSection(),
            const SizedBox(height: AppTheme.spacingXl),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.formName,
                hintText: AppStrings.formNameHint,
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.validationNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.formDescription,
                hintText: AppStrings.formDescriptionHint,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Type Field
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: AppStrings.formType,
                hintText: AppStrings.formTypeHint,
                prefixIcon: Icon(Icons.category_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Acquisition Type
            Text(
              AppStrings.formAcquisition,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<AcquisitionType>(
                    title: const Text(AppStrings.formBought),
                    value: AcquisitionType.bought,
                    groupValue: _acquisitionType,
                    onChanged: (value) {
                      setState(() {
                        _acquisitionType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<AcquisitionType>(
                    title: const Text(AppStrings.formGift),
                    value: AcquisitionType.gift,
                    groupValue: _acquisitionType,
                    onChanged: (value) {
                      setState(() {
                        _acquisitionType = value!;
                        if (value == AcquisitionType.gift) {
                          _valueController.clear();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Year Field
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: AppStrings.formYear,
                hintText: AppStrings.formYearHint,
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.validationYearInvalid;
                }
                final year = int.tryParse(value);
                if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                  return AppStrings.validationYearInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Value Field (only for bought items)
            if (_acquisitionType == AcquisitionType.bought)
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: AppStrings.formValue,
                  hintText: AppStrings.formValueHint,
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            const SizedBox(height: AppTheme.spacingXxl),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.formSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.formAddPhoto,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add Photo Button
              _buildAddPhotoButton(),
              const SizedBox(width: AppTheme.spacingM),

              // Existing Photos
              ..._imagePaths.map((path) => _buildImagePreview(path)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _showImageSourceOptions,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 32, color: AppColors.primary),
            SizedBox(height: AppTheme.spacingS),
            Text('Add Photo', style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppTheme.spacingM),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Image.file(
              File(path),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                setState(() {
                  _imagePaths.remove(path);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.formTakePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.formChoosePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.validationPhotoRequired),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final itemsProvider = context.read<ItemsProvider>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final type = _typeController.text.trim();
    final year = int.parse(_yearController.text.trim());
    final value = _valueController.text.trim().isEmpty
        ? null
        : double.tryParse(_valueController.text.trim());

    bool success;
    if (widget.itemId != null) {
      // Update existing item
      success = await itemsProvider.updateItem(
        id: widget.itemId!,
        name: name,
        description: description.isEmpty ? null : description,
        imagePaths: _imagePaths,
        type: type,
        acquisitionType: _acquisitionType,
        year: year,
        value: value,
      );
    } else {
      // Create new item
      final itemId = await itemsProvider.createItem(
        listId: widget.listId,
        name: name,
        description: description.isEmpty ? null : description,
        imagePaths: _imagePaths,
        type: type,
        acquisitionType: _acquisitionType,
        year: year,
        value: value,
      );
      success = itemId != null;
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.itemId != null
                  ? AppStrings.messageItemUpdated
                  : AppStrings.messageItemCreated,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.messageError),
          ),
        );
      }
    }
  }
}
