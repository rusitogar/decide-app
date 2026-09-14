# DECIDE
## MVP Scope & Development Phases

### Objetivo

Construir una primera versión funcional de DECIDE que permita validar la hipótesis principal del producto:

> **¿Las personas disfrutan creando decisiones y participando en las decisiones de otras personas?**

El MVP no debe intentar implementar todas las funcionalidades previstas para la versión final.

La prioridad es conseguir un producto:

- simple
- atractivo
- rápido
- social
- funcional
- moderable
- medible
- suficientemente escalable

---

# 1. Definición del MVP

El MVP de DECIDE debe permitir este ciclo completo:

```text
Usuario
   ↓
Se registra
   ↓
Explora decisiones
   ↓
Vota
   ↓
Ve resultados
   ↓
Comenta / interactúa
   ↓
Descubre otras decisiones
   ↓
Sigue usuarios
   ↓
Crea su propia decisión
   ↓
Comparte la decisión
   ↓
Recibe votos e interacciones
   ↓
Regresa a la aplicación
```

Si este ciclo funciona, tenemos un producto que vale la pena seguir desarrollando.

---

# 2. Funcionalidades INCLUIDAS en el MVP

## 2.1 Autenticación

Implementar:

- registro
- login
- logout
- persistencia de sesión
- recuperación de contraseña

Proveedor:

```text
Firebase Authentication
```

Inicialmente:

```text
Email + Password
```

No implementar inicialmente:

- Google
- Apple
- otros OAuth

Podrán agregarse posteriormente.

---

# 3. Perfil de usuario

Cada usuario tendrá:

- username
- nombre visible
- avatar
- biografía
- cantidad de seguidores
- cantidad de usuarios seguidos
- cantidad de decisiones creadas

Funciones:

- visualizar perfil
- editar perfil
- cambiar avatar
- seguir/dejar de seguir

---

# 4. Crear una decisión

Esta es una de las funcionalidades centrales del MVP.

El usuario podrá crear una decisión con:

- título
- descripción opcional
- categoría
- imagen opcional
- entre 2 y 5 opciones
- imagen opcional por opción
- fecha de cierre opcional

Ejemplo:

```text
¿Qué moto comprarías?

[ Yamaha MT-07 ]
[ Honda CB750 ]
[ Interceptor 650 ]
```

Validaciones:

- título obligatorio
- mínimo 2 opciones
- máximo 5 opciones
- texto de opción obligatorio
- usuario autenticado

---

# 5. Visualizar una decisión

La pantalla de decisión debe mostrar:

- título
- descripción
- autor
- imagen
- opciones
- cantidad de votos
- comentarios
- likes
- botón compartir
- botón guardar
- botón seguir autor

Antes de votar:

```text
Seleccionar opción
```

Después de votar:

```text
Resultados
```

---

# 6. Sistema de votación

Cada usuario puede votar una sola vez por decisión.

Regla fundamental:

```text
1 usuario
1 voto
1 decisión
```

La restricción debe existir también en el backend (Firestore), no solo en la app.

Se garantiza usando como ID del documento de voto la combinación `{userId}_{decisionId}`: si ya existe, la escritura se rechaza. Reforzado además con Firestore Security Rules.

No confiar únicamente en Flutter.

Después de votar, mostrar:

- porcentaje de cada opción
- cantidad de votos
- opción ganadora
- total de votos

---

# 7. Feed principal

El feed es una funcionalidad crítica del MVP.

El usuario debe poder abrir la aplicación y encontrar decisiones interesantes sin tener que crear primero una decisión.

Primera versión:

### Para vos

Combinación de:

- contenido reciente
- contenido popular

### Tendencias

Decisiones con mayor actividad reciente.

### Siguiendo

Decisiones de usuarios que el usuario sigue.

No implementar todavía un algoritmo de recomendación complejo.

---

# 8. Descubrimiento

El MVP debe permitir descubrir contenido.

Debe existir al menos:

```text
Para vos
Tendencias
Siguiendo
```

Y categorías básicas.

Categorías iniciales:

```text
Motos
Autos
Tecnología
Viajes
Compras
Comida
Entretenimiento
Relaciones
Hogar
Trabajo
Juegos
Otros
```

---

# 9. Comentarios

Los usuarios podrán:

- comentar decisiones
- eliminar sus propios comentarios
- reportar comentarios

Inicialmente NO implementar:

- respuestas anidadas
- menciones
- GIFs
- imágenes en comentarios
- edición compleja

Mantener los comentarios simples.

---

# 10. Likes

Permitir:

```text
Like / Unlike
```

sobre decisiones.

Debe existir:

```text
UNIQUE(userId, decisionId)
```

para impedir likes duplicados.

Los likes sobre comentarios pueden quedar fuera del MVP si agregan complejidad innecesaria.

---

# 11. Guardar decisiones

Permitir:

```text
Guardar
Quitar de guardados
```

Crear posteriormente una sección:

```text
Guardados
```

La sección puede formar parte del MVP si su implementación es sencilla.

---

# 12. Follow

Permitir:

```text
Seguir
Dejar de seguir
```

El usuario podrá consultar:

- seguidores
- siguiendo

Esto es necesario para que el feed "Siguiendo" tenga sentido.

---

# 13. Compartir

Una decisión debe poder compartirse desde el teléfono.

Utilizar:

```text
share_plus
```

Generar un deep link:

```text
https://decide.app/decision/{id}
```

El sistema debe permitir que una persona llegue directamente a la decisión compartida.

---

# 14. Notificaciones

Las notificaciones básicas forman parte del MVP.

Eventos iniciales:

```text
Alguien votó tu decisión
Alguien comentó tu decisión
Alguien comenzó a seguirte
```

Utilizar:

```text
Firebase Cloud Messaging
```

No implementar todavía:

- notificaciones complejas de tendencias
- recomendaciones
- campañas
- newsletters
- digest diarios

---

# 15. Moderación mínima

La moderación SÍ forma parte del MVP.

Debe existir:

### Reportar

- decisión
- comentario
- usuario

### Bloquear

Permitir bloquear usuarios.

### Eliminación

El usuario puede eliminar su propio contenido.

### Administración

El backend debe permitir posteriormente revisar:

- reportes
- usuarios
- contenido

No es necesario desarrollar todavía un panel administrativo completo.

---

# 16. Seguridad

Forma parte del MVP desde el primer día.

Implementar:

- Firestore Security Rules
- validación de esquema de datos
- IDs de documento que impiden duplicados (ej. votos, likes, follows)
- validaciones en Cloud Functions
- control de permisos

Nunca depender únicamente del frontend.

---

# 17. Analytics

También forma parte del MVP.

Necesitamos saber si el producto está funcionando.

Proveedor: **Firebase Analytics** (ya incluido al usar Firebase como backend). Los eventos de abajo son en su mayoría eventos estándar de Google Analytics, así que DAU/WAU/MAU y retención se obtienen directo del panel de Firebase, sin construir un sistema propio.

Además, **Firebase Crashlytics** para monitorear crashes y errores en producción (necesario desde la Fase 10, beta privada).

Eventos mínimos:

```text
app_open
sign_up
login
decision_created
decision_viewed
vote_created
comment_created
decision_shared
decision_saved
user_followed
notification_opened
```

Métricas principales:

```text
DAU
WAU
MAU
D1 retention
D7 retention
decisions_created
votes_created
comments_created
shares
decisions_per_user
votes_per_user
```

---

# 18. Lo que NO forma parte del MVP

Estas funcionalidades deben quedar explícitamente fuera de la primera versión.

## Publicidad

NO implementar todavía:

- AdMob
- publicidad contextual
- anunciantes
- campañas
- publicidad directa
- tracking de clicks
- sponsored decisions

La arquitectura debe estar preparada para incorporarlas posteriormente.

---

## Algoritmo avanzado

NO implementar:

- machine learning
- embeddings
- IA de recomendación
- ranking personalizado complejo

Inicialmente utilizar reglas simples.

---

## IA

La IA NO es parte del producto principal.

No implementar:

- chatbot
- AI decision assistant
- generación automática de decisiones
- análisis complejo de decisiones

La IA podrá utilizarse posteriormente como herramienta interna si aporta valor.

---

## Multimedia avanzada

No implementar inicialmente:

- videos
- stories
- reels
- GIFs
- edición de imágenes
- audio

Las decisiones pueden tener imágenes, pero no videos.

---

## Social avanzado

No implementar inicialmente:

- mensajes privados
- grupos
- chats
- comunidades
- menciones
- hashtags
- respuestas anidadas
- reposts complejos

---

## Gamificación

No implementar inicialmente:

- niveles
- badges
- puntos
- ranking de usuarios
- monedas
- premios

La idea "Tu criterio" queda como funcionalidad futura.

---

# 19. Arquitectura técnica del MVP

Stack:

```text
Flutter
Dart
Riverpod
go_router
Firebase (proveedor único de backend)
  - Cloud Firestore (base de datos)
  - Firebase Authentication
  - Firebase Storage
  - Cloud Functions (lógica server-side / triggers)
  - Cloud Messaging (notificaciones push)
  - Firebase Analytics
  - Firebase Crashlytics
```

Nota: se evaluó Supabase (Postgres) pero se optó por Firebase completo para tener un solo
proveedor, aprovechar las herramientas ya instaladas (Firebase CLI, FlutterFire) y su nivel
gratuito escalable sin administrar servidores.

Deep linking para compartir decisiones: **Android App Links / iOS Universal Links** vía
`go_router`, no Firebase Dynamic Links (Google lo discontinuó en 2025).

Arquitectura:

```text
Feature-first
+
Clean Architecture
```

---

# 20. Features del MVP

La estructura inicial debe contener:

```text
features/
├── auth/
├── users/
├── decisions/
├── feed/
├── comments/
├── social/
├── notifications/
├── moderation/
└── settings/
```

No crear todavía features independientes para:

```text
ads/
ai/
chat/
groups/
gamification/
```

hasta que sean necesarias.

---

# 21. Modelo de datos MVP

Colecciones principales (Firestore):

```text
users
decisions
decision_options (subcolección de decisions)
votes
comments
follows
likes
saves
notifications
reports
categories
```

Relaciones:

```text
users
  │
  ├── decisions
  │       └── decision_options
  │               └── votes
  │
  ├── comments
  ├── likes
  ├── saves
  ├── follows
  └── notifications
```

---

# 22. Fases de desarrollo

El desarrollo debe dividirse en fases pequeñas.

---

## FASE 0 — Setup y arquitectura

Objetivo:

Crear la base técnica del proyecto.

Implementar:

- Flutter
- estructura de carpetas
- Clean Architecture
- Riverpod
- go_router
- Theme
- configuración de environments
- Firebase initialization
- Result/Error system
- Logger
- testing base

Resultado:

```text
Aplicación Flutter compilando correctamente.
```

No implementar todavía funcionalidades del producto.

---

# FASE 1 — Backend y base de datos

Implementar en Firebase:

- users
- decisions
- decision_options
- votes
- comments
- follows
- likes
- saves
- notifications
- reports
- categories

Además:

- índices compuestos de Firestore
- IDs de documento que impiden duplicados (votes, likes, follows)
- Firestore Security Rules
- Cloud Functions (triggers para contadores y notificaciones)
- funciones necesarias

Resultado:

```text
Backend seguro y funcional.
```

---

# FASE 2 — Autenticación

Implementar:

- register
- login
- logout
- session
- password reset

Resultado:

```text
Usuario puede crear y mantener su cuenta.
```

---

# FASE 3 — Perfil

Implementar:

- perfil
- edición de perfil
- avatar
- username
- bio
- followers
- following

Agregar:

```text
follow / unfollow
```

Resultado:

```text
Sistema social básico funcionando.
```

---

# FASE 4 — Decisiones

Implementar:

- crear decisión
- editar decisión
- eliminar decisión
- publicar decisión
- visualizar decisión
- categorías
- opciones 2–5
- imagen opcional
- fecha de cierre

Resultado:

```text
Los usuarios pueden publicar decisiones.
```

---

# FASE 5 — Voting

Implementar:

- votar
- impedir votos duplicados
- mostrar resultados
- porcentajes
- cantidad de votos
- ganador

Resultado:

```text
DECIDE ya cumple su función principal.
```

---

# FASE 6 — Interacción social

Implementar:

- comentarios
- likes
- guardar
- compartir
- follow

Resultado:

```text
La aplicación deja de ser solamente una herramienta
y comienza a comportarse como una red social.
```

---

# FASE 7 — Feed y descubrimiento

Implementar:

```text
Para vos
Tendencias
Siguiendo
```

Inicialmente utilizar reglas simples:

### Recientes

Orden cronológico.

### Populares

Combinación de:

```text
votes
comments
likes
shares
```

### Tendencias

Actividad reciente + velocidad de crecimiento.

### Para vos

Inicialmente:

```text
popular + reciente
```

Posteriormente se reemplazará por personalización real.

---

# FASE 8 — Notificaciones

Implementar:

- push notifications
- centro de notificaciones
- marcar como leído

Eventos:

```text
vote
comment
follow
```

---

# FASE 9 — Moderación

Implementar:

- report
- block
- delete own content
- estados de reportes
- herramientas administrativas básicas

Resultado:

```text
MVP listo para usuarios externos.
```

---

# FASE 10 — Beta privada

Antes de publicar masivamente:

```text
10–20 usuarios
```

Después:

```text
50–100 usuarios
```

Finalmente:

```text
100–500 usuarios
```

Observar:

- crashes
- errores
- abuso
- decisiones creadas
- votos
- comentarios
- retención
- comportamiento del feed

No agregar funcionalidades importantes durante esta etapa salvo que sean necesarias para solucionar problemas reales.

---

# FASE 11 — MVP público

Publicar inicialmente para un grupo controlado.

Objetivo:

No maximizar usuarios.

Obj