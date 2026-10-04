import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AQ.Ab8RN6Lfz7Tude_IOrBx0yFsCVgYcZyXReeYwgqxe39nOeXu5g';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final models = data['models'] as List;
    for (var model in models) {
      if (model['supportedGenerationMethods']?.contains('generateContent') == true) {
        print(model['name']);
      }
    }
  } else {
    print('Failed to load models: ${response.body}');
  }
}
