import 'package:flutter/material.dart';

class PermissionRequestWidget extends StatelessWidget {
  final VoidCallback onRequest;

  const PermissionRequestWidget({super.key, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Konum izni gerekli.", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRequest, child: const Text("İzin Ver")),
        ],
      ),
    );
  }
}
