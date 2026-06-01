class ClubInfo {
  final String id;
  String nombre;
  String consultor;
  String fecha;
  DateTime ultimaModificacion;

  ClubInfo({
    required this.id,
    required this.nombre,
    this.consultor = '',
    this.fecha = '',
    DateTime? ultimaModificacion,
  }) : ultimaModificacion = ultimaModificacion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'consultor': consultor,
    'fecha': fecha,
    'ultimaModificacion': ultimaModificacion.toIso8601String(),
  };

  factory ClubInfo.fromJson(Map<String, dynamic> j) => ClubInfo(
    id: j['id'] ?? '',
    nombre: j['nombre'] ?? '',
    consultor: j['consultor'] ?? '',
    fecha: j['fecha'] ?? '',
    ultimaModificacion: j['ultimaModificacion'] != null
        ? DateTime.parse(j['ultimaModificacion'])
        : DateTime.now(),
  );
}
