# Configuration for KILASZLO

## API Configuration
ANTHROPIC_API_KEY_TEMPLATE=sk-ant-YOUR_API_KEY_HERE

## Available Claude Models
# claude-3-5-haiku-20241022    - Fast and cheap (recommended for KILASZLO)
# claude-3-5-sonnet-20241022   - Balance speed and quality
# claude-3-opus-20250219       - Most powerful but expensive

## Instructions
# 1. Get your API key from https://console.anthropic.com/
# 2. Replace sk-ant-YOUR_API_KEY_HERE with your actual key in lib/services/anthropic_service.dart
# 3. Never commit your API key to version control
# 4. For production, use environment variables instead
