/obj/item/clothing/suit/roguetown/armor/gambeson/steward
	name = "steward tailcoat"
	desc = "A thick, pristine leather tailcoat adorned with polished bronze buttons."
	sleeved = 'modular_twilight_axis/icons/roguetown/clothing/special/onmob/noble.dmi'
	icon_state = "stewardtailcoat"
	item_state = "stewardtailcoat"
	icon = 'modular_twilight_axis/icons/roguetown/clothing/special/noble.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/roguetown/clothing/special/onmob/noble.dmi'

/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/baotha
	name = "маскарад"
	desc = "извивающееся тряпьё, сотканное из изуродованных человеческих лиц, пребывающих в постоянной агонии, переплетённой с наркотическим экстазом. Говорят, прошлый владелец этого пердмета пропал, но вот куда?.. Да и кто это говорит.."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon = 'modular_twilight/icons/roguetown/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilight/icons/roguetown/clothing/onmob/shirts.dmi'
	icon_state = "skinrobe"
	item_state = "skinrobe"
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	salvage_result = /obj/item/reagent_containers/lux
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE + 200
	armor = ARMOR_BRIGANDINE
	auto_repair_mode = TRUE
	relative_repair_interval = 15 SECONDS
	interrupt_damount = 15
	var/realname
	var/realdesc
	var/realstate
	var/realicon
	var/realmob

/obj/item/clothing/suit/roguetown/shirt/baotha/Initialize()
	.=..()
	realname = name
	realdesc = desc
	realstate = icon_state
	realicon = icon
	realmob = mob_overlay_icon

/obj/item/clothing/suit/roguetown/shirt/baotha/examine(var/mob/living/carbon/human/user, var/obj/item/clothing/neck/roguetown/psicross/blood/i)
	. = ..()
	if(user.patron.type == /datum/patron/inhumen/baotha)
		desc = realdesc + span_love("Это существо является малым даром моего патрона. При желании я могу заставить его принять любой необходимый мне вид.")

/obj/item/clothing/suit/roguetown/shirt/baotha/attack_right(var/mob/living/carbon/human/user)
	if(user.patron.type == /datum/patron/inhumen/baotha)
		var/mimicry = list("Рубаха", "Церемониальные шелка", "Тряпье", "Туника", "Платье", "Платье-сорочка", "Бархатное платье", "Дворянское платье", "Откровенное платье", "Рубаха-паутинка", "Элегантный наряд", "Топик", "Элегантная туника", "Отмена")
		var/mimicry_choise = input("Варианты:", "Маскировка") as anything in mimicry
		switch(mimicry_choise)
			if("Рубаха")
				name = "рубаха"
				desc = ""
				icon_state = "undershirt"
				mimic()
			if("Церемониальные шелка")
				name = "церемониальные шелка"
				desc = ""
				icon_state = "puritan_shirt"
				mimic()
			if("Тряпье")
				name = "тряпье"
				desc = "Лучше, чем совсем в наготе? Вам судить."
				icon_state = "rags"
				mimic()
			if("Туника")
				name = "туника"
				desc = "Длинная рубаха для мужчин и женщин."
				icon_state = "tunic"
				mimic()
			if("Платье")
				name = "платье"
				desc = "Простое платье, которое встречается и у сельских девушек, и у городских дам."
				icon_state = "dress"
				mimic()
			if("Платье-сорочка")
				name = "платье-сорочка"
				desc = "Удобное и элегантное платье, предоставляющее стиль и комфорт для повседневного ношения."
				icon_state = "silkdress"
				mimic()
			if("Бархатное платье")
				name = "бархатное платье"
				desc = "Платье, сшитое из тончайшего бархата, достойное особы высокого положения."
				icon_state = "velvetdress"
				mimic()
			if("Дворянское платье")
				name = "дворянское платье"
				desc = "Отличное платье, подходящее для человека высокого положения"
				icon_state = "nobledress"
				mimic()
			if("Откровенное платье")
				name = "откровенное платье"
				desc = "Очень откровенное платье из мягкой и дышащей ткани. Искусная и очень кропотливая работа опытной швеи. Стоп, а оно вообще хоть что-нибудь прикрывает?"
				icon_state = "sexydress"
				mimic()
			if("Рубаха-паутинка")
				name = "рубаха-паутинка"
				desc = "Экзотический шелк, тонко вплетенный в... это? С таким же успехом можно носить паутину. Должно быть, она очень легкая и удобная?"
				icon_state = "webs"
				mimic()
			if("Элегантный наряд")
				name = "элегантный наряд"
				desc = "Модное сочетание туники и пальто. Как элегантно."
				icon_state = "noblecoat"
				mimic()
			if("Топик")
				name = "топик"
				desc = "Туника, обнажающая шею и большую часть плеч. Плечи?! Какой скандал..."
				icon_state = "lowcut"
				mimic()
			if("Элегантная туника")
				name = "элегантная туника"
				desc = "Рубашка на пуговицах из тонкого шелка, декорированная жабо и манжетами."
				icon_state = "fancyshirt"
			if("Экзотичный шелковый топик")
				name = "экзотичный шелковый топик"
				desc = "Причудливые шелка с золотым шитьем едва способны скрыть то немногое, что они прикрывают."
				icon_state = "exoticsilkbra"
			if("Отмена")
				name = realname
				desc = realdesc
				icon = realicon
				icon_state = realstate
				mob_overlay_icon = realmob
		playsound(user, pick('sound/magic/magic_nulled.ogg'), 20, TRUE)

/obj/item/clothing/suit/roguetown/shirt/baotha/proc/mimic()
	icon = 'icons/roguetown/clothing/shirts.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/shirts.dmi'
