# DECIDE

Red social donde los usuarios crean "decisiones" (encuestas de 2-5 opciones), otros votan,
comentan y siguen usuarios. Ver [DECIDE — MVP Scope & Development Phases.md](DECIDE%20%E2%80%94%20MVP%20Scope%20%26%20Development%20Phases.md)
para el alcance completo del MVP y las fases de desarrollo.

El usuario (Eduardo/Rusito) no es programador — explicar todo en lenguaje simple, sin jerga.

## Decisiones de stack (difieren del documento de scope original)

El documento original proponía Supabase (Postgres) + Firebase solo para notificaciones.
Se decidió usar **Firebase completo** como único proveedor de backend:

- Cloud Firestore (en vez de PostgreSQL/Supabase)
- Firebase Authentication (en vez de Supabase Auth)
- Firebase Storage (en vez de Supabase Storage)
- Cloud Functions (lógica server-side, triggers)
- Firebase Cloud Messaging (notificaciones — esto ya estaba en el doc original)
- Firebase Analytics (en vez de un sistema de eventos custom)
- Firebase Crashlytics (monitoreo de errores, no estaba en el doc original)

Razones: un solo proveedor, herramientas ya instaladas en la máquina (Firebase CLI,
FlutterFire) de otro proyecto (Motoviajera), nivel gratuito generoso y escalable sin
administrar servidores.

Consecuencia técnica: como Firestore no es relacional, reglas como "un voto por usuario
por decisión" se garantizan usando el ID del documento (ej. `{userId}_{decisionId}`) en
vez de un `UNIQUE constraint` de SQL — igual de robusto, reforzado con Firestore Security
Rules.

**Deep linking** (compartir decisiones): usar Android App Links / iOS Universal Links +
`go_router`. NO usar Firebase Dynamic Links — Google lo discontinuó en 2025.

Estas decisiones ya están reflejadas en el documento de scope (fue editado para decir
Firebase en vez de Supabase en todas las secciones relevantes).

## Proyecto Firebase

- Project ID: `decide-app-rusito`
- Consola: https://console.firebase.google.com/project/decide-app-rusito/overview
- Apps registradas: Android (`com.tuempresa.decide`), iOS, Web
- `lib/firebase_options.dart` generado con `flutterfire configure` — no es secreto, se
  puede commitear (igual que `android/app/google-services.json`).

## Toolchain (mismo equipo que Motoviajera)

- Flutter SDK en `C:\Users\gar_e\Desktop\flutter` — **no está en el PATH**. Invocar con
  `& "C:\Users\gar_e\Desktop\flutter\bin\flutter.bat" ...` o anteponer esa carpeta al PATH
  de la sesión.
- Firebase CLI y FlutterFire CLI ya instalados y logueados (rusitogar@gmail.com).
- Android SDK: mismo estado que Motoviajera (revisar si ya se completó el setup — al
  06/09/2026 faltaba correr el wizard de Android Studio).

## Arquitectura

Feature-first + Clean Architecture. Carpetas en `lib/`:

```
core/           config, error (Result/Failure), logging, router, theme, utils
features/       auth, users, decisions, feed, comments, social, notifications,
                moderation, settings — cada una con data/domain/presentation
```

Estado: Riverpod. Navegación: go_router (ruta `/decision/:id` ya preparada para el
deep link de compartir).

## Backend (Firestore) — Fase 1

Plan Firebase: **Spark (gratuito)**, todavía sin Blaze. Esto condiciona el diseño:

- **Contadores (votos/likes/comentarios por decisión, followers/following por usuario):**
  NO se guardan como campo denormalizado actualizado por trigger. Se calculan con
  consultas de agregación `count()` de Firestore al momento de mostrarlos (funciona en
  el plan gratuito, sin necesidad de Cloud Functions, y no se puede falsificar porque
  cuenta documentos reales). Cuando se construya la capa de datos de cada feature
  (Fase 4/5/6), usar `count()` para estos números, no leer un campo `voteCount` guardado.
- **Notificaciones automáticas** ("alguien votó/comentó/te siguió"): pendientes.
  Requieren Cloud Functions (ver abajo) porque generarlas desde el cliente sin
  validación de servidor permitiría notificaciones falsas/spam. Se activan cuando
  se pase a Blaze.
- `functions/index.js` ya tiene escritas las Cloud Functions completas (contadores +
  notificaciones + creación automática de perfil al registrarse) pero **no están
  desplegadas** — falta que el usuario active el plan Blaze en la consola de Firebase
  (gratis en la práctica para este volumen, pero pide tarjeta). Cuando lo active:
  recordarle configurar Budget Alerts (alerta de presupuesto) como resguardo, y correr
  `firebase deploy --only functions`.
- Colecciones creadas: `users`, `decisions` (+ subcolección `options`), `votes`,
  `comments`, `follows`, `likes`, `saves`, `notifications`, `reports`, `categories`.
  IDs deterministas para evitar duplicados: `votes/{userId}_{decisionId}`,
  `likes/{userId}_{decisionId}`, `saves/{userId}_{decisionId}`,
  `follows/{followerId}_{followingId}`.
- `firestore.rules` y `firestore.indexes.json` ya desplegados a producción.
- `categories` ya tiene las 12 categorías del doc de scope cargadas (sembradas con un
  script puntual, no versionado — ver el mensaje del commit de la Fase 1 si hace falta
  repetirlo).

## Estado actual

Fase 0 y Fase 1 completas (2026-09-13): proyecto Flutter compilando, estructura de
carpetas, Firebase conectado, Result/Failure, logger, tema base, router, git
inicializado, Firestore con reglas/índices desplegados y categorías cargadas. Cloud
Functions escritas pero pendientes de desplegar (falta activar Blaze). Ninguna
funcionalidad de producto implementada todavía en la app Flutter — sigue la Fase 2
(autenticación).

## Git

Repo local inicializado en esta carpeta (no en GitHub todavía). Identidad configurada
localmente: Eduardo <rusitogar@gmail.com>.
