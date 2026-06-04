import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/club_model.dart';
import '../models/club_model.dart';
import '../utils/storage_service.dart';
import '../data/initial_data.dart';
import 'diagnostico_screen.dart';
import 'mejora_screen.dart';
import 'avances_screen.dart';
import 'proyeccion_screen.dart';

const kPrimary = Color(0xFF0D1B2A);
const kNavy    = Color(0xFF1A3A5C);
const kGrey    = Color(0xFF5C6B7A);

class ClubScreen extends StatefulWidget {
  final ClubInfo club;
  const ClubScreen({super.key, required this.club});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  late AppState state;
  bool _cargando   = true;
  bool _guardando  = false;
  DateTime? _ultimoGuardado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final s = await StorageService.cargar(widget.club.id);
    // Sincronizar datos del club al state
    s.nombreClub = widget.club.nombre;
    s.consultor  = widget.club.consultor;
    s.fecha      = widget.club.fecha;
    s.tipoOrg    = widget.club.tipo.labelCompleto;
    setState(() { state = s; _cargando = false; });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    // Actualizar club info
    widget.club.nombre    = state.nombreClub;
    widget.club.consultor = state.consultor;
    widget.club.fecha     = state.fecha;
    state.tipoOrg         = widget.club.tipo.labelCompleto;
    widget.club.ultimaModificacion = DateTime.now();
    await StorageService.guardar(widget.club.id, state);
    await StorageService.actualizarClub(widget.club);
    setState(() { _guardando = false; _ultimoGuardado = DateTime.now(); });
  }

  void _upd(VoidCallback fn) {
    setState(() => fn());
    _guardar();
  }

  void _ir(BuildContext context, int sec) async {
    final screens = [
      DiagnosticoScreen(state: state, onUpdate: _upd),
      MejoraScreen(state: state, onUpdate: _upd),
      AvancesScreen(state: state, onUpdate: _upd),
      ProyeccionScreen(state: state, onUpdate: _upd),
    ];
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => screens[sec]));
    setState(() {});
    _guardar();
  }

  void _reiniciar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber, color: Colors.red, size: 22),
          SizedBox(width: 8),
          Text('Reiniciar datos', style: TextStyle(fontSize: 16)),
        ]),
        content: Text(
            'Esto borrara todos los datos de "${widget.club.nombre}".\nEsta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.borrar(widget.club.id);
              final s = crearEstadoInicial();
              s.nombreClub = widget.club.nombre;
              s.consultor  = widget.club.consultor;
              setState(() => state = s);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reiniciar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: kPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Cargando datos del club...',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 700;
    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24, vertical: 16),
            child: Column(children: [
              // Flecha volver
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Indicador guardado
                if (_guardando)
                  const Row(children: [
                    SizedBox(width: 12, height: 12,
                        child: CircularProgressIndicator(
                            color: Colors.white54, strokeWidth: 2)),
                    SizedBox(width: 6),
                    Text('Guardando...',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ])
                else if (_ultimoGuardado != null)
                  Row(children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white38, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Guardado ${_fmtHora(_ultimoGuardado!)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ]),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Colors.white38, size: 20),
                  onPressed: _reiniciar,
                  tooltip: 'Reiniciar datos',
                ),
              ]),
              Image.asset('assets/logo.png',
                  width: 100, height: 100, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.sports_soccer,
                          color: Colors.white, size: 80)),
              const SizedBox(height: 8),
              Text(widget.club.nombre,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(widget.club.tipo.labelCompleto,
                    style: const TextStyle(color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              if (widget.club.consultor.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.club.consultor,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ]),
          ),

          // ── Menú ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F6),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Secciones',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kPrimary)),
                    const SizedBox(height: 14),
                    isWide ? _gridMenu(context) : _colMenu(context),
                    const SizedBox(height: 20),
                    _resumenBars(),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _fmtHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _gridMenu(BuildContext ctx) {
    final items = _items(ctx);
    final rows  = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(Row(children: [
        Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: items[i])),
        if (i + 1 < items.length)
          Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: items[i + 1]))
        else const Expanded(child: SizedBox()),
      ]));
    }
    return Column(children: rows);
  }

  Widget _colMenu(BuildContext ctx) => Column(
    children: _items(ctx)
        .map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10), child: w))
        .toList(),
  );

  List<Widget> _items(BuildContext ctx) => [
    _card(ctx, 0, Icons.assessment_outlined, 'Diagnostico',
        'Evaluacion de areas y subtemas', kPrimary, _bdDiag()),
    _card(ctx, 1, Icons.trending_up_outlined, 'Plan de Mejora',
        'Problemas y acciones', kNavy, _bdMejora()),
    _card(ctx, 2, Icons.rocket_launch_outlined, 'Avances',
        'Plan de implementacion', const Color(0xFF1C2E3E), _bdAvances()),
    _card(ctx, 3, Icons.show_chart_outlined, 'Proyección',
        'Indicadores y resultados', const Color(0xFF2C3E50), _bdProyeccion()),
  ];

  String _bdDiag() {
    final cal = state.areas.expand((a) => a.subtemas)
        .where((s) => s.calificacion > 0).length;
    final tot = state.areas.expand((a) => a.subtemas).length;
    return '$cal/$tot subtemas';
  }

  String _bdMejora() {
    final n = state.areas.expand((a) => a.subtemas)
        .where((s) => s.problemaDetectado.isNotEmpty).length;
    return '${state.planMejora.length} acciones · $n problemas';
  }

  String _bdAvances() {
    final c = state.planImplementacion
        .where((f) => f.estado == 'Concluido').length;
    return '$c/${state.planImplementacion.length} meses';
  }

  String _bdProyeccion() =>
      '${state.proyeccion.where((f) => f.indicador.isNotEmpty).length} indicadores';

  Widget _card(BuildContext ctx, int sec, IconData icon, String title,
      String sub, Color color, String badge) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _ir(ctx, sec),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
            boxShadow: [BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: color.withOpacity(0.4), size: 14),
            ]),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge, style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _resumenBars() {
    final areas = state.areas.where((a) => a.promedio > 0).toList();
    if (areas.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart, color: kPrimary, size: 18),
          SizedBox(width: 6),
          Text('Resumen', style: TextStyle(
              fontWeight: FontWeight.bold, color: kPrimary, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        ...areas.map((a) {
          final p = a.promedio;
          Color c;
          if (p <= 2)      c = const Color(0xFFC0392B);
          else if (p <= 3) c = const Color(0xFF7D6608);
          else if (p <= 4) c = const Color(0xFF1A5276);
          else             c = const Color(0xFF1E8449);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Expanded(child: Text(a.nombre,
                    style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Text(p.toStringAsFixed(1), style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: c)),
              ]),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: p / 5, minHeight: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(c),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}
