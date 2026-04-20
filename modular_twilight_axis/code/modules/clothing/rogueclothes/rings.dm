/obj/item/clothing/ring/baotha
	name = "змеиное кольцо"
	desc = "Кольцо выполненное из стали с применением позолоты, в виде искуссно воссозданной змеи. Качество работы настолько велико, что вам кажется будто глаза-самоцветы ползучей следят за вами."
	icon_state = "baotha_knife"
	icon = 'modular_twilight_axis/icons/roguetown/weapons/32.dmi'
	max_integrity = 300
	var/realname
	var/realdesc
	var/realstate
	var/realicon

	grid_width = 32
	grid_height = 32

/obj/item/clothing/ring/baotha/Initialize()
	.=..()
	realname = name
	realdesc = desc
	realstate = icon_state
	realicon = icon

/obj/item/clothing/ring/baotha/examine(var/mob/living/carbon/human/user, var/obj/item/clothing/neck/roguetown/psicross/blood/i)
	. = ..()
	if(user.patron.type == /datum/patron/inhumen/baotha)
		desc = realdesc + span_love(" Это существо является малым даром моего патрона. При желании я могу распрямить его в небольшой смертоносный кинжал.")

/obj/item/clothing/ring/baotha/attack_right(var/mob/living/carbon/human/user)
	if(user.patron.type == /datum/patron/inhumen/baotha)
		var/mimicry = list("Золото", "Серебро", "Медь", "Отмена")
		var/mimicry_choise = input("Варианты:", "Маскировка") as anything in mimicry
		switch(mimicry_choise)
			if("Золото")
				name = "золотое кольцо"
				icon_state = "ring_g"
			if("Серебро")
				name = "серебряное кольцо"
				icon_state = "ring_s"
			if("Медь")
				name = "медное кольцо"
				icon_state = "ring_c"
			if("Отмена")
				name = realname
				desc = realdesc
				icon = realicon
				icon_state = realstate

		if(mimicry_choise != "Отмена")
			desc = ""
			icon = 'icons/roguetown/clothing/rings.dmi'
			mob_overlay_icon = 'icons/roguetown/clothing/onmob/rings.dmi'
		else
			icon = realicon

/obj/item/clothing/ring/baotha/attack_self(var/mob/living/carbon/human/user)
	if(user.patron.type == /datum/patron/inhumen/baotha)
		if(do_after(user, 10, target = src))
			var/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/S = new/obj/item/rogueweapon/huntingknife/idagger/steel/baotha(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(S)
			qdel(src)
			playsound(user, pick('sound/magic/magic_nulled.ogg'), 20, TRUE)
		else
			to_chat(user, "<span class='notice'>Я теряю концентрацию!</span>")
