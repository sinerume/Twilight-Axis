// In exchange for martial skills beyond ranged, they can now set traps, too.
/datum/advclass/janissary/jezail
	name = "Janissary Jezail"
	tutorial = "Ты — профессиональный солдат Султанского воинства, чей талант раскрывается в обращении с пороховым оружием. \
        Твой взор остер, а рука безошибочна: ты видишь слабые места врага сквозь дымную завесу, \
        используя мощь кулеврин и аркебуз, чтобы сеять погибель во имя порядка."
	outfit = /datum/outfit/job/roguetown/janissary/jezail

	maximum_possible_slots = 2//One always tells the truth, the other only lies. Guess wrong and they both shoot you.

	category_tags = list(CTAG_JANISSARY)
	//Garrison ranged/speed class. Time to go wild
	subclass_stats = list(
		STATKEY_SPD = 1,// probably objectively worse stats than skirmisher but the price ye pay
		STATKEY_PER = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 1,
	)
	traits_applied = list(TRAIT_FIREARMS_MARKSMAN, TRAIT_DODGEEXPERT)

	subclass_skills = list(
		/datum/skill/combat/twilight_firearms = SKILL_LEVEL_MASTER,//Your entire point is GUN.
		/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/bows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/slings = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,//not as acrobatic
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/janissary/jezail/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	pants = /obj/item/clothing/under/roguetown/splintlegs
	wrists = /obj/item/clothing/wrists/roguetown/bracers/brigandine
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/janissary
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/zyb
	head = /obj/item/clothing/head/roguetown/helmet/janissaryhelm
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/impact_grenade/smoke/blind_gas,
		)

	H.adjust_blindness(-3)
	if(H.mind)
		var/weapons = list("Arquebus","Culverin + Fyre Powder")
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("Arquebus")
				beltr = /obj/item/quiver/twilight_bullet/lead
				r_hand = /obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet
				backpack_contents[/obj/item/twilight_powderflask] = 1
			if("Culverin + Fyre Powder") 
				beltr = /obj/item/quiver/twilight_bullet/cannonball/lead
				r_hand = /obj/item/gun/ballistic/twilight_firearm/handgonne
				backpack_contents[/obj/item/twilight_powderflask/fyre] = 1
				backpack_contents[/obj/item/natural/bundle/fibers/full] = 1
		var/weapons2 = list("Scimitar","Whip","Club")
		var/weapon_choice2 = input(H, "Choose your sidearm.", "TAKE UP ARMS") as anything in weapons2
		switch(weapon_choice2)
			if("Scimitar")
				beltl = /obj/item/rogueweapon/scabbard/sword
				l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
			if("Whip") 
				beltl = /obj/item/rogueweapon/whip
			if("Club")
				beltl = /obj/item/rogueweapon/mace/cudgel
		H.verbs |= /mob/proc/haltyell
