// widgets/booking_dialog.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'api.dart';

final _formKey = GlobalKey<FormState>();
final _nomeContr = TextEditingController();
final _telContr = TextEditingController();
final _emailContr = TextEditingController();
String nome = "";
String tel = "";
String email = "";

Future<bool?> visualizzaAppuntamento(
  BuildContext context,
  String orario,
  DateTime giorno,
  String dati,
) {
  Map<String, dynamic> data = jsonDecode(dati);
  _nomeContr.text = data['nome'] ?? "";
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Form(
        key: _formKey,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text("Dati Prenotazione"),
          content: SizedBox(
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  'Giorno ${DateFormat('dd').format(giorno)}/${DateFormat('MM').format(giorno)} per le ore $orario',
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    nome = value;
                  },
                  readOnly: true,
                  controller: _nomeContr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Questo campo è obbligatorio';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Nome Cognome",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  onChanged: (value) {
                    tel = value;
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Telefono",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("Chiudi"),
            ),
            /* TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              onPressed: () {
                // Logica di salvataggio
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true); // Chiudi primo
                  mostraSecondoDialog(context, orario, giorno);
                } // Mostra secondo
              },
              child: Text("Conferma"),
            ),*/
          ],
        ),
      );
    },
  );
}

void mostraSecondoDialog(BuildContext context, String orario, DateTime giorno) {
  apiPrenotazione(orario, giorno, nome, tel, email);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Conferma avvenuta"),
      content: Text("Hai confermato l'operazione."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("OK"),
        ),
      ],
    ),
  );
}
