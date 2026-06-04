/datum/job/roguetown/azeb
	title = "Azeb"
	flag = BOGGUARD
	department_flag = GARRISON
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	allowed_sexes = list(MALE, FEMALE)
	forbidden_races = list(RACES_DESPISED)
	tutorial = "Будучи живой собственностью правящей династии, ты с младенчества воспитывался как воин-невольник. \
        Тебя отправили охранять рубежи и беречь покой града, пока высокородная хасса купается в роскоши за неприступными \
        городскими стенами. Твой долг неблагодарен, но эта священная ноша должна быть пронесена до конца."
	display_order = JDO_GUARD

	outfit = /datum/outfit/job/roguetown/azeb
	advclass_cat_rolls = list(CTAG_AZEB = 20)

	give_bank_account = 16
	min_pq = 5
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_desert1.ogg'
	job_traits = list(TRAIT_OUTDOORSMAN, TRAIT_WOODSMAN, TRAIT_SURVIVAL_EXPERT, TRAIT_SLAVE)
	job_subclasses = list(
		/datum/advclass/azeb/ranger,
		/datum/advclass/azeb/footman
	)
	same_job_respawn_delay = 30 MINUTES

	
/datum/job/roguetown/azeb/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/dunestalker))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "Azeb Cloak ([index])"

/datum/outfit/job/roguetown/azeb
	backr = /obj/item/storage/backpack/rogue/satchel
	id = /obj/item/scomstone/bad/garrison
	job_bitflag = BITFLAG_GARRISON

/datum/advclass/azeb/ranger
	name = "Ranger"
	tutorial = "You are well versed in the ways of handling a bow. \
	You will stand in the back, and protect the front with arrows."
	outfit = /datum/outfit/job/roguetown/azeb/ranger
	category_tags = list(CTAG_AZEB)
	traits_applied = list(TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_PER = 2,//7 points weighted, same as MAA. They get temp buffs in the city instead of in the city.
		STATKEY_SPD = 2,
		STATKEY_WIL = 1
	)
	subclass_skills = list(
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/slings = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/butchering = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE, // This should let them fry meat on fires.
	)

/datum/outfit/job/roguetown/azeb/ranger/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/sallet/raneshen
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/raneshen
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/zyb
	pants = /obj/item/clothing/under/roguetown/trou/leather/pontifex/raneshen
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/raneshen
	cloak = /obj/item/clothing/cloak/dunestalker
	shoes = /obj/item/clothing/shoes/roguetown/shalal/reinforced
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/coif/padded
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/warden
	beltr = /obj/item/quiver/arrows
	beltl = /obj/item/rogueweapon/huntingknife/idagger/steel
	backpack_contents = list(
		/obj/item/storage/keyring/azeb = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/signal_horn = 1
		)
	H.verbs |= /mob/proc/haltyell
	H.set_blindness(0)

/datum/advclass/azeb/footman
	name = "Footman"
	tutorial = "You are well versed in the ways of handling a sword. \
	You will stand in the front, and protect."
	outfit = /datum/outfit/job/roguetown/azeb/footman
	category_tags = list(CTAG_AZEB)
	traits_applied = list(TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_STR = 2,//7 points weighted, same as MAA. They get temp buffs in the desert instead of in the city.
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
		STATKEY_PER = 1
	)
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/slings = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/bows = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/butchering = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE, // This should let them fry meat on fires.
	)

/datum/outfit/job/roguetown/azeb/footman/pre_equip(mob/living/carbon/human/H)
	..()
	head = head = /obj/item/clothing/head/roguetown/helmet/sallet/raneshen
	mask = mask = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/raneshen
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/raneshen
	pants = /obj/item/clothing/under/roguetown/trou/leather/pontifex/raneshen
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass
	cloak = /obj/item/clothing/cloak/dunestalker
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/coif/padded
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	backl = /obj/item/rogueweapon/scabbard/gwstrap
	beltr = /obj/item/rogueweapon/sword/sabre
	beltl = /obj/item/rogueweapon/huntingknife
	r_hand = /obj/item/rogueweapon/halberd/bardiche
	backpack_contents = list(
		/obj/item/storage/keyring/manatarms = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/signal_horn = 1
		)
	H.verbs |= /mob/proc/haltyell
	H.set_blindness(0)
