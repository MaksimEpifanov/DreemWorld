const planets = [
 {id:'fishing',name:'Рыбалка',icon:'🎣',color:'#36caff',members:'12 842',desc:'Природа, трофеи, эмоции',story:'Улов дня',art:'🐟',topics:[['🎣','Спиннинг','4 321 участник'],['🎈','Поплавочная ловля','3 874 участника'],['🧺','Фидер','2 963 участника'],['🐟','Карповая ловля','2 421 участник'],['❄️','Зимняя рыбалка','1 872 участника'],['🌊','Морская рыбалка','1 543 участника'],['🪱','Наживки и снасти','1 216 участников'],['🗺️','Места и водоёмы','980 участников']]},
 {id:'travel',name:'Путешествия',icon:'✈️',color:'#4daeff',members:'18 421',desc:'Новые страны, маршруты, впечатления',story:'Маршрут недели',art:'🏔️',topics:[['🧭','Самостоятельные поездки','5 120 участников'],['🏕️','Походы и кемпинг','3 840 участников'],['🏖️','Море и пляжи','3 421 участник'],['🚆','Путешествия на поезде','1 280 участников']]},
 {id:'psychology',name:'Психология',icon:'🧠',color:'#a477ff',members:'15 276',desc:'Понимание себя и других',story:'Тема для обсуждения',art:'💭',topics:[['💬','Общение и отношения','4 120 участников'],['🌱','Саморазвитие','3 890 участников'],['🧘','Осознанность','2 240 участников'],['❤️','Эмоции','1 930 участников']]},
 {id:'music',name:'Музыка',icon:'🎵',color:'#ff4eae',members:'27 931',desc:'Любимые треки, артисты, новинки',story:'Что слушают сегодня',art:'🎧',topics:[['🎸','Рок','5 230 участников'],['🎤','Поп-музыка','4 980 участников'],['🎛️','Электронная музыка','3 140 участников'],['🎹','Инструментальная','1 620 участников']]},
 {id:'cinema',name:'Кино',icon:'🎬',color:'#ff7a55',members:'21 654',desc:'Фильмы, сериалы, обсуждения',story:'Что посмотреть вечером',art:'🍿',topics:[['🎞️','Классика кино','3 120 участников'],['🚀','Фантастика','4 820 участников'],['😂','Комедии','2 760 участников'],['📺','Сериалы','5 410 участников']]},
 {id:'books',name:'Книги',icon:'📚',color:'#67d9ff',members:'16 203',desc:'Истории, идеи и новые миры',story:'Книга месяца',art:'📖',topics:[['🐉','Фэнтези','3 120 участников'],['🕵️','Детективы','2 640 участников'],['🧠','Научпоп','2 180 участников'],['✍️','Писательский клуб','980 участников']]},
 {id:'sport',name:'Спорт',icon:'⚽',color:'#73e5a1',members:'14 892',desc:'Движение, цели, команда',story:'Цель недели',art:'🏆',topics:[['🏋️','Фитнес','4 620 участников'],['🏃','Бег','2 180 участников'],['🚴','Велоспорт','1 440 участников'],['⚽','Командные виды','3 560 участников']]},
 {id:'food',name:'Еда',icon:'🍜',color:'#ffc45f',members:'14 382',desc:'Рецепты, вкусы, гастрономия',story:'Рецепт сообщества',art:'🍲',topics:[['🥗','Полезная еда','2 840 участников'],['🍰','Выпечка и десерты','2 420 участников'],['🔥','Гриль и барбекю','1 830 участников'],['🌍','Кухни мира','3 150 участников']]},
 {id:'nature',name:'Природа',icon:'🌿',color:'#39e6b1',members:'11 948',desc:'Горы, леса, животные, экотуризм',story:'Красота рядом',art:'🌲',topics:[['🏔️','Горы','2 920 участников'],['🌲','Леса и походы','2 440 участников'],['🐦','Наблюдение за птицами','980 участников'],['♻️','Экология','1 760 участников']]},
 {id:'games',name:'Игры',icon:'🎮',color:'#9a68ff',members:'19 203',desc:'Обсуждения, новинки, гайды',story:'Во что играем',art:'🕹️',topics:[['🖥️','Компьютерные игры','5 620 участников'],['🎮','Консоли','3 880 участников'],['📱','Мобильные игры','2 760 участников'],['🧙','RPG и приключения','2 320 участников']]},
 {id:'art',name:'Искусство',icon:'🎨',color:'#ff6d9e',members:'8 917',desc:'Творчество, вдохновение, идеи',story:'Работа недели',art:'🖼️',topics:[['🖌️','Рисование','2 420 участников'],['📷','Фотография','1 960 участников'],['🧵','Рукоделие','1 180 участников'],['🏛️','Музеи и выставки','980 участников']]},
 {id:'reading',name:'Чтение',icon:'📖',color:'#d5c27a',members:'10 542',desc:'Читай, обсуждай, открывай новое',story:'Читаем вместе',art:'📚',topics:[['☕','Книжные встречи','1 320 участников'],['📚','Челленджи чтения','2 180 участников'],['💬','Книжные клубы','2 940 участников'],['📝','Цитаты и заметки','1 240 участников']]},
 {id:'technology',name:'Технологии',icon:'⚙️',color:'#49d8ff',members:'9 372',desc:'Идеи, устройства и будущее',story:'Технология недели',art:'🤖',topics:[['🤖','Искусственный интеллект','3 120 участников'],['💻','Программирование','2 480 участников'],['📱','Гаджеты','1 840 участников'],['🛠️','DIY и электроника','980 участников']]},
 {id:'animals',name:'Животные',icon:'🐾',color:'#a6e879',members:'12 398',desc:'Питомцы, забота и дикая природа',story:'История питомца',art:'🐕',topics:[['🐕','Собаки','4 220 участников'],['🐈','Кошки','4 980 участников'],['🐴','Лошади','820 участников'],['🦜','Птицы','740 участников']]},
 {id:'gardening',name:'Сад и огород',icon:'🌱',color:'#65e5a1',members:'6 421',desc:'Выращивай, ухаживай, делись опытом',story:'Что посадить сейчас',art:'🪴',topics:[['🍅','Овощи','2 180 участников'],['🌷','Цветы','1 420 участников'],['🌳','Садовые деревья','980 участников'],['🪴','Комнатные растения','1 320 участников']]},
 {id:'volunteering',name:'Волонтёрство',icon:'🤝',color:'#ff7caa',members:'5 731',desc:'Помощь, добрые дела, люди',story:'Добро недели',art:'💚',topics:[['🐾','Помощь животным','1 620 участников'],['🌳','Экология','1 180 участников'],['🫶','Помощь людям','2 040 участников'],['📦','Сборы и инициативы','890 участников']]},
 {id:'finance',name:'Финансы',icon:'🪙',color:'#ffc85e',members:'7 654',desc:'Бюджет, цели и финансовая грамотность',story:'Финансовая привычка',art:'💡',topics:[['📊','Личный бюджет','2 640 участников'],['🎯','Финансовые цели','1 540 участников'],['💼','Карьера','1 820 участников'],['🧾','Экономия','1 220 участников']]},
 {id:'esoteric',name:'Эзотерика',icon:'✴️',color:'#b38aff',members:'8 423',desc:'Символы, практики и загадки',story:'Вопрос недели',art:'🌙',topics:[['🌙','Астрология','3 120 участников'],['🃏','Таро','2 640 участников'],['🧘','Медитации','1 480 участников'],['🔮','Символы и традиции','980 участников']]},
 {id:'cars',name:'Автомобили',icon:'🚘',color:'#ff9a55',members:'13 740',desc:'Машины, дороги, обслуживание',story:'История из дороги',art:'🏎️',topics:[['🏁','Автоспорт','2 980 участников'],['🔧','Ремонт и обслуживание','3 120 участников'],['🚙','Внедорожники','1 820 участников'],['⚡','Электромобили','1 640 участников']]},
 {id:'volleyball',name:'Общение',icon:'💬',color:'#54dfff',members:'24 105',desc:'Знакомства, разговоры, дружба',story:'Тема для знакомства',art:'👋',topics:[['☕','Разговоры по душам','4 120 участников'],['🌍','Языковая практика','2 420 участников'],['🎲','Игры и встречи','2 180 участников'],['💞','Новые знакомства','5 340 участников']]},
 {id:'science',name:'Наука',icon:'🔭',color:'#75a6ff',members:'6 890',desc:'Вопросы, открытия и эксперименты',story:'Открытие недели',art:'🧪',topics:[['🌌','Космос','2 140 участников'],['🧬','Биология','980 участников'],['⚛️','Физика','1 120 участников'],['🦴','История Земли','760 участников']]},
 {id:'craft',name:'Ремесло',icon:'🛠️',color:'#ffb36b',members:'4 980',desc:'Создавай вещи своими руками',story:'Сделано участником',art:'🪚',topics:[['🪵','Работа с деревом','1 120 участников'],['🧶','Вязание','1 480 участников'],['🏺','Керамика','740 участников'],['🔨','Мастерская','920 участников']]}
];

const layer = document.getElementById('planetLayer');
const galaxy = document.getElementById('galaxy');
const modal = document.getElementById('modalBackdrop');
const toast = document.getElementById('toast');
let toastTimer;
let activePlanet = planets[0];
let paused = false;

function showToast(message){toast.textContent=message;toast.classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>toast.classList.remove('show'),2600)}
function renderPlanets(){
  layer.innerHTML='';
  const w=galaxy.clientWidth, h=galaxy.clientHeight;
  const mobile=window.innerWidth<=800;
  const rx=Math.min(w*.44, mobile?w*.43:470);
  const ry=Math.min(h*.39, mobile?h*.38:250);
  planets.forEach((p,i)=>{
    const el=document.createElement('button');
    el.className='planet';el.type='button';el.dataset.name=p.name.toLowerCase();el.style.setProperty('--planet-color',p.color);
    el.innerHTML=`<span class="planet-ball">${p.icon}</span><span class="planet-name">${p.name}</span><span class="planet-count">${p.members}</span>`;
    el.setAttribute('aria-label',`Открыть планету ${p.name}`);
    // Разводим планеты по эллиптическим орбитам, чтобы подписи не сливались.
    const ring=i%6, pos=Math.floor(i/6);
    const angle=(i/planets.length)*Math.PI*2 + (ring%2)*.13;
    const ringFactor=.48 + ring*.105;
    const x=w/2 + Math.cos(angle)*rx*ringFactor;
    const y=h*.48 + Math.sin(angle)*ry*(.55+ring*.09) + (pos%2?8:-8);
    el.style.left=`${Math.max(34,Math.min(w-34,x))}px`;
    el.style.top=`${Math.max(56,Math.min(h-45,y))}px`;
    el.style.animationDelay=`-${(i%7)*.43}s`;
    el.addEventListener('click',()=>openPlanet(p));
    layer.appendChild(el);
  });
}
function openPlanet(p){
  activePlanet=p;
  document.getElementById('modalIcon').textContent=p.icon;
  document.getElementById('modalIcon').style.borderColor=p.color;
  document.getElementById('modalIcon').style.boxShadow=`0 0 30px ${p.color}77`;
  document.getElementById('modalTitle').textContent=p.name;
  document.getElementById('modalTitle').style.color=p.color;
  document.getElementById('modalSubtitle').textContent=p.desc;
  document.getElementById('modalMembers').textContent=`● ${p.members} участников · сообщество открыто`;
  document.getElementById('storyTitle').textContent=p.story;
  document.getElementById('storyArt').textContent=p.art;
  document.getElementById('storyArt').style.background=`radial-gradient(circle at 50% 40%,${p.color}77,#08152f 72%)`;
  const grid=document.getElementById('subtopicGrid');grid.innerHTML='';
  p.topics.forEach(([icon,name,count])=>{
    const card=document.createElement('button');card.className='subtopic';card.innerHTML=`<span>${icon}</span><b>${name}</b><small>${count}</small>`;
    card.addEventListener('click',()=>showToast(`Раздел «${name}» выбран — здесь будет его содержимое.`));grid.appendChild(card);
  });
  document.getElementById('storyText').textContent=`Общайся с участниками «${p.name}», делись опытом, задавай вопросы и открывай новые стороны своего увлечения.`;
  document.getElementById('subsectionsHeading').textContent=`Направления: ${p.name}`;
  document.querySelectorAll('.modal-tabs button').forEach((b,i)=>b.classList.toggle('selected',i===0));
  modal.hidden=false;document.body.style.overflow='hidden';document.getElementById('closeModal').focus();
}
function closeModal(){modal.hidden=true;document.body.style.overflow=''}
document.getElementById('closeModal').addEventListener('click',closeModal);
modal.addEventListener('click',e=>{if(e.target===modal)closeModal()});
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&!modal.hidden)closeModal()});
document.getElementById('planetSearch').addEventListener('input',e=>{
  const q=e.target.value.trim().toLocaleLowerCase('ru');
  document.querySelectorAll('.planet').forEach(el=>el.classList.toggle('hidden',q&&!el.dataset.name.includes(q)));
  if(q){const match=planets.find(p=>p.name.toLocaleLowerCase('ru').includes(q));if(match&&e.target.value.trim().toLocaleLowerCase('ru')===match.name.toLocaleLowerCase('ru')){/* оставить выбор за пользователем */}}
});
document.getElementById('randomPlanet').addEventListener('click',()=>openPlanet(planets[Math.floor(Math.random()*planets.length)]));
document.getElementById('sunButton').addEventListener('click',()=>showToast('Добро пожаловать в центр галактики DreemWorld!'));
document.getElementById('joinCommunity').addEventListener('click',()=>showToast(`Ты выбрал(а) сообщество «${activePlanet.name}». Подключение пользователей добавим позже.`));
document.querySelectorAll('[data-nav]').forEach(b=>b.addEventListener('click',()=>{
  document.querySelectorAll('[data-nav]').forEach(x=>x.classList.remove('active'));b.classList.add('active');
  if(b.dataset.nav!=='Планеты')showToast(`Раздел «${b.dataset.nav}» — макет для следующего этапа.`);
}));
document.querySelectorAll('[data-open]').forEach(b=>b.addEventListener('click',()=>showToast(`Раздел «${b.dataset.open}» — макет для следующего этапа.`)));
document.querySelectorAll('[data-tab]').forEach(b=>b.addEventListener('click',()=>{
  document.querySelectorAll('.modal-tabs button').forEach(x=>x.classList.remove('selected'));b.classList.add('selected');
  showToast(`Раздел «${b.dataset.tab}» выбран. Его наполнение можно подключить следующим этапом.`);
}));
window.addEventListener('resize',renderPlanets);
renderPlanets();
