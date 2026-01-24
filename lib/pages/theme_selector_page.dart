import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/theme_data.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите сферу'),
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
                  category.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${category.subcategories.length} подсфер →',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
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
              border: Border.left(
                color: _getCategoryColor(category.id),
                width: 6,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategory.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${subcategory.topics.length} тем →',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(subcategory.name),
        backgroundColor: _getCategoryColor(category.id),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            chatProvider.selectSubcategory(
                const ThemeSubcategory(id: '', name: '', topics: []));
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            await chatProvider.startNewChat(topic);
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
                  topic.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                if (topic.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      topic.description!,
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
