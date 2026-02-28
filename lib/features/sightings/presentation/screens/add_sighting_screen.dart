import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import 'package:galapagos_wildlife/features/admin/services/image_processing_service.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/species_picker_sheet.dart';
import 'location_picker_screen.dart';

class AddSightingScreen extends ConsumerStatefulWidget {
  const AddSightingScreen({super.key});

  @override
  ConsumerState<AddSightingScreen> createState() => _AddSightingScreenState();
}

class _AddSightingScreenState extends ConsumerState<AddSightingScreen> {
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Species? _selectedSpecies;
  double? _latitude;
  double? _longitude;
  File? _photoFile;
  bool _isSaving = false;
  bool _isLoadingLocation = false;
  bool _isProcessingPhoto = false;

  bool get _hasData =>
      _selectedSpecies != null ||
      _notesController.text.isNotEmpty ||
      _photoFile != null ||
      _latitude != null;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickSpecies() async {
    final species = await showSpeciesPickerSheet(context);
    if (species != null) {
      setState(() => _selectedSpecies = species);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.location.servicesDisabled)),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.location.permissionDenied)),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Show success toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(context.t.location.locationObtained ?? 'Location obtained'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _pickFromMap() async {
    final initialLocation = _latitude != null && _longitude != null
        ? LatLng(_latitude!, _longitude!)
        : null;

    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: initialLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final title = context.t.sightings.photo;
    final picker = ImagePicker();

    setState(() => _isProcessingPhoto = true);
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 90,
        maxWidth: 1280,
        maxHeight: 720,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped != null) {
        setState(() => _photoFile = File(cropped.path));

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(context.t.sightings.photoAdded ?? 'Photo added'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessingPhoto = false);
    }
  }

  Future<void> _takePhoto() async {
    final title = context.t.sightings.photo;
    final picker = ImagePicker();

    setState(() => _isProcessingPhoto = true);
    try {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 90,
        maxWidth: 1280,
        maxHeight: 720,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped != null) {
        setState(() => _photoFile = File(cropped.path));

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(context.t.sightings.photoAdded ?? 'Photo added'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.t.sightings.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.t.sightings.fromGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto();
              },
            ),
            if (_photoFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(context.t.sightings.removePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoFile = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedSpecies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.sightings.selectSpecies)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final service = SightingsService();
      String? photoUrl;

      if (_photoFile != null) {
        final bytes = await _photoFile!.readAsBytes();
        final compressed = ImageProcessingService.compressImage(bytes);
        final fileName = 'sighting_${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoUrl = await service.uploadPhoto(bytes: compressed, fileName: fileName);
      }

      await service.createSighting(
        speciesId: _selectedSpecies!.id,
        observedAt: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        photoUrl: photoUrl,
      );

      ref.invalidate(sightingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.sightings.saved)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = LocaleSettings.currentLocale == AppLocale.es;

    return PopScope(
      canPop: !_hasData || _isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.t.common.unsavedChangesTitle),
              content: Text(context.t.common.unsavedChangesMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.t.common.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(context.t.common.discard),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(context.t.sightings.add),
        backgroundColor: isDark ? AppColors.darkBackground : null,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.t.common.save),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildFormFields(isDark, isEs),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _buildPhotoSection(isDark),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormFields(isDark, isEs),
                          const SizedBox(height: 16),
                          _buildPhotoSection(isDark),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildFormFields(bool isDark, bool isEs) {
    final speciesName = _selectedSpecies != null
        ? (isEs ? _selectedSpecies!.commonNameEs : _selectedSpecies!.commonNameEn)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Species selector
        Card(
          child: ListTile(
            leading: _selectedSpecies?.thumbnailUrl != null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(_selectedSpecies!.thumbnailUrl!),
                  )
                : Icon(
                    Icons.pets,
                    color: isDark ? AppColors.primaryLight : null,
                  ),
            title: Text(
              speciesName ?? context.t.sightings.selectSpecies,
              style: speciesName != null
                  ? null
                  : TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
            subtitle: _selectedSpecies != null
                ? Text(
                    _selectedSpecies!.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  )
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickSpecies,
          ),
        ),
        const SizedBox(height: 16),
        // Date picker
        Card(
          child: ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.primaryLight : null,
            ),
            title: Text(context.t.sightings.date),
            subtitle: Text(
              DateFormat.yMMMd().format(_selectedDate),
              style: TextStyle(color: isDark ? Colors.white54 : null),
            ),
            onTap: _pickDate,
          ),
        ),
        const SizedBox(height: 16),
        // Notes
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: context.t.sightings.notes,
            hintText: context.t.sightings.notesHint,
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        // Location — dos opciones: GPS actual o seleccionar en mapa
        Card(
          child: Column(
            children: [
              // Coordenadas actuales (si hay selección)
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: 'Quitar ubicación',
                        onPressed: () => setState(() {
                          _latitude = null;
                          _longitude = null;
                        }),
                      ),
                    ],
                  ),
                ),
              // Botón: Ubicación actual (GPS)
              ListTile(
                leading: _isLoadingLocation
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.my_location,
                        color: isDark ? AppColors.accentOrange : AppColors.primary,
                      ),
                title: Text(context.t.sightings.useCurrentLocation),
                subtitle: const Text('Usar coordenadas del GPS'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isLoadingLocation ? null : _getLocation,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              // Botón: Seleccionar en mapa
              ListTile(
                leading: Icon(
                  Icons.map_outlined,
                  color: isDark ? AppColors.accentOrange : AppColors.primary,
                ),
                title: const Text('Seleccionar en mapa'),
                subtitle: const Text('Toca el punto exacto en el mapa'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickFromMap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    return Column(
      children: [
        if (_photoFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(_photoFile!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Card(
          child: ListTile(
            leading: _isProcessingPhoto
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _photoFile != null ? Icons.photo : Icons.add_a_photo,
                    color: isDark ? AppColors.accentOrange : null,
                  ),
            title: Text(
              _isProcessingPhoto
                  ? (context.t.sightings.processingPhoto ?? 'Processing photo...')
                  : (_photoFile != null
                      ? context.t.sightings.changePhoto
                      : context.t.sightings.addPhoto),
            ),
            trailing: _isProcessingPhoto ? null : const Icon(Icons.chevron_right),
            onTap: _isProcessingPhoto ? null : _showPhotoOptions,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(context.t.sightings.save),
    );
  }
}
