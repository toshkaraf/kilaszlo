class Topic {
  final String id;
  final String name;
  final String? description;

  Topic({
    required this.id,
    required this.name,
    this.description,
  });
}

class ThemeCategory {
  final String id;
  final String name;
  final String description;
  final List<ThemeSubcategory> subcategories;

  ThemeCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.subcategories,
  });
}

class ThemeSubcategory {
  final String id;
  final String name;
  final List<Topic> topics;

  ThemeSubcategory({
    required this.id,
    required this.name,
    required this.topics,
  });
}

// Comprehensive theme data
final List<ThemeCategory> themeCategories = [
  // HISTORY
  ThemeCategory(
    id: 'history',
    name: 'История',
    description: 'Древние и современные периоды истории',
    subcategories: [
      ThemeSubcategory(
        id: 'history_ancient',
        name: 'Древний мир',
        topics: [
          Topic(id: 'ancient_egypt', name: 'Древний Египет', description: 'Цивилизация фараонов'),
          Topic(id: 'ancient_greece', name: 'Древняя Греция', description: 'Философия и демократия'),
          Topic(id: 'ancient_rome', name: 'Древний Рим', description: 'Империя и республика'),
          Topic(id: 'ancient_mesopotamia', name: 'Месопотамия', description: 'Шумеры и вавилоняне'),
          Topic(id: 'ancient_china', name: 'Древний Китай', description: 'Великие китайские династии'),
          Topic(id: 'ancient_india', name: 'Древняя Индия', description: 'Ведический период'),
          Topic(id: 'ancient_americas', name: 'Древние Америки', description: 'Майя, ацтеки, инки'),
          Topic(id: 'ancient_middle_east', name: 'Ближний Восток', description: 'Древние цивилизации'),
          Topic(id: 'ancient_africa', name: 'Древняя Африка', description: 'Нубия и другие цивилизации'),
          Topic(id: 'ancient_minoan', name: 'Минойская цивилизация', description: 'Крит'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_medieval',
        name: 'Средневековье',
        topics: [
          Topic(id: 'medieval_europe', name: 'Средневековая Европа', description: 'Феодализм и рыцарство'),
          Topic(id: 'medieval_arab', name: 'Исламский Халифат', description: 'Золотой век исламской науки'),
          Topic(id: 'medieval_china', name: 'Средневековый Китай', description: 'Династии'),
          Topic(id: 'medieval_india', name: 'Средневековая Индия', description: 'Империи и sultanates'),
          Topic(id: 'medieval_japan', name: 'Средневековая Япония', description: 'Сёгунат и самураи'),
          Topic(id: 'medieval_africa', name: 'Средневековая Африка', description: 'Великие царства'),
          Topic(id: 'medieval_americas', name: 'Средневековые Америки', description: 'Столетия до колумба'),
          Topic(id: 'medieval_rus', name: 'Средневековая Русь', description: 'Киевская Русь и Московское царство'),
          Topic(id: 'medieval_byzantium', name: 'Византия', description: 'Восточная Римская империя'),
          Topic(id: 'medieval_viking', name: 'Век викингов', description: 'Норманнские завоевания'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_renaissance',
        name: 'Ренессанс и Просвещение',
        topics: [
          Topic(id: 'renaissance_italy', name: 'Итальянский Ренессанс', description: 'Искусство и гуманизм'),
          Topic(id: 'renaissance_general', name: 'Ренессанс в Европе', description: 'Эпоха возрождения'),
          Topic(id: 'enlightenment', name: 'Эпоха просвещения', description: 'Разум и наука'),
          Topic(id: 'scientific_revolution', name: 'Научная революция', description: 'Галилей, Ньютон, Декарт'),
          Topic(id: 'baroque', name: 'Эпоха барокко', description: 'Искусство и архитектура'),
          Topic(id: 'reformation', name: 'Реформация', description: 'Лютер и религиозные войны'),
          Topic(id: 'exploration', name: 'Эпоха исследований', description: 'Географические открытия'),
          Topic(id: 'colonial_americas', name: 'Колонизация Америк', description: 'Испания и Португалия'),
          Topic(id: 'ottoman_empire', name: 'Османская империя', description: 'Расцвет и упадок'),
          Topic(id: 'early_modern', name: 'Ранее Новое время', description: 'Переход к современности'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_industrial',
        name: 'Индустриальный период',
        topics: [
          Topic(id: 'industrial_revolution', name: 'Промышленная революция', description: 'Пар и механизация'),
          Topic(id: 'american_revolution', name: 'Американская революция', description: '1776 год и независимость'),
          Topic(id: 'french_revolution', name: 'Французская революция', description: 'Террор и реформы'),
          Topic(id: 'napoleonic_wars', name: 'Наполеоновские войны', description: 'Конфликты в Европе'),
          Topic(id: 'british_empire', name: 'Британская империя', description: 'Королева Виктория'),
          Topic(id: 'colonialism', name: 'Эпоха колониализма', description: 'Экспансия в Африку и Азию'),
          Topic(id: 'nationalism', name: 'Возрождение национализма', description: 'Объединение Италии и Германии'),
          Topic(id: 'american_civil_war', name: 'Американская гражданская война', description: '1861-1865'),
          Topic(id: 'russian_empire', name: 'Российская империя', description: 'XIX век'),
          Topic(id: 'oriental_crisis', name: 'Восточный вопрос', description: 'Распад Османской империи'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_20th_early',
        name: 'XX век - начало',
        topics: [
          Topic(id: 'ww1', name: 'Первая мировая война', description: '1914-1918'),
          Topic(id: 'russian_revolution', name: 'Русская революция', description: 'Октябрьская революция'),
          Topic(id: 'roaring_twenties', name: 'Бурные двадцатые', description: 'Джаз-возраст'),
          Topic(id: 'great_depression', name: 'Великая депрессия', description: '1929 и экономический кризис'),
          Topic(id: 'rise_fascism', name: 'Восхождение фашизма', description: 'Муссолини и Гитлер'),
          Topic(id: 'chinese_revolution', name: 'Китайская революция', description: 'Мао и коммунизм'),
          Topic(id: 'spanish_civil_war', name: 'Гражданская война в Испании', description: '1936-1939'),
          Topic(id: 'rise_japan', name: 'Восхождение Японии', description: 'Имперский период'),
          Topic(id: 'interwar_europe', name: 'Межвоенная Европа', description: 'Потеря мира'),
          Topic(id: 'colonial_independence', name: 'Антиколониальные восстания', description: 'Борьба за свободу'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_ww2',
        name: 'Вторая мировая война',
        topics: [
          Topic(id: 'ww2_european', name: 'Война в Европе', description: '1939-1945'),
          Topic(id: 'ww2_pacific', name: 'Война в Тихом океане', description: 'Япония и США'),
          Topic(id: 'holocaust', name: 'Холокост', description: 'Трагедия еврейского народа'),
          Topic(id: 'soviet_involvement', name: 'СССР во Второй мировой', description: 'От нападения до победы'),
          Topic(id: 'd_day', name: 'День Д', description: 'Нормандская операция'),
          Topic(id: 'pacific_island_campaigns', name: 'Тихоокеанские кампании', description: 'Остров за островом'),
          Topic(id: 'american_homefront', name: 'Американский тыл', description: 'Война дома'),
          Topic(id: 'british_resolve', name: 'Британское сопротивление', description: 'Час славы'),
          Topic(id: 'war_technology', name: 'Военные технологии', description: 'Радар и самолеты'),
          Topic(id: 'war_resistance', name: 'Движение сопротивления', description: 'Партизаны и мятежники'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_cold_war',
        name: 'Холодная война',
        topics: [
          Topic(id: 'cold_war_origins', name: 'Начало Холодной войны', description: 'После 1945 года'),
          Topic(id: 'korean_war', name: 'Корейская война', description: '1950-1953'),
          Topic(id: 'cuban_crisis', name: 'Карибский кризис', description: 'Октябрь 1962'),
          Topic(id: 'vietnam_war', name: 'Вьетнамская война', description: 'Конфликт в Юго-Восточной Азии'),
          Topic(id: 'space_race', name: 'Космическая гонка', description: 'Спутники и Луна'),
          Topic(id: 'berlin_wall', name: 'Берлинская стена', description: 'Символ раздела'),
          Topic(id: 'decolonization', name: 'Деколонизация', description: 'Независимость колоний'),
          Topic(id: 'civil_rights', name: 'Движение за гражданские права', description: 'Америка 1960s'),
          Topic(id: 'chinese_cultural', name: 'Культурная революция в Китае', description: 'Мао и переворот'),
          Topic(id: 'middle_east_cold', name: 'Ближний Восток в Холодной войне', description: 'Израиль и арабы'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_late_20th',
        name: 'XX век - конец',
        topics: [
          Topic(id: 'soviet_collapse', name: 'Распад СССР', description: '1989-1991'),
          Topic(id: 'fall_berlin_wall', name: 'Падение Берлинской стены', description: '1989'),
          Topic(id: 'gulf_war', name: 'Войны в Персидском заливе', description: '1991 и дальше'),
          Topic(id: 'yugoslav_wars', name: 'Войны в Югославии', description: '1991-1999'),
          Topic(id: 'digital_revolution', name: 'Цифровая революция', description: 'Интернет и компьютеры'),
          Topic(id: 'end_apartheid', name: 'Конец апартеида', description: 'Южная Африка'),
          Topic(id: 'tiananmen', name: 'Площадь Тяньаньмэнь', description: 'Китай 1989'),
          Topic(id: 'chernobyl', name: 'Чернобыль', description: 'Ядерная катастрофа'),
          Topic(id: 'millennium_boom', name: 'Миллениум и Интернет-бум', description: 'Конец века'),
          Topic(id: 'sept_11', name: '11 сентября', description: 'Террористические атаки'),
        ],
      ),
      ThemeSubcategory(
        id: 'history_21st',
        name: 'XXI век',
        topics: [
          Topic(id: 'war_terror', name: 'Война с терроризмом', description: 'После 2001'),
          Topic(id: 'iraq_war', name: 'Война в Ираке', description: '2003-2011'),
          Topic(id: 'arab_spring', name: 'Арабская весна', description: '2010-2012'),
          Topic(id: 'rise_china', name: 'Восхождение Китая', description: 'Экономическая держава'),
          Topic(id: 'financial_crisis', name: 'Финансовый кризис 2008', description: 'Мировая рецессия'),
          Topic(id: 'ukraine_crisis', name: 'Кризис на Украине', description: '2014-2022'),
          Topic(id: 'refugee_crisis', name: 'Беженская кризис', description: 'Волны миграции'),
          Topic(id: 'technology_2010s', name: 'Технологии 2010s', description: 'Смартфоны и соцсети'),
          Topic(id: 'climate_movement', name: 'Климатическое движение', description: 'Глобальное потепление'),
          Topic(id: 'covid_pandemic', name: 'Пандемия COVID-19', description: '2020-2023'),
        ],
      ),
    ],
  ),

  // SCIENCE
  ThemeCategory(
    id: 'science',
    name: 'Наука',
    description: 'Естественные и фундаментальные науки',
    subcategories: [
      ThemeSubcategory(
        id: 'physics_classical',
        name: 'Классическая физика',
        topics: [
          Topic(id: 'mechanics', name: 'Механика', description: 'Движение и силы'),
          Topic(id: 'thermodynamics', name: 'Термодинамика', description: 'Тепло и энергия'),
          Topic(id: 'waves', name: 'Волны и звук', description: 'Колебания и распространение'),
          Topic(id: 'optics', name: 'Оптика', description: 'Свет и зрение'),
          Topic(id: 'electromagnetism', name: 'Электромагнетизм', description: 'Электричество и магнетизм'),
          Topic(id: 'gravity', name: 'Гравитация', description: 'Ньютонова теория'),
          Topic(id: 'fluid_dynamics', name: 'Гидродинамика', description: 'Течения жидкостей'),
          Topic(id: 'energy', name: 'Энергия', description: 'Формы и преобразования'),
          Topic(id: 'momentum', name: 'Импульс и столкновения', description: 'Сохранение импульса'),
          Topic(id: 'simple_machines', name: 'Простые механизмы', description: 'Рычаги и блоки'),
        ],
      ),
      ThemeSubcategory(
        id: 'physics_modern',
        name: 'Современная физика',
        topics: [
          Topic(id: 'relativity', name: 'Теория относительности', description: 'Эйнштейн и пространство-время'),
          Topic(id: 'quantum', name: 'Квантовая механика', description: 'Микромир и вероятность'),
          Topic(id: 'nuclear', name: 'Ядерная физика', description: 'Атомное ядро'),
          Topic(id: 'particle', name: 'Физика элементарных частиц', description: 'Стандартная модель'),
          Topic(id: 'atomic_structure', name: 'Строение атома', description: 'Электроны и орбиты'),
          Topic(id: 'quantum_entanglement', name: 'Квантовая запутанность', description: 'Странные явления'),
          Topic(id: 'dark_matter', name: 'Темная материя', description: 'Невидимая Вселенная'),
          Topic(id: 'dark_energy', name: 'Темная энергия', description: 'Ускорение расширения'),
          Topic(id: 'string_theory', name: 'Теория струн', description: 'Основные строительные блоки'),
          Topic(id: 'black_holes', name: 'Черные дыры', description: 'Точки без возврата'),
        ],
      ),
      ThemeSubcategory(
        id: 'chemistry',
        name: 'Химия',
        topics: [
          Topic(id: 'organic_chemistry', name: 'Органическая химия', description: 'Соединения углерода'),
          Topic(id: 'inorganic_chemistry', name: 'Неорганическая химия', description: 'Металлы и минералы'),
          Topic(id: 'periodic_table', name: 'Периодическая таблица', description: 'Элементы и их свойства'),
          Topic(id: 'chemical_reactions', name: 'Химические реакции', description: 'Связи и преобразования'),
          Topic(id: 'biochemistry', name: 'Биохимия', description: 'Химия жизни'),
          Topic(id: 'polymer_chemistry', name: 'Полимеры', description: 'Пластики и материалы'),
          Topic(id: 'acids_bases', name: 'Кислоты и основания', description: 'pH и растворы'),
          Topic(id: 'catalysts', name: 'Катализаторы', description: 'Ускорение реакций'),
          Topic(id: 'crystallography', name: 'Кристаллография', description: 'Структура кристаллов'),
          Topic(id: 'analytical_chemistry', name: 'Аналитическая химия', description: 'Анализ вещества'),
        ],
      ),
      ThemeSubcategory(
        id: 'biology',
        name: 'Биология',
        topics: [
          Topic(id: 'cell_biology', name: 'Клеточная биология', description: 'Клетки и органеллы'),
          Topic(id: 'genetics', name: 'Генетика', description: 'ДНК и наследование'),
          Topic(id: 'evolution', name: 'Эволюция', description: 'Дарвин и естественный отбор'),
          Topic(id: 'ecology', name: 'Экология', description: 'Живые системы и окружающая среда'),
          Topic(id: 'anatomy', name: 'Анатомия', description: 'Строение организмов'),
          Topic(id: 'physiology', name: 'Физиология', description: 'Функции организма'),
          Topic(id: 'microbiology', name: 'Микробиология', description: 'Бактерии и вирусы'),
          Topic(id: 'immunology', name: 'Иммунология', description: 'Иммунная система'),
          Topic(id: 'botany', name: 'Ботаника', description: 'Растения'),
          Topic(id: 'zoology', name: 'Зоология', description: 'Животные'),
        ],
      ),
      ThemeSubcategory(
        id: 'astronomy',
        name: 'Астрономия',
        topics: [
          Topic(id: 'solar_system', name: 'Солнечная система', description: 'Планеты и луны'),
          Topic(id: 'stars', name: 'Звезды', description: 'Жизненный цикл звезд'),
          Topic(id: 'galaxies', name: 'Галактики', description: 'Острова во Вселенной'),
          Topic(id: 'universe', name: 'Вселенная', description: 'От большого взрыва'),
          Topic(id: 'cosmology', name: 'Космология', description: 'Наука о космосе'),
          Topic(id: 'exoplanets', name: 'Экзопланеты', description: 'Миры других звезд'),
          Topic(id: 'space_exploration', name: 'Космические исследования', description: 'Спутники и зонды'),
          Topic(id: 'moon', name: 'Луна', description: 'Наш естественный спутник'),
          Topic(id: 'supernovae', name: 'Сверхновые', description: 'Взрывные звезды'),
          Topic(id: 'neutron_stars', name: 'Нейтронные звезды', description: 'Пульсары и магнетары'),
        ],
      ),
      ThemeSubcategory(
        id: 'earth_science',
        name: 'Науки о Земле',
        topics: [
          Topic(id: 'geology', name: 'Геология', description: 'Земля и горные породы'),
          Topic(id: 'mineralogy', name: 'Минералогия', description: 'Кристаллы и минералы'),
          Topic(id: 'seismology', name: 'Сейсмология', description: 'Землетрясения'),
          Topic(id: 'volcanology', name: 'Вулканология', description: 'Вулканы'),
          Topic(id: 'meteorology', name: 'Метеорология', description: 'Погода и атмосфера'),
          Topic(id: 'oceanography', name: 'Океанография', description: 'Морские науки'),
          Topic(id: 'paleontology', name: 'Палеонтология', description: 'Ископаемые и динозавры'),
          Topic(id: 'climate_science', name: 'Климатология', description: 'Климатические системы'),
          Topic(id: 'soil_science', name: 'Педология', description: 'Почвы'),
          Topic(id: 'hydrology', name: 'Гидрология', description: 'Вода и водные системы'),
        ],
      ),
      ThemeSubcategory(
        id: 'mathematics',
        name: 'Математика',
        topics: [
          Topic(id: 'algebra', name: 'Алгебра', description: 'Уравнения и функции'),
          Topic(id: 'geometry', name: 'Геометрия', description: 'Формы и пространство'),
          Topic(id: 'calculus', name: 'Анализ (Calculus)', description: 'Производные и интегралы'),
          Topic(id: 'probability', name: 'Теория вероятности', description: 'Случайность и статистика'),
          Topic(id: 'number_theory', name: 'Теория чисел', description: 'Простые числа и делимость'),
          Topic(id: 'topology', name: 'Топология', description: 'Свойства пространства'),
          Topic(id: 'logic', name: 'Математическая логика', description: 'Доказательства и аксиомы'),
          Topic(id: 'graph_theory', name: 'Теория графов', description: 'Сети и соединения'),
          Topic(id: 'set_theory', name: 'Теория множеств', description: 'Коллекции элементов'),
          Topic(id: 'linear_algebra', name: 'Линейная алгебра', description: 'Матрицы и векторы'),
        ],
      ),
    ],
  ),

  // TECHNOLOGY & ENGINEERING
  ThemeCategory(
    id: 'technology',
    name: 'Техника',
    description: 'Инженерия и технологические инновации',
    subcategories: [
      ThemeSubcategory(
        id: 'computing',
        name: 'Вычислительная техника',
        topics: [
          Topic(id: 'computer_hardware', name: 'Компьютерное железо', description: 'ПроцессорыОперативная память'),
          Topic(id: 'software', name: 'Программное обеспечение', description: 'Операционные системы и приложения'),
          Topic(id: 'programming', name: 'Программирование', description: 'Код и алгоритмы'),
          Topic(id: 'artificial_intelligence', name: 'Искусственный интеллект', description: 'Машинное обучение и нейросети'),
          Topic(id: 'internet', name: 'Интернет', description: 'Сети и протоколы'),
          Topic(id: 'cybersecurity', name: 'Кибербезопасность', description: 'Защита данных'),
          Topic(id: 'databases', name: 'Базы данных', description: 'Хранение информации'),
          Topic(id: 'cloud_computing', name: 'Облачные вычисления', description: 'Удаленные сервисы'),
          Topic(id: 'web_development', name: 'Веб-разработка', description: 'Сайты и приложения'),
          Topic(id: 'mobile_technology', name: 'Мобильные технологии', description: 'Смартфоны и планшеты'),
        ],
      ),
      ThemeSubcategory(
        id: 'mechanical_engineering',
        name: 'Машиностроение',
        topics: [
          Topic(id: 'mechanical_design', name: 'Механическое проектирование', description: 'Инженерия машин'),
          Topic(id: 'motors', name: 'Моторы и двигатели', description: 'ДВС и электромоторы'),
          Topic(id: 'robotics', name: 'Робототехника', description: 'Автоматизация и роботы'),
          Topic(id: 'automotive', name: 'Автомобили', description: 'Четырехколесный транспорт'),
          Topic(id: 'aircraft', name: 'Самолетостроение', description: 'Авиация и полеты'),
          Topic(id: 'marine_engineering', name: 'Кораблестроение', description: 'Суда и корабли'),
          Topic(id: 'hydraulics', name: 'Гидравлика', description: 'Жидкостные системы'),
          Topic(id: 'pneumatics', name: 'Пневматика', description: 'Газовые системы'),
          Topic(id: 'precision_engineering', name: 'Прецизионная инженерия', description: 'Точные технологии'),
          Topic(id: 'tool_technology', name: 'Инструментальное производство', description: 'Станки и инструменты'),
        ],
      ),
      ThemeSubcategory(
        id: 'electrical_engineering',
        name: 'Электротехника',
        topics: [
          Topic(id: 'power_generation', name: 'Энергогенерация', description: 'Производство электроэнергии'),
          Topic(id: 'power_distribution', name: 'Распределение энергии', description: 'Сети и трансформаторы'),
          Topic(id: 'renewable_energy', name: 'Возобновляемая энергия', description: 'Солнце ветер и вода'),
          Topic(id: 'electronics', name: 'Электроника', description: 'Полупроводники и диоды'),
          Topic(id: 'power_electronics', name: 'Силовая электроника', description: 'Преобразование энергии'),
          Topic(id: 'telecommunications', name: 'Телекоммуникации', description: 'Связь и передача данных'),
          Topic(id: 'lighting', name: 'Освещение', description: 'Лампы и светодиоды'),
          Topic(id: 'energy_storage', name: 'Хранение энергии', description: 'Батареи и аккумуляторы'),
          Topic(id: 'electrical_safety', name: 'Электробезопасность', description: 'Защита от опасностей'),
          Topic(id: 'microelectronics', name: 'Микроэлектроника', description: 'Микросхемы и чипы'),
        ],
      ),
      ThemeSubcategory(
        id: 'civil_engineering',
        name: 'Строительство и инфраструктура',
        topics: [
          Topic(id: 'structural_engineering', name: 'Строительная инженерия', description: 'Мосты и здания'),
          Topic(id: 'architecture', name: 'Архитектура', description: 'Проектирование зданий'),
          Topic(id: 'materials_science', name: 'Наука о материалах', description: 'Свойства материалов'),
          Topic(id: 'concrete', name: 'Бетон и железобетон', description: 'Основные строительные материалы'),
          Topic(id: 'steel_structures', name: 'Стальные конструкции', description: 'Сталь в строительстве'),
          Topic(id: 'geotechnical', name: 'Геотехника', description: 'Почва и фундаменты'),
          Topic(id: 'water_engineering', name: 'Водная инженерия', description: 'Плотины и каналы'),
          Topic(id: 'transportation', name: 'Транспортная инфраструктура', description: 'Дороги и рельсы'),
          Topic(id: 'urban_planning', name: 'Планирование городов', description: 'Развитие территорий'),
          Topic(id: 'construction_methods', name: 'Методы строительства', description: 'Технологии и процессы'),
        ],
      ),
      ThemeSubcategory(
        id: 'biotechnology',
        name: 'Биотехнология',
        topics: [
          Topic(id: 'genetic_engineering', name: 'Генная инженерия', description: 'Модификация ДНК'),
          Topic(id: 'pharmaceutical', name: 'Фармацевтика', description: 'Лекарства и вакцины'),
          Topic(id: 'synthetic_biology', name: 'Синтетическая биология', description: 'Конструирование организмов'),
          Topic(id: 'biomedical', name: 'Биомедицина', description: 'Медицинские технологии'),
          Topic(id: 'fermentation', name: 'Ферментация', description: 'Биотехнологические процессы'),
          Topic(id: 'tissue_engineering', name: 'Инженерия тканей', description: 'Искусственные органы'),
          Topic(id: 'prosthetics', name: 'Протезирование', description: 'Искусственные конечности'),
          Topic(id: 'regenerative_medicine', name: 'Регенеративная медицина', description: 'Восстановление тканей'),
          Topic(id: 'bioinformatics', name: 'Биоинформатика', description: 'Вычисления в биологии'),
          Topic(id: 'environmental_biotech', name: 'Экологическая биотехнология', description: 'Очистка окружающей среды'),
        ],
      ),
    ],
  ),

  // PHILOSOPHY
  ThemeCategory(
    id: 'philosophy',
    name: 'Философия',
    description: 'Размышления о бытии смысле и ценностях',
    subcategories: [
      ThemeSubcategory(
        id: 'metaphysics',
        name: 'Метафизика',
        topics: [
          Topic(id: 'ontology', name: 'Онтология', description: 'Природа бытия'),
          Topic(id: 'existence', name: 'Вопрос о существовании', description: 'Почему что-то есть'),
          Topic(id: 'causality', name: 'Причинность', description: 'Причины и следствия'),
          Topic(id: 'time', name: 'Природа времени', description: 'Прошлое настоящее будущее'),
          Topic(id: 'space', name: 'Природа пространства', description: 'Расширение и измерения'),
          Topic(id: 'substance', name: 'Субстанция', description: 'Материальное и нематериальное'),
          Topic(id: 'dualism', name: 'Дуализм ума и тела', description: 'Материя и сознание'),
          Topic(id: 'free_will', name: 'Свободная воля', description: 'Детерминизм и выбор'),
          Topic(id: 'identity', name: 'Личная идентичность', description: 'Что делает нас нами'),
          Topic(id: 'possibility', name: 'Возможность и реальность', description: 'Модальная логика'),
        ],
      ),
      ThemeSubcategory(
        id: 'epistemology',
        name: 'Теория познания',
        topics: [
          Topic(id: 'knowledge', name: 'Природа знания', description: 'Что такое знание'),
          Topic(id: 'truth', name: 'Истина', description: 'Определение и критерии истины'),
          Topic(id: 'belief', name: 'Вера и убеждение', description: 'Оправдание убеждений'),
          Topic(id: 'skepticism', name: 'Скептицизм', description: 'Сомнение в знании'),
          Topic(id: 'empiricism', name: 'Эмпиризм', description: 'Опыт как источник знания'),
          Topic(id: 'rationalism', name: 'Рационализм', description: 'Разум как источник знания'),
          Topic(id: 'perception', name: 'Восприятие', description: 'Как мы воспринимаем мир'),
          Topic(id: 'logic', name: 'Логика', description: 'Законы мышления'),
          Topic(id: 'scientific_method', name: 'Научный метод', description: 'Основы науки'),
          Topic(id: 'intuition', name: 'Интуиция', description: 'Непосредственное знание'),
        ],
      ),
      ThemeSubcategory(
        id: 'ethics',
        name: 'Этика',
        topics: [
          Topic(id: 'morality', name: 'Моральность', description: 'Природа добра и зла'),
          Topic(id: 'consequentialism', name: 'Консеквенциализм', description: 'Результаты поступков'),
          Topic(id: 'deontology', name: 'Деонтология', description: 'Долг и правила'),
          Topic(id: 'virtue_ethics', name: 'Этика добродетели', description: 'Добродетели и пороки'),
          Topic(id: 'justice', name: 'Справедливость', description: 'Концепции справедливости'),
          Topic(id: 'rights', name: 'Права человека', description: 'Основные права'),
          Topic(id: 'responsibility', name: 'Ответственность', description: 'Моральная ответственность'),
          Topic(id: 'virtue', name: 'Добродетель', description: 'Совершенство характера'),
          Topic(id: 'vice', name: 'Порок', description: 'Недостатки характера'),
          Topic(id: 'happiness', name: 'Счастье и благополучие', description: 'Смысл жизни'),
        ],
      ),
      ThemeSubcategory(
        id: 'aesthetics',
        name: 'Эстетика',
        topics: [
          Topic(id: 'beauty', name: 'Красота', description: 'Определение и восприятие'),
          Topic(id: 'art', name: 'Искусство', description: 'Природа и цель искусства'),
          Topic(id: 'creativity', name: 'Творчество', description: 'Творческое выражение'),
          Topic(id: 'taste', name: 'Вкус', description: 'Эстетические предпочтения'),
          Topic(id: 'sublime', name: 'Возвышенное', description: 'Величество и трагедия'),
          Topic(id: 'style', name: 'Стиль', description: 'Художественные направления'),
          Topic(id: 'interpretation', name: 'Интерпретация искусства', description: 'Смысл в искусстве'),
          Topic(id: 'authenticity', name: 'Подлинность', description: 'Оригинальность и подделки'),
          Topic(id: 'expression', name: 'Художественное выражение', description: 'Эмоции в искусстве'),
          Topic(id: 'criticism', name: 'Эстетическая критика', description: 'Оценка искусства'),
        ],
      ),
    ],
  ),

  // LITERATURE & CULTURE
  ThemeCategory(
    id: 'literature',
    name: 'Литература',
    description: 'Классические произведения и литературные движения',
    subcategories: [
      ThemeSubcategory(
        id: 'classical_literature',
        name: 'Классическая литература',
        topics: [
          Topic(id: 'ancient_epics', name: 'Древние эпосы', description: 'Илиада и Одиссея'),
          Topic(id: 'greek_tragedy', name: 'Греческая трагедия', description: 'Софокл Эсхил'),
          Topic(id: 'roman_literature', name: 'Римская литература', description: 'Вергилий и Овидий'),
          Topic(id: 'dante', name: 'Данте', description: 'Божественная комедия'),
          Topic(id: 'shakespeare', name: 'Шекспир', description: 'Драмы и сонеты'),
          Topic(id: 'cervantes', name: 'Сервантес', description: 'Дон Кихот'),
          Topic(id: 'moliere', name: 'Мольер', description: 'Французская комедия'),
          Topic(id: 'goethe', name: 'Гёте', description: 'Фауст и романы'),
          Topic(id: 'pushkin', name: 'Пушкин', description: 'Русская классика'),
          Topic(id: 'dostoevsky', name: 'Достоевский', description: 'Психологические романы'),
        ],
      ),
      ThemeSubcategory(
        id: 'modern_literature',
        name: 'Современная литература',
        topics: [
          Topic(id: 'tolstoy', name: 'Толстой', description: 'Война и мир'),
          Topic(id: 'flaubert', name: 'Флобер', description: 'Госпожа Бовари'),
          Topic(id: 'dickens', name: 'Диккенс', description: 'Викторианские романы'),
          Topic(id: 'austen', name: 'Остин', description: 'Романы о любви'),
          Topic(id: 'bronte', name: 'Бронте', description: 'Готические романы'),
          Topic(id: 'balzac', name: 'Бальзак', description: 'Человеческая комедия'),
          Topic(id: 'turgenev', name: 'Тургенев', description: 'Отцы и дети'),
          Topic(id: 'chekhov', name: 'Чехов', description: 'Пьесы и рассказы'),
          Topic(id: 'gorky', name: 'Горький', description: 'Мать и другие произведения'),
          Topic(id: 'bulgakov', name: 'Булгаков', description: 'Мастер и Маргарита'),
        ],
      ),
    ],
  ),

  // PSYCHOLOGY
  ThemeCategory(
    id: 'psychology',
    name: 'Психология',
    description: 'Наука о человеческом поведении и сознании',
    subcategories: [
      ThemeSubcategory(
        id: 'cognitive_psychology',
        name: 'Когнитивная психология',
        topics: [
          Topic(id: 'memory', name: 'Память', description: 'Кодирование хранение восстановление'),
          Topic(id: 'learning', name: 'Обучение', description: 'Классический и оперантный условные рефлексы'),
          Topic(id: 'perception', name: 'Восприятие', description: 'Как мозг обрабатывает информацию'),
          Topic(id: 'attention', name: 'Внимание', description: 'Сосредоточение и фокус'),
          Topic(id: 'thinking', name: 'Мышление', description: 'Решение проблем и суждения'),
          Topic(id: 'language', name: 'Язык', description: 'Речь и понимание'),
          Topic(id: 'intelligence', name: 'Интеллект', description: 'IQ и когнитивные способности'),
          Topic(id: 'creativity', name: 'Творчество', description: 'Инновационное мышление'),
          Topic(id: 'consciousness', name: 'Сознание', description: 'Осознанность и восприятие'),
          Topic(id: 'decision_making', name: 'Принятие решений', description: 'Риск и выбор'),
        ],
      ),
      ThemeSubcategory(
        id: 'social_psychology',
        name: 'Социальная психология',
        topics: [
          Topic(id: 'influence', name: 'Социальное влияние', description: 'Убеждение и подчинение'),
          Topic(id: 'groups', name: 'Групповое поведение', description: 'Динамика групп'),
          Topic(id: 'prejudice', name: 'Предубеждение', description: 'Дискриминация и стереотипы'),
          Topic(id: 'attraction', name: 'Привлекательность', description: 'Любовь и отношения'),
          Topic(id: 'aggression', name: 'Агрессия', description: 'Враждебное поведение'),
          Topic(id: 'helping', name: 'Помощь и альтруизм', description: 'Просоциальное поведение'),
          Topic(id: 'conformity', name: 'Конформность', description: 'Давление группы'),
          Topic(id: 'obedience', name: 'Подчинение', description: 'Власть и авторитет'),
          Topic(id: 'leadership', name: 'Лидерство', description: 'Влияние и вдохновение'),
          Topic(id: 'cooperation', name: 'Кооперация', description: 'Взаимодействие и партнерство'),
        ],
      ),
    ],
  ),

  // ECONOMICS
  ThemeCategory(
    id: 'economics',
    name: 'Экономика',
    description: 'Наука о производстве и распределении благ',
    subcategories: [
      ThemeSubcategory(
        id: 'microeconomics',
        name: 'Микроэкономика',
        topics: [
          Topic(id: 'supply_demand', name: 'Спрос и предложение', description: 'Рыночное равновесие'),
          Topic(id: 'consumer_behavior', name: 'Поведение потребителя', description: 'Предпочтения и выбор'),
          Topic(id: 'production', name: 'Производство', description: 'Затраты и выпуск'),
          Topic(id: 'competition', name: 'Конкуренция', description: 'Рынки и монополии'),
          Topic(id: 'pricing', name: 'Ценообразование', description: 'Стратегии установления цен'),
          Topic(id: 'elasticity', name: 'Эластичность', description: 'Чувствительность к цене'),
          Topic(id: 'labor_markets', name: 'Рынок труда', description: 'Зарплата и занятость'),
          Topic(id: 'capital', name: 'Капитал', description: 'Инвестиции и доход'),
          Topic(id: 'trade', name: 'Торговля', description: 'Обмен благ'),
          Topic(id: 'efficiency', name: 'Экономическая эффективность', description: 'Оптимальное распределение'),
        ],
      ),
      ThemeSubcategory(
        id: 'macroeconomics',
        name: 'Макроэкономика',
        topics: [
          Topic(id: 'gdp', name: 'ВВП', description: 'Валовой внутренний продукт'),
          Topic(id: 'inflation', name: 'Инфляция', description: 'Рост цен'),
          Topic(id: 'unemployment', name: 'Безработица', description: 'Отсутствие работы'),
          Topic(id: 'monetary_policy', name: 'Денежная политика', description: 'Центральные банки и процентные ставки'),
          Topic(id: 'fiscal_policy', name: 'Фискальная политика', description: 'Налоги и расходы правительства'),
          Topic(id: 'economic_cycles', name: 'Экономические циклы', description: 'Бум и спад'),
          Topic(id: 'international_trade', name: 'Международная торговля', description: 'Глобальные потоки'),
          Topic(id: 'exchange_rates', name: 'Обменные курсы', description: 'Валютные рынки'),
          Topic(id: 'development', name: 'Экономическое развитие', description: 'Рост и процветание'),
          Topic(id: 'inequality', name: 'Экономическое неравенство', description: 'Богатство и бедность'),
        ],
      ),
    ],
  ),

  // POLITICS & SOCIAL STUDIES
  ThemeCategory(
    id: 'politics',
    name: 'Политология',
    description: 'Управление обществом и политические системы',
    subcategories: [
      ThemeSubcategory(
        id: 'political_theory',
        name: 'Политическая теория',
        topics: [
          Topic(id: 'democracy', name: 'Демократия', description: 'Правление народом'),
          Topic(id: 'autocracy', name: 'Автократия', description: 'Единоличная власть'),
          Topic(id: 'socialism', name: 'Социализм', description: 'Коллективная собственность'),
          Topic(id: 'capitalism', name: 'Капитализм', description: 'Частная собственность и рынок'),
          Topic(id: 'liberalism', name: 'Либерализм', description: 'Индивидуальные свободы'),
          Topic(id: 'conservatism', name: 'Консервативный', description: 'Традиции и стабильность'),
          Topic(id: 'anarchism', name: 'Анархизм', description: 'Без государства и правил'),
          Topic(id: 'communism', name: 'Коммунизм', description: 'Идеальное общество'),
          Topic(id: 'federalism', name: 'Федерализм', description: 'Распределенная власть'),
          Topic(id: 'nationalism', name: 'Национализм', description: 'Национальные интересы'),
        ],
      ),
      ThemeSubcategory(
        id: 'international_relations',
        name: 'Международные отношения',
        topics: [
          Topic(id: 'diplomacy', name: 'Дипломатия', description: 'Переговоры между государствами'),
          Topic(id: 'conflict', name: 'Международный конфликт', description: 'Войны и напряженность'),
          Topic(id: 'cooperation', name: 'Международное сотрудничество', description: 'Альянсы и организации'),
          Topic(id: 'geopolitics', name: 'Геополитика', description: 'Мир и власть'),
          Topic(id: 'trade_agreements', name: 'Торговые соглашения', description: 'Двусторонние и многосторонние'),
          Topic(id: 'terrorism', name: 'Терроризм', description: 'Политическое насилие'),
          Topic(id: 'sanctions', name: 'Экономические санкции', description: 'Наказание через торговлю'),
          Topic(id: 'refugees', name: 'Беженцы', description: 'Перемещенные лица'),
          Topic(id: 'human_rights', name: 'Права человека в мире', description: 'Глобальные стандарты'),
          Topic(id: 'global_governance', name: 'Глобальное управление', description: 'Международные организации'),
        ],
      ),
    ],
  ),

  // ARTS
  ThemeCategory(
    id: 'arts',
    name: 'Искусство',
    description: 'Визуальные и исполнительские искусства',
    subcategories: [
      ThemeSubcategory(
        id: 'visual_arts',
        name: 'Визуальные искусства',
        topics: [
          Topic(id: 'painting', name: 'Живопись', description: 'История и техники'),
          Topic(id: 'sculpture', name: 'Скульптура', description: 'Трехмерное искусство'),
          Topic(id: 'architecture', name: 'Архитектура', description: 'Дизайн зданий'),
          Topic(id: 'photography', name: 'Фотография', description: 'Визуальное документирование'),
          Topic(id: 'drawing', name: 'Рисунок', description: 'Основы изобразительного искусства'),
          Topic(id: 'printmaking', name: 'Печать', description: 'Граффика и гравюра'),
          Topic(id: 'digital_art', name: 'Цифровое искусство', description: 'Компьютерное творчество'),
          Topic(id: 'installation', name: 'Инсталляция', description: 'Пространственное искусство'),
          Topic(id: 'film', name: 'Кино', description: 'Искусство кинематографа'),
          Topic(id: 'animation', name: 'Анимация', description: 'Движущееся изображение'),
        ],
      ),
      ThemeSubcategory(
        id: 'performing_arts',
        name: 'Исполнительские искусства',
        topics: [
          Topic(id: 'theater', name: 'Театр', description: 'Драматическое выступление'),
          Topic(id: 'music', name: 'Музыка', description: 'Композиция и исполнение'),
          Topic(id: 'dance', name: 'Танец', description: 'Движение и ритм'),
          Topic(id: 'opera', name: 'Опера', description: 'Музыкальное театральное искусство'),
          Topic(id: 'ballet', name: 'Балет', description: 'Классический танец'),
          Topic(id: 'comedy', name: 'Комедия', description: 'Юмор и смех'),
          Topic(id: 'circus', name: 'Цирк', description: 'Акробатика и трюки'),
          Topic(id: 'standup', name: 'Стендап', description: 'Живой комедийный монолог'),
          Topic(id: 'improv', name: 'Импровизация', description: 'Спонтанное исполнение'),
          Topic(id: 'mime', name: 'Пантомима', description: 'Безмолвное исполнение'),
        ],
      ),
    ],
  ),

  // NATURE & ENVIRONMENT
  ThemeCategory(
    id: 'nature',
    name: 'Природа',
    description: 'Экология и живой мир',
    subcategories: [
      ThemeSubcategory(
        id: 'ecosystems',
        name: 'Экосистемы',
        topics: [
          Topic(id: 'rainforests', name: 'Тропические леса', description: 'Биоразнообразие и влажность'),
          Topic(id: 'oceans', name: 'Океаны', description: 'Морские экосистемы'),
          Topic(id: 'deserts', name: 'Пустыни', description: 'Засушливые ландшафты'),
          Topic(id: 'mountains', name: 'Горные системы', description: 'Высокогорные среды'),
          Topic(id: 'freshwater', name: 'Пресные воды', description: 'Озера и реки'),
          Topic(id: 'tundra', name: 'Тундра', description: 'Арктические равнины'),
          Topic(id: 'savanna', name: 'Саванна', description: 'Травянистые равнины'),
          Topic(id: 'coral_reefs', name: 'Коралловые рифы', description: 'Подводные оазисы'),
          Topic(id: 'caves', name: 'Пещеры', description: 'Подземные миры'),
          Topic(id: 'wetlands', name: 'Болота и заболоченные земли', description: 'Влажные среды'),
        ],
      ),
      ThemeSubcategory(
        id: 'wildlife',
        name: 'Дикая природа',
        topics: [
          Topic(id: 'mammals', name: 'Млекопитающие', description: 'Волосатые животные'),
          Topic(id: 'birds', name: 'Птицы', description: 'Летающие позвоночные'),
          Topic(id: 'reptiles', name: 'Рептилии', description: 'Чешуйчатые животные'),
          Topic(id: 'amphibians', name: 'Земноводные', description: 'Лягушки и саламандры'),
          Topic(id: 'fish', name: 'Рыбы', description: 'Водные позвоночные'),
          Topic(id: 'insects', name: 'Насекомые', description: 'Членистоногие'),
          Topic(id: 'arachnids', name: 'Пауки и скорпионы', description: 'Восьминогие'),
          Topic(id: 'mollusks', name: 'Моллюски', description: 'Мягкотелые животные'),
          Topic(id: 'crustaceans', name: 'Ракообразные', description: 'Крабы и омары'),
          Topic(id: 'endangered_species', name: 'Исчезающие виды', description: 'Угроза исчезновения'),
        ],
      ),
    ],
  ),

  // SPORTS
  ThemeCategory(
    id: 'sports',
    name: 'Спорт',
    description: 'Здоровье и спортивные достижения',
    subcategories: [
      ThemeSubcategory(
        id: 'team_sports',
        name: 'Командные виды спорта',
        topics: [
          Topic(id: 'football', name: 'Футбол', description: 'Король спорта'),
          Topic(id: 'basketball', name: 'Баскетбол', description: 'Быстрая игра'),
          Topic(id: 'baseball', name: 'Бейсбол', description: 'Американская игра'),
          Topic(id: 'rugby', name: 'Регби', description: 'Контактный спорт'),
          Topic(id: 'volleyball', name: 'Волейбол', description: 'Сетевая игра'),
          Topic(id: 'hockey', name: 'Хоккей', description: 'Ледовая игра'),
          Topic(id: 'handball', name: 'Гандбол', description: 'Командная игра с мячом'),
          Topic(id: 'cricket', name: 'Крикет', description: 'Британская игра'),
          Topic(id: 'American_football', name: 'Американский футбол', description: 'Супербоул и тачдауны'),
          Topic(id: 'lacrosse', name: 'Лакросс', description: 'Палочка и сетка'),
        ],
      ),
      ThemeSubcategory(
        id: 'individual_sports',
        name: 'Индивидуальные виды спорта',
        topics: [
          Topic(id: 'tennis', name: 'Теннис', description: 'Сетка и ракетка'),
          Topic(id: 'golf', name: 'Гольф', description: 'Точность и стратегия'),
          Topic(id: 'swimming', name: 'Плавание', description: 'Водные виды спорта'),
          Topic(id: 'athletics', name: 'Легкая атлетика', description: 'Бег прыжки метание'),
          Topic(id: 'gymnastics', name: 'Гимнастика', description: 'Гибкость и акробатика'),
          Topic(id: 'boxing', name: 'Бокс', description: 'Боевое искусство'),
          Topic(id: 'wrestling', name: 'Борьба', description: 'Контактная борьба'),
          Topic(id: 'martial_arts', name: 'Боевые искусства', description: 'Карате Тхэквондо Кунг-фу'),
          Topic(id: 'cycling', name: 'Велоспорт', description: 'Гоночные велосипеды'),
          Topic(id: 'skiing', name: 'Лыжный спорт', description: 'Зимние виды спорта'),
        ],
      ),
    ],
  ),
];
