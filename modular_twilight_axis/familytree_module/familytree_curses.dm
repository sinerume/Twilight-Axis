/datum/family_curse
	var/name
	var/description
	var/curse_type
	var/severity = 1
	var/inherited = TRUE
	var/tmp/datum/weakref/cursed_by
	var/when_cursed
	var/blessing = FALSE

	var/list/curse_effects = list()


/datum/family_curse/misfortune
	name = "Family Misfortune"
	description = "Bad luck follows this bloodline"
	curse_effects = list(/datum/status_effect/misfortune)

/datum/status_effect/misfortune
	id = "family_misfortune"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/family_curse/misfortune
	effectedstats = list(STATKEY_LCK = -2)

/atom/movable/screen/alert/status_effect/family_curse/misfortune
	name = "Family Misfortune"
	desc = "Your family's curse brings ill fortune to your steps."
	icon_state = "debuff"

	var/static/list/misfortune_tips = list(
		"Dark clouds seem to follow you wherever you go...",
		"You feel the weight of your family's curse.",
		"Even simple tasks seem to go wrong more often.",
		"The fates seem to conspire against you.",
		"Your ancestors' misdeeds continue to haunt you."
	)

/atom/movable/screen/alert/status_effect/family_curse/misfortune/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(desc == initial(desc))
		desc = "[initial(desc)] [pick(misfortune_tips)]"


/datum/family_curse/hunger
	name = "Insatiable Appetite"
	description = "This bloodline is voracious in its hunger."
	curse_effects = list(/datum/status_effect/hunger)

/datum/status_effect/hunger
	id = "family_hunger"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/family_curse/hunger

/atom/movable/screen/alert/status_effect/family_curse/hunger
	name = "Insatiable Appetite"
	desc = "Your family is cursed with a hunger that is rarely sated."
	icon_state = "debuff"

	var/static/list/hunger_tips = list(
		"Your stomach growls like a caged volf...",
		"You feel the weight of your family's curse.",
		"Even the grandest feast was never enough."
	)

/atom/movable/screen/alert/status_effect/family_curse/hunger/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(desc == initial(desc))
		desc = "[initial(desc)] [pick(hunger_tips)]"


/atom/movable/screen/alert/status_effect/family_curse/Click(location, control, params)
	. = ..()
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(!user.client || !user.family_datum)
		return

	user.family_datum.OpenCursePanel(user)
