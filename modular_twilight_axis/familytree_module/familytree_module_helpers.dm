// Consolidated low-churn helper declarations for the familytree module.

/datum/preferences
	var/setspouse = ""
	var/datum/family_options/family_options
	var/gender_choice_pref = ANY_GENDER
	var/species_preference_mode = "ANY"
	var/list/preferred_species_types = list()
	var/preferred_species_anatomy = 0
	var/tmp/familytree_module_loaded_slot
	var/tmp/familytree_module_loaded_path

/mob/living/carbon/human
	var/family_UI = TRUE
	var/mob/living/carbon/spouse_mob
	var/image/spouse_indicator
	var/setspouse
	var/gender_choice_pref = ANY_GENDER
	var/familytree_pref = FAMILY_NONE
	var/datum/heritage/family_datum
	var/datum/family_member/family_member_datum
	var/tmp/familytree_module_signal_bound = FALSE
	var/tmp/familytree_assignment_scheduled = FALSE


/proc/familytree_module_get_selectable_species() as /list
	if(!GLOB.roundstart_races.len)
		generate_selectable_species()

	var/list/species_names = list()
	for(var/species_name in GLOB.roundstart_races)
		if(!istext(species_name))
			continue
		var/species_type = GLOB.species_list[species_name]
		if(!ispath(species_type, /datum/species))
			continue
		species_names += species_name

	if(!species_names.len)
		species_names += "Humen"

	return species_names

/proc/familytree_module_get_selectable_species_types() as /list
	var/list/species_types = list()
	for(var/species_name in familytree_module_get_selectable_species())
		var/species_type = GLOB.species_list[species_name]
		if(!ispath(species_type, /datum/species))
			continue
		if(species_type in species_types)
			continue
		species_types += species_type

	if(!species_types.len)
		species_types += /datum/species/human/northern

	return species_types

/datum/preferences/proc/familytree_module_get_slot(slot)
	if(!slot)
		slot = loaded_slot || default_slot
	return sanitize_integer(slot, 1, max_save_slots, initial(default_slot))

/datum/preferences/proc/familytree_module_get_cd(slot)
	slot = familytree_module_get_slot(slot)
	return "/familytree_module/character[slot]"

/datum/preferences/proc/familytree_module_reset_character()
	family = initial(family)
	setspouse = initial(setspouse)
	gender_choice_pref = initial(gender_choice_pref)
	species_preference_mode = initial(species_preference_mode)
	preferred_species_types = list()
	preferred_species_anatomy = initial(preferred_species_anatomy)

/datum/preferences/proc/familytree_module_sanitize_character()
	family = sanitize_integer(family, FAMILY_NONE, FAMILY_NEWLYWED, FAMILY_NONE)
	gender_choice_pref = sanitize_integer(gender_choice_pref, ANY_GENDER, DIFFERENT_GENDER, ANY_GENDER)
	species_preference_mode = sanitize_text(species_preference_mode, "ANY")

	if(!(species_preference_mode in list("ANY", "SAME_TYPE", "SPECIFIC_TYPE")))
		species_preference_mode = "ANY"

	var/list/valid_species = familytree_module_get_selectable_species()
	var/list/sanitized_species = list()

	if(islist(preferred_species_types))
		for(var/entry in preferred_species_types)
			if(!istext(entry))
				continue
			if(!(entry in valid_species))
				continue
			if(entry in sanitized_species)
				continue
			sanitized_species += entry

	preferred_species_types = sanitized_species

	if(species_preference_mode == "SPECIFIC_TYPE")
		if(!preferred_species_types.len)
			species_preference_mode = "ANY"
	else
		preferred_species_types = list()

	preferred_species_anatomy = text2num("[preferred_species_anatomy]")
	if(!(preferred_species_anatomy in list(0, 1, 2)))
		preferred_species_anatomy = 0

	if(!istext(setspouse))
		setspouse = ""
	else
		setspouse = copytext(setspouse, 1, 65)

/datum/preferences/proc/familytree_module_has_enabled_customizer_entry(entry_type)
	validate_customizer_entries()
	var/datum/customizer_entry/entry = get_customizer_entry_of_type(entry_type)
	return entry && !entry.disabled

/datum/preferences/proc/familytree_module_has_penis()
	return familytree_module_has_enabled_customizer_entry(/datum/customizer_entry/organ/penis)

/datum/preferences/proc/familytree_module_has_vagina()
	return familytree_module_has_enabled_customizer_entry(/datum/customizer_entry/organ/vagina)

/datum/preferences/proc/familytree_module_load_character(slot, force = FALSE)
	slot = familytree_module_get_slot(slot)
	if(!force && (familytree_module_loaded_path == path) && (familytree_module_loaded_slot == slot))
		return TRUE

	familytree_module_reset_character()

	if(path && fexists(path))
		var/savefile/S = new /savefile(path)
		if(S)
			S.cd = familytree_module_get_cd(slot)
			S["family"] >> family
			S["gender_choice_pref"] >> gender_choice_pref
			S["setspouse"] >> setspouse
			S["species_preference_mode"] >> species_preference_mode
			S["preferred_species_types"] >> preferred_species_types
			S["preferred_species_anatomy"] >> preferred_species_anatomy

	familytree_module_sanitize_character()
	familytree_module_loaded_slot = slot
	familytree_module_loaded_path = path
	return TRUE

/datum/preferences/proc/familytree_module_save_character(slot)
	if(!path)
		return FALSE

	slot = familytree_module_get_slot(slot)
	familytree_module_sanitize_character()

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	S.cd = familytree_module_get_cd(slot)
	WRITE_FILE(S["family"], family)
	WRITE_FILE(S["gender_choice_pref"], gender_choice_pref)
	WRITE_FILE(S["setspouse"], setspouse)
	WRITE_FILE(S["species_preference_mode"], species_preference_mode)
	WRITE_FILE(S["preferred_species_types"], preferred_species_types)
	WRITE_FILE(S["preferred_species_anatomy"], preferred_species_anatomy)

	familytree_module_loaded_slot = slot
	familytree_module_loaded_path = path
	return TRUE

/client/proc/familytree_module_open_preferences(mob/user = mob)
	if(!prefs)
		return FALSE

	if(!user)
		user = mob
	if(!user)
		return FALSE

	prefs.familytree_module_load_character()
	if(!prefs.family_options)
		prefs.family_options = new /datum/family_options
	prefs.family_options.ui_interact(user)
	return TRUE

/mob/living/carbon/human/proc/MarryTo(mob/living/carbon/human/spouse)
	if(!ishuman(spouse))
		return null

	spouse_mob = spouse
	spouse.spouse_mob = src

	var/datum/heritage/primary_family = null
	var/datum/family_member/primary_member = null
	var/datum/family_member/secondary_member = null

	if(family_datum && !spouse.family_datum)
		primary_family = family_datum
		primary_member = family_member_datum
		secondary_member = primary_family.CreateFamilyMember(spouse)

	else if(!family_datum && spouse.family_datum)
		primary_family = spouse.family_datum
		primary_member = spouse.family_member_datum
		secondary_member = primary_family.CreateFamilyMember(src)

	else if(family_datum && spouse.family_datum)
		primary_family = family_datum
		primary_member = family_member_datum
		secondary_member = spouse.family_member_datum

	else
		var/new_family_name = null
		if(gender == MALE)
			new_family_name = family_datum?.SurnameFormatting(src)
		else if(spouse.gender == MALE)
			new_family_name = family_datum?.SurnameFormatting(spouse)

		primary_family = new /datum/heritage(src, new_family_name)
		primary_member = primary_family.founder
		secondary_member = primary_family.CreateFamilyMember(spouse)

	if(primary_member && secondary_member && primary_family)
		primary_family.MarryMembers(primary_member, secondary_member)

	return primary_family

/mob/living/carbon/human/proc/ReturnRelation(mob/living/carbon/human/stranger)
	return family_datum.ReturnRelation(src, stranger)

/mob/living/carbon/human/proc/familytree_get_parental_style()
	var/has_penis = getorganslot(ORGAN_SLOT_PENIS) != null
	var/has_vagina = getorganslot(ORGAN_SLOT_VAGINA) != null

	if(has_penis && !has_vagina)
		return "masculine"
	if(has_vagina && !has_penis)
		return "feminine"
	if(has_penis && has_vagina)
		if(titles_pref == TITLES_M)
			return "masculine"
		if(titles_pref == TITLES_F)
			return "feminine"

	if(titles_pref == TITLES_M)
		return "masculine"
	if(titles_pref == TITLES_F)
		return "feminine"

	switch(pronouns)
		if(HE_HIM)
			return "masculine"
		if(SHE_HER)
			return "feminine"

	switch(gender)
		if(MALE)
			return "masculine"
		if(FEMALE)
			return "feminine"

	return "neutral"

/datum/mind/proc/familytree_get_known_family_relation(mob/living/carbon/human/viewer, mob/living/carbon/human/known_person)
	if(!viewer || !known_person || !viewer.family_datum || viewer.family_datum != known_person.family_datum)
		return null

	var/datum/family_member/viewer_member = viewer.family_member_datum
	var/datum/family_member/known_member = known_person.family_member_datum
	if(!viewer_member || !known_member)
		return null

	return viewer_member.GetRelationshipTo(known_member)

/datum/mind/proc/familytree_display_known_families(mob/living/carbon/human/user)
	if(!user)
		return

	if(!known_people || !known_people.len)
		to_chat(user, span_warning("I don't know any families."))
		return

	var/list/house_entries = list()
	var/list/house_names = list()
	var/list/added_names = list()

	for(var/datum/mind/M as anything in SSticker.minds)
		if(!ishuman(M.current))
			continue

		var/mob/living/carbon/human/H = M.current
		if(!H.family_datum || !known_people[H.real_name] || added_names[H.real_name])
			continue

		added_names[H.real_name] = TRUE

		var/house_name = trim("[H.family_datum.housename]")
		if(!house_name)
			house_name = "Nameless"

		var/house_key = uppertext(house_name)
		if(!house_entries[house_key])
			house_entries[house_key] = list()
			house_names += house_key
		var/list/entries = house_entries[house_key]

		var/list/person_info = known_people[H.real_name]
		var/list/details = list()
		var/relation = familytree_get_known_family_relation(user, H)
		if(relation)
			details += capitalize(relation)

		var/fjob = person_info["FJOB"]
		if(fjob)
			details += fjob

		var/fgender = person_info["FGENDER"]
		if(fgender)
			details += capitalize(fgender)

		var/fspecies = person_info["FSPECIES"]
		if(fspecies)
			details += fspecies

		var/fage = person_info["FAGE"]
		if(fage)
			details += "[fage]"

		var/fheresy = person_info["FHERESY"]
		entries += list(list(
			"name" = H.real_name,
			"label" = fheresy,
			"details" = details,
		))

	if(!house_names.len)
		to_chat(user, span_warning("I don't know any families."))
		return

	house_names = sortList(house_names)

	var/datum/familytree_display_panel/panel = new(
		user,
		"Known Families of [name || user.real_name]",
		"Shows currently present known people with active family data.",
		"I don't know any families.",
	)

	for(var/house_key in house_names)
		panel.add_section("THE [house_key] HOUSE", house_entries[house_key])

	panel.ui_interact(user)

/mob/living/carbon/human/verb/known_families()
	set name = "Known Families"
	set category = "IC"

	if(!mind)
		to_chat(src, span_warning("I don't know any families."))
		return

	mind.familytree_display_known_families(src)

/mob/living/carbon/human/get_villain_text(mob/examiner)
	. = ..()

	if(!ishuman(examiner) || !family_datum)
		return

	var/mob/living/carbon/human/H = examiner
	if(family_datum != H.family_datum)
		return

	var/family_text = ReturnRelation(H)
	if(!family_text)
		return

	if(.)
		. += "<br>"
	. += family_text

/mob/living/carbon/human/proc/MixDNA(mob/living/carbon/human/parent1, mob/living/carbon/human/parent2, override = FALSE)
	if(!dna)
		return FALSE

	dna.update_dna_identity()
	updateappearance()
	return TRUE
