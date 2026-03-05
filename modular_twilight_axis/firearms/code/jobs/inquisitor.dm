/datum/outfit/job/roguetown/inquisitor/inspector/pre_equip(mob/living/carbon/human/H)
	. = ..()
	H.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)

/datum/advclass/inquisitor/blackpowder
	name = "Blackpowder Emissary"
	tutorial = "A truly rare specimen among the ranks of the Inquisition - an agent of the Blackpowder Order now serving as an Ordinator, hunting down Psydon's many enemies, set upon this task by Marshal Inquisitionis himself. There are many mistakes a heretic can commit over their lifespan, but when facing a Blackpowder Marksman, their final error tends to be the fact that they brought a sword to a gunfight."
	outfit = /datum/outfit/job/roguetown/inquisitor/blackpowder
	subclass_languages = list(/datum/language/otavan)
	cmode_music = 'modular_twilight_axis/firearms/sound/music/combat_blackpowder.ogg'
	category_tags = list(CTAG_INQUSITOR)
	classes = list("Vanguard" = "You are an experienced commander who has served in the Blackpowder Order long enough to earn honor and glory on the battlefield. Few can rival your willpower, your shoulders bear the deadly weapons of the new era, capable of killing a God. No heretic or beast can escape Psydon's wrath.",
	"Investigator" = "You are a patient hunter in the service of the Blackpowder Order, entrusted not with glory, but with certainty. While others wage open war, you trace whispers, follow powder trails, and study the subtle tremors of heresy beneath the surface of Psydon's realm. No sinner may hide forever from a mind that does not tire, and a hand that does not tremble.",
	"Runed Volf" = "Many of your brothers died in horrible ways. Someone's body couldn't withstand the new power and tear itself apart, someone was killed on suicidal missions deep behind enemy lines. But you survived and were commissioned as an experienced commander of your order, capable of finding your prey anywhere.")
	traits_applied = list(
		TRAIT_STEELHEARTED,
		TRAIT_SILVER_BLESSED,
		TRAIT_INQUISITION,
		TRAIT_FIREARMS_MARKSMAN,
		TRAIT_PURITAN,
		TRAIT_OUTLANDER,
		TRAIT_ARTILLERY_EXPERT
		)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_WIL = 2,
		STATKEY_PER = 4,
		STATKEY_CON = 2,
		STATKEY_INT = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/twilight_firearms = SKILL_LEVEL_MASTER,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/staves = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE
	)
	subclass_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		"Branding Letters" = /obj/item/branding_letters, //TA Branding
		"Branding Iron" = /obj/item/branding_iron
	)
	extra_context = "This subclass can choose between three roles: Vanguard with the Doomsdae runic rifle and 'Medium Armor' trait, Investigator with the Inquest pistol and the 'Perfect Tracker' trait, and Runed Volf with the Umbra, silent arquebus pistol, rune magyck and the 'Dodge Expert' trait."

/datum/outfit/job/roguetown/inquisitor/blackpowder/pre_equip(mob/living/carbon/human/H)
	..()
	has_loadout = TRUE
	H.verbs |= /mob/living/carbon/human/proc/faith_test
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	backr = /obj/item/storage/backpack/rogue/satchel/otavan
	id = /obj/item/clothing/ring/signet/silver
	backpack_contents = list(
		/obj/item/storage/keyring/inquisitor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/psydagger,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/paper/inqslip/arrival/inq = 1
		)

/datum/outfit/job/roguetown/inquisitor/blackpowder/choose_loadout(mob/living/carbon/human/H)
	. = ..()
	H.adjust_blindness(-3)
	var/classes = list("Vanguard", "Investigator", "Runed Volf")
	var/classchoice = input(H,"CHOOSE YOUR SPECIFICATION.", "YOUR CURSED LYFE.") as anything in classes
	switch(classchoice)
		if("Vanguard")
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fluted/ornate, SLOT_ARMOR, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/otavan/psygloves, SLOT_GLOVES, TRUE)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/rogue/leather/steel/tasset, SLOT_BELT, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/chainlegs, SLOT_PANTS, TRUE)
			H.equip_to_slot_or_del(new /obj/item/quiver/twilight_bullet/runed, SLOT_BELT_R, TRUE)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword/noble, SLOT_BELT_L, TRUE)
			if(isdarkelf(H))
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask, SLOT_WEAR_MASK, TRUE)
			H.put_in_hands(new /obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/rifle(H), TRUE)
			H.put_in_hands(new /obj/item/rogueweapon/sword/long/oldpsysword(H), TRUE)
			var/obj/item/back = H.get_item_by_slot(SLOT_BACK_R)
			var/obj/item/hook = new /obj/item/grapplinghook(H)
			if(!SEND_SIGNAL(back, COMSIG_TRY_STORAGE_INSERT, hook, null, TRUE, TRUE))
				addtimer(CALLBACK(PROC_REF(move_storage), hook, H.loc), 3 SECONDS)
			var/helmets = list("Barbute", "Sallet", "Armet", "Bucket Helm")
			var/helmet_choice = input(H,"Choose your HELMET.", "TAKE UP PSYDON'S HELMS.") as anything in helmets
			switch(helmet_choice)
				if("Barbute")
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/psydonbarbute, SLOT_HEAD, TRUE)
				if("Sallet")
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/psysallet, SLOT_HEAD, TRUE)
				if("Armet")
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/psydonhelm, SLOT_HEAD, TRUE)
				if("Bucket Helm")
					H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/psybucket, SLOT_HEAD, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, 4, TRUE)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
		if("Investigator")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/inqcap, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat, SLOT_ARMOR, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/otavan/inqgloves, SLOT_GLOVES, TRUE)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/rogue/leather/twilight_holsterbelt/blackpowder, SLOT_BELT, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan, SLOT_PANTS, TRUE)
			H.equip_to_slot_or_del(new /obj/item/quiver/twilight_bullet/silver, SLOT_BELT_R, TRUE)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword/noble, SLOT_BELT_L, TRUE)
			if(isdarkelf(H))
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask, SLOT_WEAR_MASK, TRUE)
			H.put_in_hands(new /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/inquest(H), TRUE)
			H.put_in_hands(new /obj/item/rogueweapon/sword/rapier/psyrapier(H), TRUE)
			var/obj/item/belt = H.get_item_by_slot(SLOT_BELT)
			var/obj/item/back = H.get_item_by_slot(SLOT_BACK_R)
			var/quivers = list("Holy Fyrepowder", "Arcyne Gunpowder")
			var/ammochoice = input(H,"CHOOSE YOUR MUNITIONS.", "LAY WASTE TO THE HERETICS.") as anything in quivers
			switch(ammochoice)
				if("Holy Fyrepowder")
					var/obj/item/powderflask = new /obj/item/twilight_powderflask/holyfyre(H)
					if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, powderflask, null, TRUE, TRUE))
						addtimer(CALLBACK(PROC_REF(move_storage), powderflask, H.loc), 3 SECONDS)
				if("Arcyne Gunpowder")
					var/obj/item/powderflask = new /obj/item/twilight_powderflask/arcyne(H)
					if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, powderflask, null, TRUE, TRUE))
						addtimer(CALLBACK(PROC_REF(move_storage), powderflask, H.loc), 3 SECONDS)
			var/obj/item/lockpickring = new /obj/item/lockpickring/mundane(H)
			if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, lockpickring, null, TRUE, TRUE))
				addtimer(CALLBACK(PROC_REF(move_storage), lockpickring, H.loc), 3 SECONDS)
			var/obj/item/blackbag = new /obj/item/clothing/head/inqarticles/blackbag(H)
			if(!SEND_SIGNAL(back, COMSIG_TRY_STORAGE_INSERT, blackbag, null, TRUE, TRUE))
				addtimer(CALLBACK(PROC_REF(move_storage), blackbag, H.loc), 3 SECONDS)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, 2, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, 5, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/tracking, 5, TRUE)
			var/datum/devotion/C = new /datum/devotion(H, H.patron)
			C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1) //Capped to T1 miracles.
			ADD_TRAIT(H, TRAIT_PERFECT_TRACKER, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_BLACKBAGGER, TRAIT_GENERIC)
		if("Runed Volf")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/inq, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/inqsack, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat, SLOT_ARMOR, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/roguetown/otavan/psygloves, SLOT_GLOVES, TRUE)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/rogue/leather/twilight_holsterbelt/blackpowder, SLOT_BELT, TRUE)
			H.equip_to_slot_or_del(new /obj/item/quiver/twilight_bullet/silver, SLOT_BELT_R, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan, SLOT_PANTS, TRUE)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/rogue/satchel/beltpack, SLOT_CLOAK, TRUE)
			H.put_in_hands(new /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/umbra(H), TRUE)
			var/obj/item/belt = H.get_item_by_slot(SLOT_BELT)
			var/quivers = list("Holy Fyrepowder", "Thunderpowder")
			var/ammochoice = input(H,"CHOOSE YOUR MUNITIONS.", "LAY WASTE TO THE HERETICS.") as anything in quivers
			switch(ammochoice)
				if("Holy Fyrepowder")
					var/obj/item/powderflask = new /obj/item/twilight_powderflask/holyfyre(H)
					if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, powderflask, null, TRUE, TRUE))
						addtimer(CALLBACK(PROC_REF(move_storage), powderflask, H.loc), 3 SECONDS)
				if("Thunderpowder")
					var/obj/item/powderflask = new /obj/item/twilight_powderflask/thunder(H)
					if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, powderflask, null, TRUE, TRUE))
						addtimer(CALLBACK(PROC_REF(move_storage), powderflask, H.loc), 3 SECONDS)
			var/obj/item/lockpickring = new /obj/item/lockpickring/mundane(H)
			if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, lockpickring, null, TRUE, TRUE))
				addtimer(CALLBACK(PROC_REF(move_storage), lockpickring, H.loc), 3 SECONDS)
			var/obj/item/garrote = new /obj/item/inqarticles/garrote(H)
			if(!SEND_SIGNAL(belt, COMSIG_TRY_STORAGE_INSERT, garrote, null, TRUE, TRUE))
				addtimer(CALLBACK(PROC_REF(move_storage), garrote, H.loc), 3 SECONDS)
			H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, 5, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/magic/arcane, 3, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, 4, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/climbing, 4, TRUE)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/shadowstep)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/repulse)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fetch)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/stasis/runed)
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)