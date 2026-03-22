/datum/controller/subsystem/familytree/proc/ensure_royal_partner_job_baselines()
	if(royal_partner_job_baselines.len)
		return TRUE

	var/datum/job/consort_job = find_job_by_type(/datum/job/roguetown/lady)
	var/datum/job/suitor_job = find_job_by_type(/datum/job/roguetown/suitor)

	if(consort_job)
		royal_partner_job_baselines["consort"] = list(
			"allowed_races" = islist(consort_job.allowed_races) ? consort_job.allowed_races.Copy() : list(),
			"allowed_sexes" = islist(consort_job.allowed_sexes) ? consort_job.allowed_sexes.Copy() : list(),
			"total_positions" = consort_job.total_positions,
			"spawn_positions" = consort_job.spawn_positions,
		)

	if(suitor_job)
		royal_partner_job_baselines["suitor"] = list(
			"allowed_races" = islist(suitor_job.allowed_races) ? suitor_job.allowed_races.Copy() : list(),
			"allowed_sexes" = islist(suitor_job.allowed_sexes) ? suitor_job.allowed_sexes.Copy() : list(),
			"total_positions" = suitor_job.total_positions,
			"spawn_positions" = suitor_job.spawn_positions,
		)

	return royal_partner_job_baselines.len >= 2

/datum/controller/subsystem/familytree/proc/get_royal_partner_mode_from_preferences(datum/preferences/P)
	if(!P)
		return "closed"

	switch(P.family)
		if(FAMILY_NEWLYWED)
			return "consort"
		if(FAMILY_PARTIAL, FAMILY_FULL)
			return "suitor"

	return "closed"

/datum/controller/subsystem/familytree/proc/get_preference_species_type_list(datum/preferences/P) as /list
	var/list/result = list()
	if(!P)
		return result

	if(!islist(P.preferred_species_types))
		return result

	for(var/entry in P.preferred_species_types)
		var/species_type = entry
		if(istext(species_type))
			species_type = GLOB.species_list[species_type]
		if(!ispath(species_type, /datum/species))
			continue
		if(species_type in result)
			continue
		result += species_type

	return result

/datum/controller/subsystem/familytree/proc/get_royal_partner_allowed_races(mob/living/carbon/human/duke, datum/preferences/P, list/default_races) as /list
	var/list/allowed_races = islist(default_races) ? default_races.Copy() : list()
	if(!P)
		return allowed_races

	var/duke_species_type = duke?.client?.prefs?.pref_species?.type
	if(!ispath(duke_species_type, /datum/species))
		duke_species_type = duke?.dna?.species?.type

	switch(P.species_preference_mode)
		if("SAME_TYPE")
			if(ispath(duke_species_type, /datum/species))
				return list(duke_species_type)
		if("SPECIFIC_TYPE")
			var/list/preferred_species = get_preference_species_type_list(P)
			if(preferred_species.len)
				return preferred_species

	return allowed_races

/datum/controller/subsystem/familytree/proc/get_royal_partner_allowed_sexes(mob/living/carbon/human/duke, datum/preferences/P, list/default_sexes) as /list
	var/list/allowed_sexes = islist(default_sexes) ? default_sexes.Copy() : list()
	if(!P)
		return allowed_sexes

	var/duke_body_type = duke?.client?.prefs?.gender
	if(duke_body_type != MALE && duke_body_type != FEMALE)
		duke_body_type = duke?.gender

	switch(P.gender_choice_pref)
		if(SAME_GENDER)
			if(duke_body_type == MALE || duke_body_type == FEMALE)
				return list(duke_body_type)
		if(DIFFERENT_GENDER)
			if(duke_body_type == MALE)
				return list(FEMALE)
			if(duke_body_type == FEMALE)
				return list(MALE)

	return allowed_sexes

/datum/controller/subsystem/familytree/proc/apply_royal_partner_job_state(job_key, enabled, open_slots = 0, list/allowed_races, list/allowed_sexes)
	if(!ensure_royal_partner_job_baselines())
		return FALSE

	var/datum/job/job = null
	switch(job_key)
		if("consort")
			job = find_job_by_type(/datum/job/roguetown/lady)
		if("suitor")
			job = find_job_by_type(/datum/job/roguetown/suitor)

	var/list/baseline = royal_partner_job_baselines[job_key]
	if(!job || !baseline)
		return FALSE

	var/list/baseline_allowed_races = baseline["allowed_races"]
	var/list/baseline_allowed_sexes = baseline["allowed_sexes"]
	job.allowed_races = islist(baseline_allowed_races) ? baseline_allowed_races.Copy() : list()
	job.allowed_sexes = islist(baseline_allowed_sexes) ? baseline_allowed_sexes.Copy() : list()
	job.total_positions = baseline["total_positions"]
	job.spawn_positions = baseline["spawn_positions"]

	if(enabled)
		job.allowed_races = islist(allowed_races) ? allowed_races.Copy() : list()
		job.allowed_sexes = islist(allowed_sexes) ? allowed_sexes.Copy() : list()
		job.total_positions = open_slots
		job.spawn_positions = open_slots
	else
		job.total_positions = 0
		job.spawn_positions = 0

	return TRUE

/datum/controller/subsystem/familytree/proc/reset_royal_partner_jobs()
	current_royal_partner_owner = null
	current_royal_partner_mode = "closed"
	current_royal_partner_snapshot = list()

	apply_royal_partner_job_state("consort", FALSE)
	apply_royal_partner_job_state("suitor", FALSE)

/datum/controller/subsystem/familytree/proc/refresh_royal_partner_jobs(mob/living/carbon/human/duke, datum/preferences/P)
	if(!duke?.client)
		return FALSE

	if(!ensure_royal_partner_job_baselines())
		return FALSE

	if(!P)
		P = duke.client.prefs
	if(!P)
		return FALSE

	if(current_royal_partner_owner == duke && current_royal_partner_snapshot.len)
		return TRUE

	if(current_royal_partner_owner && current_royal_partner_owner != duke)
		return FALSE

	P.familytree_module_load_character()

	var/mode = get_royal_partner_mode_from_preferences(P)
	var/list/consort_baseline = royal_partner_job_baselines["consort"]
	var/list/suitor_baseline = royal_partner_job_baselines["suitor"]
	if(!consort_baseline || !suitor_baseline)
		return FALSE

	var/list/consort_allowed_races = get_royal_partner_allowed_races(duke, P, consort_baseline["allowed_races"])
	var/list/consort_allowed_sexes = get_royal_partner_allowed_sexes(duke, P, consort_baseline["allowed_sexes"])
	var/list/suitor_allowed_races = get_royal_partner_allowed_races(duke, P, suitor_baseline["allowed_races"])
	var/list/suitor_allowed_sexes = get_royal_partner_allowed_sexes(duke, P, suitor_baseline["allowed_sexes"])

	switch(mode)
		if("consort")
			apply_royal_partner_job_state("consort", TRUE, 1, consort_allowed_races, consort_allowed_sexes)
			apply_royal_partner_job_state("suitor", FALSE)
		if("suitor")
			apply_royal_partner_job_state("consort", FALSE)
			apply_royal_partner_job_state("suitor", TRUE, 2, suitor_allowed_races, suitor_allowed_sexes)
		else
			apply_royal_partner_job_state("consort", FALSE)
			apply_royal_partner_job_state("suitor", FALSE)

	current_royal_partner_owner = duke
	current_royal_partner_mode = mode
	current_royal_partner_snapshot = list(
		"family" = P.family,
		"duke_gender" = duke.client?.prefs?.gender,
		"duke_pronouns" = duke.client?.prefs?.pronouns,
		"duke_species_type" = duke.client?.prefs?.pref_species?.type,
		"gender_choice_pref" = P.gender_choice_pref,
		"species_preference_mode" = P.species_preference_mode,
		"preferred_species_types" = islist(P.preferred_species_types) ? P.preferred_species_types.Copy() : list(),
		"preferred_species_anatomy" = P.preferred_species_anatomy,
		"setspouse" = P.setspouse,
	)
	return TRUE

/datum/controller/subsystem/familytree/proc/get_royal_partner_job_key(role_or_job)
	var/datum/job/job = resolve_job_datum(role_or_job)
	if(is_royal_consort_job(job))
		return "consort"
	if(is_royal_suitor_job(job))
		return "suitor"
	return null

/datum/controller/subsystem/familytree/proc/royal_partner_species_match(datum/preferences/P)
	if(!P)
		return FALSE

	var/species_type = P.pref_species?.type
	if(!ispath(species_type, /datum/species))
		return FALSE

	var/preference_mode = current_royal_partner_snapshot["species_preference_mode"]
	var/duke_species_type = current_royal_partner_snapshot["duke_species_type"]
	var/list/preferred_species_types = current_royal_partner_snapshot["preferred_species_types"]

	if(!islist(preferred_species_types))
		preferred_species_types = list()

	var/list/resolved_species = list()
	for(var/entry in preferred_species_types)
		var/species_entry = entry
		if(istext(species_entry))
			species_entry = GLOB.species_list[species_entry]
		if(ispath(species_entry, /datum/species))
			resolved_species += species_entry

	switch(preference_mode)
		if("SAME_TYPE")
			return species_type == duke_species_type
		if("SPECIFIC_TYPE")
			return species_type in resolved_species

	return TRUE

/datum/controller/subsystem/familytree/proc/royal_partner_gender_match(datum/preferences/P)
	if(!P)
		return FALSE

	var/gender_pref = current_royal_partner_snapshot["gender_choice_pref"]
	if(!gender_pref || gender_pref == ANY_GENDER)
		return TRUE

	var/duke_pronouns = current_royal_partner_snapshot["duke_pronouns"]
	var/candidate_pronouns = P.pronouns
	if(!isnull(duke_pronouns) && !isnull(candidate_pronouns))
		if(gender_pref == SAME_GENDER)
			return duke_pronouns == candidate_pronouns
		if(gender_pref == DIFFERENT_GENDER)
			return duke_pronouns != candidate_pronouns

	var/duke_gender = current_royal_partner_snapshot["duke_gender"]
	var/candidate_gender = P.gender
	if(gender_pref == SAME_GENDER)
		return duke_gender == candidate_gender
	if(gender_pref == DIFFERENT_GENDER)
		return duke_gender != candidate_gender

	return TRUE

/datum/controller/subsystem/familytree/proc/royal_partner_anatomy_match(datum/preferences/P)
	if(!P)
		return FALSE

	var/anatomy_pref = current_royal_partner_snapshot["preferred_species_anatomy"]
	switch(anatomy_pref)
		if(0)
			return TRUE
		if(1)
			return P.familytree_module_has_penis()
		if(2)
			return P.familytree_module_has_vagina()

	return TRUE

/datum/controller/subsystem/familytree/proc/royal_partner_name_match(datum/preferences/P)
	if(!P)
		return FALSE

	var/required_name = current_royal_partner_snapshot["setspouse"]
	if(!istext(required_name) || !length(required_name))
		return TRUE

	return P.real_name == required_name

/datum/controller/subsystem/familytree/proc/royal_partner_candidate_allowed(client/C, role_or_job)
	if(!C?.prefs || !current_royal_partner_owner || !current_royal_partner_snapshot.len)
		return FALSE

	var/job_key = get_royal_partner_job_key(role_or_job)
	if(!job_key || current_royal_partner_mode != job_key)
		return FALSE

	var/datum/preferences/P = C.prefs
	if(!royal_partner_species_match(P))
		return FALSE
	if(!royal_partner_gender_match(P))
		return FALSE
	if(!royal_partner_anatomy_match(P))
		return FALSE
	if(job_key == "consort" && !royal_partner_name_match(P))
		return FALSE

	return TRUE

/datum/controller/subsystem/familytree/proc/AddRoyal(mob/living/carbon/human/H, status)
	if(!H)
		return
	var/block_reason = get_familytree_runtime_block_reason(H, TRUE)
	if(block_reason == "dead")
		pause_familytree_human(H, "royal assignment blocked: dead")
		return
	if(block_reason == "no client")
		return
	if(block_reason)
		unsubscribe_familytree_human(H, "royal assignment blocked: [block_reason]")
		return
	if(!ruling_family.housename)
		ruling_family.housename = " Royal"
	var/datum/family_member/member = ruling_family.CreateFamilyMember(H)
	if(!member)
		stop_tracking_human(H, "royal assignment failed; member creation returned null")
		return

	if(!ruling_family.founder)
		GenerateRoyalLineage(member, status)
		H.ShowFamilyUI(TRUE)
		stop_tracking_human(H, "royal lineage generated")
		return

	switch(status)
		if(FAMILY_FATHER, FAMILY_MOTHER)
			var/datum/family_member/existing_monarch = GetCurrentMonarch()
			member.generation = 12
			if(existing_monarch)
				ruling_family.MarryMembers(existing_monarch, member)

		if(FAMILY_PROGENY)
			var/datum/family_member/monarch = GetCurrentMonarch()
			if(monarch)
				member.generation = monarch.generation + 1
				member.AddParent(monarch)
				if(monarch.spouses.len)
					member.AddParent(monarch.spouses[1])

		if(FAMILY_OMMER)
			CreateBranchFamily(member)

	H.ShowFamilyUI(TRUE)
	stop_tracking_human(H, "royal assignment completed")

/datum/controller/subsystem/familytree/proc/GetCurrentMonarch()
	for(var/datum/family_member/member as anything in ruling_family.members)
		if(member.generation == 12 && is_royal_monarch_job(get_familytree_job(member.person)))
			return member
	return null

/datum/controller/subsystem/familytree/proc/CreateBranchFamily(datum/family_member/hand_member)
	var/datum/family_member/monarch = GetCurrentMonarch()
	if(!monarch)
		return

	hand_member.generation = monarch.generation

	if(monarch.parents.len)
		var/datum/family_member/monarch_parent = monarch.parents[1]
		var/datum/family_member/monarch_parent_second = monarch.parents[2]
		if(monarch_parent)
			hand_member.AddParent(monarch_parent)
		if(monarch_parent_second)
			hand_member.AddParent(monarch_parent_second)

		var/mob/living/carbon/human/dummy/spouse = new()
		spouse.age = hand_member.person.age
		if(hand_member.person.titles_pref == TITLES_F)
			spouse.gender = MALE
		else if(hand_member.person.titles_pref == TITLES_M)
			spouse.gender = FEMALE
		else
			spouse.gender = hand_member.person.pronouns == HE_HIM ? FEMALE : MALE
		spouse.real_name = GenerateRoyalName(spouse.gender, hand_member.generation)
		var/datum/family_member/hand_spouse = ruling_family.CreateFamilyMember(spouse)
		hand_spouse.generation = hand_member.generation
		ruling_family.MarryMembers(hand_member, hand_spouse)

/datum/controller/subsystem/familytree/proc/GenerateRoyalLineage(datum/family_member/current_royal, status)
	if(!current_royal?.person)
		return

	ruling_family.founder = current_royal
	current_royal.generation = 12

	ruling_family.dominant_species = current_royal.person.dna.species.type

	var/datum/family_member/current_ancestor = current_royal
	var/list/age_progression = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_OLD)

	for(var/i = current_royal.generation - 1; i >= 6; i--)
		var/mob/living/carbon/human/dummy/ancestor = new()
		ancestor.age = age_progression[min(current_royal.generation - i, age_progression.len)]
		ancestor.gender = prob(50) ? MALE : FEMALE
		ancestor.real_name = GenerateRoyalName(ancestor.gender, i)
		set_species_type(ancestor, ruling_family.dominant_species)
		var/datum/family_member/parent = ruling_family.CreateFamilyMember(ancestor)
		parent.generation = i

		var/mob/living/carbon/human/dummy/spouse = new()
		spouse.age = ancestor.age
		spouse.gender = ancestor.gender == MALE ? FEMALE : MALE
		spouse.real_name = GenerateRoyalName(spouse.gender, i)
		set_species_type(spouse, ruling_family.dominant_species)
		var/datum/family_member/parent_spouse = ruling_family.CreateFamilyMember(spouse)
		parent_spouse.generation = i

		ruling_family.MarryMembers(parent, parent_spouse)
		current_ancestor.AddParent(parent)
		current_ancestor.AddParent(parent_spouse)

		if(prob(30))
			var/mob/living/carbon/human/dummy/sibling = new()
			sibling.age = ancestor.age
			sibling.gender = prob(50) ? MALE : FEMALE
			sibling.real_name = GenerateRoyalName(sibling.gender, i + 1)
			set_species_type(sibling, ruling_family.dominant_species)
			var/datum/family_member/sibling_member = ruling_family.CreateFamilyMember(sibling)
			sibling_member.generation = i + 1
			sibling_member.AddParent(parent)
			sibling_member.AddParent(parent_spouse)

		current_ancestor = parent

/datum/controller/subsystem/familytree/proc/set_species_type(mob/living/carbon/human/H, species_type)
	if(!H || !species_type)
		return

	var/datum/species/S = new species_type
	H.set_species(S)
	H.dna.species = S

/datum/controller/subsystem/familytree/proc/GenerateRoyalName(gender, generation)
	var/list/male_names = list(
		"King" = list("Otto", "Arnulf", "Ludwig", "Henri", "Louis", "Francois"),
		"Prince" = list("Karl", "Konrad", "Heinrich", "Raoul", "Hugues")
	)
	var/list/female_names = list(
		"Queen" = list("Hildegard", "Freya", "Helga", "Jeanne", "Adeline"),
		"Princess" = list("Karoline", "Hedwig", "Anneliese", "Elise")
	)

	var/title
	var/list/names
	if(gender == MALE)
		title = generation > 2 ? "King" : "Prince"
		names = male_names[title]
	else
		title = generation > 2 ? "Queen" : "Princess"
		names = female_names[title]

	var/list/roman_numerals = list("I", "II", "III", "IV", "V")
	return "[title] [pick(names)] [pick(roman_numerals)]"
