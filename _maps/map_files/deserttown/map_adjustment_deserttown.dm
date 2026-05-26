/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/template/deserttown
	map_file_name = "deserttown.dmm"
	realm_name = "Al-Ashur"
	// BEGIN DESERT TOWN CONTRACTS (Rollback by removing this list)
	threat_regions = list(
		THREAT_REGION_DESERT_NEAR,
		THREAT_REGION_DESERT_DEEP
	)
	// END DESERT TOWN CONTRACTS
	realm_type = "Sultanate"
	realm_type_short = "Sultanate"
	slot_adjust = list(
		// /datum/job/roguetown/mercenary = 7, //haha fuck you one less slot!!
		// /datum/job/roguetown/apothecary = 1, //remodelled the building for more room
		/datum/job/roguetown/gnoll = 3,//hyenas just belong here!
	)
	title_adjust = list(
		/datum/job/roguetown/marshal = list(display_title = "Mushir", f_title = "Mushira"),
		/datum/job/roguetown/prince = list(display_title = "Amir", f_title = "Amira"),
		/datum/job/roguetown/priest =  list(display_title = "High Priest", f_title = "High Priestess"),
		/datum/job/roguetown/clerk = list(display_title = "Katib", f_title = "Katiba"),
		/datum/job/roguetown/squire = list(display_title = "Radif", f_title = "Radifah"),
		/datum/job/roguetown/physician = list(display_title = "Palace Physician"),
		/datum/job/roguetown/villager = list(display_title = "Villager"),
		/datum/job/roguetown/magician = list(display_title = "Palace Magician"),
		/datum/job/roguetown/pilgrim = list(display_title = "Nomad"),
	)
	tutorial_adjust = list(
		/datum/job/roguetown/marshal = "Зибантия никогда не была спокойным местом, всегда находились пустынники что решили развязать войну за торговые маршруты. Однако ситуация значительно ухудшилась после сумеречной войны. Вы - Мушир, главнокомандующий воинства Султана. В вашем распоряжении находятся катафракты, янычары и азебы - к последним вы всегда относились настороженно, какой верности можно ожидать от рабов?",
		/datum/job/roguetown/physician = "Вы личный лекарь Султана, который лично избрал вас для такого ответственного занятия. В вашем распоряжении значительные интеллектуальные труды всего востока - не посмейте же посрамить право называться лекарем самого Султана!",
		/datum/job/roguetown/magician = "Твой путь это священный обет, посвященный покорению искусства арканы и неутолимой жажды познания. \
        Ты обязан своей жизнью Султану, ибо лишь его щедрые маммоны позволили тебе продолжать изыскания в эти суровые времена. \
        Взамен ты не раз доказывал свою верность престолу, служа справедливым кади его величества.",
		/datum/job/roguetown/squire = "Ты - Радиф, младший соратник и верный оруженосец на службе у закованного в сталь Фариса. \
        Твой удел - нести щит своего мастера, чистить его пластинчатый доспех и ухаживать за его боевым сайгаком в прохладе оазисов. \
        Пусть знатная хасса и шейхи во дворцах едва замечают твое присутствие, на поле боя ты — его щит, его тень и его самый верный клинок. \
        Учись прилежно, стойко терпи суровость тренировок в песках фронтира, и однажды, пролив достаточно вражеской крови в грядущих войнах славы, \
        ты заслужишь право омыть свой лик золотом и самому наречься истинным Фарисом Султаната.",
		/datum/job/roguetown/prince = "Ты никогда не ведал, что такое зимняя стужа, не знал терзаний голода и, конечно, не трудился ни дня в своей жизни. \
        Ты волен, словно птица в небесах, и можешь предаваться любым порокам, покуда твои родители восседают на престоле. \
        Но однажды тебе придется повзрослеть, и тогда настанет день, когда твоя беспечность обойдется тебе куда дороже, чем несколько растраченных маммонов.",
		/datum/job/roguetown/clerk = "Писец-катиб, сборщик податей, благословенный глупец. Ты помогаешь султанскому Визирю во всем, что ему потребуется, и берешь на себя его бремя, когда тот отсутствует. Пусть ты и не принадлежишь к благородной хассе, это далеко не худшая доля. Вот только есть одна оговорка: если султанские маммоны будут утеряны или бесследно исчезнут, знатный вельможа всегда сможет откупиться и избежать рабских колодок. А ты? Эх... Ну, говорят, в Гизе в это время года на редкость красиво.",
		/datum/job/roguetown/shophand = "Ты трудишься в величайшей лавке Аль-Ашура по воле купца, который приковал тебя к этой тягостной рутине. \
        Раскладывать товары по полкам и вести учет для своего господина — занятие монотонное и отупляющее, но у тебя хотя бы есть кров \
        и сытая жизнь в тепле. Быть может, со временем тебе удастся стать кем-то большим, нежели просто слугой.",
	)
	/// Jobs that this map won't use
	blacklist = list(
		/datum/job/roguetown/adventurer/courtagent,
		// /datum/job/roguetown/adventurer//Adventurers (Could rename which are 'foreigners but who cares)'
		// /datum/job/roguetown/wretch,
		// /datum/job/roguetown/bandit,
		// /datum/job/roguetown/pilgrim, //I have Nomads in the dtvillager.dm //actually this makes sense as a non-zyb foreigner!
		// /datum/job/roguetown/trader,
		// /datum/job/roguetown/assassin,

		/datum/job/roguetown/lord,// sultan//moved to an if-map-then-outfit
		/datum/job/roguetown/knight,// cataphract
		/datum/job/roguetown/hand,// vizier
		// /datum/job/roguetown/suitor,
		/datum/job/roguetown/steward, //gonna try merging this role with Vizier EDIT: with the higher pop we can afford to keep em separate now
		// /datum/job/roguetown/consort,
		// /datum/job/roguetown/captain,
		// /datum/job/roguetown/bailiff,

		//church. Fine as is

		/datum/job/roguetown/seneschal,// headslave
		/datum/job/roguetown/councillor,// sheikh
		// /datum/job/roguetown/magician,// moved to an if-map-then-outfit statement in the baseblock
		/datum/job/roguetown/jester, //are jesters really a desert thing? Maybe ought to push people into playing slaves instead..?
		// /datum/job/roguetown/physician,

		/datum/job/roguetown/manorguard,//  mamaluk
		// /datum/job/roguetown/rookie,//  mamalukrookie!
	//	/datum/job/roguetown/guardsman,//  mamaluk
		/datum/job/roguetown/vanguard,//  jannissary
		/datum/job/roguetown/warden,//  jannissary
		/datum/job/roguetown/dungeoneer,// Slavemaster. Okay it's a bit different but it's nice to cut bloat y'know!
		/datum/job/roguetown/sergeant,//janissary sergeant
		// /datum/job/roguetown/squire,
		// /datum/job/roguetown/veteran,
	//	/datum/job/roguetown/watchcaptain,
	//	/datum/job/roguetown/wardenmaster,

		//trader (probably fine to keep as it is)

		/datum/job/roguetown/crier, //would be fun to integrate in with the arena? Reimplement when building is added
		// /datum/job/roguetown/archivist,
		// /datum/job/roguetown/barkeep,
		// /datum/job/roguetown/guildmaster,
		// /datum/job/roguetown/guildsman,
		// /datum/job/roguetown/merchant,
		// /datum/job/roguetown/niteman,
		// /datum/job/roguetown/tailor,
		// /datum/job/roguetown/elder,
		
		// /datum/job/roguetown/villager,
		// /datum/job/roguetown/farmer,
		// /datum/job/roguetown/prisonerb,
		// /datum/job/roguetown/prisonerr,
		// /datum/job/roguetown/hostage,
		// /datum/job/roguetown/nightmaiden, // Current ones are probably fine?
		// /datum/job/roguetown/cook,
	//	/datum/job/roguetown/knavewench, //maybe after expanding the tavern for it
		// /datum/job/roguetown/lunatic,


		//inquisition. Fine as is

		//mercenaries. Fine as is
		
		/datum/job/roguetown/servant,//slave
		// /datum/job/roguetown/apothecary,
		// /datum/job/roguetown/churchling,
		// /datum/job/roguetown/clerk, //gonna try merging this with Sheikh - EDIT with higher pop we can afford to keep this role around
		// /datum/job/roguetown/wapprentice,
		// /datum/job/roguetown/orphan,
		// /datum/job/roguetown/prince,//dtprince
		// /datum/job/roguetown/shophand,
		
	//	/datum/job/roguetown/tribalchieftain,
	//	/datum/job/roguetown/tribalshaman,
	//	/datum/job/roguetown/tribalguard,
	//	/datum/job/roguetown/tribalrabble,
	//	/datum/job/roguetown/tribalvillager,

		/datum/job/roguetown/royal_guard, 
		/datum/job/roguetown/sheriff, 
		/datum/job/roguetown/town_watch, 
		/datum/job/roguetown/vanguard, 
		/datum/job/roguetown/courtphysician, 
		/datum/job/roguetown/knight_enigma, 
		/datum/job/roguetown/royal_sergeant, 
		/datum/job/roguetown/overseer, 
		/datum/job/roguetown/dungeoneer,
		/datum/job/roguetown/mayor,
		/datum/job/roguetown/bailiff,
	)


/*list to blacklist for other maps (update as new replacements are added)
		/datum/job/roguetown/cataphract,
		/datum/job/roguetown/vizier,
		/datum/job/roguetown/headslave,
		/datum/job/roguetown/sheikh,
		/datum/job/roguetown/janissary,
		/datum/job/roguetown/janissarysergeant,
		/datum/job/roguetown/azeb,
		/datum/job/roguetown/azebagha,
		/datum/job/roguetown/slavemaster,
		/datum/job/roguetown/dtslave, */
