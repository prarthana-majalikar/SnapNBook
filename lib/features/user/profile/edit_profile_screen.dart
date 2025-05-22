import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/auth_provider.dart';
import '../../../services/auth_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool isTechnician = false;
  final Set<String> _selectedSkills = {};

  final Map<String, List<String>> skillCategories = {
    'Vehicles': ['bicycle', 'car', 'motorcycle', 'bus', 'truck', 'boat'],
    'Furniture': ['chair', 'couch', 'bed', 'dining table', 'toilet'],
    'Electronics': ['tv', 'laptop', 'cell phone'],
    'Appliances': ['microwave', 'oven', 'toaster', 'sink', 'refrigerator', 'clock', 'hair drier'],
  };

  @override
  void initState() {
    super.initState();
    final session = ref.read(authProvider)!;
    isTechnician = session.isTechnician;

    _firstNameController.text = session.firstName;
    _lastNameController.text = session.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final session = ref.read(authProvider)!;

    final data = <String, dynamic>{};

    if (_firstNameController.text.trim().isNotEmpty) {
      data['firstname'] = _firstNameController.text.trim();
    }
    if (_lastNameController.text.trim().isNotEmpty) {
      data['lastname'] = _lastNameController.text.trim();
    }
    if (_addressController.text.trim().isNotEmpty) {
      data['address'] = _addressController.text.trim();
    }
    if (_pincodeController.text.trim().isNotEmpty) {
      data['pincode'] = _pincodeController.text.trim();
    }
    if (isTechnician && _selectedSkills.isNotEmpty) {
      data['skills'] = _selectedSkills.toList();
    }

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least one field')),
      );
      return;
    }

    final success = await AuthService.updateAccount(
      id: session.userId,
      role: session.role,
      accessToken: session.accessToken,
      body: data,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop(); // Return to profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed')),
      );
    }
  }

  Widget _buildSkillCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Skills',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...skillCategories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
              ...entry.value.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return CheckboxListTile(
                  title: Text(skill),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // ✅ Back to profile
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
              ),
              if (isTechnician) _buildSkillCheckboxes(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
