import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'proxy.dart';

class PrenotazioniSettimanaliPage extends StatefulWidget {
  const PrenotazioniSettimanaliPage({super.key});

  @override
  State<PrenotazioniSettimanaliPage> createState() =>
      _PrenotazioniSettimanaliPageState();
}

class _PrenotazioniSettimanaliPageState
    extends State<PrenotazioniSettimanaliPage> {
  bool isHovered = true;
  int hoveredIndex = 0;
  int dayIndex = 0;
  String oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
  (int?, String?) hoveredCell = (0, ""); // (giornoIndex, orarioKey)
  Map<String, dynamic> res = {};

  final url = Uri.parse('${proxy}settimana2');
  final headers = {'Content-Type': 'application/json'};

  bool isChipHovered = false;

  final Map<int, String> giorniSettimana = const {
    1: "Lunedì",
    2: "Martedì",
    3: "Mercoledì",
    4: "Giovedì",
    5: "Venerdì",
    6: "Sabato",
  };

  Map<int, Map<String, Map<String, bool>>> prenotazioni = {};
  bool isLoading = true;

  Future<Map<String, dynamic>> settimana(DateTime inizio) async {
    //String dataInizio = inizio.toString();
    String formattedDate = DateFormat('yyyy-MM-dd').format(inizio);

    //print(formattedDate);
    String url3 = "${proxy}settimana2?data2=$formattedDate";

    Uri url4 = Uri.parse(url3);

    try {
      final response = await http
          .get(url4, headers: headers)
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        throw Exception('Errore nella richiesta');
      }
    } catch (e) {
      print(e);
      return {}; // ritorna mappa vuota in caso di errore
    }
  }

  DateTime startOfWeek = (DateTime.now().weekday >= 6)
      ? DateTime.now().add(Duration(days: 7))
      : DateTime.now();

  @override
  void initState() {
    super.initState();
    caricaPrenotazioniSettimanali();
    // Calcola lunedì della settimana corrente
    startOfWeek = startOfWeek.subtract(
      Duration(days: DateTime.now().weekday - 1),
    );

    aggiorna();
  }

  List<String> orari = [];

  var primoOrario;

  //  bool isLoading = true;

  /*void aggiorna1_() async {
    setState(() {
      isLoading = true;
    });

    var dati;
    try {
      dati = await settimana(startOfWeek);
    } catch (e) {
      print("Errore durante il caricamento dei dati: $e");
      dati = {}; // fallback
    }
    setState(() {
      res = dati;
      isLoading = false;
    });
  }*/
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Impedisce di chiudere il dialog toccando lo sfondo
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Sfondo trasparente
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Caricamento...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void aggiorna() async {
    //mostra dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingDialog(context);
    });

    var dati = await settimana(startOfWeek);

    if (mounted) {
      setState(() {
        res = dati;
        isLoading = false;
      });
      // chiudi dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> caricaPrenotazioniSettimanali() async {
    try {
      final oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final url = Uri.parse("http://localhost:2000/settimana2?data2=$oggi");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Converto le chiavi stringa (1, 2, 3...) in int
        setState(() {
          prenotazioni = data.map(
            (key, value) => MapEntry(
              int.parse(key),
              Map<String, Map<String, bool>>.from(
                (value as Map).map(
                  (turno, orari) =>
                      MapEntry(turno, Map<String, bool>.from(orari)),
                ),
              ),
            ),
          );
          isLoading = false;
        });
      } else {
        print("Errore ${response.statusCode}: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Errore di connessione: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildCard(int giorno, String nomeGiorno) {
    final datiGiorno = prenotazioni[giorno];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: datiGiorno == null
            ? Center(
                child: Text(
                  "$nomeGiorno\nNessuna prenotazione",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      nomeGiorno,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (datiGiorno.containsKey("mattina")) ...[
                    const Text(
                      "Mattina",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: datiGiorno["mattina"]!.entries.map((entry) {
                        return Chip(
                          backgroundColor: entry.value
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          label: Text(entry.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (datiGiorno.containsKey("pomeriggio")) ...[
                    const Text(
                      "Pomeriggio",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: datiGiorno["pomeriggio"]!.entries.map((entry) {
                        return Chip(
                          backgroundColor: entry.value
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          label: Text(entry.key),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text("Prenotazioni settimana di $oggi")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 1000
                    ? 3
                    : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: giorniSettimana.entries.map((entry) {
                  return _buildCard(entry.key, entry.value);
                }).toList(),
              ),
            ),
    );
  }
}
