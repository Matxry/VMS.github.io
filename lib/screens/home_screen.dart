import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../utils/storage_service.dart';
import 'club_screen.dart';

const kPrimary = Color(0xFF0D1B2A);
const kNavy    = Color(0xFF1A3A5C);
const kGrey    = Color(0xFF5C6B7A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ClubInfo> _clubes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final clubes = await StorageService.cargarClubes();
    setState(() { _clubes = clubes; _cargando = false; });
  }

  void _nuevoClub() {
    final nombreCtrl    = TextEditingController();
    final consultorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.add_circle_outline, color: kPrimary, size: 22),
          SizedBox(width: 8),
          Text('Nuevo Club / Academia',
              style: TextStyle(fontSize: 16, color: kPrimary)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: nombreCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre del club *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.sports_soccer, size: 18),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: consultorCtrl,
            decoration: InputDecoration(
              labelText: 'Consultor',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person_outline, size: 18),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.trim().isEmpty) return;
              final club = ClubInfo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: nombreCtrl.text.trim(),
                consultor: consultorCtrl.text.trim(),
                fecha: _hoy(),
              );
              await StorageService.agregarClub(club);
              Navigator.pop(ctx);
              await _cargar();
              if (mounted) _abrirClub(club);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirClub(ClubInfo club) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => ClubScreen(club: club),
    ));
    await _cargar(); // Refresh al volver
  }

  void _eliminarClub(ClubInfo club) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber, color: Colors.red, size: 22),
          SizedBox(width: 8),
          Text('Eliminar club', style: TextStyle(fontSize: 16)),
        ]),
        content: Text('Esto eliminara todos los datos de "${club.nombre}".\nEsta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.eliminarClub(club.id);
              Navigator.pop(ctx);
              await _cargar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _hoy() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year}';
  }

  String _formatFecha(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'ahora mismo';
    if (diff.inHours < 1)    return 'hace ${diff.inMinutes} min';
    if (diff.inDays < 1)     return 'hace ${diff.inHours} h';
    if (diff.inDays == 1)    return 'ayer';
    if (diff.inDays < 7)     return 'hace ${diff.inDays} dias';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (_cargando) {
      return const Scaffold(
        backgroundColor: kPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Cargando...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24, vertical: 20),
            child: Column(children: [
              Image.asset(
                'assets/logo.png',
                width: 140, height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.sports_soccer, color: Colors.white, size: 100),
              ),
              const SizedBox(height: 8),
              Text('Sistema de Consultoria Deportiva',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 4),
              Text('${_clubes.length} club${_clubes.length != 1 ? "es" : ""} registrado${_clubes.length != 1 ? "s" : ""}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ]),
          ),

          // ── Lista de clubes ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _clubes.isEmpty
                  ? _emptyState()
                  : Column(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            isWide ? 40 : 16, 20, isWide ? 40 : 16, 8),
                        child: Row(children: [
                          const Text('Clubes / Academias',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimary)),
                          const Spacer(),
                          Text('${_clubes.length} total',
                              style: const TextStyle(
                                  fontSize: 12, color: kGrey)),
                        ]),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 40 : 16, vertical: 4),
                          itemCount: _clubes.length,
                          itemBuilder: (ctx, i) => _clubCard(_clubes[i]),
                        ),
                      ),
                    ]),
            ),
          ),
        ]),
      ),
      // Botón agregar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoClub,
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Club',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _clubCard(ClubInfo club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sports_soccer,
              color: Colors.white, size: 24),
        ),
        title: Text(club.nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (club.consultor.isNotEmpty)
              Text(club.consultor,
                  style: const TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.access_time, size: 11, color: kGrey),
              const SizedBox(width: 3),
              Text(_formatFecha(club.ultimaModificacion),
                  style: const TextStyle(fontSize: 11, color: kGrey)),
            ]),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.red, size: 20),
            onPressed: () => _eliminarClub(club),
            tooltip: 'Eliminar',
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: kGrey),
        ]),
        onTap: () => _abrirClub(club),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer,
              size: 64, color: kPrimary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No hay clubes registrados',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimary)),
          const SizedBox(height: 8),
          Text('Toca el boton + para agregar tu primer club',
              style: TextStyle(fontSize: 13, color: kGrey)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
