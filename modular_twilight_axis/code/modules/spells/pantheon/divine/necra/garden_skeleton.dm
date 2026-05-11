#define NECRA_GARDEN_HOWL_MIN 8 SECONDS
#define NECRA_GARDEN_HOWL_MAX 18 SECONDS
#define NECRA_GARDEN_LIFESPAN 5 MINUTES
#define MOVESPEED_ID_NECRA_GARDEN "necra_garden_swift"

/mob/living/carbon/human/species/skeleton/npc/necra_garden
	threat_point = THREAT_MODERATE
	skel_outfit = /datum/outfit/job/roguetown/skeleton/npc/necra_garden
	pass_flags = PASSCLOSEDTURF

/mob/living/carbon/human/species/skeleton/npc/necra_garden/after_creation()
	..()
	pass_flags |= PASSCLOSEDTURF
	add_movespeed_modifier(MOVESPEED_ID_NECRA_GARDEN, multiplicative_slowdown = -1.0)
	add_filter("necra_garden_aura", 2, list("type" = "outline", "color" = "#dcdcdc", "alpha" = 220, "size" = 1.5))
	add_filter("necra_garden_glow", 1, list("type" = "drop_shadow", "color" = "#c8c8c8a8", "size" = 2.5, "offset" = 0))
	addtimer(CALLBACK(src, PROC_REF(necra_garden_howl)), rand(2 SECONDS, 5 SECONDS))
	addtimer(CALLBACK(src, PROC_REF(necra_garden_expire)), NECRA_GARDEN_LIFESPAN)

/mob/living/carbon/human/species/skeleton/npc/necra_garden/proc/necra_garden_howl()
	if(QDELETED(src))
		return
	if(stat != DEAD)
		playsound(get_turf(src), 'sound/effects/ghost.ogg', 70, TRUE)
	addtimer(CALLBACK(src, PROC_REF(necra_garden_howl)), rand(NECRA_GARDEN_HOWL_MIN, NECRA_GARDEN_HOWL_MAX))

/mob/living/carbon/human/species/skeleton/npc/necra_garden/proc/aggro_at(atom/target)
	if(QDELETED(src) || QDELETED(target) || stat == DEAD)
		return
	if(ai_controller)
		ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
		ai_controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, target)
		ai_controller.set_ai_status(AI_STATUS_ON)
		ai_controller.CancelActions()

/mob/living/carbon/human/species/skeleton/npc/necra_garden/proc/necra_garden_purge_inventory()
	var/list/to_delete = list()
	for(var/obj/item/I in get_equipped_items(include_pockets = TRUE))
		to_delete += I
	for(var/obj/item/I as anything in held_items)
		if(I)
			to_delete += I
	QDEL_LIST(to_delete)

/mob/living/carbon/human/species/skeleton/npc/necra_garden/death(gibbed, nocutscene = FALSE)
	necra_garden_purge_inventory()
	..()
	new /obj/effect/temp_visual/gib_animation(get_turf(src), "gibbed-h")
	qdel(src)

/mob/living/carbon/human/species/skeleton/npc/necra_garden/proc/necra_garden_expire()
	if(QDELETED(src))
		return
	necra_garden_purge_inventory()
	visible_message(span_warning("[src] рассыпается в прах — сады Некры отзывают своё."))
	new /obj/effect/temp_visual/gib_animation(get_turf(src), "gibbed-h")
	qdel(src)

/datum/outfit/job/roguetown/skeleton/npc/necra_garden/pre_equip(mob/living/carbon/human/H)
	..()
	H.STASTR = 13
	H.STASPD = 13
	H.STACON = 8
	H.STAWIL = 11
	H.STAINT = 6
	name = "Skeleton"
	head = /obj/item/clothing/head/roguetown/necrahood
	cloak = /obj/item/clothing/cloak/templar/necran
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	pants = /obj/item/clothing/under/roguetown/tights/vagrant
	shoes = /obj/item/clothing/shoes/roguetown/boots
	switch(rand(1, 3))
		if(1)
			r_hand = /obj/item/rogueweapon/sword/iron
		if(2)
			r_hand = /obj/item/rogueweapon/mace
		if(3)
			r_hand = /obj/item/rogueweapon/spear
	H.adjust_skillrank(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/datum/outfit/job/roguetown/skeleton/npc/necra_garden/post_equip(mob/living/carbon/human/H)
	..()
	for(var/obj/item/I in H.get_equipped_items(include_pockets = TRUE))
		ADD_TRAIT(I, TRAIT_NODROP, TRAIT_GENERIC)
	for(var/obj/item/I as anything in H.held_items)
		if(I)
			ADD_TRAIT(I, TRAIT_NODROP, TRAIT_GENERIC)
