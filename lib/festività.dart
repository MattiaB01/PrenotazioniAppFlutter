bool isFestivo(DateTime date) {
  print(date);
  final festivitaFisse = [
    DateTime(date.year, 1, 1), // Capodanno
    DateTime(date.year, 1, 6), // Epifania
    DateTime(date.year, 4, 25), // Festa della Liberazione
    DateTime(date.year, 5, 1), // Festa del Lavoro
    DateTime(date.year, 6, 2), // Festa della Repubblica
    DateTime(date.year, 8, 15), // Ferragosto
    DateTime(date.year, 11, 1), // Ognissanti
    DateTime(date.year, 12, 8), // Immacolata
    DateTime(date.year, 12, 25), // Natale
    DateTime(date.year, 12, 26), // Santo Stefano
  ];

  return festivitaFisse.any((f) => f.day == date.day && f.month == date.month);
}
