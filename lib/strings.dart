/// All player-facing text, keyed by language code then string key.
/// English is the fallback for any missing key or language.
const _strings = <String, Map<String, String>>{
  'en': {
    'app_title': 'Idle Stories',
    'continue': 'Continue',
    'next': 'Next',
    'start': 'Start',
    'coming_soon': 'Coming soon',
    'choose_region': 'Where are you playing from?',
    'choose_language': 'Choose your language',
    'change_later': 'You can change this later in Settings.',
    'region_IN': 'India',
    'region_US': 'United States',
    'region_BR': 'Brazil',
    'region_FR': 'France',
    'region_OTHER': 'Other',
    'choose_story': 'Choose your story',
    'story_locked_note':
        'Your first story is permanent. More stories can be unlocked later.',
    'story_startup': 'Tech Startup',
    'story_startup_desc':
        'From a shared room in {city} to a global company.',
    'story_film': 'Film Studio',
    'story_film_desc': 'From phone-shot short films to blockbusters.',
    'story_cricket': 'Cricket Academy',
    'story_cricket_desc':
        'From a dusty local ground to a national-level academy.',
    'placeholder_art': 'Placeholder art',
    'intro_1':
        '{city}. A shared room, a second-hand laptop, and rent due in a week.',
    'intro_2':
        'Your campus placement fell through. Your roommate {friend} shrugs: "Then build your own thing."',
    'intro_3':
        'Your first freelance gig lands: fix a local shop\'s website.',
    'intro_4': 'It is not much. But it is a start.',
    'ch2_1':
        'The shop owner tells three friends. Suddenly you have more work than hours.',
    'ch2_2': '{friend} quits his job to join you. "Let\'s build an app. Our own."',
    'ch2_3':
        'Across town, a well-funded rival laughs at your one-room office. For now.',
    // Story world per region: names used by the {city} and {friend} slots.
    // "Other" plays the India story.
    'city_IN': 'Bengaluru',
    'city_US': 'Austin',
    'city_BR': 'São Paulo',
    'city_FR': 'Lyon',
    'city_OTHER': 'Bengaluru',
    'friend_IN': 'Kabir',
    'friend_US': 'Marcus',
    'friend_BR': 'Rafael',
    'friend_FR': 'Hugo',
    'friend_OTHER': 'Kabir',
    // Region versions of story lines ("key@REGION"), used before the plain key.
    'intro_2@US':
        'Your first job ended in a round of layoffs. Your roommate {friend} shrugs: "Then build your own thing."',
    'intro_3@US':
        'Your first freelance gig lands: fix a food truck\'s website.',
    'ch2_1@US':
        'The food truck owner tells three friends. Suddenly you have more work than hours.',
    'ch2_3@US':
        'Across town, a well-funded rival laughs at your garage office. For now.',
    'intro_2@BR':
        'The internship never turned into a job. Your roommate {friend} shrugs: "Then build your own thing."',
    'intro_3@BR':
        'Your first freelance gig lands: fix the neighbourhood bakery\'s website.',
    'ch2_1@BR':
        'The baker tells three friends. Suddenly you have more work than hours.',
    'intro_2@FR':
        'Your short-term contract was not renewed. Your flatmate {friend} shrugs: "Then build your own thing."',
    'intro_3@FR':
        'Your first freelance gig lands: fix the corner bakery\'s website.',
    'ch2_1@FR':
        'The baker tells three friends. Suddenly you have more work than hours.',
    'product_freelance': 'Freelance Gigs',
    'product_app': 'Mobile App',
    'product_saas': 'SaaS Product',
    'product_cloud': 'Cloud Platform',
    'product_ai': 'AI Lab',
    'level': 'Level',
    'per_second': '/sec',
    'per_cycle': 'per run',
    'tap_to_work': 'Tap to work',
    'working': 'Working…',
    'automated': 'Automated',
    'launch': 'Launch',
    'upgrade': 'Upgrade',
    'hire_manager': 'Hire manager',
    'welcome_back': 'Welcome back!',
    'offline_earned': 'While you were away, your team earned',
    'collect': 'Collect',
    'double_it': 'Double it',
    'ads_not_connected': 'Ads are not connected in this build, so doubling is free.',
    'settings': 'Settings',
    'language': 'Language',
    'region': 'Region',
    'reset_progress': 'Reset progress',
    'reset_confirm': 'This erases your progress and setup. Continue?',
    'cancel': 'Cancel',
    'unit_k': 'K',
    'unit_m': 'M',
    'unit_b': 'B',
    'unit_t': 'T',
    'unit_lakh': ' L',
    'unit_cr': ' Cr',
    'unit_lakh_cr': ' L Cr',
  },
  'hi': {
    'app_title': 'आइडल स्टोरीज़',
    'continue': 'आगे बढ़ें',
    'next': 'आगे',
    'start': 'शुरू करें',
    'coming_soon': 'जल्द आ रहा है',
    'choose_region': 'आप कहाँ से खेल रहे हैं?',
    'choose_language': 'अपनी भाषा चुनें',
    'change_later': 'आप इसे बाद में सेटिंग्स में बदल सकते हैं।',
    'region_IN': 'भारत',
    'region_US': 'अमेरिका',
    'region_BR': 'ब्राज़ील',
    'region_FR': 'फ़्रांस',
    'region_OTHER': 'अन्य',
    'choose_story': 'अपनी कहानी चुनें',
    'story_locked_note':
        'आपकी पहली कहानी स्थायी है। बाकी कहानियाँ बाद में खोली जा सकती हैं।',
    'story_startup': 'टेक स्टार्टअप',
    'story_startup_desc': '{city} के एक साझा कमरे से ग्लोबल कंपनी तक।',
    'story_film': 'फ़िल्म स्टूडियो',
    'story_film_desc': 'फ़ोन से बनी शॉर्ट फ़िल्मों से ब्लॉकबस्टर तक।',
    'story_cricket': 'क्रिकेट अकादमी',
    'story_cricket_desc': 'मोहल्ले के मैदान से राष्ट्रीय स्तर की अकादमी तक।',
    'placeholder_art': 'अस्थायी चित्र',
    'intro_1':
        '{city}। एक साझा कमरा, एक पुराना लैपटॉप, और एक हफ़्ते में किराया देना है।',
    'intro_2':
        'कैंपस प्लेसमेंट नहीं हुआ। रूममेट {friend} कंधे उचकाता है: "तो अपना कुछ बना।"',
    'intro_3': 'पहला फ़्रीलांस काम मिला: एक दुकान की वेबसाइट ठीक करनी है।',
    'intro_4': 'ज़्यादा नहीं है। पर शुरुआत तो है।',
    'ch2_1':
        'दुकानदार ने तीन दोस्तों को बताया। अब काम इतना है कि घंटे कम पड़ रहे हैं।',
    'ch2_2': '{friend} नौकरी छोड़कर साथ आ गया। "चल, अपना ऐप बनाते हैं।"',
    'ch2_3':
        'शहर के दूसरे कोने में, एक बड़ी फ़ंडिंग वाला प्रतिद्वंद्वी आपके एक कमरे के दफ़्तर पर हँसता है। फ़िलहाल।',
    'city_IN': 'बेंगलुरु',
    'city_OTHER': 'बेंगलुरु',
    'friend_IN': 'कबीर',
    'friend_OTHER': 'कबीर',
    'product_freelance': 'फ़्रीलांस काम',
    'product_app': 'मोबाइल ऐप',
    'product_saas': 'सास प्रोडक्ट',
    'product_cloud': 'क्लाउड प्लेटफ़ॉर्म',
    'product_ai': 'एआई लैब',
    'level': 'स्तर',
    'per_second': '/सेकंड',
    'per_cycle': 'प्रति बार',
    'tap_to_work': 'काम करने के लिए टैप करें',
    'working': 'काम चल रहा है…',
    'automated': 'स्वचालित',
    'launch': 'शुरू करें',
    'upgrade': 'अपग्रेड',
    'hire_manager': 'मैनेजर रखें',
    'welcome_back': 'वापसी पर स्वागत है!',
    'offline_earned': 'आपकी ग़ैरमौजूदगी में आपकी टीम ने कमाए',
    'collect': 'ले लें',
    'double_it': 'दोगुना करें',
    'ads_not_connected':
        'इस बिल्ड में विज्ञापन जुड़े नहीं हैं, इसलिए दोगुना मुफ़्त है।',
    'settings': 'सेटिंग्स',
    'language': 'भाषा',
    'region': 'क्षेत्र',
    'reset_progress': 'प्रगति मिटाएँ',
    'reset_confirm': 'इससे आपकी प्रगति और सेटअप मिट जाएगा। जारी रखें?',
    'cancel': 'रद्द करें',
    'unit_k': ' हज़ार',
    'unit_lakh': ' लाख',
    'unit_cr': ' करोड़',
    'unit_lakh_cr': ' लाख करोड़',
  },
  // Portuguese (Brazil). The plain story lines carry the Brazil version.
  'pt': {
    'app_title': 'Idle Stories',
    'continue': 'Continuar',
    'next': 'Próximo',
    'start': 'Começar',
    'coming_soon': 'Em breve',
    'choose_region': 'De onde você está jogando?',
    'choose_language': 'Escolha seu idioma',
    'change_later': 'Você pode mudar isso depois nas Configurações.',
    'region_IN': 'Índia',
    'region_US': 'Estados Unidos',
    'region_BR': 'Brasil',
    'region_FR': 'França',
    'region_OTHER': 'Outro',
    'choose_story': 'Escolha sua história',
    'story_locked_note':
        'Sua primeira história é permanente. Outras poderão ser desbloqueadas depois.',
    'story_startup': 'Startup de Tecnologia',
    'story_startup_desc':
        'De um quarto dividido em {city} a uma empresa global.',
    'story_film': 'Estúdio de Cinema',
    'story_film_desc': 'De curtas gravados no celular a sucessos de bilheteria.',
    'story_cricket': 'Academia de Críquete',
    'story_cricket_desc':
        'De um campinho de terra a uma academia de nível nacional.',
    'placeholder_art': 'Arte provisória',
    'city_IN': 'Bangalore',
    'intro_1':
        '{city}. Um quarto dividido, um notebook usado e o aluguel vence em uma semana.',
    'intro_2':
        'O estágio não virou emprego. Seu colega de quarto {friend} dá de ombros: "Então cria o seu negócio."',
    'intro_3':
        'Chega o primeiro freela: arrumar o site da padaria do bairro.',
    'intro_4': 'Não é muito. Mas é um começo.',
    'ch2_1':
        'O padeiro conta para três amigos. De repente, sobra trabalho e faltam horas.',
    'ch2_2':
        '{friend} larga o emprego para se juntar a você. "Vamos fazer um app. O nosso."',
    'ch2_3':
        'Do outro lado da cidade, um rival cheio de investimento ri do seu escritório de um cômodo. Por enquanto.',
    'product_freelance': 'Freelas',
    'product_app': 'App Mobile',
    'product_saas': 'Produto SaaS',
    'product_cloud': 'Nuvem',
    'product_ai': 'Lab de IA',
    'level': 'Nível',
    'per_second': '/s',
    'per_cycle': 'por ciclo',
    'tap_to_work': 'Toque para trabalhar',
    'working': 'Trabalhando…',
    'automated': 'Automático',
    'launch': 'Lançar',
    'upgrade': 'Melhorar',
    'hire_manager': 'Contratar gerente',
    'welcome_back': 'Bem-vindo de volta!',
    'offline_earned': 'Enquanto você esteve fora, sua equipe ganhou',
    'collect': 'Coletar',
    'double_it': 'Dobrar',
    'ads_not_connected':
        'Os anúncios não estão conectados nesta versão, então dobrar é grátis.',
    'settings': 'Configurações',
    'language': 'Idioma',
    'region': 'Região',
    'reset_progress': 'Apagar progresso',
    'reset_confirm': 'Isso apaga seu progresso e sua configuração. Continuar?',
    'cancel': 'Cancelar',
    'unit_k': ' mil',
    'unit_m': ' mi',
    'unit_b': ' bi',
    'unit_t': ' tri',
  },
  // French. The plain story lines carry the France version.
  'fr': {
    'app_title': 'Idle Stories',
    'continue': 'Continuer',
    'next': 'Suivant',
    'start': 'Commencer',
    'coming_soon': 'Bientôt',
    'choose_region': 'D\'où joues-tu ?',
    'choose_language': 'Choisis ta langue',
    'change_later': 'Tu pourras changer cela plus tard dans les Réglages.',
    'region_IN': 'Inde',
    'region_US': 'États-Unis',
    'region_BR': 'Brésil',
    'region_FR': 'France',
    'region_OTHER': 'Autre',
    'choose_story': 'Choisis ton histoire',
    'story_locked_note':
        'Ta première histoire est définitive. D\'autres pourront être débloquées plus tard.',
    'story_startup': 'Start-up Tech',
    'story_startup_desc':
        'D\'une colocation à {city} à une entreprise mondiale.',
    'story_film': 'Studio de Cinéma',
    'story_film_desc': 'Des courts-métrages au téléphone aux grands succès.',
    'story_cricket': 'Académie de Cricket',
    'story_cricket_desc':
        'D\'un terrain poussiéreux à une académie de niveau national.',
    'placeholder_art': 'Illustration provisoire',
    'city_IN': 'Bangalore',
    'intro_1':
        '{city}. Une colocation, un ordinateur d\'occasion et le loyer à payer dans une semaine.',
    'intro_2':
        'Ton CDD n\'a pas été renouvelé. Ton colocataire {friend} hausse les épaules : « Alors lance ton propre projet. »',
    'intro_3':
        'Ta première mission freelance arrive : réparer le site de la boulangerie du coin.',
    'intro_4': 'Ce n\'est pas grand-chose. Mais c\'est un début.',
    'ch2_1':
        'Le boulanger en parle à trois amis. Soudain, tu as plus de travail que d\'heures.',
    'ch2_2':
        '{friend} quitte son emploi pour te rejoindre. « Créons une appli. La nôtre. »',
    'ch2_3':
        'À l\'autre bout de la ville, un rival bien financé se moque de ton bureau d\'une seule pièce. Pour l\'instant.',
    'product_freelance': 'Missions Freelance',
    'product_app': 'Appli Mobile',
    'product_saas': 'Produit SaaS',
    'product_cloud': 'Plateforme Cloud',
    'product_ai': 'Labo IA',
    'level': 'Niveau',
    'per_second': '/s',
    'per_cycle': 'par cycle',
    'tap_to_work': 'Touche pour travailler',
    'working': 'En cours…',
    'automated': 'Automatisé',
    'launch': 'Lancer',
    'upgrade': 'Améliorer',
    'hire_manager': 'Engager un manager',
    'welcome_back': 'Bon retour !',
    'offline_earned': 'Pendant ton absence, ton équipe a gagné',
    'collect': 'Récupérer',
    'double_it': 'Doubler',
    'ads_not_connected':
        'Les publicités ne sont pas connectées dans cette version : doubler est gratuit.',
    'settings': 'Réglages',
    'language': 'Langue',
    'region': 'Région',
    'reset_progress': 'Effacer la progression',
    'reset_confirm': 'Cela efface ta progression et tes réglages. Continuer ?',
    'cancel': 'Annuler',
    'unit_k': ' k',
    'unit_m': ' M',
    'unit_b': ' Md',
    'unit_t': ' Bn',
  },
};

String tr(String lang, String key) =>
    _strings[lang]?[key] ?? _strings['en']![key] ?? key;

/// Story text for the player's region. Looks for a region version of the
/// line ("key@REGION") in the player's language, then the plain line, then
/// English, and fills the {city} and {friend} slots from the region's world.
String trStory(String lang, String? region, String key) {
  final r = region ?? 'OTHER';
  final text =
      _strings[lang]?['$key@$r'] ??
      _strings[lang]?[key] ??
      _strings['en']!['$key@$r'] ??
      tr(lang, key);
  return text
      .replaceAll('{city}', tr(lang, 'city_$r'))
      .replaceAll('{friend}', tr(lang, 'friend_$r'));
}
