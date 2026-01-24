import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'theme_selector_page.dart';
import 'chat_page.dart';
import 'chat_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          // If in chat, show chat page
          if (chatProvider.currentChat != null) {
            return ChatPage(chat: chatProvider.currentChat!);
          }

          // Main menu
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    // App Title
                    Text(
                      'KILASZLO',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Интеллектуальный чат-сервис',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF7F8C8D),
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60),

                    // Main action buttons
                    _buildLargeButton(
                      context,
                      label: 'ВЫБРАТЬ ТЕМУ',
                      icon: Icons.topic,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ThemeSelectorPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    _buildLargeButton(
                      context,
                      label: 'ИСТОРИЯ ЧАТОВ',
                      icon: Icons.history,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChatHistoryPage(),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF27AE60),
                    ),
                    SizedBox(height: 60),

                    // Info text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'Выберите интересующую вас тему и начните увлекательный разговор с ИИ. Информация охватывает историю, науку, технологию, философию, литературу и многое другое.',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF34495E),
                                  height: 1.6,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF3498DB),
  }) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
