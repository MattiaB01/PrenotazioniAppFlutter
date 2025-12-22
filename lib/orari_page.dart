import 'dart:convert';

import 'package:calendario/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrariPage extends StatefulWidget {
  const OrariPage({Key? key}) : super(key: key);

  @override
  State<OrariPage> createState() => _OrariPageState();
}

class _OrariPageState extends State<OrariPage> {
  final Map<String, TextEditingController> slotControllers = {};
  final Map<String, TextEditingController> durataControllers = {};
  final Map<String, TextEditingController> inizioMatControllers = {};
  final Map<String, TextEditingController> fineMatControllers = {};
  final Map<String, TextEditingController> inizioPomControllers = {};
  final Map<String, TextEditingController> finePomControllers = {};
  final Map<int, String> giorni = {
    1: "Lunedì",
    2: "Martedì",
    3: "Mercoledì",
    4: "Giovedì",
    5: "Venerdì",
    6: "Sabato",
  };

  Map<String, bool> abilitaGiorno = {};
  final Map<String, String?> inizioMattina = {};
  final Map<String, String?> fineMattina = {};
  final Map<String, String?> inizioPomeriggio = {};
  final Map<String, String?> finePomeriggio = {};
  final Map<String, int> slot = {};
  final Map<String, int> durata = {};
  @override
  void initState() {
    super.initState();
    for (var giorno in giorni.values) {
      //abilitaGiorno[giorno] = false; // inizialmente tutti false
    }
    caricaOrari();
  }

  /*
  Future<void> _selezionaOra(
    BuildContext context,
    String giorno,
    bool mattina,
    bool inizio,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (mattina) {
          if (inizio) {
            inizioMattina[giorno] = picked;
          } else {
            fineMattina[giorno] = picked;
          }
        } else {
          if (inizio) {
            inizioPomeriggio[giorno] = picked;
          } else {
            finePomeriggio[giorno] = picked;
          }
        }
      });
    }
  }
*/
  String _formatTime(TimeOfDay? t) {
    if (t == null) return "--:--";
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildCard(String giorno) {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // card alta quanto contenuto
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                giorno,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- MATTINA ---
            const Text(
              "Mattina",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: TextField(
                      onChanged: (value) {
                        inizioMattina[giorno] = value; //_parseTime(value);
                      },
                      controller: inizioMatControllers[giorno],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        //hintText: "08:00",
                        label: Text("Inizio"),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: fineMatControllers[giorno],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Fine"),
                      //  hint: Text("12:00"),
                    ),
                  ),
                ),
                /* ElevatedButton(
                  onPressed: () => _selezionaOra(context, giorno, true, true),
                  child: Text("Inizio: ${_formatTime(inizioMattina[giorno])}"),
                ),
                ElevatedButton(
                  onPressed: () => _selezionaOra(context, giorno, true, false),
                  child: Text("Fine: ${_formatTime(fineMattina[giorno])}"),
                ),*/
              ],
            ),
            const SizedBox(height: 6),

            const SizedBox(height: 12),

            // --- POMERIGGIO ---
            const Text(
              "Pomeriggio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: TextField(
                      controller: inizioPomControllers[giorno],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        //hintText: "08:00",
                        label: Text("Inizio"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: finePomControllers[giorno],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Fine"),
                      //hint: Text("12:00"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Durata slot (min): "),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: durataControllers[giorno],

                    keyboardType: TextInputType.number,
                    onChanged: (v) => durata[giorno] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text("Disabilita giorno "),
                ),
                Checkbox(
                  checkColor: Colors.white,

                  value: abilitaGiorno[giorno] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      abilitaGiorno[giorno] = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void inviaOrari() async {
    List<Map<String, dynamic>> payload = [];

    for (var giorno in giorni.keys) {
      payload.add({
        "giorno": giorno,
        "oraInizioMat": inizioMatControllers[giorni[giorno]]?.text ?? "",
        "oraFineMat": fineMatControllers[giorni[giorno]]?.text ?? "",
        "oraInizPom": inizioPomControllers[giorni[giorno]]?.text ?? "",
        "oraFinePom": finePomControllers[giorni[giorno]]?.text ?? "",

        /*
        "oraInizioMat": inizioMattina[giorno]?.format(context) ?? "",
        "oraFineMat": fineMattina[giorno]?.format(context) ?? "",
        "oraInizPom": inizioPomeriggio[giorno]?.format(context) ?? "",
        "oraFinePom": finePomeriggio[giorno]?.format(context) ?? "",*/
        "studio": "studio1",
        /* "slot": slot[giorno] ?? 0,
        "durata": durata[giorno] ?? 0,*/
        "slot": durata[giorni[giorno]],
        "durata": durata[giorni[giorno]],
        "chiuso": abilitaGiorno[giorni[giorno]],
      });
    }
    //aggiugi domenica
    payload.add({
      "giorno": 7,
      "oraInizioMat": inizioMatControllers[giorni[7]]?.text ?? "",
      "oraFineMat": fineMatControllers[giorni[7]]?.text ?? "",
      "oraInizPom": inizioPomControllers[giorni[7]]?.text ?? "",
      "oraFinePom": finePomControllers[giorni[7]]?.text ?? "",

      /*
        "oraInizioMat": inizioMattina[giorno]?.format(context) ?? "",
        "oraFineMat": fineMattina[giorno]?.format(context) ?? "",
        "oraInizPom": inizioPomeriggio[giorno]?.format(context) ?? "",
        "oraFinePom": finePomeriggio[giorno]?.format(context) ?? "",*/
      "studio": "studio1",
      /* "slot": slot[giorno] ?? 0,
        "durata": durata[giorno] ?? 0,*/
      "slot": "",
      "durata": "",
      "chiuso": true,
    });

    try {
      final url = Uri.parse("http://localhost:2000/orario/inserisci");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Dati inviati con successo!");
      } else {
        print("Errore: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Errore di connessione: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, right: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            inviaOrari();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dati salvati con successo!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text("  Salva  "),
        ),
      ),

      appBar: AppBar(
        title: const Text("Impostazione orari"),
        backgroundColor: Colors.blue.shade200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: giorni.values.map((giorno) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 3 - 24, // 3 per riga
                child: _buildCard(giorno),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> caricaOrari() async {
    try {
      final url = Uri.parse(
        /*"http://localhost:2000/ottieniOrari",*/
        "$apiUrl/ottieniOrari",
      ); // endpoint GET
      final response = await http.get(url);

      //f(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> dati = jsonDecode(response.body);

        setState(() {
          for (var item in dati) {
            final o = Orario.fromJson(item);

            // Se il giorno non esiste nella mappa, salta
            if (!giorni.containsKey(o.giorno)) continue;

            final giornoNome = giorni[o.giorno]!;
            inizioMattina[giornoNome] =
                o.oraInizioMat; // _parseTime(o.oraInizioMat);
            fineMattina[giornoNome] = o.oraFineMat; // _parseTime(o.oraFineMat);
            inizioPomeriggio[giornoNome] =
                o.oraInizPom; //_parseTime(o.oraInizPom);
            finePomeriggio[giornoNome] =
                o.oraFinePom; //_parseTime(o.oraFinePom);
            slot[giornoNome] = o.slot;
            durata[giornoNome] = o.durata;
            abilitaGiorno[giornoNome] = o.chiuso;

            inizioMatControllers[giornoNome] = TextEditingController(
              text: o.oraInizioMat,
            );

            fineMatControllers[giornoNome] = TextEditingController(
              text: o.oraFineMat,
            );

            inizioPomControllers[giornoNome] = TextEditingController(
              text: o.oraInizPom,
            );

            finePomControllers[giornoNome] = TextEditingController(
              text: o.oraFinePom,
            );

            slotControllers[giornoNome] = TextEditingController(
              text: o.slot.toString(),
            );
            durataControllers[giornoNome] = TextEditingController(
              text: o.durata.toString(),
            );
          }
        });
      } else {
        print("Errore dal server: ${response.statusCode}");
      }
    } catch (e) {
      print("Errore di connessione: $e");
    }
  }
}

class Orario {
  final int giorno;
  final String oraInizioMat;
  final String oraFineMat;
  final String oraInizPom;
  final String oraFinePom;
  final String studio;
  final int slot;
  final int durata;
  final bool chiuso;

  Orario({
    required this.giorno,
    required this.oraInizioMat,
    required this.oraFineMat,
    required this.oraInizPom,
    required this.oraFinePom,
    required this.studio,
    required this.slot,
    required this.durata,
    required this.chiuso,
  });

  factory Orario.fromJson(Map<String, dynamic> json) {
    return Orario(
      giorno: json['giorno'],
      oraInizioMat: json['oraInizioMat'],
      oraFineMat: json['oraFineMat'],
      oraInizPom: json['oraInizPom'],
      oraFinePom: json['oraFinePom'],
      studio: json['studio'],
      slot: json['slot'],
      durata: json['durata'],
      chiuso: json['chiuso'],
    );
  }
}
