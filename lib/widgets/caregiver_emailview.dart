import 'package:flutter/material.dart';

class CaregiverEmailView extends StatefulWidget {
  final String initialEmail;
  final Function(String updatedEmail) onSave;

  const CaregiverEmailView({
    Key? key,
    required this.initialEmail,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CaregiverEmailView> createState() => _CaregiverEmailViewState();
}

class _CaregiverEmailViewState extends State<CaregiverEmailView> {
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  void cancelEditing() {
    _controller.text = widget.initialEmail;
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Edit Caregiver Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 56, 26, 3),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final newEmail = _controller.text.trim();
                    if (newEmail.isEmpty || !newEmail.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a valid email address.')),
                      );
                      return;
                    }
                    widget.onSave(newEmail);
                    setState(() => isEditing = false);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 234, 219),
                    foregroundColor: Color.fromARGB(255, 56, 26, 3),
                  ),
                  onPressed: cancelEditing,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.email, color: Color(0xFF4E2A2A)),
        title: const Text('Caregiver Email'),
        subtitle: Text(widget.initialEmail),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF4E2A2A)),
          onPressed: () {
            setState(() => isEditing = true);
          },
        ),
      );
    }
  }
}
