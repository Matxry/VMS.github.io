enum TipoOrganizacion { club, institucion, academia }

extension TipoOrganizacionExt on TipoOrganizacion {
  String get label {
    switch (this) {
      case TipoOrganizacion.club:        return 'Club';
      case TipoOrganizacion.institucion: return 'Institución';
      case TipoOrganizacion.academia:    return 'Academia';
    }
  }

  String get labelCompleto {
    switch (this) {
      case TipoOrganizacion.club:        return 'Club Deportivo';
      case TipoOrganizacion.institucion: return 'Institucion Educativa';
      case TipoOrganizacion.academia:    return 'Academia Deportiva';
    }
  }

  String get icono {
    switch (this) {
      case TipoOrganizacion.club:        return 'club';
      case TipoOrganizacion.institucion: return 'institución';
      case TipoOrganizacion.academia:    return 'academia';
    }
  }
}

class ClubInfo {
  final String id;
  String nombre;
  String consultor;
  String fecha;
  TipoOrganizacion tipo;
  DateTime ultimaModificacion;

  ClubInfo({
    required this.id,
    required this.nombre,
    this.consultor = '',
    this.fecha = '',
    this.tipo = TipoOrganizacion.club,
    DateTime? ultimaModificacion,
  }) : ultimaModificacion = ultimaModificacion ?? DateTime.now();

  // Nombre completo con tipo: "Academia VMS" o "Club Real Madrid"
  String get nombreConTipo => '${tipo.label} $nombre';

  // Titulo para encabezados de PDF
  String get tituloInforme => 'Informe de Diagnostico — ${tipo.labelCompleto}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'consultor': consultor,
    'fecha': fecha,
    'tipo': tipo.name,
    'ultimaModificacion': ultimaModificacion.toIso8601String(),
  };

  factory ClubInfo.fromJson(Map<String, dynamic> j) => ClubInfo(
    id: j['id'] ?? '',
    nombre: j['nombre'] ?? '',
    consultor: j['consultor'] ?? '',
    fecha: j['fecha'] ?? '',
    tipo: TipoOrganizacion.values.firstWhere(
      (t) => t.name == (j['tipo'] ?? 'club'),
      orElse: () => TipoOrganizacion.club,
    ),
    ultimaModificacion: j['ultimaModificacion'] != null
        ? DateTime.parse(j['ultimaModificacion'])
        : DateTime.now(),
  );
}
