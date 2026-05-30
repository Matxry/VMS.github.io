import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/initial_data.dart';

const _kKey = 'vms_app_state';

class StorageService {
  // Guarda el estado completo
  static Future<bool> guardar(AppState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = jsonEncode(state.toJson());
      return await prefs.setString(_kKey, json);
    } catch (e) {
      return false;
    }
  }

  // Carga el estado guardado, si no existe devuelve el inicial
  static Future<AppState> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = prefs.getString(_kKey);
      if (json == null) return crearEstadoInicial();
      final map   = jsonDecode(json) as Map<String, dynamic>;
      final base  = crearEstadoInicial();
      return AppState.fromJson(map, base.areas);
    } catch (_) {
      return crearEstadoInicial();
    }
  }

  // Borra los datos guardados
  static Future<void> borrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  // Verifica si hay datos guardados
  static Future<bool> hayDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kKey);
  }
}
