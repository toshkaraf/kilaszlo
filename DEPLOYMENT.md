# KILASZLO - Web Deployment Guide

## Деплойment на Firebase Hosting

### Шаг 1: Подготовка к деплойменту

```bash
# Перейти в директорию проекта
cd C:\dev\projects\kilaszlo

# Получить зависимости
flutter pub get

# Собрать веб-версию
flutter build web --release
```

### Шаг 2: Установка Firebase CLI

```bash
# Установить Node.js и npm (если еще не установлены)
# Затем установить Firebase CLI
npm install -g firebase-tools

# Авторизоваться
firebase login
```

### Шаг 3: Инициализация проекта Firebase

```bash
# В директории kilaszlo
firebase init

# Выбрать опции:
# - Hosting
# - Use existing project (или создать новый в консоли)
# - Директория для деплоя: build/web
# - Single page app: Yes
# - Не перезаписывать index.html
```

### Шаг 4: Деплойment

```bash
# Отправить на Firebase
firebase deploy
```

Ваше приложение будет доступно по адресу: `https://YOUR_PROJECT_ID.web.app`

---

## Альтернатива: Vercel

### Шаг 1: Подготовка

```bash
flutter build web --release
```

### Шаг 2: Установка Vercel CLI

```bash
npm install -g vercel
```

### Шаг 3: Деплойment

```bash
vercel --prod
```

---

## Альтернатива: GitHub Pages

### Шаг 1: Создать репозиторий на GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/kilaszlo.git
git branch -M main
git push -u origin main
```

### Шаг 2: Собрать и отправить веб-версию

```bash
# Собрать веб
flutter build web --release --base-href="/kilaszlo/"

# Скопировать содержимое build/web в gh-pages ветку
```

### Шаг 3: Включить GitHub Pages

1. Перейти в Settings репозитория
2. Pages → Source → Deploy from a branch
3. Выбрать `gh-pages` ветку

---

## Переменные окружения для Production

Создать файл `.env.production`:

```
ANTHROPIC_API_KEY=sk-ant-YOUR_KEY_HERE
```

### Использование в Flutter:

```dart
// В main.dart или в отдельном файле конфигурации
const String apiKey = String.fromEnvironment(
  'ANTHROPIC_API_KEY',
  defaultValue: 'YOUR_ANTHROPIC_API_KEY'
);
```

При сборке:
```bash
flutter build web --dart-define=ANTHROPIC_KEY=sk-ant-YOUR_KEY_HERE --release
```

---

## Оптимизация для production

### 1. Минификация и оптимизация

```bash
# Уже включено при --release флаге
flutter build web --release
```

### 2. Использование CDN

Для Firebase Hosting CDN включен автоматически.

### 3. Кэширование браузера

Убедитесь, что в `firebase.json` правильно настроены кэш-заголовки:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [{"key": "Cache-Control", "value": "max-age=31536000"}]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|webp|svg|eot|otf|ttf|ttc|woff|woff2|font.css)",
        "headers": [{"key": "Cache-Control", "value": "max-age=31536000"}]
      }
    ]
  }
}
```

---

## Мониторинг и аналитика

### Добавить Google Analytics (опционально)

```dart
// В main.dart
import 'package:google_analytics_flutter/google_analytics_flutter.dart';

void main() async {
  // ... инициализация
  
  GoogleAnalytics analytics = GoogleAnalytics('G-YOUR_TRACKING_ID');
  // Использовать analytics для отслеживания событий
}
```

---

## Troubleshooting

### Проблема: Приложение работает локально, но не на сервере

**Решение**: 
- Проверьте CORS настройки
- Убедитесь что API ключ валиден на сервере
- Посмотрите консоль браузера (F12) на ошибки

### Проблема: Медленная загрузка

**Решение**:
- Используйте `--web-renderer=html` вместо `canvaskit` для меньшего размера
- Включите GZIP сжатие на сервере
- Кэшируйте статические файлы

### Проблема: "Mixed Content" ошибки

**Решение**:
- Используйте HTTPS везде
- Убедитесь что API вызовы идут на HTTPS

---

## Обновление приложения

### Для Firebase

```bash
flutter clean
flutter pub get
flutter build web --release
firebase deploy
```

### Для GitHub Pages

```bash
flutter clean
flutter pub get
flutter build web --release --base-href="/kilaszlo/"
# Обновить gh-pages ветку
git add .
git commit -m "Update app"
git push origin gh-pages
```

---

**Готово! Ваше приложение KILASZLO теперь доступно в интернете!** 🌐
