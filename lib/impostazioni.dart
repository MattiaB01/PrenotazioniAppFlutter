import 'package:flutter/material.dart';

class Impostazioni extends StatelessWidget {
  const Impostazioni({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form in Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildRow("Nome:", "Inserisci nome"),
                const SizedBox(height: 12),
                buildRow("Cognome:", "Inserisci cognome"),
                const SizedBox(height: 12),
                buildRow("Email:", "Inserisci email"),
                const SizedBox(height: 12),
                buildRow("Telefono:", "Inserisci telefono"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funzione helper per creare una riga con label e textfield
  Widget buildRow(String label, String hint) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
