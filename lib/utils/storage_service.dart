import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/club_model.dart';
import '../data/initial_data.dart';

class StorageService {
  static const _kClubes    = 'vms_clubes_lista';
  static const _kPrefixState = 'vms_state_';

  // ── CLUBES ──────────────────────────────────────────

  static Future<List<ClubInfo>> cargarClubes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = prefs.getString(_kClubes);
      if (json == null) return [];
      final list  = jsonDecode(json) as List;
      return list.map((e) => ClubInfo.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Future<void> guardarClubes(List<ClubInfo> clubes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kClubes, jsonEncode(clubes.map((c) => c.toJson()).toList()));
  }

  static Future<void> agregarClub(ClubInfo club) async {
    final clubes = await cargarClubes();
    clubes.add(club);
    await guardarClubes(clubes);
  }

  static Future<void> actualizarClub(ClubInfo club) async {
    final clubes = await cargarClubes();
    final idx    = clubes.indexWhere((c) => c.id == club.id);
    if (idx >= 0) clubes[idx] = club;
    await guardarClubes(clubes);
  }

  static Future<void> eliminarClub(String id) async {
    final clubes = await cargarClubes();
    clubes.removeWhere((c) => c.id == id);
    await guardarClubes(clubes);
    // Borrar también el estado del club
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kPrefixState$id');
  }

  // ── ESTADO POR CLUB ──────────────────────────────────

  static Future<bool> guardar(String clubId, AppState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = jsonEncode(state.toJson());
      return await prefs.setString('$_kPrefixState$clubId', json);
    } catch (_) { return false; }
  }

  static Future<AppState> cargar(String clubId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = prefs.getString('$_kPrefixState$clubId');
      if (json == null) return crearEstadoInicial();
      final map   = jsonDecode(json) as Map<String, dynamic>;
      final base  = crearEstadoInicial();
      return AppState.fromJson(map, base.areas);
    } catch (_) { return crearEstadoInicial(); }
  }

  static Future<void> borrar(String clubId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kPrefixState$clubId');
  }
}
