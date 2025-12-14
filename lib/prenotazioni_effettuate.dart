import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calendario/appuntamento.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:calendario/proxy.dart";
import 'festività.dart';

import 'orari_page.dart';

import 'prenotazioni.dart';

import 'visualizzaAppuntamento.dart';

import 'api.dart';

import 'impostazioni.dart';

class Prenotazioni extends StatelessWidget {
  const Prenotazioni({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const MyHomePage(title: 'Gestisci le tue prenotazioni'),
      },
      title: 'Prenotazioni',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      //home: const MyHomePage(title: 'Prenota un appuntamento'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> prenotazioniSettimana = [];

  String soloData = "";
  String dataFormattata = "";
  String appuntamentiGiorno = "";
  List<String> giorni = [
    "lunedi",
    "martedi",
    "mercoledi",
    "giovedi",
    "venerdi",
    "sabato",
    "domenica",
  ];

  bool isHovered = true;
  int hoveredIndex = 0;
  int dayIndex = 0;
  String oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
  (int?, String?) hoveredCell = (0, ""); // (giornoIndex, orarioKey)
  Map<String, dynamic> res = {};

  final url = Uri.parse('${proxy}settimana2');
  final headers = {'Content-Type': 'application/json'};

  String datiAppuntamento = "";

  String nomeMese = "";
  int nMese = 1;
  List<String> mesi = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  Future<Map<String, dynamic>> settimana(DateTime inizio) async {
    //String dataInizio = inizio.toString();
    String formattedDate = DateFormat('yyyy-MM-dd').format(inizio);

    print("FormattedDate :" + formattedDate);
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

    // Calcola lunedì della settimana corrente
    startOfWeek = startOfWeek.subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    dataFormattata = DateFormat('yyyy-MM-dd').format(startOfWeek);
    try {
      ottieniPrenotazioniSettimana();
      aggiorna();
    } catch (e) {}
  }

  List<String> orari = [];

  var primoOrario;

  bool isLoading = true;

  void ottieniPrenotazioniSettimana() async {
    try {
      prenotazioniSettimana = await apiAppuntamentiSettimana(startOfWeek);
    } catch (e) {}
  }

  void aggiorna() async {
    //mostra dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingDialog(context);
    });

    var dati = await settimana(startOfWeek);
    appuntamentiGiorno = await apiAppuntamentiGiorno(startOfWeek);

    nomeMese = DateFormat.MMMM().format(startOfWeek);
    nMese = startOfWeek.month;

    if (mounted) {
      setState(() {
        res = dati;
        isLoading = false;
      });
      // chiudi dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> settimana = List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );

    void frecciaSx() {
      setState(() {
        startOfWeek = startOfWeek.subtract(Duration(days: 7));
        dataFormattata = DateFormat('yyyy-MM-dd').format(startOfWeek);
      });
      ottieniPrenotazioniSettimana();
      aggiorna();
    }

    void frecciaDx() {
      setState(() {
        startOfWeek = startOfWeek.add(Duration(days: 7));
        dataFormattata = DateFormat('yyyy-MM-dd').format(startOfWeek);
      });
      ottieniPrenotazioniSettimana();
      aggiorna();
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50, //sfondo Scaffold pagina
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Impostazioni()),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrariPage()),
              );
            },
            icon: Icon(Icons.av_timer),
          ),
          /* IconButton(
            icon: Icon(Icons.settings),

            onPressed: () {
              Navigator.push(
                context,
                //MaterialPageRoute(builder: (context) => const OrariPage()),
                MaterialPageRoute(
                  builder: (context) => const PrenotazioniSettimanaliPage(),
                ),
              );
              //Navigator.pushNamed(context, '/about');
              //_dialogBuilder(context);
            },
          ),*/
        ],
      ),
      body: Container(
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 10),
              child: SizedBox(
                width: 950,
                height: 660,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black45, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 🔵 TITOLO CENTRATO
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Center(
                          child: Text(
                            "PRENOTAZIONI DELLA SETTIMANA",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 4),

                      // 🔵 IL GRID DEVE ESSERE IN EXPANDED
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: GridView.builder(
                            itemCount: 6,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              DateTime giornoCorrente = startOfWeek.add(
                                Duration(days: index),
                              );

                              String giornoFiltro = DateFormat(
                                'yyyy-MM-dd',
                              ).format(giornoCorrente);
                              List<Map<String, dynamic>> prenotazioniDelGiorno =
                                  [];
                              try {
                                prenotazioniDelGiorno = prenotazioniSettimana
                                    .where((p) => p['data'] == giornoFiltro)
                                    .toList();
                              } catch (e) {
                                prenotazioniDelGiorno = [];
                              }
                              return Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Chip(
                                        avatar: Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                        ),
                                        backgroundColor: Colors.green.shade100,
                                        label: Text(
                                          "${giorni[index].toUpperCase()} ${DateFormat('dd-MM-yyyy').format(giornoCorrente)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // 🔵 LISTA SCROLLABILE
                                      Expanded(
                                        child: prenotazioniDelGiorno.isEmpty
                                            ? Center(
                                                child: Text(
                                                  "Nessuna prenotazione",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: prenotazioniDelGiorno
                                                    .length,
                                                itemBuilder: (context, i) {
                                                  final p =
                                                      prenotazioniDelGiorno[i];
                                                  return Card(
                                                    color:
                                                        Colors.orange.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            "${p['orario']}  -  ${p['nome']}",
                                                          ),
                                                          Spacer(),
                                                          if (p['confermato'] ==
                                                              true)
                                                            Icon(
                                                              Icons
                                                                  .verified_user_outlined,
                                                              size: 18,
                                                              color:
                                                                  Colors.green,
                                                            ),

                                                          SizedBox(width: 10),
                                                          InkWell(
                                                            onTap: () {
                                                              apiCancellaAppuntamento(
                                                                p['id'],
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.delete,
                                                              size: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    /*child: ListTile(
                                                title: Text(p['orario']),
                                                subtitle: Text(p['nome']),
                                              ),*/
                                                  );
                                                },
                                              ),
                                      ),

                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              //container visualizzazione orari
              width: 500,
              height: 660, //era 650
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.black45, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200, // colore ombra
                    blurRadius: 8, // sfocatura
                    offset: Offset(2, 4), // spostamento orizzontale/verticale
                  ),
                ],
              ),

              //color: Colors.blue.shade50,
              margin: EdgeInsets.only(top: 10, left: 10), //left:50
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        //nomeMese.toUpperCase(),
                        "${mesi[nMese - 1]} ${startOfWeek.year}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (int a = 0; a < 7; a++)
                          Column(
                            children: [
                              Container(
                                width: 60,
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  right: 3,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color:
                                      (settimana[a].day == DateTime.now().day &&
                                          settimana[a].month ==
                                              DateTime.now().month &&
                                          settimana[a].year ==
                                              DateTime.now().year)
                                      ? Colors.lightBlue[100]
                                      : isFestivo(settimana[a])
                                      ? Colors.deepOrange.shade200
                                      : (settimana[a].weekday == 6 ||
                                            settimana[a].weekday == 7)
                                      ? Colors
                                            .grey[300] // colore diverso per sabato e domenica
                                      : Colors.white,

                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      [
                                        'Lun',
                                        'Mar',
                                        'Mer',
                                        'Gio',
                                        'Ven',
                                        'Sab',
                                        'Dom',
                                      ][a],
                                      style: TextStyle(
                                        fontSize: 14,

                                        fontWeight:
                                            (settimana[a].day ==
                                                    DateTime.now().day &&
                                                settimana[a].month ==
                                                    DateTime.now().month) /* &&
                                              settimana[a].year ==
                                                  DateTime.now().year)*/
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      //DateFormat('dd').format(settimana[a]),
                                      '${DateFormat('dd').format(settimana[a])}/${DateFormat('MM').format(settimana[a])}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            (settimana[a].day ==
                                                    DateTime.now().day &&
                                                settimana[a].month ==
                                                    DateTime.now().month)
                                            /*&&
                                              settimana[a].year ==
                                                  DateTime.now().year)*/
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.blue.shade100,
                        height: 20,

                        child: Text("Mattino"),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      //190, // altezza fissa per contenere le ListView verticali
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(7, (giornoIndex) {
                            DateTime giornoCorrente = settimana[giornoIndex];

                            if (isFestivo(giornoCorrente)) {
                              return Container(
                                width: 60,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                ),
                              );
                            }

                            String giorno = (giornoIndex + 1).toString();

                            Map<String, dynamic> mattinaMap =
                                res[giorno]?["mattina"] ?? {};

                            return Container(
                              width: 60, // larghezza fissa per ogni colonna
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                              ),
                              child: ListView.builder(
                                itemCount: mattinaMap.length,
                                itemBuilder: (context, index) {
                                  final orarioKey = mattinaMap.keys.elementAt(
                                    index,
                                  );
                                  final isAvailable = mattinaMap[orarioKey];

                                  return Center(
                                    child: MouseRegion(
                                      onEnter: (_) =>
                                          setState(() => hoveredIndex = index),

                                      onExit: (_) =>
                                          setState(() => hoveredIndex = 0),
                                      child: InkWell(
                                        onTap: () async {
                                          if (!isAvailable) {
                                            soloData = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(settimana[giornoIndex]);

                                            //  visualizzaAppuntamento(context, orario, giorno, nome, tel, email)
                                            print(
                                              "dati: ${soloData} - ${orarioKey}",

                                              // $orarioKey",
                                            );
                                            http.Response response = await http
                                                .get(
                                                  Uri.parse(
                                                    "${proxy}trovaPrenotazione?data=$soloData&orario=$orarioKey",
                                                  ),
                                                )
                                                .timeout(Duration(seconds: 5));
                                            datiAppuntamento = response.body;
                                            //    print(response.body);

                                            final result =
                                                await visualizzaAppuntamento(
                                                  context,
                                                  orarioKey,
                                                  settimana[giornoIndex],
                                                  datiAppuntamento,
                                                );
                                          }
                                          aggiorna();
                                        },

                                        onHover: (h) =>
                                            //  setState(() => isHovered = h),
                                            setState(() {
                                              hoveredCell = h
                                                  ? (giornoIndex, orarioKey)
                                                  : (0, "");
                                            }),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                !isAvailable &&
                                                    hoveredCell ==
                                                        (giornoIndex, orarioKey)
                                                ? Colors.orange.shade300
                                                : !isAvailable
                                                ? Colors.orange.shade100
                                                : isAvailable &&
                                                      hoveredCell ==
                                                          (
                                                            giornoIndex,
                                                            orarioKey,
                                                          )
                                                ? Colors.blue.shade300
                                                : isAvailable
                                                ? Colors.blue.shade100
                                                : null,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              orarioKey,
                                              style: TextStyle(
                                                fontSize: 14,
                                                /*decoration: !isAvailable
                                                    ? TextDecoration.lineThrough
                                                    : null,*/
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.blue.shade100,
                        height: 20,
                        child: Text("Pomeriggio"),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      //190, // altezza fissa per contenere le ListView verticali
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(7, (giornoIndex) {
                            DateTime giornoCorrente = settimana[giornoIndex];
                            DateTime oggi = DateTime.now();

                            if (isFestivo(giornoCorrente)) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                ),
                              );
                            }

                            String giorno = (giornoIndex + 1).toString();

                            Map<String, dynamic> pomeriggioMap =
                                res[giorno]?["pomeriggio"] ?? {};
                            return Container(
                              width: 60, // larghezza fissa per ogni colonna
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                              ),
                              child: ListView.builder(
                                itemCount: pomeriggioMap.length,
                                itemBuilder: (context, index) {
                                  final orarioKey = pomeriggioMap.keys
                                      .elementAt(index);

                                  final isAvailable = pomeriggioMap[orarioKey];

                                  return Center(
                                    child: MouseRegion(
                                      onEnter: (_) =>
                                          setState(() => hoveredIndex = index),

                                      onExit: (_) =>
                                          setState(() => hoveredIndex = 0),
                                      child: InkWell(
                                        onTap: () async {
                                          if (!isAvailable) {
                                            soloData = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(settimana[giornoIndex]);

                                            //  visualizzaAppuntamento(context, orario, giorno, nome, tel, email)
                                            print(
                                              "dati: ${soloData} - ${orarioKey}",

                                              // $orarioKey",
                                            );
                                            http.Response response = await http
                                                .get(
                                                  Uri.parse(
                                                    "${proxy}trovaPrenotazione?data=$soloData&orario=$orarioKey",
                                                  ),
                                                )
                                                .timeout(Duration(seconds: 5));
                                            datiAppuntamento = response.body;
                                            // print(response.body);

                                            final result =
                                                await visualizzaAppuntamento(
                                                  context,
                                                  orarioKey,
                                                  settimana[giornoIndex],
                                                  datiAppuntamento,
                                                );
                                          }
                                          aggiorna();
                                        },

                                        onHover: (h) =>
                                            //  setState(() => isHovered = h),
                                            setState(() {
                                              hoveredCell = h
                                                  ? (giornoIndex, orarioKey)
                                                  : (0, "");
                                            }),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: !isAvailable
                                                ? Colors.orange.shade300
                                                : isAvailable &&
                                                      hoveredCell ==
                                                          (
                                                            giornoIndex,
                                                            orarioKey,
                                                          )
                                                ? Colors.blue.shade300
                                                : isAvailable
                                                ? Colors.blue.shade100
                                                : null,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              orarioKey,
                                              style: TextStyle(
                                                fontSize: 14,
                                                /*decoration: !isAvailable
                                                    ? TextDecoration.lineThrough
                                                    : null,*/
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // Questo Expanded "spinge" i pulsanti verso il basso
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // distanza massima tra i pulsanti
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                              heroTag: "fabLeft",
                              onPressed: frecciaSx,
                              child: Icon(Icons.arrow_back),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                              heroTag: "fabRight",
                              onPressed: frecciaDx,
                              child: Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /*  DropdownButton<String>(
                      dropdownColor:
                          Colors.blue[50], // colore di sfondo del menu
      
                      style: TextStyle(
                        color:
                            Colors.black, // colore testo elementi selezionati
                        fontSize: 16,
                      ),
                      hint: const Text('Seleziona un\'opzione'),
                      //  value: selezionata,
                      items: [
                        DropdownMenuItem(
                          value: 'Opzione 1',
                          child: Text('Opzione 1'),
                        ),
                        DropdownMenuItem(
                          value: 'Opzione 2',
                          child: Text('Opzione 2'),
                        ),
                        DropdownMenuItem(
                          value: 'Opzione 3',
                          child: Text('Opzione 3'),
                        ),
                      ],
                      onChanged: (String? nuovoValore) {
                        setState(() {
                          //    selezionata = nuovoValore;
                        });
                      },
                    ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*Widget altro() {
  return Container(child: Text("asf"));
}
*/
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
