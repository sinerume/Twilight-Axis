/obj/effect/proc_holder/spell/invoked/lux_steal
	name = "Lux Steal"
	desc = "!"
	action_icon = 'icons/mob/actions/baothamiracles.dmi'
	overlay_icon = 'icons/mob/actions/baothamiracles.dmi'
	overlay_state = "vice"
	releasedrain = 100
	chargedrain = 0
	chargetime = 0
	range = 1
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 SECONDS 
	miracle = TRUE
	devotion_cost = 100

/obj/effect/proc_holder/spell/invoked/lux_steal/cast(list/targets, mob/living/user)
	if(!ishuman(targets?[1]))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/H = targets[1]

	if(prob(50 + ((H.STAPER - 10) * 10)))
		to_chat(H, span_warning("???!"))

	if(!do_after(user, 5 SECONDS, TRUE, H, TRUE))
		to_chat(user, span_warning("My concentration breaks!"))
		revert_cast()
		return
	var/list/arousal_data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/point_count = 0
	if(arousal_data["arousal"] >= 90)
		to_chat(user, span_info("My pray has arousual!"))
		point_count += 2
	if(H.has_stress_event(/datum/stressevent/lasthigh))
		to_chat(user, span_info("My pray has under my high-blessing!"))
		point_count += 1
	if(H.has_status_effect(/datum/status_effect/buff/druqks))
		to_chat(user, span_info("My pray has under druqks!"))
		point_count += 1
	if(H.has_status_effect(/datum/status_effect/buff/drunk))
		to_chat(user, span_info("My pray has drunked!"))
		point_count += 1
	if(H.has_status_effect(/datum/status_effect/buff/ozium))
		to_chat(user, span_info("My pray has under ozium!"))
		point_count += 1
	if(point_count < 2)
		revert_cast()
		return
	to_chat(user, span_warning("I start!"))
	if(!do_after(user, 5 SECONDS, TRUE, H, TRUE))
		to_chat(user, span_warning("My concentration breaks!2"))
		revert_cast()
		return
	var/apply_greater
	if(isaasimar(H))
		new /obj/item/reagent_containers/lux(H.loc)
		apply_greater = TRUE
	else
		new /obj/item/reagent_containers/lux_impure(H.loc)
	SEND_SIGNAL(user, COMSIG_LUX_EXTRACTED, H)
	//record_featured_stat(FEATURED_STATS_CRIMINALS, user)	- This.. isn't normally criminal.
	record_round_statistic(STATS_LUX_HARVESTED)
	H.apply_status_effect((apply_greater ? /datum/status_effect/debuff/devitalised/greater : /datum/status_effect/debuff/devitalised))
	return TRUE

/obj/effect/proc_holder/spell/self/mirage
	name = "Mirage"
	desc = "Provide you mirror magic effect."
	overlay_state = "createlight"
	base_icon_state = "regalyscroll"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/astrata_choir.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	invocations = list("Accincti flammis.")
	invocation_type = "whisper"
	recharge_time = 0
	devotion_cost = 30
	miracle = TRUE
	var/used = FALSE
/*
	var/rname
	var/hname
	var/dna
	var/mind
	var/species
	var/skin_tone
	var/hair_color
	var/facial_hair_color
	var/eye_color
	var/dna_eye_color

	var/duble_rname
	var/duble_hname
	var/duble_dna
	var/duble_mind
	var/duble_species
	var/duble_skin_tone
	var/duble_hair_color
	var/duble_facial_hair_color
	var/duble_eye_color
	var/duble_dna_eye_color
*/
#define TRAIT_MIRAGE "Mirage"

/obj/effect/proc_holder/spell/self/mirage/cast(mob/living/carbon/human/user)
	playsound(get_turf(user), 'sound/magic/haste.ogg', 80, TRUE, soundping = TRUE)

	if(used == FALSE)
		ADD_TRAIT(user, TRAIT_MIRAGE, TRAIT_MIRACLE)
		/*rname = user.real_name
		hname = user.name
		dna = user.dna.real_name
		mind = user.mind.name
		species = user.dna.species
		skin_tone = user.skin_tone
		hair_color = user.hair_color
		facial_hair_color = user.facial_hair_color
		eye_color = user.eye_color
		dna_eye_color = user.dna.features["eye_color"]*/
		used = TRUE
		var/mirage_type = list("Name", "Feature")
		var/selection = input(user, "Rituals of Gedonism", src) as null|anything in mirage_type
		switch(selection) // put ur rite selection here
			if("Name")
				mirror_full_transform(user)
			if("Feature")
				perform_mirror_transform(user)
	else
		var/mirage_type = list("Name", "Feature", "Nevermind")
		var/selection = input(user, "Rituals of Gedonism", src) as null|anything in mirage_type
		switch(selection) // put ur rite selection here
			if("Name")
				mirror_full_transform(user)
			if("Feature")
				perform_mirror_transform(user)
			/*if("Safe")
				duble_rname = user.real_name
				duble_hname = user.name
				duble_dna = user.dna.real_name
				duble_mind = user.mind.name
				duble_species = user.dna.species
				duble_skin_tone = user.skin_tone
				duble_hair_color = user.hair_color
				duble_facial_hair_color = user.facial_hair_color
				duble_eye_color = user.eye_color
				duble_dna_eye_color = user.dna.features["eye_color"]
			if("Swap")
				if(HAS_TRAIT(user, TRAIT_MIRAGE))
					user.real_name = rname
					user.name = hname
					user.dna.real_name = dna
					user.mind.name = mind
					user.set_species(species, icon_update=0)
					user.skin_tone = skin_tone
					user.hair_color = hair_color
					user.facial_hair_color = facial_hair_color
					user.eye_color = eye_color
					user.dna.features["eye_color"] = dna_eye_color
					user.update_body()
					user.update_hair()
					user.update_body_parts()
					user.update_hair()
					user.update_body_parts()
					REMOVE_TRAIT(user, TRAIT_MIRAGE, TRAIT_MIRACLE)
				else
					user.real_name = duble_rname
					user.name = duble_hname
					user.dna.real_name = duble_dna
					user.mind.name = duble_mind
					user.set_species(duble_species, icon_update=0)
					user.skin_tone = duble_skin_tone
					user.hair_color = duble_hair_color
					user.facial_hair_color = duble_facial_hair_color
					user.eye_color = duble_eye_color
					user.dna.features["eye_color"] = duble_dna_eye_color
					user.update_body()
					user.update_hair()
					user.update_body_parts()
					user.update_hair()
					user.update_body_parts()
					ADD_TRAIT(user, TRAIT_MIRAGE, TRAIT_MIRACLE)*/
			if("Nevermind")
				revert_cast()
				return FALSE

proc/mirror_full_transform(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/should_update = FALSE
	var/newname = copytext(sanitize_name(input(H, "Who are we again?", "Name change", H.name) as null|text),1,MAX_NAME_LEN)

	if(!newname)
		return
	H.real_name = newname
	H.name = newname
	if(H.dna)
		H.dna.real_name = newname
	if(H.mind)
		H.mind.name = newname
	if(should_update)
		H.update_body()