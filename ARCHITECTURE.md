# Teman Sejenak - Refactored Architecture

## 📁 Struktur Project Baru

```
lib/
├── core/                          # Core modules (constants, theme, utils)
│   ├── constants/
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── api_endpoints.dart     # API endpoint definitions
│   │   └── asset_paths.dart       # Asset path constants
│   ├── theme/
│   │   ├── app_colors.dart        # Color palette
│   │   ├── app_text_styles.dart   # Typography styles
│   │   └── app_theme.dart         # Theme configuration
│   ├── utils/
│   │   ├── helpers.dart           # Helper functions (formatting, etc.)
│   │   └── extensions.dart        # Dart extensions & validators
│   └── core.dart                  # Barrel export
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   ├── base_model.dart
│   │   ├── destination.dart
│   │   ├── guide.dart
│   │   ├── order.dart
│   │   ├── user.dart
│   │   └── models.dart            # Barrel export
│   ├── datasources/               # Data sources
│   │   ├── local_data_source.dart # Local JSON loader
│   │   ├── remote_data_source.dart# API client
│   │   └── datasources.dart       # Barrel export
│   ├── repositories/              # Repository pattern
│   │   ├── destination_repository.dart
│   │   ├── guide_repository.dart
│   │   ├── order_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── impl/                  # Implementations
│   │   │   ├── destination_repository_impl.dart
│   │   │   ├── guide_repository_impl.dart
│   │   │   ├── order_repository_impl.dart
│   │   │   └── auth_repository_impl.dart
│   │   └── repositories.dart      # Barrel export
│   └── data.dart                  # Barrel export
│
├── presentation/                  # Presentation layer
│   ├── providers/                 # State management (Provider)
│   │   ├── destination_provider.dart
│   │   ├── guide_provider.dart
│   │   ├── order_provider.dart
│   │   ├── auth_provider.dart
│   │   └── providers.dart         # Barrel export
│   ├── screens/                   # UI screens (migrated)
│   │   └── home_screen_new.dart   # Example refactored screen
│   └── presentation.dart          # Barrel export
│
├── shared/                        # Shared/reusable components
│   ├── widgets/
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   ├── app_badge.dart
│   │   ├── app_image.dart
│   │   ├── app_card.dart
│   │   ├── app_buttons.dart
│   │   ├── app_text_field.dart
│   │   └── widgets.dart           # Barrel export
│   └── shared.dart                # Barrel export
│
├── screens/                       # Legacy screens (akan dimigrasikan)
├── widgets/                       # Legacy widgets (akan dimigrasikan)
├── models/                        # Legacy models (akan dimigrasikan)
├── services/                      # Legacy services (akan dimigrasikan)
├── utils/                         # Legacy utils (akan dimigrasikan)
│
├── main.dart                      # Legacy entry point
├── main_new.dart                  # New entry point with Provider
├── app.dart                       # Legacy app
└── app_new.dart                   # New app configuration
```

## 🏗️ Architecture Pattern

### Repository Pattern
```
UI (Screen) → Provider → Repository → DataSource
                                    ↙️        ↘️
                          LocalDataSource   RemoteDataSource
                              (JSON)            (API)
```

### Key Benefits:
1. **Separation of Concerns** - Setiap layer punya tanggung jawab jelas
2. **Easy Testing** - Bisa mock repository untuk unit test
3. **Flexible Data Source** - Mudah switch JSON ↔ API
4. **Maintainable** - Code terorganisir dan mudah ditemukan

## 🔄 Cara Migrasi dari JSON ke API

### Sebelumnya (Langsung load JSON):
```dart
// Di screen langsung load JSON
destinations = await JsonLoader.loadList('destination_data.json', Destination.fromJson);
```

### Sekarang (Melalui Repository):
```dart
// 1. Di Screen, gunakan Provider
final destinations = context.watch<DestinationProvider>().destinations;

// 2. Provider memanggil Repository
await _repository.getAll();

// 3. Repository implementation bisa pilih data source
class DestinationRepositoryImpl implements DestinationRepository {
  final bool useRemote; // false = JSON, true = API
  
  Future<List<Destination>> getAll() async {
    if (useRemote) {
      return _getFromRemote(); // API
    }
    return _getFromLocal();   // JSON
  }
}
```

### Switch ke API:
```dart
// Hanya ubah 1 baris saat initialize repository:
DestinationRepositoryImpl(useRemote: true)
```

## 📝 Cara Penggunaan

### 1. Import Core Module
```dart
import 'package:teman_sejenak/core/core.dart';
```

### 2. Import Data Layer
```dart
import 'package:teman_sejenak/data/data.dart';
```

### 3. Import Shared Widgets
```dart
import 'package:teman_sejenak/shared/shared.dart';
```

### 4. Import Presentation Layer
```dart
import 'package:teman_sejenak/presentation/presentation.dart';
```

### 5. Menggunakan Provider di Screen
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read data
    final destinations = context.watch<DestinationProvider>().destinations;
    
    // Trigger action
    context.read<DestinationProvider>().loadDestinations();
    
    // Access loading state
    final isLoading = context.watch<DestinationProvider>().isLoading;
  }
}
```

### 6. Menggunakan Shared Widgets
```dart
// Loading
LoadingWidget(message: 'Memuat data...')

// Error with retry
ErrorWidget(
  message: 'Gagal memuat data',
  onRetry: () => provider.loadDestinations(),
)

// Empty state
EmptyWidget(
  message: 'Tidak ada data',
  icon: Icons.inbox_outlined,
)

// Badge
AppBadge.success('Verified')
AppBadge.warning('Pending')

// Buttons
PrimaryButton(
  text: 'Submit',
  isLoading: isLoading,
  onPressed: () => handleSubmit(),
)

// Text Fields
AppTextField(
  label: 'Email',
  validator: Validators.email,
)

PasswordTextField(
  label: 'Password',
)
```

### 7. Menggunakan Helper Functions
```dart
// Currency
CurrencyHelper.formatRupiah(350000) // "Rp 350.000"

// Date
DateHelper.formatDate(DateTime.now()) // "6 Januari 2026"
DateHelper.formatRelative(pastDate)   // "5 menit lalu"

// String
StringHelper.capitalize('hello')      // "Hello"
StringHelper.getInitials('John Doe')  // "JD"
```

### 8. Menggunakan Extensions
```dart
// String extensions
'hello'.capitalize        // "Hello"
'test@email.com'.isValidEmail // true

// Number extensions
350000.toRupiah           // "Rp 350.000"

// Context extensions
context.showSuccess('Berhasil disimpan!');
context.showError('Terjadi kesalahan');
context.hideKeyboard();
```

## 🚀 Migration Checklist

- [x] Core layer (constants, theme, utils)
- [x] Data models with proper parsing
- [x] Data sources (local & remote)
- [x] Repository pattern with abstraction
- [x] Provider state management
- [x] Shared widgets
- [x] Utility helpers & extensions
- [ ] Migrate screens to presentation layer
- [ ] Migrate widgets to shared layer
- [ ] Setup named routes
- [ ] Add unit tests
- [ ] Remove legacy code

## 📌 Best Practices

1. **Selalu gunakan barrel exports** untuk clean imports
2. **Gunakan Provider untuk state** bukan setState langsung
3. **Semua API calls melalui Repository** bukan langsung di screen
4. **Gunakan AppColors & AppTextStyles** untuk konsistensi
5. **Validation menggunakan Validators class**
6. **Format currency/date menggunakan Helper functions**
