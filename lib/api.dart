import 'package:intl/intl.dart';
import 'package:calendario/appuntamento.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'proxy.dart';

void apiPrenotazione(
  String orario,
  DateTime giorno,
  String nome,
  String tel,
  String emails,
) async {
  print("in api prenotazione $orario e $giorno");
  String formattedDate = DateFormat('yyyy-MM-dd').format(giorno);
  final headers = {'Content-Type': 'application/json'};
  /*print(formattedDate);*/

  String url = "${proxy}insertPren";

  Uri url1 = Uri.parse(url);

  try {
    final response = await http
        .post(
          url1,
          headers: headers,
          body: jsonEncode({
            "nome": nome,
            "data": formattedDate,
            "orario": orario,
            "studio": "studio1",
            "telefono": tel,
            "email": email,
          }),
          /* body: {
            "nome": nome,
            "data": formattedDate,
            "orario": orario,
            "studio": "studio1",
          },*/
        )
        .timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      // final decoded = jsonDecode(response.body);
      print("ok prenotato");
    } else {
      throw Exception('Errore nella richiesta');
    }
  } catch (e) {
    print(e);
  }
}

Future<String> apiAppuntamentiGiorno(DateTime giorno) async {
  String url = "${proxy}prenotazioneGiorno?data=$giorno";

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      print("risposta appuntamenti giorno: ${response.body}");
      return response.body;
    } else {
      print("errore nella richiesta");
      return ""; // lista vuota o stringa vuota
    }
  } catch (e) {
    print("Errore: $e");
    return ""; // ritorni stringa vuota in caso di errore
  }
}

Future<List<Map<String, dynamic>>> apiAppuntamentiSettimana(
  DateTime giorno,
) async {
  try {
    String dataFormattata = DateFormat('yyyy-MM-dd').format(giorno);
    /*print(dataFormattata);*/
    String url = "${proxy}prenotazioniSettimana?data=$dataFormattata";
    //"${proxy}prenotazioniSettimana?data=$dataFormattata";

    final response = await http
        .get(Uri.parse(url))
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      print("risposta appuntamenti giorno: ${response.body}");

      // Decodifica il JSON in lista dinamica
      List<dynamic> jsonList = jsonDecode(response.body);

      // Converti in lista di mappe e restituisci
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print("Errore nella richiesta: ${response.statusCode}");
      //return []; // ritorna lista vuota in caso di errore
      return <Map<String, dynamic>>[];
    }
  } catch (e) {
    print("Eccezione: $e");
    //return []; // ritorna lista vuota in caso di eccezione
    return <Map<String, dynamic>>[];
  }
}

Future<String> apiCancellaAppuntamento(int id) async {
  String url = "${proxy}deletePren?id=$id";

  try {
    final response = await http
        .post(Uri.parse(url))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      print("fatto");
      return response.body;
    } else {
      print("errore nella richiesta");
      return ""; // lista vuota o stringa vuota
    }
  } catch (e) {
    print("Errore: $e");
    return ""; // ritorni stringa vuota in caso di errore
  }
}
