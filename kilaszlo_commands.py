#!/usr/bin/env python3
"""
KILASZLO Quick Commands Script
Ускоренные команды для работы с проектом
"""

import os
import subprocess
import sys

class KilaszloCommands:
    def __init__(self):
        self.project_path = r"C:\dev\projects\kilaszlo"
    
    def run_command(self, cmd):
        """Выполнить команду в PowerShell"""
        print(f"▶ Выполнение: {cmd}")
        try:
            subprocess.run(f'powershell -Command "{cmd}"', shell=True)
        except Exception as e:
            print(f"❌ Ошибка: {e}")
    
    def show_menu(self):
        """Показать меню команд"""
        print("""
╔════════════════════════════════════════════════════════╗
║          KILASZLO - Быстрые команды                    ║
╚════════════════════════════════════════════════════════╝

1. 🚀 Запустить приложение (веб)
2. 📱 Запустить приложение (мобильный)
3. 📦 Получить зависимости (pub get)
4. 🔄 Обновить зависимости (pub upgrade)
5. 🧹 Очистить проект (clean)
6. 🏗️  Собрать веб версию (release)
7. 📊 Показать информацию (doctor)
8. 🧪 Запустить тесты
9. 📝 Открыть README
0. ❌ Выход

Выберите опцию (0-9):
        """)
    
    def web_run(self):
        """Запустить веб версию"""
        print("🌐 Запуск веб версии...")
        self.run_command(f"cd {self.project_path} && flutter run -d web")
    
    def mobile_run(self):
        """Запустить мобильную версию"""
        print("📱 Запуск мобильной версии...")
        self.run_command(f"cd {self.project_path} && flutter run")
    
    def pub_get(self):
        """Получить зависимости"""
        print("📦 Получаем зависимости...")
        self.run_command(f"cd {self.project_path} && flutter pub get")
    
    def pub_upgrade(self):
        """Обновить зависимости"""
        print("🔄 Обновляем зависимости...")
        self.run_command(f"cd {self.project_path} && flutter pub upgrade")
    
    def clean_project(self):
        """Очистить проект"""
        print("🧹 Очищаем проект...")
        self.run_command(f"cd {self.project_path} && flutter clean")
    
    def build_web(self):
        """Собрать веб версию"""
        print("🏗️  Собираем веб версию...")
        self.run_command(f"cd {self.project_path} && flutter build web --release")
    
    def doctor(self):
        """Показать информацию"""
        print("📊 Информация о системе:")
        self.run_command("flutter doctor -v")
    
    def test_project(self):
        """Запустить тесты"""
        print("🧪 Запускаем тесты...")
        self.run_command(f"cd {self.project_path} && flutter test")
    
    def open_readme(self):
        """Открыть README"""
        readme_path = os.path.join(self.project_path, "README.md")
        os.startfile(readme_path)
    
    def run(self):
        """Главный цикл"""
        while True:
            self.show_menu()
            choice = input("Опция: ").strip()
            
            if choice == "1":
                self.web_run()
            elif choice == "2":
                self.mobile_run()
            elif choice == "3":
                self.pub_get()
            elif choice == "4":
                self.pub_upgrade()
            elif choice == "5":
                self.clean_project()
            elif choice == "6":
                self.build_web()
            elif choice == "7":
                self.doctor()
            elif choice == "8":
                self.test_project()
            elif choice == "9":
                self.open_readme()
            elif choice == "0":
                print("До свидания! 👋")
                break
            else:
                print("❌ Неверная опция")
            
            input("\nНажмите Enter для продолжения...")

if __name__ == "__main__":
    killer = KilaszloCommands()
    killer.run()
