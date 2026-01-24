# 🔐 Безопасность API Ключа

## ⚠️ КРИТИЧНО

### Ваш новый ключ СКОМПРОМЕТИРОВАН!
Вы дал его в открытом чате. Любой может его скопировать и использовать.

**Действуйте СРОЧНО:**

1. Перейдите: https://console.anthropic.com/
2. Найдите ключ: `sk-ant-api03-nWnrPy4mwK3Pz_...`
3. Нажмите **DELETE** и подтвердите
4. Создайте **ТРЕТИЙ** ключ (новый!)
5. **НИКОМУ** не показывайте этот ключ!

---

## 📋 Как использовать API ключ БЕЗОПАСНО

### Вариант 1: Локальная разработка (РЕКОМЕНДУЕТСЯ)

#### Шаг 1: Создайте .env файл

Откройте PowerShell и выполните:

```powershell
cd C:\dev\projects\kilaszlo

# Создайте .env файл
@"
# Anthropic API Key - НИКОГДА НЕ КОММИТЬТЕ!
ANTHROPIC_API_KEY=sk-ant-YOUR_THIRD_KEY_HERE
"@ | Out-File -Encoding UTF8 .env
```

#### Шаг 2: Установите flutter_dotenv

```bash
flutter pub add flutter_dotenv
```

#### Шаг 3: Обновите main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загрузить .env файл
  await dotenv.load();
  
  final storageService = ChatStorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ChatStorageService>(create: (_) => storageService),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(storageService: storageService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

#### Шаг 4: Обновите anthropic_service.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnthropicService {
  static String get _apiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? 'YOUR_ANTHROPIC_API_KEY';
  
  // ... rest of code
}
```

#### Шаг 5: Обновите pubspec.yaml

```yaml
flutter:
  assets:
    - .env  # Добавьте эту строку
```

---

### Вариант 2: GitHub (для CI/CD)

1. Перейдите на GitHub: https://github.com/toshkaraf/kilaszlo
2. Settings → Secrets and variables → Actions
3. New repository secret:
   - Name: `ANTHROPIC_API_KEY`
   - Value: `sk-ant-YOUR_THIRD_KEY_HERE`
4. Add secret

---

## ✅ .gitignore (уже настроено)

Убедитесь что содержит:

```
.env
.env.local
.env.*.local

# API Keys (NEVER commit these!)
anthropic_api_key.txt
api_keys.json
secrets.json
```

---

## 🚀 Готово к использованию!

### Локально:

```bash
cd C:\dev\projects\kilaszlo

# 1. Добавьте свой ТРЕТИЙ ключ в .env
# (ключ который вы создадите после удаления второго)

# 2. Запустите
flutter pub get
flutter run -d web
```

### На GitHub:

```bash
# Код БЕЗ ключей - безопасно загружать
git add .
git commit -m "Add secure API key configuration"
git push origin main
```

---

## 📝 ПАМЯТКА

```
НИКОГДА В GIT:
❌ Реальные API ключи
❌ Пароли
❌ Токены
❌ Секреты

ВСЕГДА В .env (локально):
✅ API ключи для разработки
✅ Пароли для тестирования

ВСЕГДА В GITHUB SECRETS:
✅ API ключи для production
✅ Пароли для CI/CD
```

---

## ⚡ ДЕЙСТВУЙТЕ ТАК:

1. **Удалите второй ключ** на https://console.anthropic.com/
2. **Создайте третий ключ**
3. **Добавьте в .env файл** (локально)
4. **Никому не показывайте!**
5. **Загрузите на GitHub** (без ключа в коде)

---

Все готово! Хотите я помогу с шагами 1-3? 🔐
