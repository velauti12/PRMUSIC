# PRMUSIC - Backend & Back-office

Backend de una plataforma colaborativa de acordes y tablaturas al estilo **Cifra Club** o **LaCuerda**, desarrollado con **Ruby on Rails** para el Trabajo Práctico Nº 1 de Programación IV.

La idea de la aplicación es que los usuarios puedan consultar canciones con sus acordes, cambiar la tonalidad en tiempo real, usar autoscroll mientras tocan y aportar nuevas cifras a la comunidad. Cuenta con una **API RESTful en JSON** (pensada para conectarse con un frontend en el TP2) y un **Back-office** para la administración del catálogo y la moderación de las canciones aportadas por los usuarios.

---

## Funcionalidades principales

- **Catálogo de acordes y cifras:** Canciones asociadas a artistas, géneros y álbumes, registrando la tonalidad original de cada tema.
- **Aporte colaborativo y moderación:** Cualquier usuario puede aportar una nueva canción a través de la API. El tema entra con estado `pending` (pendiente) y no se publica hasta que un administrador lo aprueba desde el back-office.
- **Transposición de acordes (`SongTransposer`):** Algoritmo propio que permite subir o bajar semitonos a los acordes respetando escalas con sostenidos o bemoles, acordes complejos y bajos invertidos (ej: `G/B`).
- **Visor interactivo en el Back-office:** Interfaz con autoscroll regulable (para tocar sin tener que usar las manos para bajar la pantalla), selector de tamaño de fuente y cambio de tonalidad en vivo.
- **Sistema de favoritos:** Los usuarios pueden guardar sus canciones preferidas en su cuenta.
- **Active Storage:** Gestión de carátulas o portadas de discos (`has_one_attached :cover`).
- **Action Mailer:** Envío automático de email de bienvenida (`welcome_email`) en segundo plano cuando un usuario se registra mediante la API.
- **Doble contexto de autenticación:**
  - **Back-office:** Protegido con autenticación HTTP Basic (`admin` / `admin`).
  - **API:** Autenticación por token (`Bearer <token>`) generado en el inicio de sesión.

---

## Requisitos previos

- **Ruby:** 3.4.x (o compatible 3.x)
- **Rails:** 8.1.x
- **SQLite3:** 2.1+
- **Bundler:** 2.x

---

## Instalación y puesta en marcha

1. **Clonar el repositorio:**
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd store
   ```

2. **Instalar dependencias:**
   ```bash
   bundle install
   ```

3. **Preparar la base de datos:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```
   *El archivo `db/seeds.rb` carga géneros, artistas de rock nacional y metal (Almendra, Hermética, Redondos, Gardelitos), usuarios de prueba y canciones con acordes (3 aprobadas y 1 pendiente de moderación).*

   **Usuarios de demostración** (contraseña `password123` para todos): `admin` (rol admin), `bauti`, `elmejor512`, `luisperez576`, `carlosalberto12`.

4. **Iniciar el servidor de desarrollo:**
   ```bash
   rails server
   ```
   La aplicación estará corriendo en `http://localhost:3000`.

---

## Back-office (Panel de administración)

El back-office está desarrollado con las herramientas nativas de Rails (arquitectura MVC, vistas ERB y controladores en el namespace `Admin::`).

- **Acceso:** `http://localhost:3000/admin`
- **Autenticación:** HTTP Basic
- **Credenciales por defecto:**
  - **Usuario:** `admin`
  - **Contraseña:** `admin`

*(Se pueden configurar otras credenciales definiendo las variables de entorno `ADMIN_USERNAME` y `ADMIN_PASSWORD`).*

### Qué se puede hacer en el back-office:
- **Dashboard:** Métricas generales de la plataforma (total de canciones, artistas, géneros y usuarios) y acceso a las canciones subidas recientemente.
- **Moderación de canciones:** Revisar las canciones aportadas por la comunidad y marcarlas como **Aprobadas** o **Rechazadas** con un solo click.
- **CRUD completo:** Crear, editar, listar y eliminar Artistas, Álbumes (con carga de portada), Géneros y Canciones.
- **Herramientas de cifra:** Probar el visor de acordes con autoscroll automático a distintas velocidades, transporte de tonalidad y visualización de portadas de álbumes.

---

## API RESTful (`/api/v1`)

La API devuelve respuestas exclusivamente en formato **JSON** y está versionada bajo el prefijo `/api/v1`.

### Autenticación
Los endpoints protegidos requieren enviar el token del usuario en el encabezado `Authorization`:

```http
Authorization: Bearer <token_del_usuario>
```

### Endpoints disponibles

Todas las respuestas son JSON. Los errores devuelven `{ "error": "..." }` (401 sin token o token inválido, 403 sin permisos de admin, 404 recurso inexistente, 400 falta un parámetro) o `{ "errors": ["..."] }` en validaciones (422).

#### Autenticación y Usuarios
- `POST /api/v1/login`: Inicia sesión con `{ "username": "...", "password": "..." }`. Devuelve `{ token, user_id, username, role }`.
- `DELETE /api/v1/logout` *(token)*: Cierra la sesión invalidando el token actual.
- `POST /api/v1/users`: Registra un usuario con `{ "user": { username, email, password, password_confirmation } }`. No devuelve token (luego hay que hacer login). Encola el correo de bienvenida.
- `GET /api/v1/users` *(admin)*: Listado de usuarios.
- `GET /api/v1/users/:id`: Información pública de un usuario (`id`, `username`, `role`, `created_at`).

> Las respuestas nunca incluyen `password_digest` ni `token`.

#### Canciones y Cifras
- `GET /api/v1/songs`: Catálogo de canciones **aprobadas** con artista y género. Filtros opcionales: `q` (título o artista), `artist_id`, `genre_id`.
- Cada canción incluye `album: { id, title, cover_url }` (o `null` si no tiene álbum). `cover_url` es la URL pública de la portada subida con Active Storage, o `null` si el álbum no tiene portada.
- `GET /api/v1/songs/:id`: Detalle de una canción. Las no aprobadas solo las ve su autor o un admin (para el resto, 404).
- `GET /api/v1/songs/mine` *(token)*: Canciones aportadas por el usuario logueado, en cualquier estado (`pending`, `approved`, `rejected`).
- `GET /api/v1/songs/:id/transpose?semitones=N`: Devuelve `{ id, original_key, semitones, key, content }` con los acordes transpuestos por `SongTransposer`.
- `POST /api/v1/songs` *(token)*: Aporta una canción con `{ "song": { title, artist_id, genre_id, original_key, content, album_id } }`. El autor se toma del token y queda en estado `pending`.
- `PUT/PATCH /api/v1/songs/:id` y `DELETE /api/v1/songs/:id` *(admin)*.

#### Artistas y Géneros
- `GET /api/v1/artists`, `GET /api/v1/genres`: Listados ordenados por nombre.
- `GET /api/v1/artists/:id`, `GET /api/v1/genres/:id`: Detalle con sus canciones **aprobadas**.
- `POST/PATCH/DELETE` *(admin)*.

#### Favoritos *(todos requieren token)*
- `GET /api/v1/favorites`: Favoritos del usuario logueado, cada uno con su canción.
- `POST /api/v1/favorites`: Agrega una canción aprobada con `{ "favorite": { "song_id": 2 } }`. 422 si ya era favorita.
- `DELETE /api/v1/favorites/:id`: Quita un favorito propio (404 si es de otro usuario).

#### CORS
Habilitado con `rack-cors` para `/api/*`. Por defecto acepta `http://localhost:5173`; en producción se configura con `FRONTEND_URL` (admite varias URLs separadas por coma).

---

## Modelo de datos

La aplicación cuenta con 6 modelos de Active Record interconectados:

1. **`Song` (Canción):**
   - Es el modelo principal de la aplicación.
   - Atributos: `title`, `content` (letra con acordes intercalados), `original_key` (tono original, validado con regex musical para acordes como C, Am, F#m7), `status` (enum con valores `pending: 0`, `approved: 1`, `rejected: 2`).
   - Asociaciones: `belongs_to :artist`, `belongs_to :genre`, `belongs_to :user`, `belongs_to :album` (opcional), `has_many :favorites`.
   - Contiene el scope `search` para filtrar canciones por nombre o por artista.

2. **`Artist` (Artista):**
   - Atributos: `name`, `bio`.
   - Asociaciones: `has_many :songs`, `has_many :albums`.

3. **`Album` (Álbum / Disco):**
   - Atributos: `title`, `artist_id`.
   - Asociaciones: `belongs_to :artist`, `has_many :songs`, `has_one_attached :cover` (Active Storage).

4. **`Genre` (Género musical):**
   - Atributos: `name` (ej: Rock Nacional, Heavy Metal, etc.).
   - Asociaciones: `has_many :songs`.

5. **`User` (Usuario):**
   - Atributos: `username`, `email`, `role` (`user` o `admin`), `password_digest`, `token`.
   - Cuenta con `has_secure_password` para encriptar contraseñas y `has_secure_token :token` para la API.
   - Asociaciones: `has_many :songs`, `has_many :favorites`, `has_many :favorite_songs, through: :favorites`.

6. **`Favorite` (Favorito):**
   - Tabla intermedia que relaciona usuarios con las canciones que guardan en su biblioteca personal.

---

## Active Storage y Action Mailer

- **Active Storage:** Utilizado en el modelo `Album` para adjuntar la imagen de portada (`cover`). La portada se sube desde `/admin/albums` (PNG, JPG o WEBP, hasta 5 MB, validado en el modelo), se muestra en el back-office y la API la expone como `album.cover_url` en cada canción para que el frontend la muestre.
- **Action Mailer:** El mailer `UserMailer` se encarga de enviar el correo de bienvenida (`welcome_email`) tras el registro de un usuario mediante la API (`deliver_later` apoyado en Solid Queue).

---

## Servicio de Transposición (`SongTransposer`)

En `app/services/song_transposer.rb` se encuentra implementada la lógica de transposición musical:
- Detecta líneas que contienen únicamente acordes y las separa de la letra.
- Calcula el desplazamiento en semitonos (positivo o negativo) a partir del tono original.
- Elige automáticamente entre la escala con sostenidos (`#`) o con bemoles (`b`) según la tonalidad de destino.
- Soporta acordes complejos (menores, séptimas, disminuidos, aumentados) y acordes invertidos con bajo marcado (como `D/F#`).

---

## Testing, Calidad y Seguridad

Para verificar el correcto funcionamiento y la calidad del código:

- **Tests automatizados (Minitest):**
  Pruebas de modelos (validaciones, unicidad y scopes de búsqueda), del mailer y de integración de los endpoints de la API (`test/integration/api/v1`): login/logout, canciones, transposición, favoritos y permisos:
  ```bash
  rails test
  ```

- **Calidad de código (RuboCop):**
  Análisis de estilo y cumplimiento de convenciones de Rails:
  ```bash
  bundle exec rubocop
  ```

- **Análisis de seguridad (Brakeman):**
  Escaneo de posibles vulnerabilidades de seguridad:
  ```bash
  bundle exec brakeman
  ```

---

## Despliegue

La aplicación incluye configuración lista para producción mediante contenedores Docker y **Kamal** (`Dockerfile` y `config/deploy.yml`).

- **Health check:** `GET /up` responde con estado HTTP 200 cuando el servidor está operativo.
- **Deploy:** A definir al momento de la publicación en servidor o plataforma cloud (Render / Fly.io / VPS).
