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

## Auth — Fase 2

Implementado con Firebase Authentication (Email/Password, activado en la consola).
Feature completa en `lib/features/auth/`: registro, login, logout, recuperación de
contraseña, persistencia de sesión (maneja sola vía `authStateChanges()`).

- `AuthGate` (en `presentation/screens/auth_gate.dart`) es el widget en la ruta `/`:
  muestra `SignInScreen` o `HomeScreen` según el estado de sesión, sin redirects de
  go_router — más simple y evita condiciones de carrera con la restauración de sesión.
- Al registrarse, `AuthRepositoryImpl.signUp` crea también el doc `users/{uid}` en
  Firestore desde el cliente (ver el TODO en ese archivo) — esto se hace desde la app
  porque la Cloud Function `onAuthUserCreate` que haría lo mismo en el servidor todavía
  no está desplegada (pendiente de Blaze, ver sección de Fase 1 arriba).
- Errores de Firebase Auth mapeados a mensajes en español en
  `data/auth_failure_mapper.dart`.
- Probado manualmente end-to-end contra el proyecto Firebase real (no el emulador):
  registro, logout, login, y persistencia de sesión al recargar — los 4 funcionan.
  Quedó una cuenta de prueba (`prueba.decide@example.com`) en Firebase Auth + su doc
  en Firestore; borrarla desde la consola si se quiere un proyecto limpio antes de la
  beta.

## Perfil y follow — Fase 3

- `lib/features/users/`: perfil (ver/editar username, nombre visible, bio, avatar) y
  `lib/features/social/`: follow/unfollow. Rutas `/profile/:uid` y `/profile/edit`.
- **Avatar sin Firebase Storage** (pendiente de Blaze, ver Fase 1): en vez de subir una
  foto, el usuario elige un color de fondo (`avatarColor`, campo nuevo en `users/{uid}`)
  y se muestra un círculo con sus iniciales. `avatarUrl` sigue existiendo en el schema
  para cuando se pueda subir fotos de verdad.
- **Usernames únicos**: colección nueva `usernames/{username} -> {uid}`, no estaba en
  el doc de scope original pero se agregó porque sin esto dos personas podrían tener el
  mismo @usuario. Se reserva/libera con una transacción de Firestore en
  `UserRepositoryImpl.updateProfile`.
  - Importante: **no lanzar excepciones propias (`throw MiFailure(...)`) dentro de
    `runTransaction`** — en la implementación web de `cloud_firestore`, el error cruza
    un puente de interop con JS y pierde el tipo Dart original, así que el `catch`
    de afuera nunca lo reconoce (siempre cae en el error genérico). Hacer que la
    transacción `return` un valor simple (bool/enum) e interpretarlo después.
  - Al registrarse, el username inicial (el uid de Firebase Auth) NO tiene una reserva
    en `usernames/` — si se borra/cambia esa reserva en una transacción, primero hay
    que leer si existe (`tx.get`) antes de `tx.delete`, si no la regla de seguridad
    rechaza toda la transacción (permission-denied) porque `resource.data` no existe.
- Contadores (followers/following/decisions) se recalculan con `count()` y se
  invalidan (`ref.invalidate(profileCountsProvider(uid))`) después de un follow/unfollow
  para que se actualicen al instante — si a futuro se agrega otra acción que cambie
  estos números, hay que invalidar ese provider también.

## Decisiones, votación, feed y moderación — Fases 4 a 9

- **`lib/features/decisions/`** (Fase 4/5): crear (título, descripción opcional,
  categoría, 2-5 opciones, fecha de cierre opcional; sin imagen todavía — Storage
  pendiente de Blaze igual que el avatar), ver, editar (solo título/descripción/
  categoría/cierre — las opciones quedan fijas una vez creada la decisión, no se
  pueden editar) y eliminar. `/decision/:id` es la pantalla real (reemplazó el
  placeholder de la Fase 0).
  - Votación (`vote_repository.dart`/`voting_section.dart`): un voto por usuario
    por decisión ya garantizado por las reglas desde la Fase 1
    (`votes/{userId}_{decisionId}`). Resultados con porcentaje, ganador destacado y
    "tu voto" resaltado, todo calculado con `count()` en vivo.
  - **Bug de reglas ya corregido**: crear la decisión y sus opciones en un mismo
    `batch` fallaba porque la regla de creación de `options` usaba `get()` para
    leer el `authorId` del documento padre — pero ese padre todavía no existe en el
    momento en que se evalúa esa regla dentro del mismo batch (un `WriteBatch` no
    es como un `runTransaction`: los `get()` en las reglas no ven los otros writes
    del mismo batch). Se solucionó guardando el `authorId` directamente en cada
    documento de `options` en vez de leerlo del padre.
  - El contador de "Decisiones" del perfil es clickeable → `/profile/:uid/decisions`
    (lista simple), la única forma de descubrir las decisiones de alguien aparte
    del feed.
- **`lib/features/comments/`** (Fase 6): crear, listar, borrar solo el propio
  comentario. Sin respuestas anidadas, menciones ni GIFs (así lo pide el doc).
- **`lib/features/social/`** ampliado (Fase 6): likes y guardados, mismo patrón que
  follow (ID determinista `{userId}_{decisionId}`, ya cubierto por las reglas de la
  Fase 1). Compartir usa `share_plus` con el deep link
  `https://decide.app/decision/{id}` + evento `decision_shared` en Firebase
  Analytics. Pantalla "Guardados" en `/saved/:uid`.
- **`lib/features/feed/`** (Fase 7): Home ahora muestra el feed real (antes solo
  tenía un texto de placeholder), con 3 pestañas + chips de categoría:
  - **Para vos**: orden cronológico (el doc permite esto como punto de partida,
    sin algoritmo de recomendación).
  - **Tendencias**: toma las últimas ~20 decisiones y las reordena client-side por
    actividad (votos+likes+comentarios sumados). Es una aproximación deliberada:
    sin contadores denormalizados (pendiente de Blaze) no se puede ordenar por
    popularidad de forma barata en un catálogo grande, pero alcanza para el
    volumen de la beta privada (10-500 usuarios, sección 10 del doc). Si el
    catálogo crece mucho antes de tener Blaze, esto va a haber que revisarlo.
  - **Siguiendo**: usa `whereIn` sobre los autores seguidos (tope de 30).
- **`lib/features/moderation/`** (Fase 9): reportar (decisión/comentario/usuario,
  con un mismo diálogo genérico `report_dialog.dart`) y bloquear/desbloquear
  usuarios (`users/{uid}/blocks/{blockedUid}`, ya existía la regla desde la Fase
  1). Pantalla de administración simple en `/blocked/:uid`. **Nota de alcance**:
  bloquear a alguien NO filtra su contenido del feed/comentarios todavía — el doc
  de scope no lo exige explícitamente para el MVP, solo pide que la relación de
  bloqueo exista y sea gestionable. Si se quiere ese filtrado más adelante, hay
  que tocar `FeedRepositoryImpl` y `CommentRepositoryImpl`.
- **`lib/features/notifications/`** (Fase 8, PARCIAL): el centro de notificaciones
  (pantalla `/notifications/:uid`, marcar como leído) está construido y andando,
  pero **va a estar siempre vacío** hasta que se active Blaze: nada escribe
  todavía en la colección `notifications` porque eso lo hacen las Cloud Functions
  `onVoteCreated`/`onCommentCreated`/`onFollowCreated` en `functions/index.js`,
  que ya están escritas pero no desplegadas (ver sección de Fase 1). Cuando se
  active Blaze y se corra `firebase deploy --only functions`, esta pantalla
  empieza a mostrar contenido real sin tocar nada del cliente.

Con esto, las fases 0 a 9 del documento de scope están implementadas y probadas a
mano en Chrome contra el proyecto Firebase real (no el emulador), salvo la parte de
Fase 8 que depende de Blaze. Las fases 10 y 11 (Beta privada, MVP público) son de
proceso/lanzamiento, no de código.

## Cómo previsualizar la app

`.claude/launch.json` en este proyecto define `decide-web` (Flutter en modo
web-server, puerto 8765) para abrir con el Browser pane de Claude Code. Para correrla
manualmente:

```
& "C:\Users\gar_e\Desktop\flutter\bin\flutter.bat" run -d web-server --web-port 8765
```

y abrir `http://localhost:8765`.

**Cuidado al probar navegando por URL con el Browser pane**: la app usa hash routing
(`#/profile/xxx`). Navegar de una URL con hash a OTRA URL que solo difiere en el hash
(ej. `#/profile/a` -> `#/profile/b`) **no recarga la página ni el código compilado** —
el navegador lo trata como navegación dentro del mismo documento. Si acabás de reiniciar
`flutter run` después de un cambio de código, primero navegá a la URL SIN hash
(`http://localhost:8765`) para forzar una recarga real, y recién después cambiá el hash
(podés hacerlo con `location.hash = '#/...'` vía JS, o navegando de nuevo). Si no,
vas a estar probando código viejo sin ningún aviso — así costó detectar que el
sistema de contadores en realidad funcionaba bien.

Para probar en el celular todavía falta terminar el setup del SDK de Android (ver
sección Toolchain).

## Estado actual

Fases 0 a 9 completas (2026-09-14), todas probadas a mano en Chrome contra el
proyecto Firebase real. Pendiente real: activar Blaze (desbloquea Cloud Functions
—notificaciones automáticas y contadores denormalizados— y Firebase Storage —fotos
de avatar/decisión/opción—) y terminar el setup del SDK de Android para probar en
el celular. Ninguna de las dos cosas requiere rehacer código ya escrito.

Lo que sigue del documento de scope son las Fases 10 y 11 (Beta privada, MVP
público) — son de proceso/lanzamiento (conseguir testers, monitorear, publicar de a
poco), no de código.

## Git

Repo local inicializado en esta carpeta (no en GitHub todavía). Identidad configurada
localmente: Eduardo <rusitogar@gmail.com>.
