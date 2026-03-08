/datum/family_options
	parent_type = /datum/tgui


/datum/family_options/ui_state(mob/user)
	return GLOB.always_state


/datum/family_options/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FamilySettingsPanel")
		ui.open()


/datum/family_options/ui_data(mob/user)
	. = ..()

	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		.["familySettings"] = list()
		return

	P.familytree_module_load_character()

	.["familySettings"] = list(
		"familyType" = _family_to_ui(P.family),
		"genderPreference" = _gender_to_ui(P.gender_choice_pref),
		"speciesPreferenceMode" = P.species_preference_mode ? P.species_preference_mode : "ANY",
		"preferredSpeciesType" = P.preferred_species_type,
		"preferredSpeciesAnatomy" = P.preferred_species_anatomy,
		"favoriteName" = (istext(P.setspouse) ? P.setspouse : ""),
		"age" = P.age
	)

	var/list/species_names = get_selectable_species().Copy()
	.["availableSpecies"] = species_names


/datum/family_options/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/datum/preferences/P = usr?.client?.prefs
	if(!P)
		return FALSE

	switch(action)
		if("save")

			var/new_family = _ui_to_family(params["familyType"])

			if(new_family == FAMILY_FULL && P.age == AGE_ADULT)
				to_chat(usr, span_warning("You are too young to be a parent."))
				return TRUE

			P.family = new_family
			P.gender_choice_pref = _ui_to_gender(params["genderPreference"])
			P.species_preference_mode = istext(params["speciesPreferenceMode"]) ? params["speciesPreferenceMode"] : "ANY"
			P.preferred_species_type = istext(params["preferredSpeciesType"]) ? params["preferredSpeciesType"] : null
			P.preferred_species_anatomy = text2num(params["preferredSpeciesAnatomy"])
			P.setspouse = istext(params["favoriteName"]) ? copytext(params["favoriteName"], 1, 65) : ""

			if(!(P.preferred_species_anatomy in list(0,1,2)))
				P.preferred_species_anatomy = 0

			if(!(P.species_preference_mode in list("ANY", "SAME_TYPE", "SPECIFIC_TYPE")))
				P.species_preference_mode = "ANY"

			if(P.species_preference_mode != "SPECIFIC_TYPE")
				P.preferred_species_type = null

			P.familytree_module_save_character()

			SStgui.update_uis(src)
			return TRUE

	return FALSE


/datum/family_options/proc/_family_to_ui(val)
	switch(val)
		if(FAMILY_PARTIAL) return "member"
		if(FAMILY_NEWLYWED) return "couple"
		if(FAMILY_FULL) return "parent"
	return "none"


/datum/family_options/proc/_gender_to_ui(val)
	switch(val)
		if(SAME_GENDER) return "same"
		if(DIFFERENT_GENDER) return "opposite"
	return "any"


/datum/family_options/proc/_ui_to_family(val)
	switch(val)
		if("member") return FAMILY_PARTIAL
		if("couple") return FAMILY_NEWLYWED
		if("parent") return FAMILY_FULL
	return FAMILY_NONE


/datum/family_options/proc/_ui_to_gender(val)
	switch(val)
		if("same") return SAME_GENDER
		if("opposite") return DIFFERENT_GENDER
	return ANY_GENDER
