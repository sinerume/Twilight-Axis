// Consolidated low-churn helper declarations for the familytree module.

/datum/preferences
	var/setspouse = ""
	var/datum/family_options/family_options
	var/gender_choice_pref = ANY_GENDER
	var/species_preference_mode = "ANY"
	var/preferred_species_type
	var/preferred_species_anatomy = 0
	var/tmp/familytree_module_loaded_slot
	var/tmp/familytree_module_loaded_path

/mob/living/carbon/human
	var/family_UI = FALSE
	var/mob/living/carbon/spouse_mob
	var/image/spouse_indicator
	var/setspouse
	var/gender_choice_pref = ANY_GENDER
	var/familytree_pref = FAMILY_NONE
	var/datum/heritage/family_datum
	var/datum/family_member/family_member_datum
	var/tmp/familytree_module_signal_bound = FALSE
	var/tmp/familytree_assignment_scheduled = FALSE

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
	preferred_species_type = initial(preferred_species_type)
	preferred_species_anatomy = initial(preferred_species_anatomy)

/datum/preferences/proc/familytree_module_sanitize_character()
	family = sanitize_integer(family, FAMILY_NONE, FAMILY_NEWLYWED, FAMILY_NONE)
	gender_choice_pref = sanitize_integer(gender_choice_pref, ANY_GENDER, DIFFERENT_GENDER, ANY_GENDER)
	species_preference_mode = sanitize_text(species_preference_mode, "ANY")
	if(!(species_preference_mode in list("ANY", "SAME_TYPE", "SPECIFIC_TYPE")))
		species_preference_mode = "ANY"
	if(species_preference_mode != "SPECIFIC_TYPE")
		preferred_species_type = null
	else if(!istext(preferred_species_type) || !(preferred_species_type in get_selectable_species()))
		species_preference_mode = "ANY"
		preferred_species_type = null
	if(!(preferred_species_anatomy in list(0, 1, 2)))
		preferred_species_anatomy = text2num("[preferred_species_anatomy]")
	if(!(preferred_species_anatomy in list(0, 1, 2)))
		preferred_species_anatomy = 0
	if(!istext(setspouse))
		setspouse = ""
	else
		setspouse = copytext(setspouse, 1, 65)

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
			S["preferred_species_type"] >> preferred_species_type
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
	WRITE_FILE(S["preferred_species_type"], preferred_species_type)
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

/client/verb/family_preferences()
	set name = "Family Preferences"
	set category = "Options"
	set desc = ""

	familytree_module_open_preferences(mob)

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

	for(var/datum/mind/M in SSticker.minds)
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
		var/fcolor = person_info["VCOLOR"]
		if(!fcolor)
			fcolor = H.voice_color
		if(!fcolor)
			fcolor = "FFFFFF"

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

		var/detail_text = jointext(details, ", ")
		var/entry_html = ""
		var/fheresy = person_info["FHERESY"]
		if(fheresy)
			entry_html += "<B><font color=#f1d669>[fheresy]</font></B> "
		entry_html += "<B><font color=#[fcolor];text-shadow:0 0 10px #8d5958, 0 0 20px #8d5958, 0 0 30px #8d5958, 0 0 40px #8d5958, 0 0 50px #e60073, 0 0 60px #8d5958, 0 0 70px #8d5958;>[H.real_name]</font></B>"
		if(detail_text)
			entry_html += "<BR>[detail_text]"

		entries += entry_html

	if(!house_names.len)
		to_chat(user, span_warning("I don't know any families."))
		return

	house_names = sortList(house_names)

	var/contents = "<center>Known families of [name || user.real_name]:</center><BR>"
	contents += "<i>Shows currently present known people with active family data.</i><BR><BR>"

	for(var/house_key in house_names)
		contents += "<center><B>THE [house_key] HOUSE</B></center><BR>"
		for(var/entry_html in house_entries[house_key])
			contents += "[entry_html]<BR><BR>"

	var/datum/browser/popup = new(user, "KNOWNFAMILIES", "", 320, 420)
	popup.set_content(contents)
	popup.open()

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
