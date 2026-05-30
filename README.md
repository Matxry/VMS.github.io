# VMS Sports — Sistema de Consultoría Deportiva

Aplicación Flutter completa para diagnóstico y consultoría de clubes deportivos.

## Estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada
├── models/
│   └── models.dart                    # Modelos de datos
├── data/
│   └── initial_data.dart              # Datos iniciales (áreas y subtemas del xlsx)
├── screens/
│   └── diagnostico_screen.dart        # Pantalla principal
├── widgets/
│   ├── header_section.dart            # Información del informe
│   ├── area_card.dart                 # Tarjeta de área con subtemas calificables
│   ├── problemas_section.dart         # Sección de problemas detectados
│   ├── plan_mejora_section.dart       # Tabla plan de mejora
│   ├── plan_implementacion_section.dart # Tabla plan de implementación
│   └── proyeccion_section.dart        # Tabla proyección de resultados
└── utils/
    └── pdf_generator.dart             # Generador de PDF completo
```

## Funcionalidades

### 1. Diagnóstico Detallado
- 7 áreas con 9–15 subtemas cada una
- Calificación 1–5 por botones (color-coded)
- Observaciones y problemas detectados por subtema
- Promedio automático por área
- **En PC**: doble columna (2 áreas por fila)
- **En móvil**: columna simple

### 2. Problemas Detectados e Impacto
- Agregar/eliminar problemas dinámicamente
- Impacto del 1 al 5 (1=urgente, 5=bajo impacto)
  - 1–2: URGENTE (rojo)
  - 3–4: MEDIO (naranja)
  - 5: BAJO (verde)
- Campo de consecuencias por problema

### 3. Plan de Mejora
- Tabla editable con: Área, Acción, Responsable, Tiempo, Dificultad, Impacto
- Filas dinámicas (agregar/eliminar)
- Dropdowns para Dificultad e Impacto esperado

### 4. Plan de Implementación
- Períodos pre-definidos (Mes 1, Mes 2, ...)
- Columnas: Período, Acción, Estado, Observaciones
- Estado con dropdown: Pendiente / En progreso / Concluido
- Filas dinámicas

### 5. Proyección de Resultados
- Tabla con: Indicador, Estado Actual, Proyección, Mejora Esperada
- Filas dinámicas

### 6. Generación PDF
- Portada con datos del club
- Todas las secciones en formato profesional
- Diagnóstico en doble columna en el PDF
- Colores de impacto en secciones de problemas
- Compatible con impresión y descarga

## Instalación

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Crear carpeta de assets (opcional, para logo)
mkdir -p assets
# Copiar logo.png en assets/ (si no existe, se mostrará ícono por defecto)

# 3. Ejecutar
flutter run

# Para web
flutter run -d chrome

# Para producción web
flutter build web
```

## Dependencias principales

- `pdf: ^3.11.1` — Generación de PDF
- `printing: ^5.13.2` — Imprimir/descargar PDF

## Personalización

Para cambiar el logo, reemplaza `assets/logo.png` con tu imagen (80x80px recomendado).

Para agregar más áreas o subtemas, editar `lib/data/initial_data.dart`.

## Notas de plataforma

- **Web/Desktop**: El PDF se abre en una nueva pestaña para imprimir/descargar
- **iOS/Android**: El PDF se abre con el sistema de impresión nativo
- El layout responsive cambia a doble columna en pantallas ≥ 800px de ancho
