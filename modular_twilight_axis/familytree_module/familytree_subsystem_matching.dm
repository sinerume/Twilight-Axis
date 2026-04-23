/datum/controller/subsystem/familytree/proc/familytree_join_create_phase_open()
	if(!SSticker?.round_start_time)
		return TRUE
	return (world.time - SSticker.round_start_time) >= FAMILYTREE_JOIN_CREATE_DELAY

/datum/controller/subsystem/familytree/proc/familytree_join_create_delay_remaining()
	if(familytree_join_create_phase_open())
		return 0
	if(!SSticker?.round_start_time)
		return 0
	return max(0, FAMILYTREE_JOIN_CREATE_DELAY - (world.time - SSticker.round_start_time))

/datum/controller/subsystem/familytree/proc/familytree_relative_join_phase_open()
	if(!SSticker?.round_start_time)
		return TRUE
	return (world.time - SSticker.round_start_time) >= FAMILYTREE_RELATIVE_JOIN_DELAY

/datum/controller/subsystem/familytree/proc/familytree_join_create_fallback_open()
	return familytree_join_create_phase_open() && !familytree_relative_join_phase_open()

/datum/controller/subsystem/familytree/proc/familytree_relative_join_delay_remaining()
	if(familytree_relative_join_phase_open())
		return 0
	if(!SSticker?.round_start_time)
		return 0
	return max(0, FAMILYTREE_RELATIVE_JOIN_DELAY - (world.time - SSticker.round_start_time))

/datum/controller/subsystem/familytree/proc/wait_for_relative_join_phase(mob/living/carbon/human/H, reason)
	if(!H || QDELETED(H) || H.family_datum || H.familytree_opted_out)
		return
	if(H.familytree_assignment_scheduled)
		ftlog("WAIT_JOIN_PHASE SKIP: [H.real_name] already scheduled reason=[reason]")
		return
	var/jitter = rand(10, 100)
	var/delay = max(10 SECONDS, familytree_relative_join_delay_remaining() + jitter)
	ftlog("WAIT_JOIN_PHASE: [H.real_name] reason=[reason], scheduling re-assignment in [delay / 10]s")
	H.familytree_assignment_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, H.familytree_pref), delay)

/datum/controller/subsystem/familytree/proc/wait_for_join_create_phase(mob/living/carbon/human/H, reason)
	if(!H || QDELETED(H) || H.family_datum || H.familytree_opted_out)
		return
	if(H.familytree_assignment_scheduled)
		ftlog("WAIT_JOIN_CREATE_PHASE SKIP: [H.real_name] already scheduled reason=[reason]")
		return
	var/jitter = rand(10, 100)
	var/delay = max(10 SECONDS, familytree_join_create_delay_remaining() + jitter)
	ftlog("WAIT_JOIN_CREATE_PHASE: [H.real_name] reason=[reason], scheduling re-assignment in [delay / 10]s")
	H.familytree_assignment_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, H.familytree_pref), delay)

/datum/controller/subsystem/familytree/proc/AddLocal(mob/living/carbon/human/H, status)
	ftlog("AddLocal: [H?.real_name] ([H?.ckey]) status=[status]")
	if(!H || istype(H, /mob/living/carbon/human/dummy))
		return
	var/family_mode = familytree_pref_mask(status)
	if(!family_mode)
		return
	if(H.familytree_opted_out)
		return

	var/block_reason = get_familytree_runtime_block_reason(H, TRUE)
	if(block_reason == "dead")
		pause_familytree_human(H, "local assignment blocked: dead")
		return
	if(block_reason == "no client")
		return
	if(block_reason)
		unsubscribe_familytree_human(H, "local assignment blocked: [block_reason]")
		return

	var/royal_status = get_royal_status(H)
	if(royal_status && royal_status != FAMILY_OMMER)
		ftlog("AddLocal SKIP: [H.real_name] royal flow")
		stop_tracking_human(H, "local assignment skipped; handled by royal flow")
		return
	if(is_royal_suitor_job(get_familytree_job(H)))
		ftlog("AddLocal SKIP: [H.real_name] suitor job")
		stop_tracking_human(H, "local assignment skipped; suitor job")
		return

	var/join_create_phase_open = familytree_join_create_phase_open()
	var/relative_join_phase_open = familytree_relative_join_phase_open()

	var/target_name = familytree_get_target_name(H)
	if(target_name && length(target_name))
		ftlog("AddLocal: [H.real_name] has favorite=[target_name], trying favorite assign (retry #[H.familytree_setspouse_retries])")
		var/favorite_result = TryAssignToFavorite(H, status)
		if(favorite_result == "assigned")
			stop_tracking_human(H, "assigned via favorite")
			return
		if(favorite_result == "phase_locked")
			wait_for_relative_join_phase(H, "favorite house join is phase locked")
			return
		if(favorite_result == "waiting")
			if(!relative_join_phase_open && (family_mode & FAMILYTREE_MODE_JOIN) && !(family_mode & FAMILYTREE_MODE_CREATE))
				if(!join_create_phase_open)
					wait_for_join_create_phase(H, "favorite unavailable before join/create fallback phase")
					return
				find_and_confirm_newlywed(H)
				wait_for_relative_join_phase(H, "favorite unavailable during join/create fallback phase")
				return
			H.familytree_setspouse_retries++
			if(H.familytree_setspouse_retries >= 30 && !H.familytree_setspouse_timeout_offered)
				H.familytree_setspouse_timeout_offered = TRUE
				ftlog("AddLocal: [H.real_name] setspouse timeout reached (30 retries), offering reset")
				INVOKE_ASYNC(src, PROC_REF(offer_setspouse_reset), H, status)
				return
			ftlog("AddLocal: [H.real_name] favorite not found, waiting 60s")
			H.familytree_assignment_scheduled = TRUE
			addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, status), 60 SECONDS)
			return

	var/can_try_relative_join = relative_join_phase_open && (family_mode & FAMILYTREE_MODE_JOIN)

	if(!relative_join_phase_open && (family_mode & FAMILYTREE_MODE_JOIN))
		ftlog("AddLocal: [H.real_name] relative join phase locked; join_create_phase=[join_create_phase_open], create_mode=[!!(family_mode & FAMILYTREE_MODE_CREATE)]")

	if(can_try_relative_join && H.desired_relative_role == RELATIVE_ANY && try_assign_noble_to_dynasty(H))
		return

	if(can_try_relative_join && H.desired_relative_role != RELATIVE_ANY)
		ftlog("AddLocal: [H.real_name] desired_role=[H.desired_relative_role], trying role assign")
		if(H.desired_relative_role == RELATIVE_SPOUSE)
			INVOKE_ASYNC(src, PROC_REF(find_and_confirm_family), H, FALSE)
		else
			var/forced_role = familytree_forced_role_from_relative_role(H.desired_relative_role)
			if(forced_role && !HasSuitableHouseForRelative(H, forced_role))
				wait_for_relative_house(H, "no suitable house for selected role")
				return
			request_family_confirmation(H, CALLBACK(src, PROC_REF(do_assign_desired_role), H), "house")
		return

	var/can_fallthrough_from_join = !!(family_mode & (FAMILYTREE_MODE_CREATE | FAMILYTREE_MODE_LEGACY_SPOUSE))
	if(can_try_relative_join)
		if(HasSuitableHouseForRelative(H))
			ftlog("AddLocal: [H.real_name] -> AssignToHouse (pending confirm)")
			request_family_confirmation(H, CALLBACK(src, PROC_REF(do_assign_house), H), "house")
			return
		else
			ftlog("AddLocal: [H.real_name] -> NO suitable house")
			if(!can_fallthrough_from_join)
				wait_for_relative_house(H, "no suitable house for relative")
				return

	if(family_mode & FAMILYTREE_MODE_CREATE)
		ftlog("AddLocal: [H.real_name] -> FindNewlyWedMatch")
		if(find_and_confirm_newlywed(H))
			return
		if(!(family_mode & FAMILYTREE_MODE_LEGACY_SPOUSE))
			return
		if(!relative_join_phase_open)
			if(!join_create_phase_open)
				wait_for_join_create_phase(H, "legacy spouse fallback locked before join/create phase")
			else
				wait_for_relative_join_phase(H, "legacy spouse fallback locked during join/create phase")
			return
		viable_spouses -= H

	if(!relative_join_phase_open && (family_mode & FAMILYTREE_MODE_JOIN))
		if(!join_create_phase_open)
			ftlog("AddLocal: [H.real_name] waiting for join/create fallback phase")
			wait_for_join_create_phase(H, "join/create fallback phase locked")
			return
		ftlog("AddLocal: [H.real_name] waiting for relative join phase while available as new-family partner")
		find_and_confirm_newlywed(H)
		wait_for_relative_join_phase(H, "relative join phase locked")
		return

	if(!relative_join_phase_open && (family_mode & FAMILYTREE_MODE_LEGACY_SPOUSE))
		if(!join_create_phase_open)
			wait_for_join_create_phase(H, "legacy spouse flow locked before join/create phase")
		else
			wait_for_relative_join_phase(H, "legacy spouse flow locked during join/create phase")
		return

	if(family_mode & FAMILYTREE_MODE_LEGACY_SPOUSE)
		if(H.virginity && !xylix_roulette_active)
			ftlog("AddLocal: [H.real_name] SKIP: virginity gate")
			stop_tracking_human(H, "legacy full family flow skipped; virginity gate")
			return
		ftlog("AddLocal: [H.real_name] -> FindFamilyMatch")
		INVOKE_ASYNC(src, PROC_REF(find_and_confirm_family), H)

/datum/controller/subsystem/familytree/proc/do_assign_house(mob/living/carbon/human/H)
	if(!H || QDELETED(H) || H.family_datum)
		return
	if(!familytree_relative_join_phase_open())
		wait_for_relative_join_phase(H, "house confirmation accepted before join phase")
		return
	ftlog("do_assign_house: [H.real_name] confirmed, calling AssignToHouse")
	AssignToHouse(H)
	if(H.family_datum)
		to_chat(H, span_love("Вы успешно присоединились к семье!"))
		stop_tracking_human(H, "assigned to house")
	else
		retry_local_assignment(H, "no suitable house found after confirm")

/datum/controller/subsystem/familytree/proc/do_assign_desired_role(mob/living/carbon/human/H)
	if(!H || QDELETED(H) || H.family_datum)
		return
	if(!familytree_relative_join_phase_open())
		wait_for_relative_join_phase(H, "desired role confirmation accepted before join phase")
		return
	var/block_reason = get_familytree_runtime_block_reason(H, TRUE)
	if(block_reason)
		retry_local_assignment(H, "desired role blocked: [block_reason]")
		return
	AssignWithDesiredRole(H)
	if(H.family_datum || H.spouse_mob)
		ftlog("AddLocal: [H.real_name] assigned via desired role")
		stop_tracking_human(H, "assigned via desired relative role")
	else
		retry_local_assignment(H, "no suitable family found for selected role")

/datum/controller/subsystem/familytree/proc/find_and_confirm_newlywed(mob/living/carbon/human/H)
	if(!H || QDELETED(H))
		return FALSE
	if(H.family_datum)
		return FALSE
	if(H.familytree_confirmation_pending)
		return FALSE
	if(!familytree_is_new_family_candidate(H))
		return FALSE
	var/mob/living/carbon/human/match = FindNewlyWedMatch(H)
	if(!match)
		ftlog("AddLocal: [H.real_name] newlywed no match found")
		return FALSE
	var/relation = familytree_new_family_pair_relation(H, match)
	if(relation == "spouse")
		if(H.spouse_mob && !familytree_can_have_multiple_spouses(H))
			return FALSE
		ftlog("AddLocal: [H.real_name] newlywed match=[match.real_name], requesting mutual confirm")
		request_mutual_confirmation(H, match, CALLBACK(src, PROC_REF(do_execute_newlywed), H, match), "spouse")
		return TRUE
	if(relation)
		ftlog("AddLocal: [H.real_name] new-family relation=[relation] match=[match.real_name], requesting mutual confirm")
		request_mutual_confirmation(H, match, CALLBACK(src, PROC_REF(do_execute_new_family_relative), H, match, relation), "family")
		return TRUE
	return FALSE

/datum/controller/subsystem/familytree/proc/do_execute_newlywed(mob/living/carbon/human/H, mob/living/carbon/human/spouse)
	if(!H || QDELETED(H))
		return
	if(!spouse || QDELETED(spouse))
		retry_local_assignment(H, "spouse unavailable after confirm")
		return
	if(H.family_datum || spouse.family_datum)
		retry_local_assignment(H, "new family spouse already has a family")
		return
	if(familytree_new_family_pair_relation(H, spouse) != "spouse")
		retry_local_assignment(H, "spouse no longer wants to create a new family")
		return
	if(!familytree_new_family_relation_valid(H, spouse, "spouse"))
		retry_local_assignment(H, "spouse role no longer compatible")
		return
	if(familytree_new_family_pair_pref_reject_mask(H, spouse))
		retry_local_assignment(H, "spouse no longer matches creator preferences")
		return
	if(!familytree_estates_compatible(H, spouse))
		retry_local_assignment(H, "spouse estate no longer compatible")
		return
	if(!familytree_polygamy_compatible(H, spouse))
		retry_local_assignment(H, "spouse already married")
		return
	ftlog("AddLocal: [H.real_name] + [spouse.real_name] -> MarryTo (both confirmed)")
	viable_spouses -= H
	viable_spouses -= spouse
	var/mob/living/carbon/human/founder = familytree_new_family_founder(H, spouse)
	var/mob/living/carbon/human/partner = founder == H ? spouse : H
	var/datum/heritage/family = founder.MarryTo(partner)
	if(family)
		family.closed = FALSE
		if(!family.house_leader)
			family.house_leader = founder.family_member_datum || family.founder
		on_family_formed(family)
		wake_waiting_relative_seekers(family)
		familytree_admin_log_house_assignment(H, family, "created new house with spouse [key_name(spouse)]", spouse.family_member_datum)
		familytree_admin_log_house_assignment(spouse, family, "created new house with spouse [key_name(H)]", H.family_member_datum)
	introduce_pair(H, spouse)
	bestow_wedding_rings(H, spouse)
	stop_tracking_human(H, "newlywed flow matched spouse")
	stop_tracking_human(spouse, "newlywed flow matched spouse")

/datum/controller/subsystem/familytree/proc/do_execute_new_family_relative(mob/living/carbon/human/H, mob/living/carbon/human/relative, expected_relation)
	if(!H || QDELETED(H))
		return
	if(!relative || QDELETED(relative))
		retry_local_assignment(H, "relative unavailable after confirm")
		return
	if(H.family_datum || relative.family_datum)
		retry_local_assignment(H, "new family relative already has a family")
		return
	var/relation = familytree_new_family_pair_relation(H, relative)
	if(relation != expected_relation)
		retry_local_assignment(H, "relative no longer wants this new family role")
		return
	if(!familytree_new_family_relation_valid(H, relative, relation))
		retry_local_assignment(H, "relative role no longer compatible")
		return
	if(familytree_new_family_pair_pref_reject_mask(H, relative))
		retry_local_assignment(H, "relative no longer matches creator preferences")
		return
	if(!familytree_estates_compatible(H, relative))
		retry_local_assignment(H, "relative estate no longer compatible")
		return
	if(!familytree_role_tiers_compatible(H, relative))
		retry_local_assignment(H, "relative role tier no longer compatible")
		return
	var/mob/living/carbon/human/leader = familytree_new_family_founder(H, relative)
	var/datum/heritage/family = familytree_create_new_relative_house(leader, H, relative, relation)
	if(!family)
		retry_local_assignment(H, "relative house creation failed")
		return
	on_family_formed(family)
	wake_waiting_relative_seekers(family)
	introduce_pair(H, relative)
	familytree_admin_log_house_assignment(H, family, familytree_new_family_relation_audit_text(H, relative, relation, TRUE), relative.family_member_datum)
	familytree_admin_log_house_assignment(relative, family, familytree_new_family_relation_audit_text(H, relative, relation, FALSE), H.family_member_datum)
	stop_tracking_human(H, "new family relative flow matched")
	stop_tracking_human(relative, "new family relative flow matched")
	ask_open_sibling_house(leader, family)

/datum/controller/subsystem/familytree/proc/find_and_confirm_family(mob/living/carbon/human/H, create_if_no_match = TRUE)
	if(!H || QDELETED(H) || H.family_datum)
		return
	if(H.familytree_confirmation_pending)
		return
	var/list/match = FindFamilyMatch(H)
	if(!match)
		if(!create_if_no_match)
			ftlog("AddLocal: [H.real_name] family no match found, waiting for a family founder")
			wait_for_new_family_founder(H)
			return
		ftlog("AddLocal: [H.real_name] family no match found, creating new house")
		var/datum/heritage/new_house = new /datum/heritage(H, null)
		register_family(new_house)
		ftlog("AddLocal: [H.real_name] founded new house '[new_house.housename]'")
		familytree_admin_log_house_assignment(H, new_house, "created new house; no compatible family match")
		stop_tracking_human(H, "founded new house (no match)")
		return
	var/datum/heritage/house = match[1]
	var/datum/family_member/partner_member = match[2]
	var/mob/living/carbon/human/partner = partner_member?.person
	if(!partner)
		return
	ftlog("AddLocal: [H.real_name] family match=[partner.real_name] in house=[house.housename], requesting mutual confirm")
	request_mutual_confirmation(H, partner, CALLBACK(src, PROC_REF(do_execute_family), H, house, partner_member), "family")

/datum/controller/subsystem/familytree/proc/do_execute_family(mob/living/carbon/human/H, datum/heritage/house, datum/family_member/partner_member)
	if(!H || QDELETED(H) || H.family_datum)
		return
	if(!familytree_relative_join_phase_open())
		wait_for_relative_join_phase(H, "family spouse confirmation accepted before join phase")
		return
	if(!house || !partner_member?.person)
		retry_local_assignment(H, "partner lost")
		return
	if(!familytree_polygamy_compatible(H, partner_member.person))
		retry_local_assignment(H, "partner already married")
		return
	var/soft_reject_mask = familytree_pair_soft_pref_reject_mask(H, partner_member.person)
	if(soft_reject_mask & FTREJ_N_PRONOUNS)
		retry_local_assignment(H, "partner pronouns no longer compatible")
		return
	if(soft_reject_mask & FTREJ_N_SPECIES)
		retry_local_assignment(H, "partner species or anatomy no longer compatible")
		return
	if(!familytree_estates_compatible(H, partner_member.person))
		retry_local_assignment(H, "partner estate no longer compatible")
		return
	if(!familytree_role_tiers_compatible(H, partner_member.person))
		retry_local_assignment(H, "partner role tier no longer compatible")
		return
	ftlog("AddLocal: [H.real_name] -> AssignToFamily in house=[house.housename] (both confirmed)")
	var/datum/family_member/new_member = house.CreateFamilyMember(H)
	if(new_member)
		house.MarryMembers(new_member, partner_member)
		on_family_formed(house)
		introduce_pair(H, partner_member.person)
		bestow_wedding_rings(H, partner_member.person)
	if(H.family_datum)
		familytree_admin_log_house_assignment(H, house, "joined existing house as spouse of [key_name(partner_member.person)]", partner_member)
		stop_tracking_human(H, "assigned to family")
	else
		retry_local_assignment(H, "family assignment failed")

/datum/controller/subsystem/familytree/proc/TryAssignToFavorite(mob/living/carbon/human/H, status)
	var/target_name = familytree_get_target_name(H)
	if(!target_name || !length(target_name))
		ftlog("TryFavorite SKIP: [H?.real_name] no setspouse")
		return "skip"

	var/status_mode = familytree_pref_mask(status)
	ftlog("TryFavorite: [H.real_name] looking for '[target_name]'")
	var/mob/living/carbon/human/favorite = FindFavoriteMob(H)

	if(!favorite)
		ftlog("TryFavorite: [H.real_name] favorite NOT FOUND, waiting")
		return "waiting"

	ftlog("TryFavorite: [H.real_name] found favorite=[favorite.real_name] ([favorite.ckey])")

	if(favorite.familytree_opted_out)
		return "waiting"
	if(!familytree_name_lock_allows_pair(H, favorite))
		return "waiting"
	if(favorite.familytree_confirmation_pending)
		return "waiting"

	var/mutual_sibling = (H.desired_relative_role == RELATIVE_SIBLING && favorite.desired_relative_role == RELATIVE_SIBLING)

	if(mutual_sibling)
		ftlog("TryFavorite: [H.real_name] + [favorite.real_name] mutual sibling -> mutual confirm")
		request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_form_sibling_house), H, favorite), "sibling_house")
		return "assigned"

	if(favorite.family_datum)
		var/datum/heritage/house = favorite.family_datum
		if(status_mode & FAMILYTREE_MODE_CREATE)
			ftlog("TryFavorite: [H.real_name] favorite [favorite.real_name] already has a family; new-family mode will wait")
			return "waiting"
		if(!familytree_relative_join_phase_open())
			ftlog("TryFavorite: [H.real_name] favorite has house but relative join phase is locked")
			return "phase_locked"
		if((status_mode & FAMILYTREE_MODE_JOIN) && H.desired_relative_role == RELATIVE_SPOUSE)
			if(!familytree_polygamy_compatible(H, favorite))
				return "skip"
			if(familytree_pair_soft_pref_reject_mask(H, favorite))
				return "skip"
			if(!familytree_estates_compatible(H, favorite) || !familytree_role_tiers_compatible(H, favorite))
				return "skip"
			request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_execute_family), H, house, favorite.family_member_datum), "family")
			return "assigned"
		if(status_mode & FAMILYTREE_MODE_LEGACY_SPOUSE)
			var/favorite_has_dummy_spouse = FALSE
			var/list/favorite_spouses = favorite.family_member_datum?.get_spouse_members()
			if(favorite_spouses?.len)
				var/datum/family_member/existing_spouse_member = favorite_spouses[1]
				if(existing_spouse_member?.person && istype(existing_spouse_member.person, /mob/living/carbon/human/dummy))
					favorite_has_dummy_spouse = TRUE
			if(!favorite_has_dummy_spouse && !familytree_polygamy_compatible(H, favorite))
				return "skip"
			if(familytree_pair_soft_pref_reject_mask(H, favorite))
				return "skip"
			if(!familytree_estates_compatible(H, favorite) || !familytree_role_tiers_compatible(H, favorite))
				return "skip"
			request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_execute_family), H, house, favorite.family_member_datum), "family")
		else
			request_family_confirmation(H, CALLBACK(src, PROC_REF(do_assign_to_favorite_house), H, house), "house")
		return "assigned"

	if((status_mode & (FAMILYTREE_MODE_CREATE | FAMILYTREE_MODE_JOIN | FAMILYTREE_MODE_LEGACY_SPOUSE)) && familytree_new_family_pair_eligible(H, favorite))
		var/relation = familytree_new_family_pair_relation(H, favorite)
		if(relation && !familytree_new_family_relation_valid(H, favorite, relation))
			return "skip"
		if(familytree_new_family_pair_pref_reject_mask(H, favorite))
			return "skip"
		if(!familytree_estates_compatible(H, favorite))
			return "skip"
		if(relation == "spouse")
			if(!familytree_polygamy_compatible(H, favorite))
				return "skip"
			request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_execute_newlywed), H, favorite), "spouse")
			return "assigned"
		if(relation)
			request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_execute_new_family_relative), H, favorite, relation), "family")
			return "assigned"

	return "waiting"

/datum/controller/subsystem/familytree/proc/familytree_get_target_name(mob/living/carbon/human/H)
	if(!H)
		return null
	if(H.setspouse && length(H.setspouse))
		return H.setspouse
	var/datum/preferences/P = H.client?.prefs
	if(!P)
		return null
	P.familytree_module_load_character()
	if(P.setspouse && length(P.setspouse))
		return P.setspouse
	return null

/datum/controller/subsystem/familytree/proc/familytree_targets_name(mob/living/carbon/human/seeker, mob/living/carbon/human/target)
	var/target_name = familytree_get_target_name(seeker)
	if(!target || !target_name || !length(target_name))
		return FALSE
	return familytree_names_match(target_name, target.real_name)

/datum/controller/subsystem/familytree/proc/familytree_mutual_setspouse(mob/living/carbon/human/A, mob/living/carbon/human/B)
	return familytree_targets_name(A, B) && familytree_targets_name(B, A)

/datum/controller/subsystem/familytree/proc/familytree_name_lock_allows_pair(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!A || !B)
		return FALSE
	if(A.setspouse && length(A.setspouse) && !familytree_targets_name(A, B))
		return FALSE
	if(B.setspouse && length(B.setspouse) && !familytree_targets_name(B, A))
		return FALSE
	return TRUE

/datum/controller/subsystem/familytree/proc/do_assign_to_favorite_house(mob/living/carbon/human/H, datum/heritage/house)
	if(!H || QDELETED(H) || H.family_datum || !house)
		return
	if(!familytree_relative_join_phase_open())
		wait_for_relative_join_phase(H, "favorite house confirmation accepted before join phase")
		return
	var/forced_role = familytree_forced_role_from_relative_role(H.desired_relative_role)
	if(forced_role)
		AddPersonToHouse(house, H, FALSE, forced_role)
	else
		house.CreateFamilyMember(H)
	if(H.family_datum)
		var/favorite_role = forced_role ? forced_role : "direct member"
		familytree_admin_log_house_assignment(H, house, "joined favorite house as [favorite_role]")
		to_chat(H, span_love("Вы успешно присоединились к семье!"))
		stop_tracking_human(H, "assigned to favorite house")
	else
		retry_local_assignment(H, "favorite house assignment failed")

/datum/controller/subsystem/familytree/proc/FindFavoriteMob(mob/living/carbon/human/H)
	var/target_name = familytree_get_target_name(H)
	if(!target_name)
		return null

	for(var/datum/heritage/house as anything in families)
		for(var/datum/family_node/node as anything in house.member_nodes)
			if(node.person && familytree_names_match(node.person.real_name, target_name))
				return node.person

	for(var/mob/living/carbon/human/candidate as anything in viable_spouses.Copy())
		if(!candidate || QDELETED(candidate))
			viable_spouses -= candidate
			continue
		if(candidate == H)
			continue
		if(candidate.familytree_opted_out)
			viable_spouses -= candidate
			continue
		if(familytree_names_match(candidate.real_name, target_name))
			return candidate

	for(var/mob/living/carbon/human/candidate in GLOB.alive_mob_list)
		if(candidate == H)
			continue
		if(!candidate.client || candidate.stat == DEAD)
			continue
		if(candidate.familytree_opted_out)
			continue
		var/candidate_pref = candidate.familytree_pref
		var/datum/preferences/candidate_prefs = candidate.client?.prefs
		if(candidate_prefs)
			candidate_prefs.familytree_module_load_character()
			candidate_pref = candidate_prefs.family
		if(!familytree_pref_enabled(candidate_pref))
			continue
		if(familytree_names_match(candidate.real_name, target_name))
			return candidate

	return null

/datum/controller/subsystem/familytree/proc/try_force_mutual_targeted_match(mob/living/carbon/human/H)
	var/target_name = familytree_get_target_name(H)
	if(!H || !target_name || !length(target_name))
		return FALSE
	if(H.family_datum || H.familytree_opted_out || H.familytree_confirmation_pending)
		return FALSE

	var/mob/living/carbon/human/favorite = FindFavoriteMob(H)
	if(!favorite || favorite == H)
		return FALSE
	if(!familytree_mutual_setspouse(H, favorite))
		return FALSE
	if(favorite.familytree_opted_out || favorite.familytree_confirmation_pending)
		return FALSE
	if(favorite.family_datum)
		return FALSE

	var/h_block = get_familytree_runtime_block_reason(H, TRUE)
	var/f_block = get_familytree_runtime_block_reason(favorite, TRUE)
	if(h_block || f_block)
		return FALSE

	ftlog("TARGETED MATCH: [H.real_name] <-> [favorite.real_name] forcing mutual spouse confirmation before regular matching")
	request_mutual_confirmation(H, favorite, CALLBACK(src, PROC_REF(do_execute_targeted_spouse_match), H, favorite), "spouse")
	return TRUE

/datum/controller/subsystem/familytree/proc/do_execute_targeted_spouse_match(mob/living/carbon/human/H, mob/living/carbon/human/favorite)
	if(!H || QDELETED(H))
		return
	if(!favorite || QDELETED(favorite))
		retry_local_assignment(H, "targeted spouse unavailable after confirm")
		return
	if(H.family_datum || favorite.family_datum)
		retry_local_assignment(H, "targeted spouse already has a family")
		return
	ftlog("TARGETED MATCH: [H.real_name] + [favorite.real_name] -> forced spouse match")
	viable_spouses -= H
	viable_spouses -= favorite
	var/mob/living/carbon/human/founder = familytree_new_family_founder(H, favorite)
	var/mob/living/carbon/human/partner = founder == H ? favorite : H
	var/datum/heritage/family = founder.MarryTo(partner)
	if(!family)
		retry_local_assignment(H, "targeted spouse family creation failed")
		retry_local_assignment(favorite, "targeted spouse family creation failed")
		return
	family.closed = FALSE
	if(!family.house_leader)
		family.house_leader = founder.family_member_datum || family.founder
	on_family_formed(family)
	wake_waiting_relative_seekers(family)
	familytree_admin_log_house_assignment(H, family, "created targeted house with spouse [key_name(favorite)]", favorite.family_member_datum)
	familytree_admin_log_house_assignment(favorite, family, "created targeted house with spouse [key_name(H)]", H.family_member_datum)
	introduce_pair(H, favorite)
	bestow_wedding_rings(H, favorite)
	stop_tracking_human(H, "targeted spouse match completed")
	stop_tracking_human(favorite, "targeted spouse match completed")

/datum/controller/subsystem/familytree/proc/AssignToHouse(mob/living/carbon/human/H, forced_role = null)
	if(!H)
		return
	ftlog("AssignToHouse START: [H.real_name] race=[H.dna?.species?.name] isolated=[is_isolated(H)] pref=[H.familytree_pref]")

	var/our_race = H.dna.species.name
	var/we_are_isolated = is_isolated(H)

	var/list/candidates = list()
	var/reject_mask = 0

	for(var/datum/heritage/house as anything in families)
		if(house.closed)
			reject_mask |= FTREJ_H_CLOSED
			continue
		if(!house.housename || house.housename == "no name")
			reject_mask |= FTREJ_H_NONAME
			continue
		if(!house_allows_relatives(house))
			reject_mask |= FTREJ_H_RELATIVES
			continue
		if(!house_race_compatible(house, our_race, we_are_isolated))
			reject_mask |= FTREJ_H_RACE
			continue
		if(!forced_role && WouldCreateAgeConflict(house, H))
			reject_mask |= FTREJ_H_AGE
			continue
		if(house.member_nodes.len < 1)
			reject_mask |= FTREJ_H_EMPTY
			continue
		if(!house_has_online_member(house))
			reject_mask |= FTREJ_H_OFFLINE
			continue
		if(!familytree_house_supports_role(house, H, forced_role))
			reject_mask |= FTREJ_H_AGE
			continue

		candidates += house

	ftlog("AssignToHouse REJECTS [H.real_name]: mask=[reject_mask] ([ftreject_decode_house(reject_mask)]) -> candidates=[candidates.len]", FTLOG_DEBUG)

	if(candidates.len)
		var/datum/heritage/chosen_house = pick_least_filled_house(candidates)
		ftlog("AssignToHouse: [H.real_name] → JOINED existing house '[chosen_house.housename || "no name"]' (members=[chosen_house.member_nodes.len])")
		var/assigned_role = forced_role || DetermineAppropriateRole(chosen_house, H)
		AddPersonToHouse(chosen_house, H, FALSE, assigned_role)
		if(H.family_datum)
			var/assigned_role_text = assigned_role || "relative"
			familytree_admin_log_house_assignment(H, chosen_house, "joined existing house as [assigned_role_text]")
			stop_tracking_human(H, "assigned to house")
		else
			ftlog("AssignToHouse: [H.real_name] selected house did not accept assigned_role=[assigned_role]", FTLOG_WARN)
	else
		ftlog("AssignToHouse: [H.real_name] → NO suitable existing house found. Staying without family.", FTLOG_WARN)

/datum/controller/subsystem/familytree/proc/AddPersonToHouse(datum/heritage/house, mob/living/carbon/human/person, adopted = FALSE, forced_role = null)
	var/role = forced_role || DetermineAppropriateRole(house, person, adopted)

	switch(role)
		if("child")
			var/list/potential_parents = list()
			for(var/datum/family_member/member as anything in house.members)
				if(member.person && CanBeParentOf(member.person, person))
					potential_parents += member

			var/datum/family_member/parent1
			var/datum/family_member/parent2
			var/list/valid_parent_pairs = list()

			for(var/i = 1 to potential_parents.len)
				var/datum/family_member/candidate1 = potential_parents[i]
				if(!candidate1?.person)
					continue

				for(var/j = i + 1 to potential_parents.len)
					var/datum/family_member/candidate2 = potential_parents[j]
					if(!candidate2?.person)
						continue
					if(house.SpeciesCalculation(person, candidate1.person, candidate2.person))
						valid_parent_pairs += list(list(candidate1, candidate2))

			if(valid_parent_pairs.len)
				var/list/chosen_pair = pick(valid_parent_pairs)
				parent1 = chosen_pair[1]
				parent2 = chosen_pair[2]

			if(!parent1)
				parent1 = familytree_best_parent_member(house, person)
			if(parent1 && !parent2)
				parent2 = familytree_best_parent_member(house, person, parent1)
				if(parent2 && !house.SpeciesCalculation(person, parent1.person, parent2.person) && house.SingleParentSpeciesCalculation(person, parent1.person))
					parent2 = null
			if(!parent1 && !parent2)
				return FALSE

			return house.AddToFamily(person, parent1, parent2, adopted)

		if("sibling")
			var/datum/family_member/member = familytree_best_sibling_member(house, person)
			if(!member)
				return FALSE
			var/list/member_parents = member.get_parent_members()
			var/datum/family_member/parent1 = member_parents.len > 0 ? member_parents[1] : null
			var/datum/family_member/parent2 = member_parents.len > 1 ? member_parents[2] : null
			return house.AddToFamily(person, parent1, parent2, adopted)

		if("parent")
			var/datum/family_member/child_member = familytree_best_child_member_for_parent(house, person)
			if(!child_member)
				return FALSE
			var/datum/family_member/new_member = house.CreateFamilyMember(person)
			if(!new_member)
				return FALSE
			if(!child_member.AddParent(new_member))
				house.RemoveFamilyMember(new_member)
				return FALSE
			if(!house.founder)
				house.founder = new_member
				new_member.generation = 0
			if(!house.housename)
				house.housename = house.SurnameFormatting(person)
			return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/familytree_forced_role_from_relative_role(relative_role)
	switch(relative_role)
		if(RELATIVE_SIBLING)
			return "sibling"
		if(RELATIVE_PARENT)
			return "parent"
		if(RELATIVE_CHILD)
			return "child"
	return null

/datum/controller/subsystem/familytree/proc/familytree_best_parent_member(datum/heritage/house, mob/living/carbon/human/child, datum/family_member/exclude = null)
	if(!house || !child)
		return null
	var/list/candidates = list()
	for(var/datum/family_member/member as anything in house.members)
		if(member == exclude || !member?.person)
			continue
		if(!CanBeParentOf(member.person, child))
			continue
		if(!house.SingleParentSpeciesCalculation(child, member.person))
			continue
		candidates += member
	if(!candidates.len)
		return null
	return pick(candidates)

/datum/controller/subsystem/familytree/proc/familytree_best_sibling_member(datum/heritage/house, mob/living/carbon/human/person)
	if(!house || !person)
		return null
	var/list/candidates = list()
	for(var/datum/family_member/member as anything in house.members)
		if(!member?.person)
			continue
		if(!CanBeSiblings(member.person.age, person.age))
			continue
		candidates += member
	if(!candidates.len)
		return null
	return pick(candidates)

/datum/controller/subsystem/familytree/proc/familytree_best_child_member_for_parent(datum/heritage/house, mob/living/carbon/human/parent)
	if(!house || !parent)
		return null
	var/list/candidates = list()
	for(var/datum/family_member/member as anything in house.members)
		if(!member?.person)
			continue
		if(member.get_parent_members().len >= 2)
			continue
		if(!CanBeParentOf(parent, member.person))
			continue
		candidates += member
	if(!candidates.len)
		return null
	return pick(candidates)

/datum/controller/subsystem/familytree/proc/familytree_house_supports_role(datum/heritage/house, mob/living/carbon/human/person, forced_role)
	if(!house || !person)
		return FALSE
	if(!forced_role)
		return DetermineAppropriateRole(house, person) ? TRUE : FALSE
	switch(forced_role)
		if("child")
			return familytree_best_parent_member(house, person) ? TRUE : FALSE
		if("sibling")
			return familytree_best_sibling_member(house, person) ? TRUE : FALSE
		if("parent")
			return familytree_best_child_member_for_parent(house, person) ? TRUE : FALSE
	return TRUE

/datum/controller/subsystem/familytree/proc/AssignToFamily(mob/living/carbon/human/H)
	if(!H)
		return
	ftlog("AssignToFamily: [H.real_name] species=[H.dna?.species?.name] isolated=[is_isolated(H)]")
	var/our_race = H.dna.species.name
	var/our_isolated = is_isolated(H)
	var/list/eligible_houses = list()

	for(var/datum/heritage/house as anything in families)
		if(house.closed)
			continue
		if(!house_race_compatible(house, our_race, our_isolated))
			continue

		var/has_single_adult = FALSE
		for(var/datum/family_member/member as anything in house.members)
			if(member.person && familytree_polygamy_compatible(H, member.person))
				if(!member.person.client)
					continue
				if(!member.person.setspouse || !length(member.person.setspouse) || familytree_targets_name(member.person, H))
					var/candidate_soft_reject_mask = familytree_pair_soft_pref_reject_mask(H, member.person)
					if(candidate_soft_reject_mask & FTREJ_N_PRONOUNS)
						continue
					if(candidate_soft_reject_mask & FTREJ_N_SPECIES)
						continue
					if(!familytree_estates_compatible(H, member.person))
						continue
					if(!familytree_role_tiers_compatible(H, member.person))
						continue
					if(familytree_pref_is_join_only(member.person.familytree_pref))
						continue
					has_single_adult = TRUE
					eligible_houses += house
					break

		if(!has_single_adult && !house.housename)
			eligible_houses += house

	ftlog("AssignToFamily: [H.real_name] eligible_houses=[eligible_houses.len]")
	if(!eligible_houses.len)
		ftlog("AssignToFamily: [H.real_name] no eligible houses, creating new")
		var/datum/heritage/new_house = new /datum/heritage(H, null)
		register_family(new_house)
		ftlog("AssignToFamily: [H.real_name] founded new house '[new_house.housename]'")
		familytree_admin_log_house_assignment(H, new_house, "created new house; spouse role found no eligible house")
		return

	for(var/datum/heritage/house as anything in eligible_houses)
		for(var/datum/family_member/member as anything in house.members)
			if(member.person && familytree_polygamy_compatible(H, member.person))
				if(!member.person.client)
					continue
				if(!member.person.setspouse || !length(member.person.setspouse) || familytree_targets_name(member.person, H))
					var/final_soft_reject_mask = familytree_pair_soft_pref_reject_mask(H, member.person)
					if(!final_soft_reject_mask && familytree_estates_compatible(H, member.person) && familytree_role_tiers_compatible(H, member.person))
						var/datum/family_member/new_member = house.CreateFamilyMember(H)
						if(new_member)
							house.MarryMembers(new_member, member)
							on_family_formed(house)
							familytree_admin_log_house_assignment(H, house, "joined existing house as spouse of [key_name(member.person)]", member)
							return

		if(!house.housename)
			var/datum/family_member/new_member = house.CreateFamilyMember(H)
			if(new_member)
				house.founder = new_member
				new_member.generation = 0
				house.housename = house.SurnameFormatting(H)
				familytree_admin_log_house_assignment(H, house, "founded unnamed eligible house")
				return

/datum/controller/subsystem/familytree/proc/familytree_is_new_family_candidate(mob/living/carbon/human/H)
	if(!H || H.family_datum)
		return FALSE
	var/family_mode = familytree_pref_mask(H.familytree_pref)
	if(family_mode & FAMILYTREE_MODE_CREATE)
		return TRUE
	if(family_mode & FAMILYTREE_MODE_JOIN)
		return familytree_join_create_fallback_open()
	return FALSE

/datum/controller/subsystem/familytree/proc/familytree_can_found_new_family(mob/living/carbon/human/H)
	if(!H || H.family_datum)
		return FALSE
	return !!(familytree_pref_mask(H.familytree_pref) & FAMILYTREE_MODE_CREATE)

/datum/controller/subsystem/familytree/proc/familytree_new_family_pair_eligible(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!familytree_is_new_family_candidate(A) || !familytree_is_new_family_candidate(B))
		return FALSE
	var/a_mode = familytree_pref_mask(A.familytree_pref)
	var/b_mode = familytree_pref_mask(B.familytree_pref)
	var/a_creates = !!(a_mode & FAMILYTREE_MODE_CREATE)
	var/b_creates = !!(b_mode & FAMILYTREE_MODE_CREATE)
	return a_creates || b_creates

/datum/controller/subsystem/familytree/proc/familytree_new_family_join_any_relation(mob/living/carbon/human/A, mob/living/carbon/human/B)
	var/a_join_only = familytree_pref_is_join_only(A?.familytree_pref)
	var/b_join_only = familytree_pref_is_join_only(B?.familytree_pref)
	if(a_join_only == b_join_only)
		return null

	var/mob/living/carbon/human/joiner = a_join_only ? A : B
	var/mob/living/carbon/human/creator = a_join_only ? B : A

	if(CanBeParentOf(creator, joiner))
		return a_join_only ? "b_parent" : "a_parent"
	if(CanBeSiblings(creator.age, joiner.age))
		return "sibling"
	if(CanBeParentOf(joiner, creator))
		return a_join_only ? "a_parent" : "b_parent"
	if(familytree_can_be_uncle_aunt_of(joiner, creator))
		return a_join_only ? "a_uncle_aunt" : "b_uncle_aunt"
	return null

/datum/controller/subsystem/familytree/proc/familytree_new_family_pair_relation(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!familytree_new_family_pair_eligible(A, B))
		return null

	var/a_role = A.desired_relative_role || RELATIVE_ANY
	var/b_role = B.desired_relative_role || RELATIVE_ANY
	var/a_join_only = familytree_pref_is_join_only(A.familytree_pref)
	var/b_join_only = familytree_pref_is_join_only(B.familytree_pref)

	if(a_role == RELATIVE_SPOUSE || b_role == RELATIVE_SPOUSE)
		var/a_allows_spouse = (a_role == RELATIVE_SPOUSE || (!a_join_only && a_role == RELATIVE_ANY))
		var/b_allows_spouse = (b_role == RELATIVE_SPOUSE || (!b_join_only && b_role == RELATIVE_ANY))
		if(a_allows_spouse && b_allows_spouse)
			return "spouse"
		return null

	if(a_role == RELATIVE_SIBLING || b_role == RELATIVE_SIBLING)
		if((a_role == RELATIVE_SIBLING || a_role == RELATIVE_ANY) && (b_role == RELATIVE_SIBLING || b_role == RELATIVE_ANY))
			return "sibling"
		return null

	if(a_role == RELATIVE_PARENT)
		if(b_role == RELATIVE_CHILD || b_role == RELATIVE_ANY)
			return "a_parent"
		return null
	if(b_role == RELATIVE_PARENT)
		if(a_role == RELATIVE_CHILD || a_role == RELATIVE_ANY)
			return "b_parent"
		return null

	if(a_role == RELATIVE_CHILD)
		if(b_role == RELATIVE_PARENT || b_role == RELATIVE_ANY)
			return "b_parent"
		return null
	if(b_role == RELATIVE_CHILD)
		if(a_role == RELATIVE_PARENT || a_role == RELATIVE_ANY)
			return "a_parent"
		return null

	if(a_role == RELATIVE_UNCLE_AUNT)
		if(b_role == RELATIVE_ANY)
			return "a_uncle_aunt"
		return null
	if(b_role == RELATIVE_UNCLE_AUNT)
		if(a_role == RELATIVE_ANY)
			return "b_uncle_aunt"
		return null

	if(a_role == RELATIVE_ANY && b_role == RELATIVE_ANY)
		if(a_join_only || b_join_only)
			return familytree_new_family_join_any_relation(A, B)
		return "spouse"

	return null

/datum/controller/subsystem/familytree/proc/familytree_can_be_uncle_aunt_of(mob/living/carbon/human/uncle_aunt, mob/living/carbon/human/nibling)
	if(!uncle_aunt || !nibling)
		return FALSE
	if(CanBeParentOf(uncle_aunt, nibling))
		return TRUE
	return CanBeSiblings(uncle_aunt.age, nibling.age)

/datum/controller/subsystem/familytree/proc/familytree_new_family_relation_valid(mob/living/carbon/human/A, mob/living/carbon/human/B, relation)
	switch(relation)
		if("spouse")
			return familytree_polygamy_compatible(A, B)
		if("sibling")
			return CanBeSiblings(A.age, B.age)
		if("a_parent")
			return CanBeParentOf(A, B)
		if("b_parent")
			return CanBeParentOf(B, A)
		if("a_uncle_aunt")
			return familytree_can_be_uncle_aunt_of(A, B)
		if("b_uncle_aunt")
			return familytree_can_be_uncle_aunt_of(B, A)
	return FALSE

/datum/controller/subsystem/familytree/proc/familytree_create_phantom_member(datum/heritage/house, generation = 0)
	if(!house)
		return null
	var/datum/family_member/phantom = new /datum/family_member(null, house)
	phantom.generation = generation
	phantom.phantom = TRUE
	house.members += phantom
	return phantom

/datum/controller/subsystem/familytree/proc/familytree_apply_uncle_aunt_relation(datum/heritage/house, datum/family_member/uncle_aunt, datum/family_member/nibling)
	if(!house || !uncle_aunt || !nibling)
		return FALSE
	var/datum/family_member/parent = familytree_create_phantom_member(house, nibling.generation - 1)
	var/datum/family_member/grandparent = familytree_create_phantom_member(house, nibling.generation - 2)
	if(!parent || !grandparent)
		return FALSE
	if(!nibling.AddParent(parent))
		return FALSE
	if(!parent.AddParent(grandparent))
		return FALSE
	return uncle_aunt.AddParent(grandparent)

/datum/controller/subsystem/familytree/proc/familytree_apply_new_family_relation(datum/heritage/house, mob/living/carbon/human/A, mob/living/carbon/human/B, relation)
	if(!house || !A || !B)
		return FALSE
	var/datum/family_member/member_a = house.GetFamilyMember(A)
	if(!member_a)
		member_a = house.CreateFamilyMember(A)
	var/datum/family_member/member_b = house.GetFamilyMember(B)
	if(!member_b)
		member_b = house.CreateFamilyMember(B)
	if(!member_a || !member_b)
		return FALSE

	switch(relation)
		if("sibling")
			var/datum/family_member/phantom_parent = familytree_create_phantom_member(house, min(member_a.generation, member_b.generation) - 1)
			if(!phantom_parent)
				return FALSE
			if(!member_a.AddParent(phantom_parent))
				return FALSE
			return member_b.AddParent(phantom_parent)
		if("a_parent")
			return member_b.AddParent(member_a)
		if("b_parent")
			return member_a.AddParent(member_b)
		if("a_uncle_aunt")
			return familytree_apply_uncle_aunt_relation(house, member_a, member_b)
		if("b_uncle_aunt")
			return familytree_apply_uncle_aunt_relation(house, member_b, member_a)
	return FALSE

/datum/controller/subsystem/familytree/proc/familytree_create_new_relative_house(mob/living/carbon/human/leader, mob/living/carbon/human/A, mob/living/carbon/human/B, relation)
	if(!leader || !A || !B || relation == "spouse")
		return null
	var/datum/heritage/new_house = new /datum/heritage(leader, null)
	new_house.closed = TRUE
	new_house.house_leader = new_house.founder
	register_family(new_house)
	if(!familytree_apply_new_family_relation(new_house, A, B, relation))
		new_house.RemovePersonFromFamily(A)
		new_house.RemovePersonFromFamily(B)
		families -= new_house
		return null
	return new_house

/datum/controller/subsystem/familytree/proc/familytree_new_family_relation_audit_text(mob/living/carbon/human/A, mob/living/carbon/human/B, relation, for_a)
	var/mob/living/carbon/human/other = for_a ? B : A
	switch(relation)
		if("sibling")
			return "created new house as sibling of [key_name(other)]"
		if("a_parent")
			return for_a ? "created new house as parent of [key_name(B)]" : "joined new house as child of [key_name(A)]"
		if("b_parent")
			return for_a ? "joined new house as child of [key_name(B)]" : "created new house as parent of [key_name(A)]"
		if("a_uncle_aunt")
			return for_a ? "created new house as uncle/aunt of [key_name(B)]" : "joined new house as niece/nephew of [key_name(A)]"
		if("b_uncle_aunt")
			return for_a ? "joined new house as niece/nephew of [key_name(B)]" : "created new house as uncle/aunt of [key_name(A)]"
	return "created new house as relative of [key_name(other)]"

/datum/controller/subsystem/familytree/proc/familytree_creator_pronouns_compatible(mob/living/carbon/human/creator, mob/living/carbon/human/partner, respect_xylix = TRUE)
	if(respect_xylix && xylix_roulette_active)
		return TRUE
	if(!creator || !partner)
		return FALSE
	var/pref = creator.gender_choice_pref || ANY_GENDER
	return pronoun_preference_matches(pref, creator.pronouns == partner.pronouns)

/datum/controller/subsystem/familytree/proc/GetCreatorSpeciesPreferenceFailureReason(mob/living/carbon/human/creator, mob/living/carbon/human/partner, respect_xylix = TRUE)
	if(!creator || !partner)
		return "missing mob"

	var/creator_isolated = is_isolated(creator)
	var/partner_isolated = is_isolated(partner)
	if(creator_isolated || partner_isolated)
		if(!creator_isolated || !partner_isolated)
			return "isolated group mismatch"

	if(respect_xylix && xylix_roulette_active)
		return null

	var/datum/preferences/P = creator.client?.prefs
	if(!P)
		return null

	var/creator_type = creator.dna.species.type
	var/partner_type = partner.dna.species.type
	var/list/pref_types = get_preference_species_type_list(P)

	switch(P.species_preference_mode)
		if("ANY")
			;
		if("SAME_TYPE")
			if(creator_type != partner_type)
				return "species mismatch"
		if("SPECIFIC_TYPE")
			if(!(partner_type in pref_types))
				return "species mismatch"

	if(!AnatomyCompatible(P.preferred_species_anatomy, partner))
		return "anatomy mismatch"

	return null

/datum/controller/subsystem/familytree/proc/familytree_creator_role_tiers_compatible(mob/living/carbon/human/creator, mob/living/carbon/human/partner)
	if(xylix_roulette_active)
		return TRUE

	var/creator_tier = familytree_get_role_tier(creator)
	var/partner_tier = familytree_get_role_tier(partner)

	if((creator_tier == ROLE_TIER_LOW && partner_tier == ROLE_TIER_HIGH) || (creator_tier == ROLE_TIER_HIGH && partner_tier == ROLE_TIER_LOW))
		return FALSE

	if(creator_tier == partner_tier)
		return TRUE
	if(creator_tier == ROLE_TIER_NONE && partner_tier != ROLE_TIER_LOW)
		return TRUE
	if(partner_tier == ROLE_TIER_NONE && creator_tier != ROLE_TIER_LOW)
		return TRUE
	if(creator_tier == ROLE_TIER_LOW && partner_tier != ROLE_TIER_LOW)
		return partner.allow_low_status_marriage
	if(partner_tier == ROLE_TIER_LOW && creator_tier != ROLE_TIER_LOW)
		return creator.allow_low_status_marriage
	return TRUE

/datum/controller/subsystem/familytree/proc/familytree_new_family_creator_pref_reject_mask(mob/living/carbon/human/creator, mob/living/carbon/human/partner)
	var/reject_mask = 0
	if(!familytree_creator_pronouns_compatible(creator, partner))
		reject_mask |= FTREJ_N_PRONOUNS
	if(GetCreatorSpeciesPreferenceFailureReason(creator, partner))
		reject_mask |= FTREJ_N_SPECIES
	if(!familytree_creator_role_tiers_compatible(creator, partner))
		reject_mask |= FTREJ_N_TIER
	return reject_mask

/datum/controller/subsystem/familytree/proc/familytree_soft_pref_reject_mask(mob/living/carbon/human/seeker, mob/living/carbon/human/partner)
	var/reject_mask = 0
	var/respect_xylix = !(familytree_targets_name(seeker, partner) || familytree_targets_name(partner, seeker))
	if(!familytree_creator_pronouns_compatible(seeker, partner, respect_xylix))
		reject_mask |= FTREJ_N_PRONOUNS
	if(GetCreatorSpeciesPreferenceFailureReason(seeker, partner, respect_xylix))
		reject_mask |= FTREJ_N_SPECIES
	return reject_mask

/datum/controller/subsystem/familytree/proc/familytree_pair_soft_pref_reject_mask(mob/living/carbon/human/A, mob/living/carbon/human/B)
	var/reject_mask = 0
	if(!familytree_targets_name(A, B))
		reject_mask |= familytree_soft_pref_reject_mask(A, B)
	if(!familytree_targets_name(B, A))
		reject_mask |= familytree_soft_pref_reject_mask(B, A)
	return reject_mask

/datum/controller/subsystem/familytree/proc/familytree_new_family_pair_pref_reject_mask(mob/living/carbon/human/A, mob/living/carbon/human/B)
	var/reject_mask = familytree_pair_soft_pref_reject_mask(A, B)
	if(!familytree_role_tiers_compatible(A, B))
		reject_mask |= FTREJ_N_TIER
	return reject_mask

/datum/controller/subsystem/familytree/proc/familytree_new_family_founder(mob/living/carbon/human/A, mob/living/carbon/human/B)
	var/a_creates = familytree_pref_is_create(A?.familytree_pref)
	var/b_creates = familytree_pref_is_create(B?.familytree_pref)
	if(b_creates && !a_creates)
		return B
	return A

/datum/controller/subsystem/familytree/proc/wait_for_new_family_founder(mob/living/carbon/human/H)
	if(!H || QDELETED(H) || H.family_datum)
		return
	if(!familytree_is_new_family_candidate(H))
		if(familytree_pref_is_join(H.familytree_pref))
			wait_for_relative_house(H, "new-family fallback is not active")
		return
	if(!(H in viable_spouses))
		viable_spouses += H
	INVOKE_ASYNC(src, PROC_REF(find_and_confirm_newlywed), H)

/datum/controller/subsystem/familytree/proc/FindNewlyWedMatch(mob/living/carbon/human/H)
	if(!H)
		return null
	var/block_reason = get_familytree_runtime_block_reason(H, TRUE)
	if(block_reason)
		return null
	if(H.family_datum || !familytree_is_new_family_candidate(H))
		return null
	if(!(H in viable_spouses))
		viable_spouses += H

	var/reject_mask = 0
	var/list/potential_matches = list()
	for(var/mob/living/carbon/human/candidate as anything in viable_spouses.Copy())
		if(!candidate || QDELETED(candidate))
			viable_spouses -= candidate
			continue
		if(candidate == H)
			continue
		if(candidate.family_datum)
			viable_spouses -= candidate
			reject_mask |= FTREJ_N_BLOCK
			continue
		if(candidate.familytree_opted_out)
			viable_spouses -= candidate
			reject_mask |= FTREJ_N_OPTOUT
			continue
		if(!familytree_is_new_family_candidate(candidate))
			viable_spouses -= candidate
			reject_mask |= FTREJ_N_BLOCK
			continue
		if(!familytree_new_family_pair_eligible(H, candidate))
			reject_mask |= FTREJ_N_BLOCK
			continue
		var/relation = familytree_new_family_pair_relation(H, candidate)
		if(!relation)
			reject_mask |= FTREJ_N_BLOCK
			continue
		if(candidate.familytree_confirmation_pending)
			reject_mask |= FTREJ_N_BLOCK
			continue
		var/cand_block = get_familytree_runtime_block_reason(candidate, TRUE)
		if(cand_block)
			viable_spouses -= candidate
			reject_mask |= FTREJ_N_BLOCK
			continue
		if(relation == "spouse" && !familytree_polygamy_compatible(H, candidate))
			reject_mask |= FTREJ_N_POLY
			continue
		if(!familytree_new_family_relation_valid(H, candidate, relation))
			reject_mask |= FTREJ_N_BLOCK
			continue
		var/pref_reject_mask = familytree_new_family_pair_pref_reject_mask(H, candidate)
		if(pref_reject_mask)
			reject_mask |= pref_reject_mask
			continue
		if(!familytree_estates_compatible(H, candidate))
			reject_mask |= FTREJ_N_ESTATE
			continue
		if(!familytree_name_lock_allows_pair(H, candidate))
			reject_mask |= FTREJ_N_SETSPOUSE
			continue
		var/priority = 0
		if(familytree_mutual_setspouse(H, candidate))
			priority += 100
		else
			if(familytree_targets_name(H, candidate))
				priority += 10
			if(familytree_targets_name(candidate, H))
				priority += 10
		potential_matches += list(list(candidate, priority))

	ftlog("FindNewlyWedMatch REJECTS [H.real_name] (pool=[viable_spouses.len]): mask=[reject_mask] ([ftreject_decode_newlywed(reject_mask)]) -> matches=[potential_matches.len]", FTLOG_DEBUG)

	if(!potential_matches.len)
		return null

	var/best_priority = -1
	var/list/best_matches = list()
	for(var/list/match_data in potential_matches)
		var/match_priority = match_data[2]
		if(match_priority > best_priority)
			best_priority = match_priority
			best_matches = list(match_data[1])
		else if(match_priority == best_priority)
			best_matches += match_data[1]

	if(!best_matches.len)
		return null
	return pick(best_matches)

/datum/controller/subsystem/familytree/proc/FindFamilyMatch(mob/living/carbon/human/H)
	if(!H)
		return null
	var/our_race = H.dna.species.name
	var/our_isolated = is_isolated(H)
	var/houses_scanned = 0
	var/reject_mask = 0
	var/list/potential_matches = list()

	for(var/datum/heritage/house as anything in families)
		if(house.closed)
			reject_mask |= FTREJ_F_CLOSED
			continue
		if(!house_race_compatible(house, our_race, our_isolated))
			reject_mask |= FTREJ_F_RACE
			continue
		houses_scanned++
		for(var/datum/family_member/member as anything in house.members)
			if(!member.person)
				continue
			if(member.person.familytree_confirmation_pending)
				reject_mask |= FTREJ_F_OFFLINE
				continue
			if(!familytree_polygamy_compatible(H, member.person))
				reject_mask |= FTREJ_F_POLY
				continue
			if(!member.person.client)
				reject_mask |= FTREJ_F_OFFLINE
				continue
			if(!familytree_name_lock_allows_pair(H, member.person))
				reject_mask |= FTREJ_F_SETSPOUSE
				continue
			var/soft_reject_mask = familytree_pair_soft_pref_reject_mask(H, member.person)
			if(soft_reject_mask & FTREJ_N_PRONOUNS)
				reject_mask |= FTREJ_F_PRONOUNS
				continue
			if(soft_reject_mask & FTREJ_N_SPECIES)
				reject_mask |= FTREJ_F_SPECIES
				continue
			if(!familytree_estates_compatible(H, member.person))
				reject_mask |= FTREJ_F_ESTATE
				continue
			if(!familytree_role_tiers_compatible(H, member.person))
				reject_mask |= FTREJ_F_TIER
				continue
			if(familytree_pref_is_join_only(member.person.familytree_pref))
				reject_mask |= FTREJ_F_PARTIAL
				continue
			if(member.person.familytree_opted_out)
				reject_mask |= FTREJ_F_OPTOUT
				continue
			potential_matches += list(list(house, member, house.member_nodes.len))

	ftlog("FindFamilyMatch REJECTS [H.real_name] (houses=[families.len]): mask=[reject_mask] ([ftreject_decode_family(reject_mask)]) -> matches=[potential_matches.len]", potential_matches.len ? FTLOG_DEBUG : FTLOG_WARN)
	if(!potential_matches.len)
		return null

	var/min_house_size = 100000
	for(var/list/match_data in potential_matches)
		min_house_size = min(min_house_size, match_data[3])

	var/list/best_matches = list()
	for(var/list/match_data in potential_matches)
		if(match_data[3] == min_house_size)
			best_matches += list(match_data)

	var/list/chosen = pick(best_matches)
	var/datum/heritage/chosen_house = chosen[1]
	var/datum/family_member/chosen_member = chosen[2]
	ftlog("FindFamilyMatch [H.real_name] -> [chosen_member.person.real_name] in '[chosen_house.housename]' (scanned=[houses_scanned]h matches=[potential_matches.len] min_size=[min_house_size])", FTLOG_DEBUG)
	return list(chosen_house, chosen_member)

/datum/controller/subsystem/familytree/proc/AssignNewlyWed(mob/living/carbon/human/H)
	if(!H)
		return
	find_and_confirm_newlywed(H)

/datum/controller/subsystem/familytree/proc/AssignAuntUncle(mob/living/carbon/human/H)
	var/base_species = H.dna.species.name
	var/base_isolated = is_isolated(H)
	var/datum/heritage/chosen_house
	var/list/candidates = list()

	for(var/datum/heritage/house as anything in families)
		if(house.closed)
			continue
		if(!house_race_compatible(house, base_species, base_isolated))
			continue
		if(!house.housename || house.member_nodes.len < 2)
			continue

		var/has_compatible_parent = FALSE
		for(var/datum/family_member/member as anything in house.members)
			if(member.get_child_members().len > 0 && member.person?.client)
				if(!GetSpeciesCompatibilityFailureReason(H, member.person))
					has_compatible_parent = TRUE
					break

		if(has_compatible_parent && !WouldCreateAgeConflict(house, H))
			candidates += house

	if(candidates.len)
		chosen_house = pick_least_filled_house(candidates)

	if(chosen_house)
		var/datum/family_member/new_member = chosen_house.CreateFamilyMember(H)
		if(new_member)
			for(var/datum/family_member/member as anything in chosen_house.members)
				if(member.get_child_members().len > 0 && member.person && CanBeSiblings(H.age, member.person.age))
					for(var/datum/family_member/grandparent as anything in member.get_parent_members())
						new_member.AddParent(grandparent)
					break
			familytree_admin_log_house_assignment(H, chosen_house, "joined existing house as uncle/aunt")

/datum/controller/subsystem/familytree/proc/do_form_sibling_house(mob/living/carbon/human/initiator, mob/living/carbon/human/partner)
	if(!initiator || QDELETED(initiator) || initiator.family_datum)
		return
	if(!partner || QDELETED(partner) || partner.family_datum)
		return

	var/datum/heritage/new_house = new /datum/heritage(initiator, null)
	new_house.closed = TRUE
	new_house.house_leader = new_house.founder
	register_family(new_house)

	var/datum/family_member/phantom_parent = new /datum/family_member(null, new_house)
	phantom_parent.generation = -1
	phantom_parent.phantom = TRUE
	new_house.members += phantom_parent
	new_house.founder.AddParent(phantom_parent)

	var/datum/family_member/partner_member = new_house.CreateFamilyMember(partner)
	if(partner_member)
		partner_member.generation = 1
		partner_member.AddParent(phantom_parent)

	introduce_pair(initiator, partner)
	ftlog("SIBLING HOUSE: [initiator.real_name] + [partner.real_name] formed closed house '[new_house.housename]', leader=[initiator.real_name]")
	on_family_formed(new_house)
	familytree_admin_log_house_assignment(initiator, new_house, "formed sibling house with [key_name(partner)]", partner_member)
	familytree_admin_log_house_assignment(partner, new_house, "joined sibling house with [key_name(initiator)]", new_house.founder)

	to_chat(initiator, span_love("Вы основали дом [new_house.housename]!"))
	to_chat(partner, span_love("Вы вступили в дом [new_house.housename]."))

	stop_tracking_human(initiator, "formed sibling house")
	stop_tracking_human(partner, "joined sibling house")

	ask_open_sibling_house(initiator, new_house)

/datum/controller/subsystem/familytree/proc/ask_open_sibling_house(mob/living/carbon/human/leader, datum/heritage/house)
	if(!leader?.client)
		return
	INVOKE_ASYNC(src, PROC_REF(do_ask_open_sibling_house), leader, house)

/datum/controller/subsystem/familytree/proc/do_ask_open_sibling_house(mob/living/carbon/human/leader, datum/heritage/house)
	if(!leader?.client)
		return

	var/result = tgui_alert(leader, "Открыть дом [house.housename] для вступления родственников?", "Дом [house.housename]", list("Да", "Нет"))

	if(!leader || QDELETED(leader))
		return
	if(!house)
		return

	if(result == "Да")
		house.closed = FALSE
		ftlog("SIBLING HOUSE: [leader.real_name] opened house '[house.housename]' for relatives")
		to_chat(leader, span_notice("Дом [house.housename] открыт для родственников."))
	else
		ftlog("SIBLING HOUSE: [leader.real_name] kept house '[house.housename]' closed")
		to_chat(leader, span_notice("Дом [house.housename] останется закрытым. Вступить можно только через обряд жреца."))

/datum/controller/subsystem/familytree/proc/HasSuitableHouseForRelative(mob/living/carbon/human/H, forced_role = null)
	if(!H)
		return FALSE

	var/our_race = H.dna.species.name
	var/we_are_isolated = is_isolated(H)

	for(var/datum/heritage/house as anything in families)
		if(house.closed)
			continue
		if(!house.housename || house.housename == "no name")
			continue
		if(!house_allows_relatives(house))
			continue
		if(!house_race_compatible(house, our_race, we_are_isolated))
			continue
		if(!forced_role && WouldCreateAgeConflict(house, H))
			continue
		if(!familytree_house_supports_role(house, H, forced_role))
			continue
		if(house.member_nodes.len >= 1 && house_has_online_member(house))
			return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/TryFormSiblingHouseFromPartial(mob/living/carbon/human/H)
	if(!H || H.family_datum)
		return FALSE

	var/list/candidates = list()
	for(var/mob/living/carbon/human/candidate as anything in GLOB.alive_mob_list)
		if(candidate == H || !candidate.client || candidate.stat == DEAD || !familytree_pref_is_join_only(candidate.familytree_pref) || candidate.family_datum)
			continue
		if(candidate.familytree_confirmation_pending)
			continue
		if(!pronouns_compatible(H, candidate))
			continue
		if(GetSpeciesCompatibilityFailureReason(H, candidate))
			continue
		if(!familytree_estates_compatible(H, candidate))
			continue
		if(!familytree_role_tiers_compatible(H, candidate))
			continue
		if(!CanBeSiblings(H.age, candidate.age))
			continue
		candidates += candidate

	if(candidates.len)
		var/mob/living/carbon/human/chosen = pick(candidates)
		ftlog("TryFormSiblingHouseFromPartial: [H.real_name] + [chosen.real_name] -> forming sibling house (candidates=[candidates.len])")
		request_mutual_confirmation(H, chosen, CALLBACK(src, PROC_REF(do_form_sibling_house), H, chosen), "sibling_house")
		return TRUE

	ftlog("TryFormSiblingHouseFromPartial: [H.real_name] → no mutual sibling found")

	return FALSE

/datum/controller/subsystem/familytree/proc/house_has_online_member(datum/heritage/house)
	if(!house)
		return FALSE
	for(var/datum/family_node/node as anything in house.member_nodes)
		if(node.person?.client)
			return TRUE
	return FALSE

/datum/controller/subsystem/familytree/proc/pick_least_filled_house(list/candidates)
	if(!candidates.len)
		return null
	if(candidates.len == 1)
		return candidates[1]
	var/min_member_count = 100000
	for(var/datum/heritage/house as anything in candidates)
		min_member_count = min(min_member_count, house.member_nodes.len)
	var/list/least_filled = list()
	for(var/datum/heritage/house as anything in candidates)
		if(house.member_nodes.len == min_member_count)
			least_filled += house
	return pick(least_filled)

/datum/controller/subsystem/familytree/proc/bestow_wedding_rings(mob/living/carbon/human/A, mob/living/carbon/human/B)
	give_wedding_ring(A)
	give_wedding_ring(B)

/datum/controller/subsystem/familytree/proc/give_wedding_ring(mob/living/carbon/human/H)
	if(!H || QDELETED(H) || !ishuman(H))
		return
	if(istype(H, /mob/living/carbon/human/dummy))
		return
	if(H.mind)
		H.mind.special_items["Silver wedding ring"] = /obj/item/clothing/ring/band
		to_chat(H, span_love("Серебряное свадебное кольцо добавлено в ваш стеш в знак союза."))
		return
	var/obj/item/clothing/ring/band/ring = new(H)
	ring.forceMove(get_turf(H))
	to_chat(H, span_love("Серебряное свадебное кольцо упало у ваших ног в знак союза."))

/datum/controller/subsystem/familytree/proc/house_allows_relatives(datum/heritage/house)
	if(!house)
		return FALSE
	if(xylix_roulette_active)
		return TRUE
	if(!house.house_leader?.person)
		return TRUE
	var/mob/living/carbon/human/leader = house.house_leader.person
	if(!leader.setspouse || !length(leader.setspouse))
		return TRUE
	return leader.allow_relatives_in_family

/datum/controller/subsystem/familytree/proc/wait_for_relative_house(mob/living/carbon/human/H, reason)
	if(!H || QDELETED(H) || H.family_datum || H.familytree_opted_out)
		return
	if(H.familytree_assignment_scheduled)
		ftlog("WAIT_RELATIVE SKIP: [H.real_name] already scheduled reason=[reason]")
		return
	ftlog("WAIT_RELATIVE: [H.real_name] reason=[reason], scheduling re-assignment in 20s")
	H.familytree_assignment_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, H.familytree_pref), 20 SECONDS)

/datum/controller/subsystem/familytree/proc/wake_waiting_relative_seekers(datum/heritage/house)
	if(!house || house.closed)
		return
	if(!familytree_relative_join_phase_open())
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H?.client || H.family_datum || !familytree_pref_is_join(H.familytree_pref))
			continue
		if(!H.familytree_module_signal_bound || !H.familytree_assignment_scheduled)
			continue
		addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, H.familytree_pref), 1 SECONDS)

/datum/controller/subsystem/familytree/proc/retry_local_assignment(mob/living/carbon/human/H, reason)
	if(!H || QDELETED(H) || H.family_datum || H.familytree_opted_out)
		return
	if(H.familytree_assignment_scheduled)
		ftlog("RETRY SKIP: [H.real_name] already scheduled reason=[reason]")
		return
	ftlog("RETRY: [H.real_name] reason=[reason], scheduling re-assignment in 10s")
	to_chat(H, span_warning("Не удалось найти подходящую семью. Система попробует снова."))
	H.familytree_assignment_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, H.familytree_pref), 10 SECONDS)

/datum/controller/subsystem/familytree/proc/introduce_pair(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!A || !B)
		return
	if(A.mind && B.mind)
		A.mind.i_know_person(B)
		B.mind.i_know_person(A)
		fix_family_fjob(A, B)
		fix_family_fjob(B, A)
	else
		addtimer(CALLBACK(src, PROC_REF(delayed_introduce_pair), A, B), 3 SECONDS)

/datum/controller/subsystem/familytree/proc/delayed_introduce_pair(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!A || QDELETED(A) || !B || QDELETED(B))
		return
	if(A.mind && B.mind)
		A.mind.i_know_person(B)
		B.mind.i_know_person(A)
		fix_family_fjob(A, B)
		fix_family_fjob(B, A)

/datum/controller/subsystem/familytree/proc/fix_family_fjob(mob/living/carbon/human/knower, mob/living/carbon/human/known)
	if(!knower?.mind?.known_people || !known?.mind)
		return
	var/list/info = knower.mind.known_people[known.real_name]
	if(!info)
		return
	if(LAZYLEN(known.mind.antag_datums))
		info["FJOB"] = "Adventurer"

// --- Reject-mask decoders (log-time only, not on hot path) ---

/proc/ftreject_decode_house(mask)
	if(!mask)
		return "none"
	var/list/parts = list()
	if(mask & FTREJ_H_CLOSED)    parts += "closed"
	if(mask & FTREJ_H_NONAME)    parts += "noname"
	if(mask & FTREJ_H_RELATIVES) parts += "no_relatives"
	if(mask & FTREJ_H_RACE)      parts += "race"
	if(mask & FTREJ_H_AGE)       parts += "age"
	if(mask & FTREJ_H_EMPTY)     parts += "empty"
	if(mask & FTREJ_H_OFFLINE)   parts += "offline"
	return parts.Join(",")

/proc/ftreject_decode_newlywed(mask)
	if(!mask)
		return "none"
	var/list/parts = list()
	if(mask & FTREJ_N_POLY)      parts += "poly"
	if(mask & FTREJ_N_OPTOUT)    parts += "optout"
	if(mask & FTREJ_N_BLOCK)     parts += "block"
	if(mask & FTREJ_N_PRONOUNS)  parts += "pronouns"
	if(mask & FTREJ_N_SPECIES)   parts += "species"
	if(mask & FTREJ_N_ESTATE)    parts += "estate"
	if(mask & FTREJ_N_TIER)      parts += "tier"
	if(mask & FTREJ_N_SETSPOUSE) parts += "setspouse"
	return parts.Join(",")

/proc/ftreject_decode_family(mask)
	if(!mask)
		return "none"
	var/list/parts = list()
	if(mask & FTREJ_F_CLOSED)    parts += "closed"
	if(mask & FTREJ_F_RACE)      parts += "race"
	if(mask & FTREJ_F_POLY)      parts += "poly"
	if(mask & FTREJ_F_OFFLINE)   parts += "offline"
	if(mask & FTREJ_F_SETSPOUSE) parts += "setspouse"
	if(mask & FTREJ_F_PRONOUNS)  parts += "pronouns"
	if(mask & FTREJ_F_SPECIES)   parts += "species"
	if(mask & FTREJ_F_ESTATE)    parts += "estate"
	if(mask & FTREJ_F_TIER)      parts += "tier"
	if(mask & FTREJ_F_PARTIAL)   parts += "partial"
	if(mask & FTREJ_F_OPTOUT)    parts += "optout"
	return parts.Join(",")
