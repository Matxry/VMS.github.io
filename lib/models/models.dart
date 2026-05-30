import 'dart:convert';
import 'dart:typed_data';

class SubtemaModel {
  final String nombre;
  final String subarea;
  int calificacion;
  String observacion;
  String problemaDetectado;
  List<Uint8List> imagenes;

  SubtemaModel({
    required this.nombre,
    required this.subarea,
    this.calificacion = 0,
    this.observacion = '',
    this.problemaDetectado = '',
    List<Uint8List>? imagenes,
  }) : imagenes = imagenes ?? [];

  int get impactoAutomatico {
    if (calificacion <= 0) return 3;
    if (calificacion <= 2) return 1;
    if (calificacion == 3) return 3;
    return 5;
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'subarea': subarea,
    'calificacion': calificacion,
    'observacion': observacion,
    'problemaDetectado': problemaDetectado,
    'imagenes': imagenes.map((img) => base64Encode(img)).toList(),
  };

  factory SubtemaModel.fromJson(Map<String, dynamic> j) {
    final sub = SubtemaModel(
      nombre: j['nombre'] ?? '',
      subarea: j['subarea'] ?? '',
      calificacion: j['calificacion'] ?? 0,
      observacion: j['observacion'] ?? '',
      problemaDetectado: j['problemaDetectado'] ?? '',
    );
    if (j['imagenes'] != null) {
      sub.imagenes = (j['imagenes'] as List)
          .map((s) => base64Decode(s as String))
          .toList();
    }
    return sub;
  }
}

class AreaModel {
  final String nombre;
  final List<SubtemaModel> subtemas;

  AreaModel({required this.nombre, required this.subtemas});

  double get promedio {
    final cal = subtemas.where((s) => s.calificacion > 0).toList();
    if (cal.isEmpty) return 0;
    return cal.fold(0, (sum, s) => sum + s.calificacion) / cal.length;
  }

  int get totalProblemas =>
      subtemas.where((s) => s.problemaDetectado.isNotEmpty).length;

  List<SubtemaModel> get subtemasConProblema =>
      subtemas.where((s) => s.problemaDetectado.isNotEmpty).toList()
        ..sort((a, b) => a.impactoAutomatico.compareTo(b.impactoAutomatico));

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'subtemas': subtemas.map((s) => s.toJson()).toList(),
  };

  factory AreaModel.fromJson(Map<String, dynamic> j) => AreaModel(
    nombre: j['nombre'] ?? '',
    subtemas: (j['subtemas'] as List? ?? [])
        .map((s) => SubtemaModel.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class FilaMejora {
  String area;
  String problema;
  String accionRecomendada;
  String responsable;
  String tiempoEstimado;
  String dificultad;
  String impactoEsperado;
  int    nivelImpacto;
  bool   autoGenerado;
  bool   incluido;

  FilaMejora({
    this.area = '',
    this.problema = '',
    this.accionRecomendada = '',
    this.responsable = '',
    this.tiempoEstimado = '',
    this.dificultad = '',
    this.impactoEsperado = '',
    this.nivelImpacto = 3,
    this.autoGenerado = false,
    this.incluido = true,
  });

  String get impactoLabel {
    if (nivelImpacto <= 2) return 'URGENTE';
    if (nivelImpacto <= 4) return 'MEDIO';
    return 'BAJO';
  }

  Map<String, dynamic> toJson() => {
    'area': area,
    'problema': problema,
    'accionRecomendada': accionRecomendada,
    'responsable': responsable,
    'tiempoEstimado': tiempoEstimado,
    'dificultad': dificultad,
    'impactoEsperado': impactoEsperado,
    'nivelImpacto': nivelImpacto,
    'autoGenerado': autoGenerado,
    'incluido': incluido,
  };

  factory FilaMejora.fromJson(Map<String, dynamic> j) => FilaMejora(
    area: j['area'] ?? '',
    problema: j['problema'] ?? '',
    accionRecomendada: j['accionRecomendada'] ?? '',
    responsable: j['responsable'] ?? '',
    tiempoEstimado: j['tiempoEstimado'] ?? '',
    dificultad: j['dificultad'] ?? '',
    impactoEsperado: j['impactoEsperado'] ?? '',
    nivelImpacto: j['nivelImpacto'] ?? 3,
    autoGenerado: j['autoGenerado'] ?? false,
    incluido: j['incluido'] ?? true,
  );
}

class FilaImplementacion {
  String periodo;
  String accion;
  String estado;
  String observaciones;

  FilaImplementacion({
    this.periodo = '',
    this.accion = '',
    this.estado = 'Pendiente',
    this.observaciones = '',
  });

  Map<String, dynamic> toJson() => {
    'periodo': periodo,
    'accion': accion,
    'estado': estado,
    'observaciones': observaciones,
  };

  factory FilaImplementacion.fromJson(Map<String, dynamic> j) =>
      FilaImplementacion(
        periodo: j['periodo'] ?? '',
        accion: j['accion'] ?? '',
        estado: j['estado'] ?? 'Pendiente',
        observaciones: j['observaciones'] ?? '',
      );
}

class FilaProyeccion {
  String indicador;
  String estadoActual;
  String proyeccion;
  String mejoraEsperada;

  FilaProyeccion({
    this.indicador = '',
    this.estadoActual = '',
    this.proyeccion = '',
    this.mejoraEsperada = '',
  });

  Map<String, dynamic> toJson() => {
    'indicador': indicador,
    'estadoActual': estadoActual,
    'proyeccion': proyeccion,
    'mejoraEsperada': mejoraEsperada,
  };

  factory FilaProyeccion.fromJson(Map<String, dynamic> j) => FilaProyeccion(
    indicador: j['indicador'] ?? '',
    estadoActual: j['estadoActual'] ?? '',
    proyeccion: j['proyeccion'] ?? '',
    mejoraEsperada: j['mejoraEsperada'] ?? '',
  );
}

class AppState {
  String nombreClub;
  String fecha;
  String consultor;

  final List<AreaModel> areas;
  final List<FilaMejora> planMejora;
  final List<FilaImplementacion> planImplementacion;
  final List<FilaProyeccion> proyeccion;

  AppState({
    this.nombreClub = '',
    this.fecha = '',
    this.consultor = '',
    required this.areas,
    required this.planMejora,
    required this.planImplementacion,
    required this.proyeccion,
  });

  Map<String, dynamic> toJson() => {
    'nombreClub': nombreClub,
    'fecha': fecha,
    'consultor': consultor,
    'areas': areas.map((a) => a.toJson()).toList(),
    'planMejora': planMejora.map((f) => f.toJson()).toList(),
    'planImplementacion': planImplementacion.map((f) => f.toJson()).toList(),
    'proyeccion': proyeccion.map((f) => f.toJson()).toList(),
  };

  factory AppState.fromJson(Map<String, dynamic> j, List<AreaModel> areasBase) {
    // Restaurar areas preservando la estructura base pero con datos guardados
    final areasGuardadas = (j['areas'] as List? ?? []);
    final areas = areasBase.asMap().entries.map((e) {
      if (e.key < areasGuardadas.length) {
        final ag = areasGuardadas[e.key] as Map<String, dynamic>;
        final subtemasGuardados = (ag['subtemas'] as List? ?? []);
        final subtemas = e.value.subtemas.asMap().entries.map((se) {
          if (se.key < subtemasGuardados.length) {
            final sg = subtemasGuardados[se.key] as Map<String, dynamic>;
            return SubtemaModel.fromJson({
              'nombre': se.value.nombre,
              'subarea': se.value.subarea,
              ...sg,
            });
          }
          return se.value;
        }).toList();
        return AreaModel(nombre: e.value.nombre, subtemas: subtemas);
      }
      return e.value;
    }).toList();

    return AppState(
      nombreClub: j['nombreClub'] ?? '',
      fecha: j['fecha'] ?? '',
      consultor: j['consultor'] ?? '',
      areas: areas,
      planMejora: (j['planMejora'] as List? ?? [])
          .map((f) => FilaMejora.fromJson(f as Map<String, dynamic>))
          .toList(),
      planImplementacion: (j['planImplementacion'] as List? ?? [])
          .map((f) => FilaImplementacion.fromJson(f as Map<String, dynamic>))
          .toList(),
      proyeccion: (j['proyeccion'] as List? ?? [])
          .map((f) => FilaProyeccion.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  void sincronizarProblemas() {
    final nuevos = <FilaMejora>[];
    for (final area in areas) {
      for (final sub in area.subtemasConProblema) {
        nuevos.add(FilaMejora(
          area: area.nombre,
          problema: sub.problemaDetectado,
          accionRecomendada: '',
          nivelImpacto: sub.impactoAutomatico,
          autoGenerado: true,
          incluido: sub.calificacion < 4,
        ));
      }
    }
    final manuales = planMejora.where((f) => !f.autoGenerado).toList();
    planMejora.clear();
    for (final nuevo in nuevos) {
      final existente = manuales.firstWhere(
        (m) => m.area == nuevo.area && m.problema == nuevo.problema,
        orElse: () => nuevo,
      );
      existente.autoGenerado = true;
      existente.nivelImpacto = nuevo.nivelImpacto;
      planMejora.add(existente);
    }
    for (final m in manuales) {
      if (!planMejora.contains(m)) planMejora.add(m);
    }
  }
}
