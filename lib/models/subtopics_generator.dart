import 'theme_data.dart';
import '../providers/language_provider.dart';

/// Генерирует подтемы для тем в виде сфер/областей (не конкретных вопросов); минимум 20 на тему.
List<Topic> generateSubtopicsForTopic(String topicId, String topicName, AppLanguage language) {
  final isGerman = language == AppLanguage.german;
  
  if (topicSubtopics.containsKey(topicId)) {
    final predefined = topicSubtopics[topicId]!;
    return predefined;
  }
  
  final category = _getCategoryForTopic(topicId);
  return _generateSubtopicsByCategory(topicId, topicName, category, isGerman);
}

String _getCategoryForTopic(String topicId) {
  // Определяем категорию по ID темы
  if (topicId.startsWith('ancient_') || topicId.startsWith('medieval_') || 
      topicId.startsWith('renaissance_') || topicId.startsWith('industrial_') ||
      topicId.startsWith('ww') || topicId.startsWith('cold_war') ||
      topicId.startsWith('soviet_') || topicId.startsWith('war_') ||
      topicId.startsWith('russian_') || topicId.startsWith('american_') ||
      topicId.startsWith('french_') || topicId.startsWith('gulf_') ||
      topicId.startsWith('yugoslav_') || topicId.startsWith('arab_') ||
      topicId.startsWith('ukraine_') || topicId.startsWith('covid_')) {
    return 'history';
  }
  if (topicId.startsWith('mechanics') || topicId.startsWith('thermodynamics') ||
      topicId.startsWith('waves') || topicId.startsWith('optics') ||
      topicId.startsWith('electromagnetism') || topicId.startsWith('gravity') ||
      topicId.startsWith('relativity') || topicId.startsWith('quantum') ||
      topicId.startsWith('nuclear') || topicId.startsWith('particle') ||
      topicId.startsWith('atomic_') || topicId.startsWith('dark_') ||
      topicId.startsWith('string_') || topicId.startsWith('black_')) {
    return 'physics';
  }
  if (topicId.startsWith('organic_') || topicId.startsWith('inorganic_') ||
      topicId.startsWith('periodic_') || topicId.startsWith('chemical_') ||
      topicId.startsWith('biochemistry') || topicId.startsWith('polymer_') ||
      topicId.startsWith('acids_') || topicId.startsWith('catalysts') ||
      topicId.startsWith('crystallography') || topicId.startsWith('analytical_')) {
    return 'chemistry';
  }
  if (topicId.startsWith('cell_') || topicId.startsWith('genetics') ||
      topicId.startsWith('evolution') || topicId.startsWith('ecology') ||
      topicId.startsWith('anatomy') || topicId.startsWith('physiology') ||
      topicId.startsWith('microbiology') || topicId.startsWith('immunology') ||
      topicId.startsWith('botany') || topicId.startsWith('zoology')) {
    return 'biology';
  }
  if (topicId.startsWith('solar_') || topicId.startsWith('stars') ||
      topicId.startsWith('galaxies') || topicId.startsWith('universe') ||
      topicId.startsWith('cosmology') || topicId.startsWith('exoplanets') ||
      topicId.startsWith('space_') || topicId.startsWith('moon') ||
      topicId.startsWith('supernovae') || topicId.startsWith('neutron_')) {
    return 'astronomy';
  }
  if (topicId.startsWith('geology') || topicId.startsWith('mineralogy') ||
      topicId.startsWith('seismology') || topicId.startsWith('volcanology') ||
      topicId.startsWith('meteorology') || topicId.startsWith('oceanography') ||
      topicId.startsWith('paleontology') || topicId.startsWith('climate_') ||
      topicId.startsWith('soil_') || topicId.startsWith('hydrology')) {
    return 'earth_science';
  }
  if (topicId.startsWith('algebra') || topicId.startsWith('geometry') ||
      topicId.startsWith('calculus') || topicId.startsWith('probability') ||
      topicId.startsWith('number_') || topicId.startsWith('topology') ||
      topicId.startsWith('logic') || topicId.startsWith('graph_') ||
      topicId.startsWith('set_') || topicId.startsWith('linear_')) {
    return 'mathematics';
  }
  if (topicId.startsWith('computer_') || topicId.startsWith('software') ||
      topicId.startsWith('programming') || topicId.startsWith('artificial_') ||
      topicId.startsWith('internet') || topicId.startsWith('cybersecurity') ||
      topicId.startsWith('databases') || topicId.startsWith('cloud_') ||
      topicId.startsWith('web_') || topicId.startsWith('mobile_')) {
    return 'technology';
  }
  if (topicId.startsWith('ontology') || topicId.startsWith('existence') ||
      topicId.startsWith('causality') || topicId.startsWith('time') ||
      topicId.startsWith('space') || topicId.startsWith('substance') ||
      topicId.startsWith('dualism') || topicId.startsWith('free_will') ||
      topicId.startsWith('identity') || topicId.startsWith('possibility') ||
      topicId.startsWith('knowledge') || topicId.startsWith('truth') ||
      topicId.startsWith('belief') || topicId.startsWith('skepticism') ||
      topicId.startsWith('empiricism') || topicId.startsWith('rationalism') ||
      topicId.startsWith('perception') || topicId.startsWith('scientific_') ||
      topicId.startsWith('intuition') || topicId.startsWith('morality') ||
      topicId.startsWith('consequentialism') || topicId.startsWith('deontology') ||
      topicId.startsWith('virtue_') || topicId.startsWith('justice') ||
      topicId.startsWith('rights') || topicId.startsWith('responsibility') ||
      topicId.startsWith('virtue') || topicId.startsWith('vice') ||
      topicId.startsWith('happiness') || topicId.startsWith('beauty') ||
      topicId.startsWith('art') || topicId.startsWith('creativity') ||
      topicId.startsWith('taste') || topicId.startsWith('sublime') ||
      topicId.startsWith('style') || topicId.startsWith('interpretation') ||
      topicId.startsWith('authenticity') || topicId.startsWith('expression') ||
      topicId.startsWith('criticism')) {
    return 'philosophy';
  }
  return 'general';
}

List<Topic> _generateSubtopicsByCategory(
    String topicId, String topicName, String category, bool isGerman) {
  // Сферы/области (не вопросы); минимум 50 на категорию
  final spheres = <String>[];
  
  if (isGerman) {
    switch (category) {
      case 'history':
        spheres.addAll([
          'Macht und Einfluss', 'Alltag und Gesellschaft', 'Kriege und Konflikte',
          'Religion und Kult', 'Kunst und Kultur', 'Handel und Wirtschaft',
          'Recht und Verfassung', 'Frauen und Minderheiten', 'Technik und Infrastruktur',
          'Erbe und Rezeption', 'Mythen und Realität', 'Eliten und Volk',
          'Grenzen und Expansion', 'Krise und Wandel', 'Bildung und Wissen',
          'Diplomatie und Bündnisse', 'Ursachen und Folgen', 'Zeitzeugnisse',
          'Vergleich zu anderen Epochen', 'Ungesagte Geschichten',
          'Herrscher und Dynastien', 'Revolutionen und Umstürze', 'Reformen und Veränderungen',
          'Migration und Völkerwanderung', 'Kolonisation und Eroberung', 'Unabhängigkeit und Freiheit',
          'Bündnisse und Verträge', 'Handelsbeziehungen', 'Kultureller Austausch',
          'Sprache und Schrift', 'Literatur und Dichtung', 'Musik und Gesang',
          'Tanz und Theater', 'Feste und Feiern', 'Traditionen und Bräuche',
          'Kleidung und Mode', 'Essen und Küche', 'Wohnen und Architektur',
          'Transport und Reisen', 'Kommunikation', 'Medizin und Gesundheit',
          'Wissenschaft und Forschung', 'Technologie und Innovation', 'Landwirtschaft und Ernährung',
          'Handwerk und Industrie', 'Städte und Urbanisierung', 'Dörfer und Landleben',
        ]);
        break;
      case 'physics':
        spheres.addAll([
          'Grundkonzepte', 'Experimente und Beweise', 'Anwendungen',
          'Grenzen des Wissens', 'Zusammenhänge mit anderen Gebieten',
          'Paradoxien und Rätsel', 'Zeit und Raum', 'Interpretationen',
          'Geschichte der Ideen', 'Zukunft und Technik',
          'Mathematische Grundlagen', 'Messung und Beobachtung',
          'Modell und Realität', 'Symmetrien und Erhaltungssätze',
          'Feldtheorie', 'Teilchen und Wechselwirkungen',
          'Klassisch vs. modern', 'Philosophische Deutung',
          'Populäre Missverständnisse', 'Ungelöste Probleme',
          'Mechanik und Bewegung', 'Energie und Arbeit', 'Kraft und Beschleunigung',
          'Impuls und Stoß', 'Drehbewegung', 'Schwingungen und Wellen',
          'Elektrizität und Magnetismus', 'Licht und Optik', 'Wärme und Temperatur',
          'Thermodynamik', 'Statistik und Wahrscheinlichkeit', 'Chaos und Komplexität',
          'Nichtlinearität', 'Emergenz', 'Reduktionismus',
          'Emergente Eigenschaften', 'Skalierung', 'Selbstorganisation',
          'Netzwerke und Systeme', 'Information und Entropie', 'Komplexitätstheorie',
          'Computersimulationen', 'Numerische Methoden', 'Experimentelle Techniken',
          'Messtechnik', 'Datenanalyse', 'Theoriebildung',
          'Hypothesenbildung', 'Falsifizierung', 'Verifikation',
        ]);
        break;
      case 'chemistry':
        spheres.addAll([
          'Moleküle und Bindungen', 'Reaktionen und Gleichgewichte',
          'Anwendungen und Umwelt', 'Analytik und Nachweis',
          'Organische Chemie', 'Anorganische Chemie',
          'Biochemie', 'Gefahren und Sicherheit',
          'Geschichte und Entdeckungen', 'Grenzen und offene Fragen',
          'Katalyse', 'Elektrochemie', 'Festkörper',
          'Lösungen und Konzentration', 'Säuren und Basen',
          'Oxidation und Reduktion', 'Komplexe Verbindungen',
          'Industrielle Prozesse', 'Theorie und Modell',
          'Experimente im Alltag', 'Atome und Elemente', 'Periodensystem',
          'Ionen und Salze', 'Metalle und Legierungen', 'Nichtmetalle',
          'Edelgase', 'Halogene', 'Übergangsmetalle',
          'Lanthanoide und Actinoide', 'Isotope und Radioaktivität', 'Kernchemie',
          'Strukturanalyse', 'Spektroskopie', 'Chromatographie',
          'Titration', 'pH und Puffer', 'Redoxpotentiale',
          'Elektrolyse', 'Galvanische Zellen', 'Batterien und Akkus',
          'Korrosion', 'Oberflächenchemie', 'Kolloidchemie',
          'Polymere', 'Kunststoffe', 'Farbstoffe',
          'Aromastoffe', 'Pharmazeutika', 'Pestizide',
          'Düngemittel', 'Reinigungsmittel', 'Kosmetika',
        ]);
        break;
      case 'biology':
        spheres.addAll([
          'Evolution und Anpassung', 'Ökosysteme', 'Zellen und Organellen',
          'Genetik und Vererbung', 'Physiologie', 'Verhalten',
          'Artenvielfalt', 'Medizin und Anwendung',
          'Ethik und Technik', 'Ungelöste Rätsel',
          'Mikroorganismen', 'Pflanzen', 'Tiere',
          'Entwicklung und Wachstum', 'Immunsystem',
          'Ökologie und Naturschutz', 'Biotechnologie',
          'Geschichte der Biologie', 'Experimente und Methoden',
          'Zusammenspiel mit anderen Wissenschaften', 'Grenzen des Wissens',
          'DNA und RNA', 'Proteine und Enzyme', 'Metabolismus',
          'Photosynthese', 'Zellatmung', 'Zellteilung',
          'Meiose und Mitose', 'Stammzellen', 'Gewebe und Organe',
          'Nervensystem', 'Hormone', 'Reproduktion',
          'Sexualität', 'Altern', 'Tod und Zerfall',
          'Fossilien', 'Paläontologie', 'Taxonomie',
          'Systematik', 'Phylogenie', 'Biodiversität',
          'Artenschutz', 'Umweltschutz', 'Klimawandel',
          'Anpassung', 'Selektion', 'Mutation',
          'Genfluss', 'Gendrift', 'Isolation',
          'Speziation', 'Konvergenz', 'Divergenz',
        ]);
        break;
      case 'astronomy':
        spheres.addAll([
          'Entstehung und Ende', 'Beobachtung und Instrumente',
          'Sonnensystem', 'Sterne und Galaxien',
          'Kosmologie', 'Raumfahrt und Erforschung',
          'Leben im All', 'Gefahren aus dem All',
          'Geschichte der Astronomie', 'Ungelöste Fragen',
          'Schwarze Löcher', 'Exoplaneten', 'Dunkle Materie und Energie',
          'Zeit und Entfernung', 'Physik im Weltraum',
          'Mythologie und Kultur', 'Zukunft der Raumfahrt',
          'Messmethoden', 'Modelle und Simulationen',
          'Zusammenhang mit Physik und Philosophie',
          'Planeten und Monde', 'Asteroiden und Kometen', 'Meteoriten',
          'Sternentstehung', 'Sternentod', 'Supernovae',
          'Neutronensterne', 'Pulsare', 'Weiße Zwerge',
          'Rote Riesen', 'Braune Zwerge', 'Quasare',
          'Galaxienhaufen', 'Superhaufen', 'Große Mauer',
          'Urknall', 'Inflation', 'Hintergrundstrahlung',
          'Rotverschiebung', 'Hubble-Gesetz', 'Expansion',
          'Gravitationswellen', 'Röntgenastronomie', 'Radioastronomie',
          'Infrarotastronomie', 'Ultraviolettastronomie', 'Gammastrahlen',
          'Teleskope', 'Satelliten', 'Raumsonden',
          'Marsmissionen', 'Mondlandung', 'ISS',
          'SETI', 'Außerirdisches Leben', 'Habitable Zone',
        ]);
        break;
      case 'mathematics':
        spheres.addAll([
          'Strukturen und Beweise', 'Anwendungen', 'Geschichte',
          'Ungelöste Probleme', 'Zahlentheorie', 'Geometrie',
          'Analysis', 'Algebra', 'Logik und Mengenlehre',
          'Wahrscheinlichkeit und Statistik', 'Topologie',
          'Graphentheorie', 'Algorithmen', 'Modellierung',
          'Schönheit und Eleganz', 'Paradoxien',
          'Grenzen und Unvollständigkeit', 'Didaktik',
          'Zusammenhänge zwischen Teilgebieten', 'Offene Fragen',
          'Reale Welt und Abstraktion', 'Zahlen und Operationen', 'Gleichungen',
          'Funktionen', 'Grenzwerte', 'Ableitungen',
          'Integrale', 'Differentialgleichungen', 'Vektoren',
          'Matrizen', 'Determinanten', 'Eigenwerte',
          'Gruppentheorie', 'Ringtheorie', 'Körpertheorie',
          'Kombinatorik', 'Permutationen', 'Kombinationen',
          'Rekursion', 'Induktion', 'Kontraposition',
          'Widerspruch', 'Konstruktivismus', 'Intuitionismus',
          'Formalismus', 'Platonismus', 'Empirismus',
          'Komplexe Zahlen', 'Quaternionen', 'Oktonionen',
          'Fraktale', 'Chaostheorie', 'Katastrophentheorie',
          'Optimierung', 'Lineare Programmierung', 'Nichtlineare Optimierung',
        ]);
        break;
      case 'technology':
        spheres.addAll([
          'Funktionsweise', 'Anwendungen', 'Risiken und Sicherheit',
          'Gesellschaftliche Auswirkungen', 'Ethik',
          'Grenzen und Zukunft', 'Geschichte der Technik',
          'Regulierung und Recht', 'Zugang und Ungleichheit',
          'Nachhaltigkeit', 'Hardware und Software',
          'Netzwerke und Daten', 'Künstliche Intelligenz',
          'Nutzer und Nutzung', 'Innovation und Forschung',
          'Missbrauch und Gegenmaßnahmen', 'Standards und Kompatibilität',
          'Ausbildung und Qualifizierung', 'Offene Fragen',
          'Vernetzung mit anderen Bereichen', 'Prozessoren', 'Speicher',
          'Grafikkarten', 'Netzwerke', 'Internet',
          'Cloud Computing', 'Edge Computing', 'IoT',
          'Blockchain', 'Kryptowährungen', 'Smart Contracts',
          'Maschinelles Lernen', 'Deep Learning', 'Neuronale Netze',
          'NLP', 'Computer Vision', 'Robotik',
          'Autonome Systeme', 'Autonomes Fahren', 'Drohnen',
          '3D-Druck', 'Nanotechnologie', 'Biotechnologie',
          'Gentechnik', 'CRISPR', 'Synthetische Biologie',
          'Energiespeicher', 'Solarenergie', 'Windenergie',
          'Kernenergie', 'Fusion', 'Wasserstoff',
          'Recycling', 'Kreislaufwirtschaft', 'Nachhaltige Materialien',
        ]);
        break;
      case 'philosophy':
        spheres.addAll([
          'Begriffe und Argumente', 'Klassische Positionen',
          'Kontroversen', 'Realität und Erkenntnis',
          'Praktische Implikationen', 'Moderne Anwendungen',
          'Paradoxien', 'Relevanz für heute',
          'Geschichte der Ideen', 'Offene Fragen',
          'Sprache und Bedeutung', 'Ethik und Moral',
          'Freiheit und Determinismus', 'Bewusstsein',
          'Wissenschaft und Philosophie', 'Kultur und Werte',
          'Logik und Schlussfolgerung', 'Metaphysik',
          'Vergleich der Denkschulen', 'Grenzen des Denkens',
          'Sein und Nichts', 'Wesen und Erscheinung', 'Substanz und Akzidenz',
          'Kausalität', 'Finalität', 'Teleologie',
          'Zufall und Notwendigkeit', 'Möglichkeit und Wirklichkeit', 'Potenz und Akt',
          'Universalien', 'Nominalismus', 'Realismus',
          'Konzeptualismus', 'Idealismus', 'Materialismus',
          'Dualismus', 'Monismus', 'Pluralismus',
          'Pragmatismus', 'Empirismus', 'Rationalismus',
          'Skeptizismus', 'Dogmatismus', 'Relativismus',
          'Absolutismus', 'Subjektivismus', 'Objektivismus',
          'Hermeneutik', 'Phänomenologie', 'Strukturalismus',
          'Poststrukturalismus', 'Dekonstruktion', 'Postmoderne',
          'Analytische Philosophie', 'Kontinentale Philosophie', 'Praktische Philosophie',
        ]);
        break;
      default:
        spheres.addAll([
          'Grundbegriffe', 'Geschichte', 'Anwendungen',
          'Kontroversen', 'Offene Fragen', 'Zusammenhänge',
          'Praktische Relevanz', 'Missverständnisse',
          'Zukunft', 'Vernetzung mit anderen Gebieten',
          'Methoden', 'Klassische Positionen',
          'Moderne Debatten', 'Kultur und Gesellschaft',
          'Grenzen', 'Ethik', 'Experimente und Belege',
          'Interpretationen', 'Weitere Vertiefung 1', 'Weitere Vertiefung 2',
          'Theorie und Praxis', 'Grundlagenforschung', 'Angewandte Forschung',
          'Interdisziplinarität', 'Multidisziplinarität', 'Transdisziplinarität',
          'Paradigmenwechsel', 'Revolutionen', 'Evolutionen',
          'Kontinuität', 'Diskontinuität', 'Brüche',
          'Traditionen', 'Innovationen', 'Reformen',
          'Konservatismus', 'Progressivismus', 'Radikalismus',
          'Moderation', 'Extremismus', 'Balance',
          'Komplexität', 'Einfachheit', 'Reduktion',
          'Synthese', 'Analyse', 'Integration',
          'Differenzierung', 'Spezialisierung', 'Generalisierung',
        ]);
    }
  } else {
    switch (category) {
      case 'history':
        spheres.addAll([
          'Власть и влияние', 'Повседневность и общество', 'Войны и конфликты',
          'Религия и культ', 'Искусство и культура', 'Торговля и экономика',
          'Право и устройство', 'Женщины и меньшинства', 'Техника и инфраструктура',
          'Наследие и рецепция', 'Мифы и реальность', 'Элиты и народ',
          'Границы и экспансия', 'Кризис и смена эпох', 'Образование и знание',
          'Дипломатия и союзы', 'Причины и последствия', 'Свидетельства эпохи',
          'Сравнение с другими эпохами', 'Нерассказанные истории',
          'Правители и династии', 'Революции и перевороты', 'Реформы и изменения',
          'Миграция и переселения', 'Колонизация и завоевания', 'Независимость и свобода',
          'Союзы и договоры', 'Торговые отношения', 'Культурный обмен',
          'Язык и письменность', 'Литература и поэзия', 'Музыка и пение',
          'Танец и театр', 'Праздники и торжества', 'Традиции и обычаи',
          'Одежда и мода', 'Еда и кухня', 'Жилище и архитектура',
          'Транспорт и путешествия', 'Коммуникация', 'Медицина и здоровье',
          'Наука и исследования', 'Технологии и инновации', 'Сельское хозяйство и питание',
          'Ремесло и промышленность', 'Города и урбанизация', 'Деревни и сельская жизнь',
        ]);
        break;
      default:
        spheres.addAll([
          'Основные понятия', 'История', 'Применения',
          'Споры', 'Открытые вопросы', 'Связи с другими областями',
          'Практическая значимость', 'Заблуждения',
          'Будущее', 'Методы', 'Классические позиции',
          'Современные дебаты', 'Культура и общество',
          'Границы', 'Этика', 'Эксперименты и доказательства',
          'Интерпретации', 'Углубление 1', 'Углубление 2', 'Углубление 3',
        ]);
    }
  }
  
  final count = spheres.length >= 50 ? 50 : spheres.length;
  final list = spheres.take(count).toList();
  if (list.length < 50) {
    for (var i = list.length; i < 50; i++) {
      list.add(isGerman ? 'Weitere Aspekte ${i + 1}' : 'Другие аспекты ${i + 1}');
    }
  }
  return list.asMap().entries.map((entry) {
    return Topic(
      id: '${topicId}_subtopic_${entry.key + 1}',
      name: entry.value,
      description: null,
    );
  }).toList();
}
