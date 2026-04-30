# Parcial 2 Flutter

## 1. Descripción del proyecto
Esta es una aplicación móvil desarrollada en Flutter como parte del Parcial 2. Cuenta con dos módulos principales accesibles desde un Dashboard:
- **Módulo de Accidentes:** Consume una API de datos abiertos para mostrar estadísticas mediante 4 gráficas (procesadas en un Isolate en segundo plano).
- **Módulo de Establecimientos:** Un CRUD completo que consume una API REST, incluyendo la capacidad de subir imágenes (multipart/form-data).

## 2. Descripción de las APIs

### API Accidentes de Tránsito en Tuluá
- **Fuente:** Datos Abiertos Colombia (Socrata).
- **Endpoint:** `GET https://www.datos.gov.co/resource/ezt8-5wyj.json` (Usando `$limit=100000`).
- **Campos Relevantes:** `clase_de_accidente`, `gravedad_del_accidente`, `barrio_hecho`, `dia`, `hora`, `area`, `clase_de_vehiculo`.

### API Parqueaderos/Establecimientos
- **Fuente:** VisionTIC API.
- **Endpoints:**
  - `GET /establecimientos` (Listar todos)
  - `GET /establecimientos/{id}` (Obtener detalle)
  - `POST /establecimientos` (Crear nuevo)
  - `POST /establecimiento-update/{id}` (Actualizar existente - requiere `_method=PUT` en form-data)
  - `DELETE /establecimientos/{id}` (Eliminar)
- **Campos Relevantes:** `id`, `nombre`, `nit`, `direccion`, `telefono`, `logo`.

## 3. Future/async/await vs Isolate
- **Future/async/await:** Se utilizan para tareas asíncronas no bloqueantes, típicamente operaciones I/O como peticiones HTTP a una API (Ej: `fetchAccidentes()` o `getAll()`). Estas pausan la ejecución de la corrutina esperando respuesta, pero mantienen el hilo principal libre para renderizar la UI.
- **Isolate:** Se utiliza para procesamiento pesado de CPU que de otra manera bloquearía el hilo principal de Flutter, causando "jank" o congelamientos en la UI. En este proyecto se eligió Isolate para el procesamiento de las estadísticas (`calcularEstadisticas()`) porque agrupar y ordenar miles de registros JSON en Dart requiere tiempo de CPU intensivo. Usando `Isolate.run()`, el cálculo de las agrupaciones (distribución por clase, top 5 barrios, etc.) se hace en un hilo separado sin afectar los 60/120 fps de la UI.

## 4. Arquitectura del proyecto

| Carpeta       | Responsabilidad                                                                                          |
| ------------- | -------------------------------------------------------------------------------------------------------- |
| `models/`     | Contiene las clases Dart que representan la estructura de datos (Accidente, Establecimiento).             |
| `services/`   | Encapsula toda la lógica de peticiones HTTP utilizando Dio. Provee métodos a los widgets para obtener datos. |
| `isolates/`   | Aloja las funciones top-level diseñadas para correr en un hilo secundario y realizar procesamiento pesado. |
| `router/`     | Define la configuración de navegación declarativa de la aplicación usando `go_router`.                    |
| `views/`      | Almacena la capa de presentación (UI). Subdividido por dominio (dashboard, accidentes, establecimientos).  |

## 5. Tabla de rutas go_router

| Nombre/Vista               | Path                         | Parámetros         |
| -------------------------- | ---------------------------- | ------------------ |
| DashboardView              | `/`                          | N/A                |
| AccidentesView             | `/accidentes`                | N/A                |
| EstablecimientosListView   | `/establecimientos`          | N/A                |
| EstablecimientoFormView    | `/establecimientos/new`      | N/A                |
| EstablecimientoDetailView  | `/establecimientos/:id`      | `id` (int)         |
| EstablecimientoFormView    | `/establecimientos/:id/edit` | `id` (int)         |

## 6. Ejemplo de respuesta JSON

**Accidente:**
```json
{
  "clase_de_accidente": "Choque",
  "gravedad_del_accidente": "Con Heridos",
  "barrio_hecho": "Centro",
  "dia": "Lunes",
  "hora": "14:30:00",
  "area": "Urbana",
  "clase_de_vehiculo": "Motocicleta"
}
```

**Establecimiento:**
```json
{
  "id": 1,
  "nombre": "Parqueadero Central",
  "nit": "900123456-7",
  "direccion": "Carrera 4 # 5-6",
  "telefono": "3001234567",
  "logo": "https://url-de-la-imagen.com/logo.jpg"
}
```

## 7. Instrucciones de instalación

1. Clona este repositorio o asegúrate de tener el código fuente.
2. Ejecuta `flutter pub get` en la raíz del proyecto para instalar todas las dependencias.
3. Asegúrate de tener el archivo `.env` configurado en la raíz del proyecto con las siguientes variables:
   ```env
   BASE_URL_ACCIDENTES=https://www.datos.gov.co/resource/ezt8-5wyj.json
   BASE_URL_PARQUEADERO=https://parking.visiontic.com.co/api
   ```
4. Ejecuta el proyecto con `flutter run`.

## 8. Distribución con Firebase App Distribution

### Flujo resumido:
1. **Generar APK**: Compilación en modo release (`app-release.apk`).
2. **App Distribution**: Subida del artefacto a Firebase App Distribution mediante consola o CLI.
3. **Testers**: Asignación del release al grupo `QA_Team`.
4. **Instalación**: Recepción del correo de invitación e instalación en el dispositivo mediante App Tester.

### Comando para reproducir el build:
`flutter build apk --release`

### Política de versionado usada:
Se emplea Semantic Versioning (SemVer) bajo el formato `MAJOR.MINOR.PATCH+buildNumber` (Ejemplo: `1.0.1+2`).
- **MAJOR**: Cambios incompatibles en la API o arquitectura.
- **MINOR**: Nuevas funcionalidades retrocompatibles.
- **PATCH**: Corrección de errores.
- **buildNumber**: Incremento interno consecutivo para cada compilación subida.

### Formato de Release Notes del equipo:
`v[Versión] - [Fecha] - [Nombre_App]: [Descripción de cambios]`
Ejemplo: `v1.0.1 - 30/04/2026 - EduAlert: Integración inicial de Firebase.`
