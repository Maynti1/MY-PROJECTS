/* ============================================================
   USA — travel guide · interactions + bilingual content
   ============================================================ */
(function () {
  "use strict";

  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var STORAGE_KEY = "usa-lang";

  /* ==========================================================
     1. Translations
     ========================================================== */

  var I18N = {
    ru: {
      "a11y.skip": "Перейти к содержанию",
      "a11y.home": "USA — на главную",
      "a11y.menu": "Меню",
      "a11y.top": "USA — наверх",

      "nav.tagline": "Путеводитель",
      "nav.regions": "Регионы",
      "nav.map": "Карта",
      "nav.places": "Места",
      "nav.history": "История",
      "nav.culture": "Культура",
      "nav.cta": "В путь",

      "t.1": "Йеллоустоун",
      "t.2": "Гранд-Каньон",
      "t.3": "Йосемити",
      "t.4": "Верхнее озеро",
      "t.5": "Зион",
      "t.6": "Глейсиер",
      "t.7": "Маунт-Рейниер",
      "t.8": "Подкова-Бенд",

      "hero.eyebrow": "Путеводитель по США · 2026",
      "hero.title": "Страна, которая<br>измеряется <em>милями</em>",
      "hero.lead": "50 штатов, 63 национальных парка и тысячи километров между ними. Горы, реки и озёра — места, которые стоит увидеть, и конструктор маршрута, который соберёт поездку за вас.",
      "hero.btn1": "Собрать маршрут",
      "hero.btn2": "Смотреть места",
      "hero.stat1": "Штатов",
      "hero.stat2": "Нац. парков",
      "hero.stat3": "Регионов",
      "hero.stat4": "Часовых поясов",
      "hero.coords": "44.0626° N — 110.8050° W",
      "hero.rail": "Grand Teton · Wyoming",

      "manifesto.kicker": "Манифест",
      "manifesto.title": "Пятьдесят штатов.<br>Четыре характера.<br><em>Одна дорога.</em>",
      "manifesto.lead": "Америка начинается не с городов, а с расстояний между ними. С пустыни, где дорога уходит за горизонт, с неона на заправке, с радио, которое меняется вместе со штатом.",
      "manifesto.body": "Мы собрали четыре региона, двенадцать природных точек и карту, на которой маршрут собирается в два клика. Выбирайте свои места — остальное сделает дорога.",
      "manifesto.cta": "Начать с регионов",

      "stats.states": "штатов",
      "stats.area": "млн км²",
      "stats.parks": "национальных парка",
      "stats.places": "природных точек",

      "regions.kicker": "География",
      "regions.note": "Нажмите на регион, чтобы открыть",
      "regions.title": "Четыре <em>Америки</em>",
      "regions.lead": "От Тихого океана до Атлантики — четыре разных ритма, воды и пейзажа. Выберите свой: океан, озёра, прерии или небоскрёбы.",
      "regions.link": "Смотреть места",
      "regions.west.count": "13 штатов",
      "regions.west.eyebrow": "Тихоокеанский берег и Скалистые горы",
      "regions.west.name": "Запад",
      "regions.west.text": "Ледники спускаются к океану, каньоны прорезают пустыню, а дорога вдоль побережья входит в списки лучших в мире.",
      "regions.west.sr": "Открыть регион Запад",
      "regions.south.count": "16 штатов",
      "regions.south.eyebrow": "Болота, музыка и барбекю",
      "regions.south.name": "Юг",
      "regions.south.text": "Медленный ритм Нового Орлеана, ар-деко Майами и пряная кухня, которую ни с чем не спутать. Здесь вечер начинается днём.",
      "regions.south.sr": "Открыть регион Юг",
      "regions.midwest.count": "12 штатов",
      "regions.midwest.eyebrow": "Великие озёра и поля",
      "regions.midwest.name": "Средний Запад",
      "regions.midwest.text": "Поля до горизонта, архитектура Чикаго и озеро, которое больше похоже на море. Самая спокойная и самая недооценённая Америка.",
      "regions.midwest.sr": "Открыть регион Средний Запад",
      "regions.northeast.count": "9 штатов",
      "regions.northeast.eyebrow": "Нью-Йорк и кленовая осень",
      "regions.northeast.name": "Северо-Восток",
      "regions.northeast.text": "Нью-Йорк, Бостон и осень Новой Англии. Кирпичные кварталы, университеты и океан в двух шагах — самая европейская часть страны.",
      "regions.northeast.sr": "Открыть регион Северо-Восток",

      "map.kicker": "Конструктор",
      "map.note": "Максимум 6 остановок",
      "map.title": "Соберите <em>свой</em> маршрут",
      "map.lead": "Нажмите на точку на карте — мы посчитаем дни и соберём основу поездки. Остановки можно менять в любом порядке.",
      "map.hint": "Нажмите на точку",
      "map.legend1": "В маршруте",
      "map.legend2": "Доступно",
      "map.legend3": "Кликните по точке, чтобы добавить",
      "map.panel": "Информация о точке маршрута",
      "map.days": "Дней",
      "map.season": "Сезон",
      "map.add": "Добавить в маршрут",
      "map.remove": "Убрать из маршрута",

      "route.label": "Ваш маршрут",
      "route.hint": "Максимум 6 остановок. Нажмите на точку, чтобы добавить.",
      "route.list": "Выбранные остановки",
      "route.email": "Ваш email",
      "route.emailPh": "email, чтобы получить маршрут",
      "route.submit": "Получить",
      "route.note": "Без спама. Только маршрут и полезные ссылки.",
      "route.empty": "Пока пусто — выберите точки на карте.",
      "route.summary": "остановок · дней",
      "route.max": "Достигнут лимит в 6 остановок. Уберите одну, чтобы добавить новую.",
      "route.invalid": "Проверьте адрес — кажется, в нём опечатка.",
      "route.sent": "Готово! Маршрут отправлен на ",
      "route.pluralStops": "остановок",
      "route.pluralDays": "дней",

      "places.kicker": "Места",
      "places.note": "Нажмите на карточку — точка появится на карте",
      "places.title": "Масштаб, который <em>не передать</em>",
      "places.lead": "Восемь открыток, которые стоит увидеть вживую. Каждая — отдельная история о стране и её расстояниях.",
      "places.tag1": "Каньон",
      "places.tag2": "Источники",
      "places.tag3": "Водопад",
      "places.tag4": "Озеро",
      "places.tag5": "Озеро",
      "places.tag6": "Река",
      "places.tag7": "Каньон",
      "places.tag8": "Река",
      "places.p1": "Гранд-Каньон",
      "places.p1s": "Аризона · 1,8 млрд лет истории в слоях камня",
      "places.p2": "Йеллоустоун",
      "places.p2s": "Вайоминг · первый национальный парк мира",
      "places.p3": "Йосемити",
      "places.p3s": "Калифорния · 739 метров падения воды",
      "places.p4": "Верхнее озеро",
      "places.p4s": "Мичиган · 82 100 км² пресной воды",
      "places.p5": "Крейтер-Лейк",
      "places.p5s": "Орегон · самое глубокое озеро США",
      "places.p6": "Подкова-Бенд",
      "places.p6s": "Аризона · Колорадо в скальном кольце",
      "places.p7": "Антилоп-Каньон",
      "places.p7s": "Аризона · свет падает сверху, а не сбоку",
      "places.p8": "Зион",
      "places.p8s": "Юта · каньон, выточенный водой",

      "history.kicker": "История",
      "history.title": "Пять дат, <em>которые всё изменили</em>",
      "history.lead": "Короткая хронология страны: от подписания Декларации до первого шага на Луне.",
      "history.h1": "Декларация независимости",
      "history.h1t": "Тринадцать колоний объявляют о создании нового государства.",
      "history.h2": "13-я поправка",
      "history.h2t": "Отмена рабства закреплена в Конституции после Гражданской войны.",
      "history.h3": "Первый полёт",
      "history.h3t": "Братья Райт поднимают самолёт в воздух на 12 секунд, изменивших мир.",
      "history.h4": "«Аполлон-11»",
      "history.h4t": "Нил Армстронг делает первый шаг по поверхности Луны.",
      "history.h5": "44-й президент",
      "history.h5t": "Барак Обама становится первым темнокожим президентом США.",

      "culture.kicker": "Культура",
      "culture.title": "Не только <em>места</em>",
      "culture.lead": "Америка экспортирует не пейзажи, а истории. Кино, музыка, спорт и еда — четыре способа узнать страну ещё до поездки.",
      "culture.c1": "Кино",
      "culture.c1t": "Голливуд с 1910-х задаёт мировые стандарты — от нуара до блокбастеров.",
      "culture.c2": "Музыка",
      "culture.c2t": "Джаз, блюз, рок-н-ролл и хип-хоп родились здесь и разошлись по планете.",
      "culture.c2tag": "Новый Орлеан — Бронкс",
      "culture.c3": "Спорт",
      "culture.c3t": "NFL, NBA, MLB и NHL: один Супербоул собирает больше 100 млн зрителей.",
      "culture.c4": "Еда",
      "culture.c4t": "Бургеры, BBQ, food trucks и сотни региональных кухонь — от Техаса до Вермонта.",
      "culture.c4tag": "50 штатов",

      "cta.kicker": "Дальше — только вы",
      "cta.title": "Следующая<br>остановка — <em>вы.</em>",
      "cta.lead": "Соберите маршрут из точек на карте или начните с готового варианта на восемь дней. Остальное — вопрос дороги.",
      "cta.btn1": "Собрать маршрут",
      "cta.btn2": "Смотреть места",
      "cta.note": "50 штатов · 63 парка · одна дорога",

      "footer.about": "Путеводитель по стране, где дорога важнее пункта назначения. Демо-проект.",
      "footer.nav": "Навигация в подвале",
      "footer.sections": "Разделы",
      "footer.places": "Природные места",
      "footer.about2": "О проекте",
      "footer.manifesto": "Манифест",
      "footer.rights": "Все права на вдохновение свободны.",
      "footer.credits": "Фото: Wikimedia Commons · Unsplash ✦ Сделано с вниманием к деталям",

      "d.yosemite": "Йосемити",
      "d.grandcanyon": "Гранд-Каньон",
      "d.yellowstone": "Йеллоустоун",
      "d.superior": "Верхнее озеро",
      "d.horseshoe": "Подкова-Бенд"
    },

    en: {
      "a11y.skip": "Skip to content",
      "a11y.home": "USA — home",
      "a11y.menu": "Menu",
      "a11y.top": "USA — back to top",

      "nav.tagline": "Travel guide",
      "nav.regions": "Regions",
      "nav.map": "Map",
      "nav.places": "Places",
      "nav.history": "History",
      "nav.culture": "Culture",
      "nav.cta": "Let's go",

      "t.1": "Yellowstone",
      "t.2": "Grand Canyon",
      "t.3": "Yosemite",
      "t.4": "Lake Superior",
      "t.5": "Zion",
      "t.6": "Glacier",
      "t.7": "Mount Rainier",
      "t.8": "Horseshoe Bend",

      "hero.eyebrow": "USA travel guide · 2026",
      "hero.title": "A country measured<br>in <em>miles</em>",
      "hero.lead": "50 states, 63 national parks and thousands of kilometres between them. Mountains, rivers and lakes worth seeing, plus a route builder that assembles the trip for you.",
      "hero.btn1": "Build a route",
      "hero.btn2": "See the places",
      "hero.stat1": "States",
      "hero.stat2": "Nat. parks",
      "hero.stat3": "Regions",
      "hero.stat4": "Time zones",
      "hero.coords": "44.0626° N — 110.8050° W",
      "hero.rail": "Grand Teton · Wyoming",

      "manifesto.kicker": "Manifesto",
      "manifesto.title": "Fifty states.<br>Four characters.<br><em>One road.</em>",
      "manifesto.lead": "America begins not with cities, but with the distances between them. With deserts where the road runs past the horizon, neon at a gas station, radio that changes with the state line.",
      "manifesto.body": "We gathered four regions, twelve natural points and a map where a route assembles in two clicks. Choose your places — the road does the rest.",
      "manifesto.cta": "Start with the regions",

      "stats.states": "states",
      "stats.area": "million km²",
      "stats.parks": "national parks",
      "stats.places": "natural points",

      "regions.kicker": "Geography",
      "regions.note": "Click a region to open it",
      "regions.title": "Four <em>Americas</em>",
      "regions.lead": "From the Pacific to the Atlantic — four different rhythms, waters and landscapes. Pick yours: ocean, lakes, prairies or skylines.",
      "regions.link": "See the places",
      "regions.west.count": "13 states",
      "regions.west.eyebrow": "Pacific coast and the Rockies",
      "regions.west.name": "West",
      "regions.west.text": "Glaciers run down to the ocean, canyons cut through desert, and the coastal highway ranks among the world's best drives.",
      "regions.west.sr": "Open the West region",
      "regions.south.count": "16 states",
      "regions.south.eyebrow": "Bayous, music and barbecue",
      "regions.south.name": "South",
      "regions.south.text": "New Orleans takes its time, Miami does art deco, and the food is unmistakable. Here evening starts in the afternoon.",
      "regions.south.sr": "Open the South region",
      "regions.midwest.count": "12 states",
      "regions.midwest.eyebrow": "Great lakes and open fields",
      "regions.midwest.name": "Midwest",
      "regions.midwest.text": "Fields to the horizon, Chicago architecture and a lake that behaves like a sea. The calmest and most underrated America.",
      "regions.midwest.sr": "Open the Midwest region",
      "regions.northeast.count": "9 states",
      "regions.northeast.eyebrow": "New York and maple autumn",
      "regions.northeast.name": "Northeast",
      "regions.northeast.text": "New York, Boston and New England autumn. Brick quarters, universities and the ocean two steps away — the most European part of the country.",
      "regions.northeast.sr": "Open the Northeast region",

      "map.kicker": "Route builder",
      "map.note": "Up to 6 stops",
      "map.title": "Build <em>your</em> route",
      "map.lead": "Click a point on the map — we'll count the days and assemble the backbone of the trip. Stops can be reordered freely.",
      "map.hint": "Click a point",
      "map.legend1": "In route",
      "map.legend2": "Available",
      "map.legend3": "Click a point to add it",
      "map.panel": "Route point details",
      "map.days": "Days",
      "map.season": "Season",
      "map.add": "Add to route",
      "map.remove": "Remove from route",

      "route.label": "Your route",
      "route.hint": "Up to 6 stops. Click a point to add it.",
      "route.list": "Selected stops",
      "route.email": "Your email",
      "route.emailPh": "email to receive the route",
      "route.submit": "Send",
      "route.note": "No spam. Just the route and useful links.",
      "route.empty": "Empty so far — pick some points on the map.",
      "route.summary": "stops · days",
      "route.max": "Limit of 6 stops reached. Remove one to add another.",
      "route.invalid": "Check the address — it looks like a typo.",
      "route.sent": "Done! The route is on its way to ",
      "route.pluralStops": "stops",
      "route.pluralDays": "days",

      "places.kicker": "Places",
      "places.note": "Click a card — the point appears on the map",
      "places.title": "A scale <em>you can't convey</em>",
      "places.lead": "Eight postcards worth seeing in person. Each one is a separate story about the country and its distances.",
      "places.tag1": "Canyon",
      "places.tag2": "Springs",
      "places.tag3": "Waterfall",
      "places.tag4": "Lake",
      "places.tag5": "Lake",
      "places.tag6": "River",
      "places.tag7": "Canyon",
      "places.tag8": "River",
      "places.p1": "Grand Canyon",
      "places.p1s": "Arizona · 1.8 bn years of rock layers",
      "places.p2": "Yellowstone",
      "places.p2s": "Wyoming · the world's first national park",
      "places.p3": "Yosemite",
      "places.p3s": "California · 739 metres of falling water",
      "places.p4": "Lake Superior",
      "places.p4s": "Michigan · 82,100 km² of fresh water",
      "places.p5": "Crater Lake",
      "places.p5s": "Oregon · the deepest lake in the USA",
      "places.p6": "Horseshoe Bend",
      "places.p6s": "Arizona · the Colorado in a rock ring",
      "places.p7": "Antelope Canyon",
      "places.p7s": "Arizona · light falls from above, not the side",
      "places.p8": "Zion",
      "places.p8s": "Utah · a canyon carved by water",

      "history.kicker": "History",
      "history.title": "Five dates that <em>changed everything</em>",
      "history.lead": "A short chronology of the country: from the signing of the Declaration to the first step on the Moon.",
      "history.h1": "Declaration of Independence",
      "history.h1t": "Thirteen colonies declare a new state.",
      "history.h2": "13th Amendment",
      "history.h2t": "Abolition is written into the Constitution after the Civil War.",
      "history.h3": "First flight",
      "history.h3t": "The Wright brothers lift off for 12 seconds and change the world.",
      "history.h4": "Apollo 11",
      "history.h4t": "Neil Armstrong takes the first step on the Moon.",
      "history.h5": "44th president",
      "history.h5t": "Barack Obama becomes the first Black president of the USA.",

      "culture.kicker": "Culture",
      "culture.title": "More than <em>places</em>",
      "culture.lead": "America exports stories, not landscapes. Film, music, sport and food — four ways to know the country before you arrive.",
      "culture.c1": "Film",
      "culture.c1t": "Since the 1910s Hollywood has set the world standard — from noir to blockbusters.",
      "culture.c2": "Music",
      "culture.c2t": "Jazz, blues, rock'n'roll and hip-hop were born here and spread worldwide.",
      "culture.c2tag": "New Orleans — the Bronx",
      "culture.c3": "Sport",
      "culture.c3t": "NFL, NBA, MLB and NHL: one Super Bowl pulls in over 100 million viewers.",
      "culture.c4": "Food",
      "culture.c4t": "Burgers, BBQ, food trucks and hundreds of regional kitchens — from Texas to Vermont.",
      "culture.c4tag": "50 states",

      "cta.kicker": "Everything else is up to you",
      "cta.title": "The next stop<br>is <em>yours.</em>",
      "cta.lead": "Assemble a route from the points on the map, or start from a ready-made eight-day option. The rest is up to the road.",
      "cta.btn1": "Build a route",
      "cta.btn2": "See the places",
      "cta.note": "50 states · 63 parks · one road",

      "footer.about": "A guide to the country where the road matters more than the destination. Demo project.",
      "footer.nav": "Footer navigation",
      "footer.sections": "Sections",
      "footer.places": "Natural places",
      "footer.about2": "About",
      "footer.manifesto": "Manifesto",
      "footer.rights": "All rights to inspiration are free.",
      "footer.credits": "Photos: Wikimedia Commons · Unsplash ✦ Made with attention to detail",

      "d.yosemite": "Yosemite",
      "d.grandcanyon": "Grand Canyon",
      "d.yellowstone": "Yellowstone",
      "d.superior": "Lake Superior",
      "d.horseshoe": "Horseshoe Bend"
    }
  };

  /* Destination data with bilingual fields */
  var DESTINATIONS = {
    yosemite: {
      x: 78.84, y: 259.13, img: "assets/waterfall.jpg",
      name: { ru: "Йосемити", en: "Yosemite" },
      meta: { ru: "Калифорния · Водопад", en: "California · Waterfall" },
      desc: {
        ru: "Гранитная долина и 739 метров падения воды. Деревянный путь ведёт к подножию водопада — это один из главных видов планеты.",
        en: "A granite valley and 739 metres of falling water. The boardwalk leads to the base of the falls — one of the great views on earth."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Май — октябрь", en: "May — October" },
      daysNum: 2
    },
    grandcanyon: {
      x: 197.8, y: 321.62, img: "assets/canyon.jpg",
      name: { ru: "Гранд-Каньон", en: "Grand Canyon" },
      meta: { ru: "Аризона · Каньон", en: "Arizona · Canyon" },
      desc: {
        ru: "1,8 млрд лет истории в слоях камня. Смотрите на закат со South Rim — это один из главных видов планеты.",
        en: "1.8 billion years of history in layers of rock. Watch the sunset from the South Rim — one of the great views on earth."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Апрель — июнь", en: "April — June" },
      daysNum: 2
    },
    zion: {
      x: 188.04, y: 293.15, img: "assets/zion.jpg",
      name: { ru: "Зион", en: "Zion" },
      meta: { ru: "Юта · Река", en: "Utah · River" },
      desc: {
        ru: "Красные стены каньона, выточенные рекой Вирджин. Мост Навахо — самая фотогеничная точка парка.",
        en: "Red canyon walls carved by the Virgin River. The Navajo Bridge is the park's most photogenic spot."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Апрель — октябрь", en: "April — October" },
      daysNum: 1
    },
    yellowstone: {
      x: 252.86, y: 144.57, img: "assets/yellowstone.jpg",
      name: { ru: "Йеллоустоун", en: "Yellowstone" },
      meta: { ru: "Вайоминг · Источники", en: "Wyoming · Springs" },
      desc: {
        ru: "Первый национальный парк мира: 400 гейзеров, 500 видов животных и 4 000 км² вулканической земли.",
        en: "The world's first national park: 400 geysers, 500 animal species and 4,000 km² of volcanic ground."
      },
      days: { ru: "3 дня", en: "3 days" },
      season: { ru: "Июнь — сентябрь", en: "June — September" },
      daysNum: 3
    },
    glacier: {
      x: 226.65, y: 43.77, img: "assets/glacier.jpg",
      name: { ru: "Глейсиер", en: "Glacier" },
      meta: { ru: "Монтана · Горы", en: "Montana · Mountains" },
      desc: {
        ru: "Сорок глетчеров спускаются по хребту к бирюзовой воде озера Макдональд. Это и есть настоящая Монтана.",
        en: "Forty glaciers descend along the divide to the turquoise water of Lake McDonald. This is the real Montana."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Июнь — сентябрь", en: "June — September" },
      daysNum: 2
    },
    rainier: {
      x: 96.25, y: 56.17, img: "assets/rainier.jpg",
      name: { ru: "Маунт-Рейниер", en: "Mount Rainier" },
      meta: { ru: "Вашингтон · Вулкан", en: "Washington · Volcano" },
      desc: {
        ru: "Вулкан высотой 4 392 метра отражается в озере Спраг. Тропа через поля грозы ведёт к вершине.",
        en: "A 4,392-metre volcano mirrored in Sprague Lake. The trail through thunder meadows leads to the summit."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Июль — сентябрь", en: "July — September" },
      daysNum: 1
    },
    craterlake: {
      x: 67.56, y: 137.15, img: "assets/crater.jpg",
      name: { ru: "Крейтер-Лейк", en: "Crater Lake" },
      meta: { ru: "Орегон · Озеро", en: "Oregon · Lake" },
      desc: {
        ru: "Самое глубокое озеро США — 594 метра в кальдере, которое осталось после извержения вулкана.",
        en: "The deepest lake in the USA — 594 metres inside a caldera left behind by a volcanic eruption."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Июль — сентябрь", en: "July — September" },
      daysNum: 1
    },
    superior: {
      x: 562.64, y: 108.27, img: "assets/superior.jpg",
      name: { ru: "Верхнее озеро", en: "Lake Superior" },
      meta: { ru: "Мичиган · Озеро", en: "Michigan · Lake" },
      desc: {
        ru: "Крупнейшее пресное озеро мира: 82 100 км², 300 метров глубины и холодная вода, которую зовут «пресным морем».",
        en: "The world's largest freshwater lake: 82,100 km², 300 metres deep, and cold water locals call a freshwater sea."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Июнь — сентябрь", en: "June — September" },
      daysNum: 2
    },
    niagara: {
      x: 750.58, y: 167.31, img: "assets/niagara.jpg",
      name: { ru: "Ниагара", en: "Niagara" },
      meta: { ru: "Нью-Йорк · Водопад", en: "New York · Waterfall" },
      desc: {
        ru: "Три тонны воды в секунду падают в Ниагарский водопад. Стоять рядом с краем — значит слышать грохот.",
        en: "Three tonnes of water per second plunge over Niagara Falls. Standing at the edge means hearing the roar."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Май — октябрь", en: "May — October" },
      daysNum: 1
    },
    acadia: {
      x: 910.17, y: 98.8, img: "assets/acadia.jpg",
      name: { ru: "Акадия", en: "Acadia" },
      meta: { ru: "Мэн · Океан", en: "Maine · Coast" },
      desc: {
        ru: "Скалы, лес и океан на одной территории. Первым в США национальный парк появился именно здесь.",
        en: "Cliffs, forest and ocean on one stretch of coast. The first national park in the USA was founded right here."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Сентябрь — октябрь", en: "September — October" },
      daysNum: 2
    },
    horseshoe: {
      x: 211.1, y: 306.57, img: "assets/horseshoe.jpg",
      name: { ru: "Подкова-Бенд", en: "Horseshoe Bend" },
      meta: { ru: "Аризона · Река", en: "Arizona · River" },
      desc: {
        ru: "Колорадо делает разворот на 180 градусов в скальном кольце. Вода здесь холоднее, чем кажется.",
        en: "The Colorado makes a 180-degree turn inside a stone ring. The water is colder than it looks."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Октябрь — апрель", en: "October — April" },
      daysNum: 1
    },
    monument: {
      x: 235.86, y: 307.71, img: "assets/monument.jpg",
      name: { ru: "Монумент-Вэлли", en: "Monument Valley" },
      meta: { ru: "Юта · Пустыня", en: "Utah · Desert" },
      desc: {
        ru: "Песчаные стены поднимаются на 300 метров над долиной. Здесь снимали «Форрест Гампа» и «Мальчика с вагончика».",
        en: "Sandstone walls rise 300 metres over the valley. Forrest Gump and The Lone Ranger were shot here."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Май — октябрь", en: "May — October" },
      daysNum: 1
    },
    bryce: {
      x: 202.63, y: 288.33, img: "assets/bryce.jpg",
      name: { ru: "Брайс-Каньон", en: "Bryce Canyon" },
      meta: { ru: "Юта · Хoodoo", en: "Utah · Hoodoos" },
      desc: {
        ru: "Тысячи оранжевых столбов высотой до 60 метров. Лучший свет — на рассвете в Inspiration Point.",
        en: "Thousands of orange spires reaching 60 metres. The best light is at sunrise from Inspiration Point."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Май — октябрь", en: "May — October" },
      daysNum: 1
    },
    antelope: {
      x: 213.38, y: 307.33, img: "assets/antelope.jpg",
      name: { ru: "Антилоп-Каньон", en: "Antelope Canyon" },
      meta: { ru: "Аризона · Каньон", en: "Arizona · Canyon" },
      desc: {
        ru: "Узкий каньон из песчаника, где свет падает сверху и рисует стены красным. Сюда пускают маленькими группами.",
        en: "A narrow sandstone slot where light falls from above and paints the walls red. Only small groups are allowed in."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Апрель — октябрь", en: "April — October" },
      daysNum: 1
    },
    joshua: {
      x: 115.72, y: 349.85, img: "assets/joshua.jpg",
      name: { ru: "Джошуа-Три", en: "Joshua Tree" },
      meta: { ru: "Калифорния · Пустыня", en: "California · Desert" },
      desc: {
        ru: "Гранитные юкки стоят в пустыне Мохаве уже 10 000 лет. Здесь снимали «Звёздных войн».",
        en: "Granite yucca trees have stood in the Mojave desert for 10,000 years. Star Wars was filmed here."
      },
      days: { ru: "1 день", en: "1 day" },
      season: { ru: "Октябрь — апрель", en: "October — April" },
      daysNum: 1
    },
    tahoe: {
      x: 78.08, y: 228.09, img: "assets/tahoe.jpg",
      name: { ru: "Озеро Тахо", en: "Lake Tahoe" },
      meta: { ru: "Калифорния · Озеро", en: "California · Lake" },
      desc: {
        ru: "Озеро на границе двух штатов: 501 метр глубины и вода, которая никогда не замерзает.",
        en: "A lake on the border of two states: 501 metres deep, with water that never freezes over."
      },
      days: { ru: "2 дня", en: "2 days" },
      season: { ru: "Июнь — сентябрь", en: "June — September" },
      daysNum: 2
    }
  };

  /* ==========================================================
     2. Language handling
     ========================================================== */

  var currentLang = "ru";

  function t(key) {
    var dict = I18N[currentLang] || I18N.ru;
    if (dict[key] != null) return dict[key];
    return I18N.ru[key] != null ? I18N.ru[key] : key;
  }

  function applyStaticTranslations() {
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      el.textContent = t(el.getAttribute("data-i18n"));
    });

    document.querySelectorAll("[data-i18n-html]").forEach(function (el) {
      el.innerHTML = t(el.getAttribute("data-i18n-html"));
    });

    document.querySelectorAll("[data-i18n-aria]").forEach(function (el) {
      el.setAttribute("aria-label", t(el.getAttribute("data-i18n-aria")));
    });

    document.querySelectorAll("[data-i18n-placeholder]").forEach(function (el) {
      el.setAttribute("placeholder", t(el.getAttribute("data-i18n-placeholder")));
    });
  }

  function setLanguage(lang, persist) {
    if (!I18N[lang]) return;
    currentLang = lang;
    document.documentElement.setAttribute("lang", lang);

    document.querySelectorAll(".lang__btn").forEach(function (btn) {
      var active = btn.getAttribute("data-lang") === lang;
      btn.classList.toggle("is-active", active);
      btn.setAttribute("aria-pressed", String(active));
    });

    applyStaticTranslations();
    renderRoute();
    updateDestPanel();

    if (persist) {
      try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) {}
    }
  }

  document.querySelectorAll(".lang__btn").forEach(function (btn) {
    btn.addEventListener("click", function () {
      setLanguage(btn.getAttribute("data-lang"), true);
    });
  });

  /* ==========================================================
     3. Nav / scroll
     ========================================================== */

  var nav = document.getElementById("nav");
  var progressBar = document.getElementById("progressBar");

  function onScroll() {
    var y = window.scrollY || document.documentElement.scrollTop;
    var max = document.documentElement.scrollHeight - window.innerHeight;
    var progress = max > 0 ? Math.min(y / max, 1) : 0;
    if (progressBar) progressBar.style.width = (progress * 100).toFixed(3) + "%";
    if (nav) nav.classList.toggle("is-scrolled", y > 30);
  }

  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  /* mobile menu */
  var burger = document.getElementById("burger");
  var navLinks = document.getElementById("navLinks");

  function setMenu(open) {
    if (!nav || !burger) return;
    nav.classList.toggle("is-open", open);
    burger.setAttribute("aria-expanded", String(open));
    document.body.style.overflow = open ? "hidden" : "";
  }

  if (burger) {
    burger.addEventListener("click", function () {
      setMenu(!nav.classList.contains("is-open"));
    });
  }

  if (navLinks) {
    navLinks.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () { setMenu(false); });
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") setMenu(false);
  });

  document.addEventListener("click", function (event) {
    if (!nav || !nav.classList.contains("is-open")) return;
    if (!nav.contains(event.target)) setMenu(false);
  });

  window.addEventListener("resize", function () {
    if (window.innerWidth > 880) setMenu(false);
  });

  /* ==========================================================
     4. Reveal on scroll
     ========================================================== */

  var revealItems = document.querySelectorAll("[data-reveal]");

  function revealNow(el) {
    el.classList.add("is-in");
  }

  if (reducedMotion || !("IntersectionObserver" in window)) {
    revealItems.forEach(revealNow);
  } else {
    var revealObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-in");
          revealObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1, rootMargin: "0px 0px -5% 0px" });

    revealItems.forEach(function (el) { revealObserver.observe(el); });

    /* Anything already on screen shows immediately — the observer alone can
       lag on first paint, which would leave the hero blank for a moment. */
    revealItems.forEach(function (el) {
      var rect = el.getBoundingClientRect();
      if (rect.top < window.innerHeight && rect.bottom > 0) {
        revealNow(el);
        revealObserver.unobserve(el);
      }
    });
  }

  /* ==========================================================
     5. Stat counters
     ========================================================== */

  var statNumbers = document.querySelectorAll(".stat__num");

  function formatStat(value, decimals) {
    if (decimals > 0) {
      return value.toFixed(decimals).replace(".", currentLang === "ru" ? "," : ".");
    }
    return String(Math.round(value));
  }

  function animateStat(el) {
    var target = parseFloat(el.dataset.count || "0");
    var decimals = parseInt(el.dataset.decimals || "0", 10);

    if (reducedMotion) {
      el.textContent = formatStat(target, decimals);
      return;
    }

    var duration = 1700;
    var start = performance.now();

    function tick(now) {
      var t = Math.min((now - start) / duration, 1);
      var eased = 1 - Math.pow(1 - t, 4);
      el.textContent = formatStat(target * eased, decimals);
      if (t < 1) requestAnimationFrame(tick);
    }

    requestAnimationFrame(tick);
  }

  if ("IntersectionObserver" in window && statNumbers.length) {
    var statObserver = new IntersectionObserver(function (entries, observer) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          animateStat(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    statNumbers.forEach(function (el) { statObserver.observe(el); });
  } else {
    statNumbers.forEach(function (el) {
      el.textContent = formatStat(parseFloat(el.dataset.count || "0"), parseInt(el.dataset.decimals || "0", 10));
    });
  }

  /* ==========================================================
     6. Regions accordion
     ========================================================== */

  var regions = document.querySelectorAll(".region");

  regions.forEach(function (region) {
    var toggle = region.querySelector(".region__toggle");
    if (!toggle) return;

    toggle.addEventListener("click", function () {
      var wasActive = region.classList.contains("is-active");

      regions.forEach(function (other) {
        other.classList.remove("is-active");
        var btn = other.querySelector(".region__toggle");
        if (btn) btn.setAttribute("aria-expanded", "false");
      });

      if (!wasActive) {
        region.classList.add("is-active");
        toggle.setAttribute("aria-expanded", "true");
      }
    });
  });

  /* ==========================================================
     7. Map pins
     ========================================================== */

  var pinsHost = document.getElementById("mapPins");
  var selected = [];
  var activeId = null;

  function buildPins() {
    if (!pinsHost) return;

    pinsHost.innerHTML = "";

    Object.keys(DESTINATIONS).forEach(function (id) {
      var dest = DESTINATIONS[id];
      var pin = document.createElement("button");
      pin.type = "button";
      pin.className = "map-pin";
      pin.setAttribute("data-dest", id);
      pin.setAttribute("aria-label", dest.name[currentLang]);
      pin.setAttribute("aria-pressed", "false");
      pin.style.left = (dest.x / 959 * 100).toFixed(3) + "%";
      pin.style.top = (dest.y / 593 * 100).toFixed(3) + "%";

      var tip = document.createElement("span");
      tip.className = "map-pin__tooltip";
      tip.textContent = dest.name[currentLang];
      pin.appendChild(tip);

      pin.addEventListener("click", function () {
        toggleDest(id);
      });

      pinsHost.appendChild(pin);
    });

    syncPins();
  }

  function syncPins() {
    document.querySelectorAll(".map-pin").forEach(function (pin) {
      var id = pin.getAttribute("data-dest");
      var isOn = selected.indexOf(id) !== -1;
      pin.classList.toggle("is-selected", isOn);
      pin.setAttribute("aria-pressed", String(isOn));
      var tip = pin.querySelector(".map-pin__tooltip");
      if (tip) tip.textContent = DESTINATIONS[id].name[currentLang];
    });
  }

  /* ==========================================================
     8. Destination panel
     ========================================================== */

  var destImg = document.getElementById("destImg");
  var destMeta = document.getElementById("destMeta");
  var destTitle = document.getElementById("destTitle");
  var destDesc = document.getElementById("destDesc");
  var destDays = document.getElementById("destDays");
  var destSeason = document.getElementById("destSeason");
  var destToggle = document.getElementById("destToggle");

  function updateDestPanel() {
    var id = activeId || "grandcanyon";
    var dest = DESTINATIONS[id];
    if (!dest) return;

    if (destImg) {
      destImg.src = dest.img;
      destImg.alt = dest.name[currentLang];
    }
    if (destMeta) destMeta.textContent = dest.meta[currentLang];
    if (destTitle) destTitle.textContent = dest.name[currentLang];
    if (destDesc) destDesc.textContent = dest.desc[currentLang];
    if (destDays) destDays.textContent = dest.days[currentLang];
    if (destSeason) destSeason.textContent = dest.season[currentLang];

    if (destToggle) {
      var on = selected.indexOf(id) !== -1;
      destToggle.classList.toggle("is-remove", on);
      destToggle.textContent = on ? t("map.remove") : t("map.add");
    }
  }

  function toggleDest(id) {
    activeId = id;
    var index = selected.indexOf(id);

    if (index === -1) {
      if (selected.length >= 6) {
        var hint = document.getElementById("routeHint");
        if (hint) {
          hint.textContent = t("route.max");
          hint.style.color = "var(--red-2)";
        }
        return;
      }
      selected.push(id);
    } else {
      selected.splice(index, 1);
    }

    syncPins();
    renderRoute();
    updateDestPanel();
  }

  if (destToggle) {
    destToggle.addEventListener("click", function () {
      if (activeId) toggleDest(activeId);
    });
  }

  /* ==========================================================
     9. Route list
     ========================================================== */

  var routeList = document.getElementById("routeList");
  var routeSummary = document.getElementById("routeSummary");
  var routeHint = document.getElementById("routeHint");

  function renderRoute() {
    if (!routeList) return;

    routeList.innerHTML = "";

    if (!selected.length) {
      var empty = document.createElement("li");
      empty.className = "route-list__empty";
      empty.textContent = t("route.empty");
      routeList.appendChild(empty);
    } else {
      selected.forEach(function (id, index) {
        var dest = DESTINATIONS[id];
        var li = document.createElement("li");
        li.className = "route-chip";

        var num = document.createElement("span");
        num.className = "route-chip__num";
        num.textContent = String(index + 1);
        li.appendChild(num);

        var label = document.createElement("span");
        label.textContent = dest.name[currentLang];
        li.appendChild(label);

        var x = document.createElement("button");
        x.type = "button";
        x.className = "route-chip__x";
        x.setAttribute("aria-label", "×");
        x.textContent = "×";
        x.addEventListener("click", function () {
          toggleDest(id);
        });
        li.appendChild(x);

        routeList.appendChild(li);
      });
    }

    var totalDays = selected.reduce(function (sum, id) {
      return sum + (DESTINATIONS[id].daysNum || 1);
    }, 0);

    if (routeSummary) {
      routeSummary.textContent = selected.length + " " + t("route.pluralStops") + " · " + totalDays + " " + t("route.pluralDays");
    }

    if (routeHint && !routeHint.dataset.custom) {
      routeHint.textContent = t("route.hint");
    }
  }

  /* ==========================================================
     10. Places -> map
     ========================================================== */

  document.querySelectorAll("[data-destination]").forEach(function (link) {
    link.addEventListener("click", function (event) {
      var id = link.getAttribute("data-destination");
      if (!DESTINATIONS[id]) return;

      event.preventDefault();
      activeId = id;
      updateDestPanel();

      if (selected.indexOf(id) === -1 && selected.length < 6) {
        selected.push(id);
        syncPins();
        renderRoute();
      }

      var mapSection = document.getElementById("map");
      if (mapSection) {
        mapSection.scrollIntoView({ behavior: reducedMotion ? "auto" : "smooth", block: "start" });
      }
    });
  });

  /* ==========================================================
     11. Route form
     ========================================================== */

  var form = document.getElementById("routeForm");
  var routeNote = document.getElementById("routeNote");

  if (form && routeNote) {
    var emailInput = form.querySelector('input[type="email"]');
    var noteDefault = routeNote.textContent;

    form.addEventListener("submit", function (event) {
      event.preventDefault();
      var value = (emailInput.value || "").trim();
      var valid = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value);

      form.classList.remove("is-invalid");
      routeNote.classList.remove("is-success");

      if (!valid) {
        void form.offsetWidth;
        form.classList.add("is-invalid");
        routeNote.textContent = t("route.invalid");
        emailInput.focus();
        return;
      }

      routeNote.textContent = t("route.sent") + value;
      routeNote.classList.add("is-success");
      form.reset();

      window.setTimeout(function () {
        routeNote.textContent = t("route.note");
        routeNote.classList.remove("is-success");
      }, 6000);
    });

    if (emailInput) {
      emailInput.addEventListener("input", function () {
        form.classList.remove("is-invalid");
        if (routeNote.classList.contains("is-success")) return;
        routeNote.textContent = t("route.note");
      });
    }
  }

  /* ==========================================================
     12. Scroll spy + misc
     ========================================================== */

  var spyLinks = Array.from(document.querySelectorAll('.nav__links a[href^="#"]'));

  if (spyLinks.length && "IntersectionObserver" in window) {
    var sections = spyLinks
      .map(function (link) { return document.querySelector(link.getAttribute("href")); })
      .filter(Boolean);

    var spyObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        spyLinks.forEach(function (link) {
          link.classList.toggle("is-active", link.getAttribute("href") === "#" + entry.target.id);
        });
      });
    }, { rootMargin: "-45% 0px -50% 0px", threshold: 0 });

    sections.forEach(function (section) { spyObserver.observe(section); });
  }

  var year = document.getElementById("year");
  if (year) year.textContent = String(new Date().getFullYear());

  /* ==========================================================
     13. Init
     ========================================================== */

  buildPins();

  var stored = null;
  try { stored = localStorage.getItem(STORAGE_KEY); } catch (e) {}
  var browserLang = (navigator.language || "ru").toLowerCase().indexOf("en") === 0 ? "en" : "ru";

  setLanguage(stored || browserLang, false);

  if (stored === null) {
    try { localStorage.setItem(STORAGE_KEY, currentLang); } catch (e) {}
  }
})();
