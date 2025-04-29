import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_response.dart';
import '../providers/user_provider.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _jobController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _isSubmitting = true;

      final user = UserResponse(
        firstName: _firstNameController.text.trim(),
        job: _jobController.text.trim(),
      );

      final success =
          await Provider.of<UserProvider>(context, listen: false).addUser(user);

      _isSubmitting = false;

      setState(() {});
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomTextFormField(
                controller: _firstNameController,
                label: 'Name',
                hintText: 'Enter your name',
              ),
              SizedBox(height: 16),
              _buildCustomTextFormField(
                controller: _jobController,
                label: 'Job',
                hintText: 'Enter your job title',
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        // fillColor: Colors.deepPurpleAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          // borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          // borderSide: BorderSide(color: Colors.deepPurpleAccent.shade700, width: 2),
        ),
        prefixIcon: Icon(
          Icons.person,
          // color: Colors.deepPurpleAccent,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
