# Backloggr - Mobile Game Backlog & Deal Tracker

**Backloggr** adalah aplikasi _mobile game backlog tracker_ dan _deal browser_ berbasis Flutter. Aplikasi ini memfasilitasi pengguna dalam melakukan penelusuran katalog diskon game Steam secara _real-time_ via **CheapShark API**, sekaligus mengelola daftar koleksi _game backlog_ pribadi (status penyelesaian, skala prioritas, dan catatan progres) yang tersimpan secara _persistent_ di **Supabase Cloud Database**.

Aplikasi ini dibangun untuk memenuhi kualifikasi **Project Ujian Tengah Semester (UTS) Pemrograman Mobile**, Universitas Pendidikan Ganesha.

---

## Identitas Pengembang

- **Nama**: Marvello Adwitya Nyahu
- **NIM**: 2315091054
- **Kelas**: 3A / D4 Teknologi Rekayasa Perangkat Lunak
- **Dosen Pengampu**: Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom.
- **Teaching Assistant**: Made Yuda Sadewa, S.Pd.

---

## Fitur Utama

### 1. Catalog & Real-Time Deal Browser (`REST API`)

- **Live Catalog Query**: Menampilkan katalog _game deals_ toko Steam secara _real-time_ dari CheapShark REST API.
- **Infinite Scrolling & Pagination**: Fitur _lazy loading_ data katalog secara mulus tanpa batas menggunakan `ScrollController`.
- **Global Game Search**: Pencarian judul game secara instan yang terintegrasi dengan endpoint CheapShark API.
- **Multi-Tier Asset CDN Fallback**: Sistem mitigasi _error image_ otomatis untuk mengambil sampel gambar vertikal HD (`library_600x900.jpg`) maupun horizontal (`capsule_616x353.jpg`) langsung dari CDN Steam (`shared.fastly.steamstatic.com`).

### 2. Backlog Management (`Backend & Database CRUD`)

- **Add to Backlog**: Menambahkan game dari katalog CheapShark ke dalam database Supabase pribadi.
- **Status & Priority Tracking**: Mengelompokkan status progres game ke dalam _Backlog_, _Playing_, atau _Completed_.
- **Custom Notes & Progress Logs**: Menyimpan catatan pribadi/ulasan game secara fleksibel.
- **Full Database CRUD**:
  - **Create**: Menyimpan game baru ke Supabase (`user_game_backlog`).
  - **Read**: Menampilkan daftar koleksi game tersimpan secara presisi di layar Backlog.
  - **Update**: Mengubah catatan dan status penyelesaian game pada layar Detail.
  - **Delete**: Menghapus game dari _backlog_ dengan _Confirmation Alert Dialog_.

### 3. Responsive UI & Navigation

- **Adaptive Navigation Layout**: Menggunakan Material 3 `NavigationBar` untuk tampilan ponsel/compact (< 840px) dan `NavigationRail` untuk tampilan layar lebar/tablet (≥ 840px).
- **Swipable Navigation Pages**: Integrasi `PageView` dengan `GoRouter`'s `StatefulNavigationShell` untuk transisi halaman yang mulus via _gesture_ usap (_swipe_).
- **Responsive Grid System**: Grid katalog yang secara otomatis menyesuaikan jumlah kolom berdasarkan lebar layar (`3 kolom` pada perangkat mobile, `5 kolom` pada tablet/desktop).

---

## ️ Tech Stack & Dependencies

- **Framework**: Flutter (Dart SDK `>=3.3.0 <4.0.0`)
- **Architecture**: Clean Architecture / Layered Architecture (UI → Provider → Service → Database/API)
- **State Management**: `provider` (ChangeNotifier)
- **Routing**: `go_router` (StatefulShellRoute & Deep Linking support)
- **Backend & Database**: Supabase (PostgreSQL Cloud Database)
- **REST API**: CheapShark API (`/api/1.0/deals`, `/api/1.0/games`)
- **HTTP & Image Caching**: `http`, `cached_network_image`
- **UI & Layout Utilities**: `exui`, `dropdown_flutter`, `flutter_screenutil_plus`
- **Environment Security**: `flutter_dotenv`

---

## API & Database Specifications

### 1. REST API Integration

- **Provider**: CheapShark API (`https://www.cheapshark.com/api/1.0`)
- **Endpoints Used**:
  - `GET /deals?storeID=1&pageNumber={page}&pageSize={size}`: Mengambil katalog diskon game Steam.
  - `GET /games?title={query}`: Pencarian judul game global.

### 2. Database Schema (Supabase PostgreSQL)

- **Table Name**: `user_game_backlog`
- **Columns**:
  - `id` (`int8`, Primary Key, Auto-increment)
  - `user_id` (`uuid`, Foreign Key ke `auth.users`)
  - `game_id` (`text`)
  - `game_title` (`text`)
  - `cover_url` (`text`)
  - `capsule_url` (`text`)
  - `completion_status` (`text`, Default: `'Backlog'`)
  - `review_notes` (`text`, Optional)
  - `created_at` (`timestamptz`)
- **Constraints**:
  - `user_game_unique`: Composite Unique constraint pada `(user_id, game_id)` untuk mencegah mendedeksi duplikasi game per user.

---

## Struktur Arsitektur Aplikasi

Project ini menerapkan prinsip pemisahan tanggung jawab (_Separation of Concerns_) berbasis **Layered Architecture**:

```text
lib/
├── core/
│   ├── constants.dart        # Warna tema (AppColors), ukuran layout & breakpoint
│   └── theme.dart            # Konfigurasi ThemeData (Dark Theme Material 3)
├── data/
│   ├── models/
│   │   ├── backlog_item.dart # Dart Model untuk Supabase Backlog
│   │   └── game_model.dart   # Dart Model untuk CheapShark API
│   ├── providers/
│   │   └── backlog_provider.dart # Shared State Management (ChangeNotifier)
│   └── services/
│       ├── cheapshark_api_service.dart # HTTP Client REST API CheapShark
│       └── supabase_service.dart       # Supabase CRUD Client
├── ui/
│   ├── screens/
│   │   ├── backlog_detail_screen.dart # Screen Edit & Detail Game
│   │   ├── backlog_screen.dart        # Screen Collection & List Backlog
│   │   ├── home_screen.dart           # Screen Catalog & Infinite Scroll Search
│   │   ├── login_screen.dart          # Screen Auth/Login
│   │   └── profile_screen.dart        # Screen Informasi Profile Developer
│   └── widgets/
│       ├── game_card.dart             # Custom Reusable Game Card Widget
│       ├── game_detail_modal.dart     # Modal Bottom Sheet / Dialog Add to Backlog
│       └── adaptive_navigation.dart   # Responsive NavigationBar / Rail Shell
└── main.dart                          # App Entry Point, GoRouter & MultiProvider Setup
```

---

## Cara Menjalankan Project (Installation Guide)

### Prasyarat

- Dart SDK `^3.3.0` dan Flutter SDK `^3.19.0` terpasang di komputer.
- Emulator Android/iOS atau Perangkat Fisik tersambung.

### Langkah-Langkah

1. **Clone Repository**

   ```bash
   git clone https://github.com/nyaivu/backloggr
   cd backloggr
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Konfigurasi Environment Variables (`.env`)**
   Buat file `.env` di direktori utama (_root_) project, lalu masukkan kredensial Supabase milikmu:

   ```env
   SUPABASE_URL=https://XXX.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

4. **Jalankan Aplikasi dalam Mode Debug**

   ```bash
   flutter run
   ```

5. **Build APK Release**
   ```bash
   flutter build apk --release --split-per-abi
   ```
   _File APK release hasil kompilasi akan berada di direktori:_ `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## Git Commit Log

Proses pengembangan dikomit secara berkala sesuai dengan tahap integrasi fitur (_Milestones_):

```text
2d755e5 (HEAD -> main, origin/main, origin/HEAD) Implemented App Icon
2c768fa Added Responsive Breakpoint to Login Screen
73da0ed Added Logout Function to Profile Screen
88325a3 Added Backlog Provider as State Management
1fdfd4d Responsive Grid and Game Modal
8dede20 Added Duplicate Game Error Handling
97c3563 Updated Button Styling
c36cc0e Added Backlog Item Editing Function
2976ec8 Added Dropdown in Backlog Detail
b755406 Added Pull Down Refresh Function to Backlogs Screen
bec454a Implemented Backlog Detail
34b97f4  Implemented Add/Create Backlog Item to Supabase
5396437 Completed Game Catalog and Search Screen
e5c818b Ignored .env
9e895eb Initial commit
```
