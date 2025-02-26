import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart'; // Import the CustomFormField widget

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _hasAttempted = false; // Track form validation attempts

Future<void> _changePassword() async {
  setState(() {
    _hasAttempted = true;
    _isLoading = true;
  });

  User? user = _auth.currentUser;
  if (user == null) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("User not logged in.")));
    return;
  }

  String currentPassword = _currentPasswordController.text.trim();
  String newPassword = _newPasswordController.text.trim();
  String confirmPassword = _confirmPasswordController.text.trim();

  if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")));
    return;
  }

  if (newPassword == currentPassword) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password cannot be the same as the current password.")));
    return;
  }

  if (newPassword != confirmPassword) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")));
    return;
  }

  try {
    // Reauthenticate the user
    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully.")));
    Navigator.pop(context); // Close the change password screen
  } on FirebaseAuthException catch (e) {
    print("Error Code: ${e.code}");
    print("Error Message: ${e.message}");

    String errorMessage;
    if (e.code == 'invalid-credential') {
      errorMessage = "The current password you entered is incorrect.";
    } else {
      errorMessage = e.message ?? "An unexpected error occurred.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    print("Unexpected Error: $e");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  }

  setState(() => _isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 3, 47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomFormField(
              controller: _currentPasswordController,
              label: "Current Password",
              obscureText: true,
              errorText:
                  _hasAttempted && _currentPasswordController.text.isEmpty
                      ? "Current password is required"
                      : null,
            ),
            CustomFormField(
              controller: _newPasswordController,
              label: "New Password",
              obscureText: true,
              errorText: _hasAttempted && _newPasswordController.text.isEmpty
                  ? "New password is required"
                  : null,
            ),
            CustomFormField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              obscureText: true,
              errorText:
                  _hasAttempted && _confirmPasswordController.text.isEmpty
                      ? "Confirm password is required"
                      : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350, // Make button smaller
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: AppStyles.primaryButtonStyle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
