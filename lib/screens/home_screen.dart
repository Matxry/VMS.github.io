import 'package:flutter/material.dart';
import '../data/initial_data.dart';
import '../models/models.dart';
import '../utils/storage_service.dart';
import 'diagnostico_screen.dart';
import 'mejora_screen.dart';
import 'avances_screen.dart';
import 'proyeccion_screen.dart';

const kPrimary = Color(0xFF0D1B2A);
const kNavy    = Color(0xFF1A3A5C);
const kGrey    = Color(0xFF5C6B7A);

const String? kHomeBgImage = null;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppState state;
  bool _cargando = true;
  bool _guardando = false;
  DateTime? _ultimoGuardado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ── Carga datos al iniciar ──
  Future<void> _cargarDatos() async {
    final cargado = await StorageService.cargar();
    setState(() {
      state    = cargado;
      _cargando = false;
    });
  }

  // ── Guarda automáticamente cada vez que hay un cambio ──
  Future<void> _guardarDatos() async {
    setState(() => _guardando = true);
    await StorageService.guardar(state);
    setState(() {
      _guardando    = false;
      _ultimoGuardado = DateTime.now();
    });
  }

  void _upd(VoidCallback fn) {
    setState(() => fn());
    _guardarDatos(); // auto-save en cada cambio
  }

  void _ir(BuildContext context, int sec) async {
    final screens = [
      DiagnosticoScreen(state: state, onUpdate: _upd),
      MejoraScreen(state: state, onUpdate: _upd),
      AvancesScreen(state: state, onUpdate: _upd),
      ProyeccionScreen(state: state, onUpdate: _upd),
    ];
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screens[sec]));
    setState(() {});
    _guardarDatos();
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
        content: const Text(
            'Esto borrara todos los datos ingresados.\nEsta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.borrar();
              setState(() => state = crearEstadoInicial());
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
              Text('Cargando datos...',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 700;
    return Scaffold(
      backgroundColor: kPrimary,
      body: Stack(children: [
        if (kHomeBgImage != null)
          Positioned.fill(
            child: Image.asset(kHomeBgImage!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        if (kHomeBgImage != null)
          Positioned.fill(
            child: Container(color: kPrimary.withOpacity(0.75))),

        SafeArea(
          child: Column(children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 48 : 24, vertical: 20),
              child: Column(children: [
                Image.asset(
                  'assets/logo.png',
                  width: 160, height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.sports_soccer, color: Colors.white, size: 120),
                ),
                const SizedBox(height: 8),
                Text('Sistema de Consultoria Deportiva',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13)),
                if (state.nombreClub.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(state.nombreClub,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 10),
                // ── Fila de acciones ──
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // Indicador de guardado
                  if (_guardando)
                    const Row(children: [
                      SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                            color: Colors.white54, strokeWidth: 2),
                      ),
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
                        'Guardado ${_formatHora(_ultimoGuardado!)}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ]),
                  const SizedBox(width: 16),
                  // Botón reiniciar
                  TextButton.icon(
                    onPressed: _reiniciar,
                    icon: const Icon(Icons.refresh,
                        color: Colors.white38, size: 15),
                    label: const Text('Reiniciar',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                  ),
                ]),
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
                      const Text('Selecciona una seccion',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kPrimary)),
                      const SizedBox(height: 14),
                      isWide ? _gridMenu(context) : _columnMenu(context),
                      const SizedBox(height: 20),
                      _resumenBars(),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _gridMenu(BuildContext context) {
    final items = _menuItems(context);
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
        else
          const Expanded(child: SizedBox()),
      ]));
    }
    return Column(children: rows);
  }

  Widget _columnMenu(BuildContext context) => Column(
    children: _menuItems(context)
        .map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10), child: w))
        .toList(),
  );

  List<Widget> _menuItems(BuildContext context) => [
    _card(context, 0, Icons.assessment_outlined,
        'Diagnostico', 'Evaluacion de areas y subtemas',
        kPrimary, _badgeDiag()),
    _card(context, 1, Icons.trending_up_outlined,
        'Plan de Mejora', 'Problemas detectados y acciones',
        kNavy, _badgeMejora()),
    _card(context, 2, Icons.rocket_launch_outlined,
        'Avances', 'Plan de implementacion mensual',
        const Color(0xFF1C2E3E), _badgeAvances()),
    _card(context, 3, Icons.show_chart_outlined,
        'Proyeccion', 'Indicadores y resultados esperados',
        const Color(0xFF2C3E50), _badgeProyeccion()),
  ];

  String _badgeDiag() {
    final cal = state.areas
        .expand((a) => a.subtemas)
        .where((s) => s.calificacion > 0)
        .length;
    final tot = state.areas.expand((a) => a.subtemas).length;
    return '$cal/$tot subtemas calificados';
  }

  String _badgeMejora() {
    final nProb = state.areas
        .expand((a) => a.subtemas)
        .where((s) => s.problemaDetectado.isNotEmpty)
        .length;
    return '${state.planMejora.length} acciones · $nProb problemas';
  }

  String _badgeAvances() {
    final c = state.planImplementacion
        .where((f) => f.estado == 'Concluido')
        .length;
    return '$c/${state.planImplementacion.length} meses concluidos';
  }

  String _badgeProyeccion() =>
      '${state.proyeccion.where((f) => f.indicador.isNotEmpty).length} indicadores';

  Widget _card(BuildContext context, int sec, IconData icon, String title,
      String sub, Color color, String badge) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _ir(context, sec),
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
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 3),
            Text(sub,
                style: const TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _resumenBars() {
    final areasConDatos =
        state.areas.where((a) => a.promedio > 0).toList();
    if (areasConDatos.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart, color: kPrimary, size: 18),
          SizedBox(width: 6),
          Text('Resumen de calificaciones',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        ...areasConDatos.map((a) {
          final p = a.promedio;
          Color c;
          if (p <= 2) c = const Color(0xFFC0392B);
          else if (p <= 3) c = const Color(0xFF7D6608);
          else if (p <= 4) c = const Color(0xFF1A5276);
          else c = const Color(0xFF1E8449);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Expanded(
                    child: Text(a.nombre,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Text(p.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: c)),
              ]),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: p / 5,
                  minHeight: 7,
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
