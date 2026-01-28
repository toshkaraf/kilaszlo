import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../models/theme_data.dart';
import '../models/subtopics_generator.dart';

class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        // Show subcategories if category selected
        if (chatProvider.selectedCategory != null &&
            chatProvider.selectedSubcategory == null) {
          return _buildSubcategoryPage(context, chatProvider);
        }

        // Show topics if subcategory selected
        if (chatProvider.selectedSubcategory != null) {
          return _buildTopicsPage(context, chatProvider);
        }

        // Show categories
        return _buildCategoriesPage(context, chatProvider);
      },
    );
  }

  Widget _buildCategoriesPage(
      BuildContext context, ChatProvider chatProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;
    return Scaffold(
      appBar: AppBar(
        title: Text(isGerman ? 'Wählen Sie einen Bereich' : 'Выберите сферу'),
        backgroundColor: const Color(0xFF3498DB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themeCategories.length,
        itemBuilder: (context, index) {
          final category = themeCategories[index];
          return _buildCategoryTile(context, category, chatProvider);
        },
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, ThemeCategory category,
      ChatProvider chatProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            chatProvider.selectCategory(category);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(category.id),
                  _getCategoryColor(category.id).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.getName(isGerman),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.getDescription(isGerman),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isGerman 
                      ? '${category.subcategories.length} Unterkategorien →'
                      : '${category.subcategories.length} подсфер →',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryPage(
      BuildContext context, ChatProvider chatProvider) {
    final category = chatProvider.selectedCategory!;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.getName(isGerman)),
        backgroundColor: _getCategoryColor(category.id),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            chatProvider.clearSelection();
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = category.subcategories[index];
          return _buildSubcategoryTile(
              context, subcategory, chatProvider, category);
        },
      ),
    );
  }

  Widget _buildSubcategoryTile(
    BuildContext context,
    ThemeSubcategory subcategory,
    ChatProvider chatProvider,
    ThemeCategory category,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            chatProvider.selectSubcategory(subcategory);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: _getCategoryColor(category.id),
                  width: 6,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategory.getName(isGerman),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGerman
                      ? '${subcategory.topics.length} Themen →'
                      : '${subcategory.topics.length} тем →',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsPage(
      BuildContext context, ChatProvider chatProvider) {
    final category = chatProvider.selectedCategory!;
    final subcategory = chatProvider.selectedSubcategory!;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;

    return Scaffold(
      appBar: AppBar(
        title: Text(subcategory.getName(isGerman)),
        backgroundColor: _getCategoryColor(category.id),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            chatProvider.selectSubcategory(
              ThemeSubcategory(id: '', name: '', topics: []),
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subcategory.topics.length,
        itemBuilder: (context, index) {
          final topic = subcategory.topics[index];
          return _buildTopicTile(context, topic, chatProvider);
        },
      ),
    );
  }

  Widget _buildTopicTile(
      BuildContext context, Topic topic, ChatProvider chatProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            // Получаем подтемы (предопределенные или сгенерированные)
            List<Topic> subtopics = topicSubtopics[topic.id] ?? [];
            
            // Если нет предопределенных подтем, генерируем их
            if (subtopics.isEmpty) {
              subtopics = generateSubtopicsForTopic(
                topic.id,
                topic.getName(isGerman),
                languageProvider.currentLanguage,
              );
            }
            
            // Всегда показываем подтемы
            if (subtopics.isNotEmpty) {
              // Отдельный экран выбора подтем
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SubtopicSelectorPage(
                    parentTopic: topic,
                    subtopics: subtopics,
                  ),
                ),
              );
              return;
            }

            // Если подтем нет, сразу создаём чат по выбранной теме
            await chatProvider.startNewChat(topic, language: languageProvider.currentLanguage);
            if (context.mounted) {
              // Возвращаемся на стартовый экран (HomePage)
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.getName(isGerman),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                if (topic.getDescription(isGerman) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      topic.getDescription(isGerman)!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    const colors = {
      'history': Color(0xFF8B4513),
      'science': Color(0xFF1ABC9C),
      'technology': Color(0xFF9B59B6),
      'philosophy': Color(0xFFE67E22),
      'literature': Color(0xFFE74C3C),
      'psychology': Color(0xFF3498DB),
      'economics': Color(0xFF27AE60),
      'politics': Color(0xFF2C3E50),
      'arts': Color(0xFFF39C12),
      'nature': Color(0xFF16A085),
      'sports': Color(0xFFC0392B),
    };
    return colors[categoryId] ?? const Color(0xFF3498DB);
  }
}

/// Экран выбора подтем внутри конкретной темы.
class SubtopicSelectorPage extends StatelessWidget {
  final Topic parentTopic;
  final List<Topic> subtopics;

  const SubtopicSelectorPage({
    Key? key,
    required this.parentTopic,
    required this.subtopics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isGerman = languageProvider.isGerman;
    return Scaffold(
      appBar: AppBar(
        title: Text(parentTopic.getName(isGerman)),
        backgroundColor: const Color(0xFF3498DB),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subtopics.length,
            itemBuilder: (context, index) {
              final subtopic = subtopics[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () async {
                      await chatProvider.startNewChat(
                        subtopic, 
                        language: languageProvider.currentLanguage,
                        parentTopic: parentTopic,
                      );
                      if (context.mounted) {
                        // Возвращаемся на стартовый экран (HomePage)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtopic.getName(isGerman),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          if (subtopic.getDescription(isGerman) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                subtopic.getDescription(isGerman)!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
