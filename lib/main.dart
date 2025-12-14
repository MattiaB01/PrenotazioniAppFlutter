import 'package:flutter/material.dart';

//import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:calendario/appuntamento.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:calendario/proxy.dart";
import 'festività.dart';
import 'test.dart';

//import 'orari_page.dart';

//import 'prenotazioni.dart';

import 'prenotazioni_effettuate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Prenota un appuntamento'),
        '/test': (context) => const Test(),
        '/about': (context) => const AboutPage(),
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

  bool isHovered = true;
  int hoveredIndex = 0;
  int dayIndex = 0;
  String oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
  (int?, String?) hoveredCell = (0, ""); // (giornoIndex, orarioKey)
  Map<String, dynamic> res = {};

  final url = Uri.parse('${proxy}settimana2');
  final headers = {'Content-Type': 'application/json'};

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

    // Calcola lunedì della settimana corrente
    startOfWeek = startOfWeek.subtract(
      Duration(days: DateTime.now().weekday - 1),
    );

    aggiorna();
  }

  List<String> orari = [];

  var primoOrario;

  bool isLoading = true;

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

    nMese = startOfWeek.month;
  }

  /*
  void aggiorna() async {
    var dati;
    try {
      dati = await settimana(startOfWeek);
    } catch (e) {
      print("Errore durante il caricamento dei dati: $e");
      dati = {
        "1": {"mattina": "", "pomeriggio": ""},
        "2": {"mattina": "", "pomeriggio": ""},
        "3": {"mattina": "", "pomeriggio": ""},
        "4": {"mattina": "", "pomeriggio": ""},
        "5": {"mattina": "", "pomeriggio": ""},
        "6": {"mattina": "", "pomeriggio": ""},
        "7": {"mattina": "", "pomeriggio": ""},
      };
      //return;
    }
    setState(() {
      res = dati;

      final orari = res["1"]?["mattina"] as Map<String, dynamic>?;

      primoOrario = orari?.entries
          .firstWhere(
            (entry) => entry.value == true,
            orElse: () => const MapEntry("", false),
          )
          .key;

      print(res["1"]["mattina"]);
    });
  }
*/

  @override
  Widget build(BuildContext context) {
    List<DateTime> settimana = List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );
    var oggi = DateTime.now();
    var num_settimana = oggi.weekOfYear;

    var num_sett_selezionato = startOfWeek.weekOfYear;

    void frecciaSx() {
      setState(() {
        //  print(oggi.weekday);

        //non lascia selezionare le settimane passate
        if (oggi.weekday > 6) {
          if (num_sett_selezionato > num_settimana + 1) {
            startOfWeek = startOfWeek.subtract(Duration(days: 7));
          }
        } else {
          if (num_sett_selezionato > num_settimana) {
            startOfWeek = startOfWeek.subtract(Duration(days: 7));
          }
        }

        print("$num_sett_selezionato $num_settimana");
      });
      aggiorna();
    }

    void frecciaDx() {
      setState(() {
        startOfWeek = startOfWeek.add(Duration(days: 7));
      });
      aggiorna();
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          /*  IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrariPage()),
              );
            },
            icon: Icon(Icons.settings_applications),
          ),*/
          IconButton(
            icon: Icon(Icons.settings),

            onPressed: () {
              Navigator.push(
                context,
                //MaterialPageRoute(builder: (context) => const OrariPage()),
                MaterialPageRoute(
                  builder: (context) =>
                      const Prenotazioni(), // PrenotazioniSettimanaliPage(),
                ),
              );
              //Navigator.pushNamed(context, '/about');
              //_dialogBuilder(context);
            },
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints(
          minHeight: 200,
          minWidth: 300,
          maxHeight: 900,
        ),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 680,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  //container visualizzazione orari
                  width: 500,
                  height: 650, //era 650
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black45, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200, // colore ombra
                        blurRadius: 8, // sfocatura
                        offset: Offset(
                          2,
                          4,
                        ), // spostamento orizzontale/verticale
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
                                          (settimana[a].day ==
                                                  DateTime.now().day &&
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
                                                        DateTime.now()
                                                            .month) /* &&
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

                            child: Center(child: Text("Mattino")),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          //190, // altezza fissa per contenere le ListView verticali
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (giornoIndex) {
                                DateTime giornoCorrente =
                                    settimana[giornoIndex];
                                DateTime oggi = DateTime.now();

                                // Se il giorno è prima di oggi (solo data, senza ora) → non mostra nulla
                                if (DateTime(
                                  giornoCorrente.year,
                                  giornoCorrente.month,
                                  giornoCorrente.day,
                                ).isBefore(
                                  DateTime(oggi.year, oggi.month, oggi.day),
                                )) {
                                  return Container(
                                    width: 60,
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ); // spazio vuoto per il giorno passato
                                }

                                if (DateTime(
                                  giornoCorrente.year,
                                  giornoCorrente.month,
                                  giornoCorrente.day,
                                ).isAtSameMomentAs(
                                  DateTime(oggi.year, oggi.month, oggi.day),
                                )) {
                                  return Container(
                                    width: 60,
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ); // spazio vuoto per il giorno passato
                                }

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
                                      final orarioKey = mattinaMap.keys
                                          .elementAt(index);
                                      final isAvailable = mattinaMap[orarioKey];

                                      return Center(
                                        child: MouseRegion(
                                          onEnter: (_) => setState(
                                            () => hoveredIndex = index,
                                          ),

                                          onExit: (_) =>
                                              setState(() => hoveredIndex = 0),
                                          child: InkWell(
                                            onTap: () async {
                                              if (!isAvailable) {
                                                return;
                                              }

                                              final result = await appuntamento(
                                                context,
                                                orarioKey,
                                                settimana[giornoIndex],
                                              );

                                              aggiorna();
                                            },

                                            /*  onTap: () => isAvailable
                                                ? appuntamento(
                                                    context,
                                                    orarioKey,
                                                    settimana[giornoIndex],
                                                  ).then((result) {
                                                    if (result == true) {
                                                      aggiorna();
                                                    }
                                                  })*/
                                            //                                           : print("premuto"),
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
                                                    isAvailable &&
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
                                              /* color: /* hoveredIndex == index
                                                  ? Colors.blue.shade100
                                                  : Colors.transparent,*/
                                                  hoveredCell ==
                                                      (giornoIndex, orarioKey)
                                                  ? Colors.blue.shade100
                                                  : Colors.transparent,*/
                                              child: Center(
                                                child: Text(
                                                  orarioKey,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    decoration: !isAvailable
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
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
                            child: Center(child: Text("Pomeriggio")),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          //190, // altezza fissa per contenere le ListView verticali
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (giornoIndex) {
                                DateTime giornoCorrente =
                                    settimana[giornoIndex];
                                DateTime oggi = DateTime.now();

                                if (DateTime(
                                  giornoCorrente.year,
                                  giornoCorrente.month,
                                  giornoCorrente.day,
                                ).isAtSameMomentAs(
                                  DateTime(oggi.year, oggi.month, oggi.day),
                                )) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ); // spazio vuoto per il giorno passato
                                }

                                // Se il giorno è prima di oggi (solo data, senza ora) → non mostra nulla
                                if (DateTime(
                                  giornoCorrente.year,
                                  giornoCorrente.month,
                                  giornoCorrente.day,
                                ).isBefore(
                                  DateTime(oggi.year, oggi.month, oggi.day),
                                )) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ); // spazio vuoto per il giorno passato
                                }

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
                                      final isAvailable =
                                          pomeriggioMap[orarioKey];

                                      return Center(
                                        child: MouseRegion(
                                          onEnter: (_) => setState(
                                            () => hoveredIndex = index,
                                          ),

                                          onExit: (_) =>
                                              setState(() => hoveredIndex = 0),
                                          child: InkWell(
                                            onTap: () async => isAvailable
                                                ? await appuntamento(
                                                    context,
                                                    orarioKey,
                                                    settimana[giornoIndex],
                                                  ).then((result) {
                                                    aggiorna();
                                                    /*
                                                    if (result == true) {
                                                      aggiorna();
                                                    }*/
                                                  })
                                                : print("premuto"),

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
                                                    isAvailable &&
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
                                              /* color: /* hoveredIndex == index
                                                  ? Colors.blue.shade100
                                                  : Colors.transparent,*/
                                                  hoveredCell ==
                                                      (giornoIndex, orarioKey)
                                                  ? Colors.blue.shade100
                                                  : Colors.transparent,*/
                                              child: Center(
                                                child: Text(
                                                  orarioKey,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    decoration: !isAvailable
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );

                                      /*      return Container(
                                        //contentPadding: EdgeInsets.symmetric(
                                        //horizontal: 2,
                                        //),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () => isAvailable
                                                ? appuntamento(
                                                    context,
                                                    orarioKey,
                                                    settimana[giornoIndex],
                                                  ).then((result) {
                                                    if (result == true) {
                                                      aggiorna();
                                                    }
                                                  })
                                                : print("premuto"),
                      
                                            child: Text(
                                              orarioKey,
                                              style: TextStyle(
                                                fontSize: 14,
                                                decoration: !isAvailable
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ),
                      
                                        /* subtitle: Text(
                                        isAvailable ? "Disponibile" : "Occupato",*/
                                        //),
                                        // dense: true,
                                        // visualDensity: VisualDensity.compact,
                                      );*/
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        /*
                        DropdownButton<String>(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 70),
              child: SizedBox(
                height: 600,
                width: 900,

                /*decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // raggio di arrotondamento
                ),*/
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Align(
                                alignment: AlignmentGeometry.xy(-1, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius:
                                        90, // aumenta per renderlo più grande
                                    backgroundImage: AssetImage(
                                      'assets/image.png',
                                    ), // o NetworkImage(url)
                                    backgroundColor: Colors
                                        .grey[200], // colore di sfondo se l'immagine ha trasparenza
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              width: 250,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Dove ricevo:"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Text(
                                      'Piazza del Sole 7 \n 50123 Firenze FI',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16), // spazio tra immagine e testo
                        Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: Column(
                            children: [
                              SizedBox(height: 70),
                              Text(
                                'Dott.ssa Sara Bianchi',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Fisioterapista',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ), // spazio tra immagine e testo
                              SizedBox(
                                width: 500,
                                child: Text(
                                  'Professionista dedicata e appassionata, specializzata nella riabilitazione motoria e nel recupero post-trauma. Oltre 10 anni di esperienza nel seguire pazienti di tutte le età.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),

                              SizedBox(
                                height: 25,
                              ), // spazio tra immagine e testo
                              SizedBox(
                                width: 500,
                                height: 200, // altezza fissa contenitore
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  child: Text(
                                    '• Laurea in Fisioterapia – Università di Milano (2012)\n'
                                    '• Specializzazione in Terapia Manuale Ortopedica (2015)\n'
                                    '• Esperienza in cliniche sportive e centri di riabilitazione neurologica\n'
                                    '• Relatrice a convegni di fisioterapia e prevenzione infortuni\n'
                                    '• Collaborazioni con squadre di calcio dilettantistiche',
                                    style: TextStyle(fontSize: 14),
                                    softWrap: true,
                                  ),
                                ),
                              ),

                              /* SizedBox(
                                width: 500,
                                height: 50,
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Text(
                                      '•Laurea in Fisioterapia – Università di Milano (2012)\n•Specializzazione in Terapia Manuale Ortopedica (2015)\n•Esperienza in cliniche sportive e centri di riabilitazione neurologica \n•Relatrice a convegni di fisioterapia e prevenzione infortuni \n•Collaborazioni con squadre di calcio dilettantistiche',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /*floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: SizedBox(
          //width: 500,
          width: 550,
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 65,
                //bottom: 16,
                //  left: 46,
                left: 56, //era:106
                child: FloatingActionButton(
                  heroTag: 'btnSinistra',
                  onPressed: frecciaSx,
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              Positioned(
                bottom: 65,
                //bottom: 16,
                // right: 16,
                right: 54, // era 24,
                child: FloatingActionButton(
                  heroTag: 'btnDestra',
                  onPressed: frecciaDx,
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        ),
      ),*/
    );
  }
}

Widget altro() {
  return Container(child: Text("asf"));
}

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

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Center(child: Text('Questa è la pagina About')),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context) {
  final TextEditingController _controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SizedBox(
          width: 50,

          child: Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Inserisci password"),
                  TextField(obscureText: true),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        () => //Navigator.pop(context),
                            Navigator.pushNamed(context, '/about'),
                    child: Text("OK"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
