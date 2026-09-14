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

## Estado actual

Fase 0 completa (2026-09-13): proyecto Flutter compilando, estructura de carpetas,
Firebase conectado, Result/Failure, logger, tema base, router, git inicializado.
Ninguna funcionalidad de producto implementada todavía — sigue la Fase 1 (backend:
colecciones de Firestore, security rules, Cloud Functions).

## Git

Repo local inicializado en esta carpeta (no en GitHub todavía). Identidad configurada
localmente: Eduardo <rusitogar@gmail.com>.
