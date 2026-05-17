/datum/mind
	var/datum/manor/owned_manor = null

/datum/mind/proc/get_owned_manor()
	return owned_manor

/datum/mind/proc/set_owned_manor(datum/manor/manor)
	owned_manor = manor
	return owned_manor

/datum/manor
	var/manor_name = "Неизвестное имение"
	var/manor_size = "big"
	var/manor_type = "manor"
	var/min_workers = 5
	var/total_workers = 5
	var/patron = /datum/patron/divine/astrata
	var/last_cycle_productivity = 0
	var/list/workstations = list()
	var/list/workstation_types = list(/datum/workstation/field)

/datum/manor/proc/get_owner_display_name(mob/living/carbon/human/owner)
	if(owner?.client?.prefs?.manor_name && length(owner.client.prefs.manor_name))
		return owner.client.prefs.manor_name
	return "Неизвестное имение"

/datum/manor/proc/get_owner_manor_type(mob/living/carbon/human/owner)
	if(owner?.client?.prefs?.manor_type && length(owner.client.prefs.manor_type))
		return owner.client.prefs.manor_type
	return manor_type

/datum/manor/proc/get_manor_size(mob/living/carbon/human/owner)
	if(owner)
		if(owner.advjob == "Knight Banneret" || owner.mind?.assigned_role in list("Marshal", "Steward", "Hand"))
			return "big"
		if(owner.mind?.assigned_role in list("Councillor", "Knight"))
			return "medium"
		if(HAS_TRAIT(owner, TRAIT_NOBLE) && HAS_TRAIT(owner, TRAIT_RESIDENT))
			return "small"
	return manor_size

/datum/manor/proc/update_workstation_types(type = "manor", manor_size = "big")
	if(!type)
		type = manor_type
	switch(manor_size)
		if("big")
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field/big,
						/datum/workstation/farm,
						/datum/workstation/trade
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt/big,
						/datum/workstation/fruit,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish/medium,
						/datum/workstation/field/medium,
						/datum/workstation/trade/medium
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining/big,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/fruit/medium,
						/datum/workstation/hunt/medium,
					)
			min_workers = 15
		if("medium")
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/trade,
						/datum/workstation/farm
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt/medium,
						/datum/workstation/fruit,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish/medium,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining/medium,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/fruit,
						/datum/workstation/hunt,
					)
			min_workers = 10
		else
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field,
						/datum/workstation/farm
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish,
						/datum/workstation/field
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field,
						/datum/workstation/fruit,
					)


/datum/manor/proc/get_owner_patron(mob/living/carbon/human/owner)
	if(!owner || !owner.mind)
		return null
	if(owner.patron)
		return owner.patron.type
	return null

/datum/manor/proc/on_creation(mob/living/carbon/human/owner)
	var/workers_limit = 0

	manor_name = get_owner_display_name(owner)
	manor_type = get_owner_manor_type(owner)
	manor_size = get_manor_size(owner)
	update_workstation_types(manor_type, manor_size)

	var/owner_patron = get_owner_patron(owner)
	if(owner_patron)
		patron = owner_patron

	workstations = list()
	for(var/workstation_type in workstation_types)
		var/datum/workstation/new_workstation = new workstation_type()
		workstations += new_workstation
		workers_limit += new_workstation.workstation_size

	switch(patron)
		if(/datum/patron/divine/xylix)
			if(/datum/workstation/trade in workstation_types)
				for(var/datum/workstation/trade/trade_station in workstations)
					trade_station.workstation_size += 5
					workers_limit += 5
			else
				var/datum/workstation/trade/new_trade = new /datum/workstation/trade()
				workstations += new_trade
				workers_limit += new_trade.workstation_size

	if(workers_limit < min_workers)
		workers_limit = min_workers
	total_workers = rand(min_workers, workers_limit)

/datum/manor/proc/ensure_initialized(mob/living/carbon/human/owner)
	if(!length(workstations))
		on_creation(owner)
	if(total_workers < min_workers)
		total_workers = min_workers
	return src

/datum/manor/proc/get_assigned_workers()
	. = 0
	for(var/datum/workstation/workstation in workstations)
		. += workstation.workers_employed

/datum/manor/proc/get_free_workers()
	return max(total_workers - get_assigned_workers(), 0)

/datum/manor/proc/get_last_cycle_productivity()
	. = max(last_cycle_productivity, 0)
	for(var/datum/workstation/workstation in workstations)
		. += max(workstation.last_cycle_productivity, 0)
		. += max(workstation.production_increase, 0)

/datum/manor/proc/get_stockpile_entry_for_good(good_path)
	if(!good_path)
		return null
	var/datum/roguestock/stockpile/stockpile = new good_path()
	if(!stockpile)
		return null
	var/trade_good_id = stockpile.trade_good_id
	qdel(stockpile)
	if(!trade_good_id)
		return null
	return SSeconomy.find_stockpile_by_trade_good(trade_good_id)

/datum/manor/proc/get_readable_good_name(good_path, fallback = "Ресурс")
	if(!good_path)
		return fallback
	var/as_text = "[good_path]"
	var/last_slash = findlasttext(as_text, "/")
	if(last_slash)
		as_text = copytext(as_text, last_slash + 1)
	as_text = replacetext(as_text, "_", " ")
	if(!length(as_text))
		return fallback
	return uppertext(copytext(as_text, 1, 2)) + copytext(as_text, 2)

/datum/manor/proc/produce_resources(mob/living/carbon/human/owner, is_dawn = FALSE, is_dusk = FALSE)
	if(!owner || !owner.mind || owner.mind.get_owned_manor() != src)
		return null
	if(!length(workstations))
		return null

	var/list/produced_summary = list()
	var/total_units = 0
	var/total_profit_money = 0

	for(var/datum/workstation/workstation in workstations)
		if(workstation.workers_employed <= 0 || !length(workstation.produce))
			continue
		if(is_dawn && !(patron == /datum/patron/divine/noc || patron == /datum/patron/inhumen/zizo))
			continue
		if(is_dusk && patron == /datum/patron/divine/noc)
			continue

		var/list/available_produce = workstation.produce
		var/selected_count = min(length(available_produce), rand(2, 6))
		var/list/selected_produce = list()
		while(length(selected_produce) < selected_count)
			var/choice = pick(available_produce)
			available_produce -= choice
			selected_produce += choice

		var/this_workstation_units = 0
		for(var/i = 1; i <= workstation.workers_employed; i++)
			var/selected_good = pick(selected_produce)
			var/min_units = patron == /datum/patron/divine/noc ? 1 : 0
			var/max_units = patron == /datum/patron/divine/noc ? 3 : 2
			var/units = rand(min_units, max_units)
			if(units <= 0)
				continue
			if(patron == /datum/patron/divine/noc)
				if(istype(workstation, /datum/workstation/hunt))
					units = max(1, ceil(units * 1.2))
				else if(istype(workstation, /datum/workstation/field))
					units = max(0, floor(units * 0.8))

			var/datum/roguestock/stockpile_entry = get_stockpile_entry_for_good(selected_good)
			if(!stockpile_entry)
				continue

			stockpile_entry.stockpile_amount += units
			produced_summary[selected_good] = produced_summary[selected_good] ? produced_summary[selected_good] + units : units
			this_workstation_units += units
			total_units += units

		workstation.last_cycle_productivity = max(this_workstation_units, 0)
		if(workstation.generate_profit)
			total_profit_money += workstation.workers_employed * 2

	last_cycle_productivity = max(total_units, 0)

	if(!total_units && !total_profit_money)
		return null

	var/coin_income = 0
	if(SStreasury.has_account(owner))
		if(total_units)
			coin_income = ceil(total_units / 10)
			SStreasury.generate_money_account(coin_income, owner)
		if(total_profit_money)
			SStreasury.generate_money_account(total_profit_money, owner)
			coin_income += total_profit_money

	var/message = "За этот дае ваше поместье поставило Короне: "
	for(var/good in produced_summary)
		message += "[produced_summary[good]]x [get_readable_good_name(good)]; "

	if(coin_income)
		message += "чистая прибыль составила [coin_income] маммон."
	else
		message += "чистая прибыль от поместья отсутствует."
	if(owner.client)
		to_chat(owner, span_notice(message))

	return list(
		"products" = produced_summary,
		"money" = coin_income,
		"profit_money" = total_profit_money
	)

/obj/structure/roguemachine/mail/proc/can_open_manor_panel(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE

	var/datum/manor_panel/access_probe = new(user)
	var/allowed = access_probe.can_have_manor(user)
	qdel(access_probe)
	return allowed

/obj/structure/roguemachine/mail/proc/open_manor_panel(mob/user)
	if(.)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!Adjacent(H))
		return

	var/datum/manor_panel/panel = new(H)
	var/datum/manor/manor = panel.get_manor_for_user(H)
	if(!manor)
		qdel(panel)
		to_chat(H, span_warning("У этого персонажа пока нет доступного поместья."))
		return TRUE

	H.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/keyboard_enter.ogg', 50, FALSE, -1)
	panel.ui_interact(H)
	return TRUE
