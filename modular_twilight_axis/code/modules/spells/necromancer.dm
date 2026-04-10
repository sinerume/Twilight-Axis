#define MAX_RAISED_SKELETONS 3

/datum/advclass/wretch/necromancer/post_equip(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	if(!spawned || QDELETED(spawned))
		return

	spawned.AddSpell(new /obj/effect/proc_holder/spell/invoked/raise_to_skeleton)

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton
	name = "Raise to Skeleton"
	desc = "Reanimate a corpse as a player-controlled skeleton. The body must have all limbs and its head. Maximum 3 active skeletons."
	clothes_req = FALSE
	range = 7
	overlay_state = "animate"
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 100
	chargetime = 60
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	invocations = list("Hygf'akni'kthakchratah!")
	invocation_type = "shout"
	chargedrain = 2
	recharge_time = 5 MINUTES
	var/list/raised_skeletons = list()
	var/mob/living/registered_caster
	var/caster_signal_registered = FALSE

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton/proc/count_active()
	for(var/i in raised_skeletons.len to 1 step -1)
		var/mob/living/M = raised_skeletons[i]
		if(QDELETED(M) || M.stat == DEAD)
			raised_skeletons -= M
	return raised_skeletons.len

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton/proc/on_skeleton_death(mob/living/source)
	SIGNAL_HANDLER
	raised_skeletons -= source
	UnregisterSignal(source, COMSIG_LIVING_DEATH)
	if(registered_caster && !QDELETED(registered_caster))
		to_chat(registered_caster, span_warning("One of my raised skeletons has fallen. I may raise another."))

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton/proc/on_caster_death(mob/living/source)
	SIGNAL_HANDLER
	for(var/mob/living/M in raised_skeletons)
		to_chat(M, span_userdanger("My master has fallen! The binding weakens..."))
		UnregisterSignal(M, COMSIG_LIVING_DEATH)
	raised_skeletons.Cut()
	UnregisterSignal(source, COMSIG_LIVING_DEATH)
	caster_signal_registered = FALSE

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton/cast(list/targets, mob/living/carbon/human/user)
	. = ..()

	if(!("undead" in user.faction))
		user.faction |= "undead"

	if(count_active() >= MAX_RAISED_SKELETONS)
		to_chat(user, span_warning("I cannot sustain another skeleton. My previous ones must perish first."))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/target = targets[1]

	if(!istype(target))
		to_chat(user, span_warning("I need to cast this spell on a corpse."))
		revert_cast()
		return FALSE

	if(target.stat != DEAD)
		to_chat(user, span_warning("I cannot raise the living."))
		revert_cast()
		return FALSE

	if(target in raised_skeletons)
		to_chat(user, span_warning("This corpse is already one of mine."))
		revert_cast()
		return FALSE

	var/static/list/forbidden_types = list(
		/mob/living/carbon/human/species/goblin,
		/mob/living/carbon/human/species/skeleton/npc
	)
	for(var/forbidden_type in forbidden_types)
		if(istype(target, forbidden_type))
			to_chat(user, span_warning("I cannot raise this body."))
			revert_cast()
			return FALSE

	var/obj/item/bodypart/target_head = target.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/bodypart/target_larm = target.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/target_rarm = target.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/target_lleg = target.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/target_rleg = target.get_bodypart(BODY_ZONE_R_LEG)
	if(!target_head || !target_larm || !target_rarm || !target_lleg || !target_rleg)
		to_chat(user, span_warning("This corpse is missing limbs."))
		revert_cast()
		return FALSE

	if(target.ckey)
		var/offer = tgui_alert(target, "A Necromancer wishes to reanimate your body as a skeleton minion. Do you accept?", "Raised by Necromancer", list("Yes", "Give to another", "No"), 15 SECONDS)

		if(count_active() >= MAX_RAISED_SKELETONS)
			to_chat(user, span_warning("I already have too many skeletons while waiting for a response."))
			return FALSE
		if(QDELETED(target) || target.stat != DEAD)
			return FALSE

		if(offer == "Yes")
			finalize_raise(target, user, target.ckey)
			return TRUE
		else if(offer == "No")
			to_chat(user, span_warning("The soul resists my power."))
			return FALSE

	var/list/candidates = pollGhostCandidates("Do you want to play as a Necromancer's skeleton?", ROLE_NECRO_SKELETON, null, null, 10 SECONDS, POLL_IGNORE_NECROMANCER_SKELETON)

	if(count_active() >= MAX_RAISED_SKELETONS)
		to_chat(user, span_warning("I already have too many skeletons while waiting for souls."))
		return FALSE
	if(QDELETED(target) || target.stat != DEAD)
		return FALSE

	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("No souls answer my call."))
		return FALSE

	var/mob/dead/candidate = pick(candidates)
	if(QDELETED(candidate) || !istype(candidate, /mob/dead))
		to_chat(user, span_warning("The soul slipped away."))
		return FALSE

	if(istype(candidate, /mob/dead/new_player))
		var/mob/dead/new_player/N = candidate
		N.close_spawn_windows()

	finalize_raise(target, user, candidate.ckey)
	return TRUE

/obj/effect/proc_holder/spell/invoked/raise_to_skeleton/proc/finalize_raise(mob/living/carbon/human/target, mob/living/carbon/human/master, new_ckey)
	target.revive(TRUE, TRUE)
	target.ckey = new_ckey

	if(!target.mind)
		target.mind_initialize()
	target.mind.current.job = null

	target.become_skeleton()

	target.patron = master.patron
	target.faction = list("undead", "[master.real_name]_faction")
	target.ambushable = FALSE
	target.underwear = "Nude"
	target.can_do_sex = FALSE
	target.cmode_music = 'sound/music/combat_cult.ogg'

	ADD_TRAIT(target, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_INFINITE_STAMINA, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)

	target.mind.AddSpell(new /obj/effect/proc_holder/spell/self/suicidebomb/lesser)

	raised_skeletons += target
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_skeleton_death))

	if(!caster_signal_registered)
		registered_caster = master
		RegisterSignal(master, COMSIG_LIVING_DEATH, PROC_REF(on_caster_death))
		caster_signal_registered = TRUE

	target.visible_message(span_warning("[target.real_name]'s eyes light up with an evil glow!"))
	to_chat(target, span_userdanger("My master is [master.real_name]. I must obey [master.p_them()] as long as [master.p_they()] live."))
