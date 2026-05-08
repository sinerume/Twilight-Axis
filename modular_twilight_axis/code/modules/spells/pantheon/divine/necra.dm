#define TRANQUILITY_SHROUD_DURATION 12 MINUTES
#define TRANQUILITY_SHROUD_APPLY_TIME 2 SECONDS
#define TRANQUILITY_SHROUD_FORGET_RANGE 12
#define TRANQUILITY_SHROUD_ANGER_RANGE 5
#define TRANQUILITY_SHROUD_AI_TARGET_SIGNAL "mob_ai_target_check"
#define TRANQUILITY_SHROUD_ITEM_PICKUP_SIGNAL "tranquility_shroud_item_pickup"
#define TRANQUILITY_SHROUD_FILTER "tranquility_shroud_glow"
#define TRANQUILITY_SHROUD_EXPENSIVE_ITEM_VALUE 30
#define TRANQUILITY_SHROUD_ANGER_THREAT 1000
#define TRANQUILITY_SHROUD_DEADITE_MASK_SKILL SKILL_LEVEL_JOURNEYMAN
#define TRANQUILITY_SHROUD_ALLY_MASK_SKILL SKILL_LEVEL_EXPERT
#define TRANQUILITY_SHROUD_ALLY_MASK_TIER CLERIC_T2
#define TRANQUILITY_SHROUD_ANGER_SOUND 'sound/vo/mobs/skel/skeleton_laugh.ogg'
#define TRANQUILITY_SHROUD_REMOVAL_AGGRESSION "aggression"
#define TRANQUILITY_SHROUD_REMOVAL_UNDEAD_ATTACK "undead_attack"
#define TRANQUILITY_SHROUD_REMOVAL_NECRA_ANGER "necra_anger"

/datum/action/cooldown/spell/touch/shroud_of_tranquility
	name = "Shroud of Tranquility"
	desc = "Draw a graveward hush over a living soul, causing lesser undead to forget them until violence, sacrilege, or time tears the blessing away."

	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'modular_twilight_axis/icons/mob/actions/necra_shroud.dmi'
	button_icon_state = "shroud_tranquility"

	draw_message = span_notice("A pale, quiet light gathers around my hand. A hush settles over my palm.")
	drop_message = span_notice("The hush slips from my hand.")

	hand_path = /obj/item/melee/new_touch_attack/tranquility_shroud
	can_cast_on_self = TRUE
	ignore_armor_penalty = TRUE

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = SPELLCOST_MIRACLE_MINOR

	secondary_resource_type = SPELL_COST_STAMINA
	secondary_resource_cost = SPELLCOST_CANTRIP

	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = CLERIC_T0
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 0
	required_items = list(/obj/item/clothing/neck/roguetown/psicross)
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	cooldown_time = 30 SECONDS
	attunement_school = null
	sound = 'sound/magic/whiteflame.ogg'

/datum/action/cooldown/spell/touch/shroud_of_tranquility/on_hand_deleted(datum/source)
	SIGNAL_HANDLER
	remove_hand(null, FALSE)

/datum/action/cooldown/spell/touch/shroud_of_tranquility/on_hand_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	remove_hand(dropper, FALSE)

/datum/action/cooldown/spell/touch/shroud_of_tranquility/cast(mob/living/carbon/cast_on)
	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(cast_on, FALSE)
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/shroud_of_tranquility/cast_on_hand_hit(obj/item/melee/new_touch_attack/hand, atom/victim, mob/living/carbon/caster, list/modifiers)
	if(QDELETED(hand) || QDELETED(caster))
		return FALSE
	if(!isliving(victim))
		to_chat(caster, span_warning("The hush finds no living name to cover."))
		return FALSE
	if(get_dist(caster, victim) > 1)
		to_chat(caster, span_warning("I must be beside [victim] to draw the shroud over them."))
		return FALSE

	var/mob/living/living_target = victim
	if(QDELETED(living_target) || living_target.stat != CONSCIOUS)
		to_chat(caster, span_warning("The shroud will only settle over the living and wakeful."))
		return FALSE
	if((living_target.mob_biotypes & MOB_UNDEAD) || living_target.mind?.has_antag_datum(/datum/antagonist/zombie))
		to_chat(caster, span_warning("The shroud recoils; the dead have no living breath to veil."))
		return FALSE
	if(living_target.has_tranquility_shroud())
		to_chat(caster, span_notice("[living_target] is already held in a solemn stillness."))
		return FALSE

	caster.visible_message(span_notice("[caster] raises a pale, quiet hand toward [living_target]."), span_notice("I begin drawing a tranquil shroud over [living_target]."))
	if(living_target != caster)
		to_chat(living_target, span_notice("A pale, quiet light gathers close to me."))

	if(!do_after(caster, TRANQUILITY_SHROUD_APPLY_TIME, target = living_target))
		return FALSE
	if(QDELETED(hand) || QDELETED(caster) || QDELETED(living_target))
		return FALSE
	if(get_dist(caster, living_target) > 1 || living_target.stat != CONSCIOUS)
		to_chat(caster, span_warning("The shroud slips away before it can settle."))
		return FALSE
	if((living_target.mob_biotypes & MOB_UNDEAD) || living_target.mind?.has_antag_datum(/datum/antagonist/zombie))
		to_chat(caster, span_warning("The shroud recoils; the dead have no living breath to veil."))
		return FALSE
	if(living_target.has_tranquility_shroud())
		to_chat(caster, span_notice("[living_target] is already held in a solemn stillness."))
		return FALSE

	var/applied_shroud_tier = spell_tier
	if(ishuman(caster))
		var/mob/living/carbon/human/human_caster = caster
		applied_shroud_tier = max(applied_shroud_tier, human_caster.devotion?.level || CLERIC_T0)
	var/datum/status_effect/tranquility_shroud/shroud = living_target.apply_status_effect(/datum/status_effect/tranquility_shroud, caster, caster.get_skill_level(/datum/skill/magic/holy), applied_shroud_tier)
	if(!shroud)
		to_chat(caster, span_warning("The shroud fails to settle."))
		return FALSE

	playsound(get_turf(living_target), sound, 50, TRUE)
	caster.visible_message(span_notice("[caster] traces a quiet sign over [living_target]."), span_notice("I draw a tranquil shroud over [living_target]."))
	to_chat(living_target, span_notice("A solemn stillness settles over me, as if the dead briefly forget my name."))
	hand.remove_hand_with_no_refund(caster)
	return TRUE

/obj/item/melee/new_touch_attack/tranquility_shroud
	name = "tranquil shroud"
	desc = "A quiet holy stillness gathered around the hand."
	possible_item_intents = list(/datum/intent/use)
	icon = 'modular_twilight_axis/icons/mob/actions/necra_shroud.dmi'
	icon_state = "shroud_tranquility"
	associated_skill = /datum/skill/magic/holy
	experimental_inhand = FALSE
	w_class = WEIGHT_CLASS_TINY

/obj/item/melee/new_touch_attack/tranquility_shroud/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	var/datum/action/cooldown/spell/touch/shroud_of_tranquility/spell = spell_which_made_us?.resolve()
	if(spell)
		spell.cast_on_hand_hit(src, target, user)

/datum/status_effect/tranquility_shroud
	id = "tranquility_shroud"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tranquility_shroud
	duration = TRANQUILITY_SHROUD_DURATION
	status_type = STATUS_EFFECT_UNIQUE
	on_remove_on_mob_delete = TRUE
	var/outline_colour = "#a0a0a0"
	var/removal_reason
	var/holy_skill = 0
	var/shroud_tier = CLERIC_T0
	var/datum/weakref/caster_ref

/datum/status_effect/tranquility_shroud/on_creation(mob/living/new_owner, mob/living/caster, caster_holy_skill, applied_shroud_tier = CLERIC_T0)
	if(caster)
		caster_ref = WEAKREF(caster)
	holy_skill = caster_holy_skill || 0
	shroud_tier = applied_shroud_tier
	return ..()

/datum/status_effect/tranquility_shroud/on_apply()
	if(!owner || QDELETED(owner) || owner.stat != CONSCIOUS || (owner.mob_biotypes & MOB_UNDEAD) || owner.mind?.has_antag_datum(/datum/antagonist/zombie))
		return FALSE
	owner.AddElement(/datum/element/tranquility_shroud)
	if(!owner.get_filter(TRANQUILITY_SHROUD_FILTER))
		owner.add_filter(TRANQUILITY_SHROUD_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 120, "size" = 2))
	return TRUE

/datum/status_effect/tranquility_shroud/on_remove()
	if(owner && !QDELETED(owner))
		owner.RemoveElement(/datum/element/tranquility_shroud)
		owner.remove_filter(TRANQUILITY_SHROUD_FILTER)
		if(removal_reason == TRANQUILITY_SHROUD_REMOVAL_AGGRESSION || removal_reason == TRANQUILITY_SHROUD_REMOVAL_UNDEAD_ATTACK || removal_reason == TRANQUILITY_SHROUD_REMOVAL_NECRA_ANGER)
			to_chat(owner, span_warning("The tranquil shroud tears away. The dead remember me."))
		else
			to_chat(owner, span_notice("The solemn stillness around me fades."))
	return ..()

/datum/status_effect/tranquility_shroud/proc/dispel(reason, mob/living/undead_source)
	if(QDELETED(src))
		return
	removal_reason = reason
	if(reason == TRANQUILITY_SHROUD_REMOVAL_UNDEAD_ATTACK)
		on_shroud_broken_by_undead(undead_source)
	qdel(src)

/datum/status_effect/tranquility_shroud/proc/on_shroud_broken_by_undead(mob/living/undead_source)
	// TODO: Apprentice+ scaling hook for a mild holy debuff once boss/resistance rules are settled.
	return

/datum/status_effect/tranquility_shroud/proc/uses_deadite_mask()
	return holy_skill >= TRANQUILITY_SHROUD_DEADITE_MASK_SKILL

/datum/status_effect/tranquility_shroud/proc/uses_deadite_ally_mask()
	return holy_skill >= TRANQUILITY_SHROUD_ALLY_MASK_SKILL && shroud_tier >= TRANQUILITY_SHROUD_ALLY_MASK_TIER

/atom/movable/screen/alert/status_effect/buff/tranquility_shroud
	name = "Shroud of Tranquility"
	desc = "A solemn stillness lingers over me. Lesser dead may briefly forget my name."
	icon = 'modular_twilight_axis/icons/mob/actions/necra_shroud.dmi'
	icon_state = "shroud_tranquility"

/datum/element/tranquility_shroud

/datum/element/tranquility_shroud/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/owner = target
	RegisterSignal(owner, TRANQUILITY_SHROUD_AI_TARGET_SIGNAL, PROC_REF(on_ai_target_check))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_owner_item_attack))
	RegisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_owner_unarmed_attack))
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_owner_ranged_attack))
	RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(on_owner_attackby))
	RegisterSignals(owner, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW), PROC_REF(on_owner_attack_generic))
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_owner_attack_npc))
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_owner_bullet_act))
	RegisterSignal(owner, COMSIG_ATOM_HITBY, PROC_REF(on_owner_hitby))
	RegisterSignal(owner, TRANQUILITY_SHROUD_ITEM_PICKUP_SIGNAL, PROC_REF(on_owner_picked_up_item))
	owner.tranquility_shroud_hide_from_nearby_undead()

/datum/element/tranquility_shroud/Detach(datum/source, ...)
	UnregisterSignal(source, list(
		TRANQUILITY_SHROUD_AI_TARGET_SIGNAL,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_HUMAN_EARLY_UNARMED_ATTACK,
		COMSIG_MOB_ATTACK_RANGED,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		TRANQUILITY_SHROUD_ITEM_PICKUP_SIGNAL,
	))
	return ..()

/datum/element/tranquility_shroud/proc/on_ai_target_check(mob/living/source, mob/living/attacker)
	SIGNAL_HANDLER
	var/datum/status_effect/tranquility_shroud/shroud = source.has_status_effect(/datum/status_effect/tranquility_shroud)
	if(shroud?.uses_deadite_mask() && attacker?.tranquility_shroud_respects_deadites())
		return TRUE
	if(attacker?.is_lesser_npc_undead())
		return TRUE

/datum/element/tranquility_shroud/proc/should_break_from_outgoing_aggression(mob/living/source, atom/target, obj/item/weapon)
	if(QDELETED(source) || !isliving(target) || target == source)
		return FALSE
	if(weapon?.force)
		return TRUE
	if(source.used_intent?.type == INTENT_HELP)
		return FALSE
	return TRUE

/datum/element/tranquility_shroud/proc/break_from_incoming_attack(atom/target, atom/attacker)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	var/mob/living/undead_attacker
	if(isliving(attacker))
		var/mob/living/living_attacker = attacker
		if(living_attacker.mob_biotypes & MOB_UNDEAD)
			undead_attacker = living_attacker
	living_target.remove_tranquility_shroud(undead_attacker ? TRANQUILITY_SHROUD_REMOVAL_UNDEAD_ATTACK : TRANQUILITY_SHROUD_REMOVAL_AGGRESSION, undead_attacker)

/datum/element/tranquility_shroud/proc/on_owner_item_attack(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	if(should_break_from_outgoing_aggression(source, target, weapon))
		source.remove_tranquility_shroud(TRANQUILITY_SHROUD_REMOVAL_AGGRESSION)

/datum/element/tranquility_shroud/proc/on_owner_unarmed_attack(mob/living/source, atom/target, proximity)
	SIGNAL_HANDLER
	if(!proximity)
		return
	if(should_break_from_outgoing_aggression(source, target, null))
		source.remove_tranquility_shroud(TRANQUILITY_SHROUD_REMOVAL_AGGRESSION)

/datum/element/tranquility_shroud/proc/on_owner_ranged_attack(mob/living/source, atom/target, params)
	SIGNAL_HANDLER
	if(should_break_from_outgoing_aggression(source, target, null))
		source.remove_tranquility_shroud(TRANQUILITY_SHROUD_REMOVAL_AGGRESSION)

/datum/element/tranquility_shroud/proc/on_owner_attackby(atom/target, obj/item/weapon, mob/attacker, list/modifiers)
	SIGNAL_HANDLER
	break_from_incoming_attack(target, attacker)

/datum/element/tranquility_shroud/proc/on_owner_attack_generic(atom/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	break_from_incoming_attack(target, attacker)

/datum/element/tranquility_shroud/proc/on_owner_attack_npc(atom/target, mob/living/attacker)
	SIGNAL_HANDLER
	break_from_incoming_attack(target, attacker)

/datum/element/tranquility_shroud/proc/on_owner_bullet_act(atom/target, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(!hit_projectile)
		return
	break_from_incoming_attack(target, hit_projectile.firer)

/datum/element/tranquility_shroud/proc/on_owner_hitby(atom/target, atom/movable/hit_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!hit_atom)
		return
	var/atom/attacker
	if(isitem(hit_atom))
		var/obj/item/hit_item = hit_atom
		attacker = hit_item.thrownby
	break_from_incoming_attack(target, attacker)

/datum/element/tranquility_shroud/proc/on_owner_picked_up_item(mob/living/source, obj/item/picked_item, atom/old_loc)
	SIGNAL_HANDLER
	if(QDELETED(source) || QDELETED(picked_item) || !isturf(old_loc))
		return
	if(!picked_item.is_expensive_for_tranquility_shroud())
		return
	if(!source.tranquility_shroud_has_nearby_protected_undead())
		return
	source.break_tranquility_shroud_and_anger_necra("theft")

/mob/living/proc/has_tranquility_shroud()
	return !!has_status_effect(/datum/status_effect/tranquility_shroud)

/mob/living/proc/remove_tranquility_shroud(reason = null, mob/living/undead_source = null)
	var/datum/status_effect/tranquility_shroud/shroud = has_status_effect(/datum/status_effect/tranquility_shroud)
	if(!shroud)
		return FALSE
	shroud.dispel(reason, undead_source)
	return TRUE

/mob/living/proc/is_player_raised_undead()
	if(summoner)
		return TRUE
	if(faction)
		if(FACTION_CABAL in faction)
			return TRUE
		for(var/faction_name as anything in faction)
			if(istext(faction_name) && findtext(faction_name, "_faction"))
				return TRUE
	return FALSE

/mob/living/proc/ta_mark_player_raised_undead(mob/living/raiser)
	if(!raiser)
		return FALSE
	if(raiser.mind?.current)
		summoner = raiser.mind.current.real_name
	else
		summoner = raiser.name
	return TRUE

/mob/living/proc/tranquility_shroud_has_deadite_mask()
	var/datum/status_effect/tranquility_shroud/shroud = has_status_effect(/datum/status_effect/tranquility_shroud)
	return shroud?.uses_deadite_mask()

/mob/living/proc/tranquility_shroud_undead_examine_text(mob/examiner)
	var/datum/status_effect/tranquility_shroud/shroud = has_status_effect(/datum/status_effect/tranquility_shroud)
	if(!shroud || !shroud.uses_deadite_mask())
		return null
	if(shroud.uses_deadite_ally_mask())
		return span_boldnotice("Another deadite. My ally.")
	return span_boldnotice("Another deadite.")

/mob/living/proc/tranquility_shroud_respects_deadites()
	if(!(mob_biotypes & MOB_UNDEAD))
		return FALSE
	if(client || ckey || is_player_raised_undead())
		return FALSE
	var/mob/living/simple_animal/hostile/hostile_mob = src
	if(istype(hostile_mob) && hostile_mob.attack_same)
		return FALSE
	var/datum/targetting_datum/basic/ignore_faction/ignore_faction_targeting = ai_controller?.blackboard[BB_TARGETTING_DATUM]
	if(istype(ignore_faction_targeting))
		return FALSE
	if(!faction)
		return FALSE
	return (FACTION_UNDEAD in faction) || ("zombie" in faction)

/mob/living/proc/tranquility_shroud_has_nearby_protected_undead()
	for(var/mob/living/witness in viewers(TRANQUILITY_SHROUD_ANGER_RANGE, src))
		if(witness == src)
			continue
		if(witness.tranquility_shroud_is_valid_anger_undead() && !witness.can_undead_see_target(src))
			return TRUE
	return FALSE

/mob/living/proc/break_tranquility_shroud_and_anger_necra(reason)
	if(QDELETED(src) || stat == DEAD)
		return FALSE
	if(!remove_tranquility_shroud(TRANQUILITY_SHROUD_REMOVAL_NECRA_ANGER))
		return FALSE
	playsound(get_turf(src), TRANQUILITY_SHROUD_ANGER_SOUND, 80, TRUE)
	to_chat(src, span_userdanger("Ваши действия прогневили Некру. Вы чувствуете ледяной озноб и взгляд, устремленный на вас из темноты."))
	addtimer(CALLBACK(src, PROC_REF(tranquility_shroud_anger_nearby_undead)), 0)
	return TRUE

/mob/living/proc/tranquility_shroud_anger_nearby_undead()
	if(QDELETED(src) || stat == DEAD)
		return FALSE
	var/angered_any = FALSE
	for(var/mob/living/undead in viewers(TRANQUILITY_SHROUD_ANGER_RANGE, src))
		if(undead == src)
			continue
		if(undead.tranquility_shroud_force_undead_aggro(src))
			angered_any = TRUE
	return angered_any

/mob/living/proc/tranquility_shroud_force_undead_aggro(mob/living/target)
	if(!target || QDELETED(target) || target.stat == DEAD || !tranquility_shroud_is_valid_anger_undead())
		return FALSE
	if(ai_controller)
		var/list/aggro_table = ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
		if(!aggro_table)
			aggro_table = list()
			ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = aggro_table
		aggro_table[target] = max(aggro_table[target] || 0, TRANQUILITY_SHROUD_ANGER_THREAT)
		ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
		ai_controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, target)
		ai_controller.set_ai_status(AI_STATUS_ON)
		ai_controller.CancelActions()
	var/datum/component/ai_aggro_system/aggro = GetComponent(/datum/component/ai_aggro_system)
	if(aggro)
		aggro.add_threat_to_mob(target, TRANQUILITY_SHROUD_ANGER_THREAT)
	var/mob/living/simple_animal/hostile/hostile_mob = src
	if(istype(hostile_mob))
		hostile_mob.GiveTarget(target)
	return TRUE

/mob/living/proc/is_lesser_npc_undead()
	if(!(mob_biotypes & MOB_UNDEAD))
		return FALSE
	if(client || ckey)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(is_player_raised_undead())
		return FALSE
	if(istype(src, /mob/living/simple_animal/hostile/boss))
		return FALSE
	if(istype(src, /mob/living/carbon/human/species/skeleton/npc/special))
		return FALSE
	if(threat_point >= THREAT_ELITE)
		return FALSE
	if(!ai_controller && !istype(src, /mob/living/simple_animal/hostile))
		return FALSE
	return TRUE

/mob/living/proc/tranquility_shroud_is_valid_anger_undead()
	if(is_lesser_npc_undead())
		return TRUE
	if(!tranquility_shroud_respects_deadites())
		return FALSE
	if(istype(src, /mob/living/simple_animal/hostile/boss))
		return FALSE
	if(istype(src, /mob/living/carbon/human/species/skeleton/npc/special))
		return FALSE
	if(threat_point >= THREAT_ELITE)
		return FALSE
	if(!ai_controller && !istype(src, /mob/living/simple_animal/hostile))
		return FALSE
	return TRUE

/mob/living/proc/can_undead_see_target(mob/living/target)
	if(!target || QDELETED(target))
		return TRUE
	if(!target.has_tranquility_shroud())
		return TRUE
	if(target.tranquility_shroud_has_deadite_mask() && tranquility_shroud_respects_deadites())
		return FALSE
	return !is_lesser_npc_undead()

/mob/living/proc/tranquility_shroud_hide_from_nearby_undead()
	for(var/mob/living/undead in viewers(TRANQUILITY_SHROUD_FORGET_RANGE, src))
		if(!undead.can_undead_see_target(src))
			undead.forget_tranquility_shrouded_target(src)

/mob/living/proc/forget_tranquility_shrouded_target(mob/living/target)
	if(!target || can_undead_see_target(target))
		return
	if(ai_controller)
		if(ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
			ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		if(ai_controller.blackboard[BB_HIGHEST_THREAT_MOB] == target)
			ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
		var/list/aggro_table = ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
		if(aggro_table && aggro_table[target])
			aggro_table -= target
		ai_controller.CancelActions()
	var/mob/living/simple_animal/hostile/hostile_mob = src
	if(istype(hostile_mob) && hostile_mob.target == target)
		hostile_mob.LoseTarget()

/obj/item/proc/is_expensive_for_tranquility_shroud()
	return get_real_price() > TRANQUILITY_SHROUD_EXPENSIVE_ITEM_VALUE

/obj/structure/closet/dirthole/closed/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/rogueweapon/shovel) && isliving(user))
		var/mob/living/living_user = user
		if(living_user.used_intent?.type == /datum/intent/shovelscoop && living_user.has_tranquility_shroud())
			living_user.break_tranquility_shroud_and_anger_necra("grave")
	return ..()

#undef TRANQUILITY_SHROUD_DURATION
#undef TRANQUILITY_SHROUD_APPLY_TIME
#undef TRANQUILITY_SHROUD_FORGET_RANGE
#undef TRANQUILITY_SHROUD_ANGER_RANGE
#undef TRANQUILITY_SHROUD_AI_TARGET_SIGNAL
#undef TRANQUILITY_SHROUD_ITEM_PICKUP_SIGNAL
#undef TRANQUILITY_SHROUD_FILTER
#undef TRANQUILITY_SHROUD_EXPENSIVE_ITEM_VALUE
#undef TRANQUILITY_SHROUD_ANGER_THREAT
#undef TRANQUILITY_SHROUD_DEADITE_MASK_SKILL
#undef TRANQUILITY_SHROUD_ALLY_MASK_SKILL
#undef TRANQUILITY_SHROUD_ALLY_MASK_TIER
#undef TRANQUILITY_SHROUD_ANGER_SOUND
#undef TRANQUILITY_SHROUD_REMOVAL_AGGRESSION
#undef TRANQUILITY_SHROUD_REMOVAL_UNDEAD_ATTACK
#undef TRANQUILITY_SHROUD_REMOVAL_NECRA_ANGER
