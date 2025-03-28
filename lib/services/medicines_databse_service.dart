import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class MedicineDatabase {
  static List<Map<String, String>> medicines = [];

  static Future<void> loadMedicines() async {
    final csvData = await rootBundle.loadString('assets/medicines_dataset.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData, eol: '\n');
    
    // Assuming the first row is headers
    List<String> headers = csvTable.first.map((e) => e.toString()).toList();
    csvTable.removeAt(0);
    
    medicines = csvTable.map((row) {
      Map<String, String> rowMap = {};
      for (int i = 0; i < headers.length; i++) {
        rowMap[headers[i]] = row[i].toString();
      }
      return rowMap;
    }).toList();
  }

  static Map<String, String>? searchMedicine(String name) {
    // simple case-insensitive search, can add fuzzy search later
    return medicines.firstWhere(
      (medicine) => (medicine['drug_name'] ?? '').toLowerCase().contains(name.toLowerCase(),),
      orElse: () => {},
    );
  }
}
