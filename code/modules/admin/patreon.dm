/datum/config_entry/string/donator_command_channel
	default = null

#define PATREONT1 "[global.config.directory]/roguetown/patreon/p1.txt"
#define PATREONT2 "[global.config.directory]/roguetown/patreon/p2.txt"
#define PATREONT3 "[global.config.directory]/roguetown/patreon/p3.txt"
#define PATREONT4 "[global.config.directory]/roguetown/patreon/p4.txt"
#define PATREONT5 "[global.config.directory]/roguetown/patreon/p5.txt"

#define PATREON_FILE "data/Members_7968561.csv"
#define DONATOR_SOURCE_CONFIG_IMPORT "config_import"
#define DONATOR_SOURCE_CSV_IMPORT "csv_import"
#define DONATOR_SOURCE_TGS "tgs"

GLOBAL_LIST_EMPTY(patreont1)
GLOBAL_LIST_EMPTY(patreont2)
GLOBAL_LIST_EMPTY(patreont3)
GLOBAL_LIST_EMPTY(patreont4)
GLOBAL_LIST_EMPTY(patreont5)
GLOBAL_LIST_EMPTY(allpatreons)
GLOBAL_VAR(PatreonsLoaded)
GLOBAL_VAR(PatreonsLoading)

/proc/donator_tgs_sender_in_configured_channel(datum/tgs_chat_user/sender)
	var/allowed_channel = CONFIG_GET(string/donator_command_channel)
	if(!allowed_channel)
		return FALSE
	allowed_channel = trim(allowed_channel)
	if(!allowed_channel)
		return FALSE
	if(!sender || !sender.channel)
		return FALSE

	var/datum/tgs_chat_channel/channel = sender.channel
	var/allowed_channel_lower = lowertext(allowed_channel)

	if(channel.id && lowertext("[channel.id]") == allowed_channel_lower)
		return TRUE
	if(channel.custom_tag && lowertext("[channel.custom_tag]") == allowed_channel_lower)
		return TRUE
	if(channel.friendly_name && lowertext("[channel.friendly_name]") == allowed_channel_lower)
		return TRUE

	return FALSE

/proc/normalize_donator_tier(tier, min_tier = 0)
	var/parsed_tier = 0
	if(isnum(tier))
		parsed_tier = tier
	else if(istext(tier))
		parsed_tier = text2num(tier)
	if(isnull(parsed_tier))
		parsed_tier = 0
	return clamp(round(parsed_tier), min_tier, 5)

/proc/donator_tgs_reply(text)
	return new /datum/tgs_message_content(text || "")

/proc/patreon_tier_from_csv_line(line)
	if(!line || !findtext(line, "Active patron"))
		return 0
	if(findtext(line, "ROGUETOWN LORD"))
		return 5
	if(findtext(line, "ROGUETOWN MERCHANT"))
		return 4
	if(findtext(line, "ROGUETOWN MYTHRIL"))
		return 3
	if(findtext(line, "ROGUETOWN GOLD"))
		return 2
	if(findtext(line, "ROGUETOWN SILVER"))
		return 1
	return 0

/proc/patreon_email_from_csv_line(line)
	if(!line)
		return
	var/index = findtext(line, ",")
	if(!index)
		return
	var/indexs = findtext(line, ",", index + 1)
	if(!indexs)
		return
	return copytext(line, index + 1, indexs)

/proc/patreon_record_import_entry(list/entries, list/sources, key, tier, source)
	key = ckey(key)
	tier = normalize_donator_tier(tier)
	if(!key || tier < 1 || tier > 5)
		return
	var/current_tier = entries[key]
	if(!current_tier || tier >= current_tier)
		entries[key] = tier
		sources[key] = source

/proc/patreon_collect_config_file(list/entries, list/sources, path, tier)
	var/config_file = file(path)
	if(!fexists(config_file))
		return
	for(var/line in world.file2list(config_file))
		if(!line)
			continue
		if(findtextEx(line, "#", 1, 2))
			continue
		patreon_record_import_entry(entries, sources, line, tier, DONATOR_SOURCE_CONFIG_IMPORT)

/proc/patreon_collect_csv_file(list/entries, list/sources)
	var/csv_file = file(PATREON_FILE)
	if(!fexists(csv_file))
		return
	for(var/line in world.file2list(csv_file))
		var/tier = patreon_tier_from_csv_line(line)
		if(!tier)
			continue
		var/player_email = patreon_email_from_csv_line(line)
		var/find_ckey = patemail2ckey(player_email)
		if(find_ckey)
			patreon_record_import_entry(entries, sources, find_ckey, tier, DONATOR_SOURCE_CSV_IMPORT)

/proc/patreon_collect_legacy_entries()
	var/list/entries = list()
	var/list/sources = list()
	patreon_collect_config_file(entries, sources, PATREONT1, 1)
	patreon_collect_config_file(entries, sources, PATREONT2, 2)
	patreon_collect_config_file(entries, sources, PATREONT3, 3)
	patreon_collect_config_file(entries, sources, PATREONT4, 4)
	patreon_collect_config_file(entries, sources, PATREONT5, 5)
	patreon_collect_csv_file(entries, sources)
	return list("entries" = entries, "sources" = sources)

/proc/patreon_clear_cache()
	GLOB.patreont1.Cut()
	GLOB.patreont2.Cut()
	GLOB.patreont3.Cut()
	GLOB.patreont4.Cut()
	GLOB.patreont5.Cut()
	GLOB.allpatreons.Cut()

/proc/patreon_apply_level_to_cache(key, tier)
	key = ckey(key)
	tier = normalize_donator_tier(tier)
	if(!key)
		return
	GLOB.patreont1 -= key
	GLOB.patreont2 -= key
	GLOB.patreont3 -= key
	GLOB.patreont4 -= key
	GLOB.patreont5 -= key
	GLOB.allpatreons -= key
	if(tier < 1 || tier > 5)
		return
	switch(tier)
		if(1)
			GLOB.patreont1 |= key
		if(2)
			GLOB.patreont2 |= key
		if(3)
			GLOB.patreont3 |= key
		if(4)
			GLOB.patreont4 |= key
		if(5)
			GLOB.patreont5 |= key
	GLOB.allpatreons |= key

/proc/patreon_level_from_cache(key)
	key = ckey(key)
	if(!key)
		return 0
	var/level = 0
	if(key in GLOB.patreont1)
		level = 1
	if(key in GLOB.patreont2)
		level = 2
	if(key in GLOB.patreont3)
		level = 3
	if(key in GLOB.patreont4)
		level = 4
	if(key in GLOB.patreont5)
		level = 5
	return level

/proc/patreon_load_legacy_cache()
	var/list/legacy_data = patreon_collect_legacy_entries()
	var/list/entries = legacy_data["entries"]
	for(var/key in entries)
		patreon_apply_level_to_cache(key, entries[key])

/proc/db_donators_count()
	if(!SSdbcore.Connect())
		return
	var/datum/DBQuery/query_count_donators = SSdbcore.NewQuery({"
		SELECT COUNT(*) FROM [format_table_name("donators")]
	"})
	if(!query_count_donators.Execute())
		log_sql("Failed to count donators: [query_count_donators.ErrorMsg()]")
		qdel(query_count_donators)
		return
	var/count = 0
	if(query_count_donators.NextRow())
		count = text2num(query_count_donators.item[1])
	qdel(query_count_donators)
	return count

/proc/db_load_patreons_to_cache()
	if(!SSdbcore.Connect())
		return FALSE
	var/datum/DBQuery/query_get_donators = SSdbcore.NewQuery({"
		SELECT ckey, tier FROM [format_table_name("donators")]
		WHERE active = 1 AND tier BETWEEN 1 AND 5
		ORDER BY tier ASC, ckey ASC
	"})
	if(!query_get_donators.Execute())
		log_sql("Failed to load donators from database: [query_get_donators.ErrorMsg()]")
		qdel(query_get_donators)
		return FALSE
	while(query_get_donators.NextRow())
		var/key = query_get_donators.item[1]
		var/tier = text2num(query_get_donators.item[2])
		patreon_apply_level_to_cache(key, tier)
	qdel(query_get_donators)
	return TRUE

/proc/db_set_donator_tier(key, tier, source = "manual", added_by = null, notes = null)
	key = ckey(key)
	tier = normalize_donator_tier(tier, 1)
	if(!key || tier < 1 || tier > 5)
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE
	var/datum/DBQuery/query_set_donator = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("donators")] (ckey, tier, active, source, added_by, notes)
		VALUES (:ckey, :tier, 1, :source, :added_by, :notes)
		ON DUPLICATE KEY UPDATE
			tier = VALUES(tier),
			active = 1,
			source = VALUES(source),
			added_by = VALUES(added_by),
			notes = VALUES(notes)
	"}, list(
		"ckey" = key,
		"tier" = tier,
		"source" = source,
		"added_by" = added_by,
		"notes" = notes,
	))
	if(!query_set_donator.Execute())
		log_sql("Failed to set donator tier for [key]: [query_set_donator.ErrorMsg()]")
		qdel(query_set_donator)
		return FALSE
	qdel(query_set_donator)
	return TRUE

/proc/db_import_donator_tier(key, tier, source = DONATOR_SOURCE_CONFIG_IMPORT, added_by = null, notes = null)
	key = ckey(key)
	tier = normalize_donator_tier(tier, 1)
	if(!key || tier < 1 || tier > 5)
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE
	var/datum/DBQuery/query_import_donator = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("donators")] (ckey, tier, active, source, added_by, notes)
		VALUES (:ckey, :tier, 1, :source, :added_by, :notes)
		ON DUPLICATE KEY UPDATE
			active = 1,
			source = IF(VALUES(tier) >= tier, VALUES(source), source),
			added_by = IF(VALUES(tier) >= tier, VALUES(added_by), added_by),
			notes = IF(VALUES(tier) >= tier, VALUES(notes), notes),
			tier = GREATEST(tier, VALUES(tier))
	"}, list(
		"ckey" = key,
		"tier" = tier,
		"source" = source,
		"added_by" = added_by,
		"notes" = notes,
	))
	if(!query_import_donator.Execute())
		log_sql("Failed to import donator tier for [key]: [query_import_donator.ErrorMsg()]")
		qdel(query_import_donator)
		return FALSE
	qdel(query_import_donator)
	return TRUE

/proc/db_remove_donator(key, removed_by = null)
	key = ckey(key)
	if(!key)
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE
	var/datum/DBQuery/query_remove_donator = SSdbcore.NewQuery({"
		UPDATE [format_table_name("donators")]
		SET active = 0, source = 'tgs_removed', added_by = :removed_by, notes = NULL
		WHERE ckey = :ckey
	"}, list(
		"ckey" = key,
		"removed_by" = removed_by,
	))
	if(!query_remove_donator.Execute())
		log_sql("Failed to remove donator [key]: [query_remove_donator.ErrorMsg()]")
		qdel(query_remove_donator)
		return FALSE
	qdel(query_remove_donator)
	return TRUE

/proc/db_get_donator_info(key)
	key = ckey(key)
	if(!key)
		return
	if(!SSdbcore.Connect())
		return
	var/datum/DBQuery/query_get_donator = SSdbcore.NewQuery({"
		SELECT ckey, tier, active, source, added_by, notes, created_at, updated_at
		FROM [format_table_name("donators")]
		WHERE ckey = :ckey
	"}, list("ckey" = key))
	if(!query_get_donator.Execute())
		log_sql("Failed to get donator [key]: [query_get_donator.ErrorMsg()]")
		qdel(query_get_donator)
		return
	var/list/info
	if(query_get_donator.NextRow())
		info = list(
			"ckey" = query_get_donator.item[1],
			"tier" = text2num(query_get_donator.item[2]),
			"active" = text2num(query_get_donator.item[3]),
			"source" = query_get_donator.item[4],
			"added_by" = query_get_donator.item[5],
			"notes" = query_get_donator.item[6],
			"created_at" = query_get_donator.item[7],
			"updated_at" = query_get_donator.item[8],
		)
	qdel(query_get_donator)
	return info

/proc/db_import_config_donators(force = FALSE)
	var/current_count = db_donators_count()
	if(isnull(current_count))
		return -1
	if(current_count && !force)
		return 0
	var/list/legacy_data = patreon_collect_legacy_entries()
	var/list/entries = legacy_data["entries"]
	var/list/sources = legacy_data["sources"]
	var/imported = 0
	for(var/key in entries)
		if(db_import_donator_tier(key, entries[key], sources[key], "auto_import", "Imported from legacy patreon config/csv"))
			imported++
	return imported

/proc/refresh_online_donator_cache(key = null)
	key = ckey(key)
	for(var/client/C in GLOB.clients)
		if(key && C.ckey != key)
			continue
		C.patreonlevel = -1
		C.add_patreon_verbs()

/proc/load_patreons(force_reload = FALSE)
	if(GLOB.PatreonsLoaded && !force_reload)
		GLOB.PatreonsLoading = FALSE
		return TRUE
	GLOB.PatreonsLoading = TRUE
	patreon_clear_cache()

	var/current_count = db_donators_count()
	if(!isnull(current_count))
		if(!current_count)
			db_import_config_donators(TRUE)
		if(db_load_patreons_to_cache())
			GLOB.PatreonsLoaded = TRUE
			GLOB.PatreonsLoading = FALSE
			return TRUE

	log_world("Failed to load donators from database. Falling back to legacy patreon config files for current round.")
	log_game("Failed to load donators from database. Falling back to legacy patreon config files for current round.")
	patreon_load_legacy_cache()
	GLOB.PatreonsLoaded = TRUE
	GLOB.PatreonsLoading = FALSE
	return TRUE

/proc/queue_load_patreons()
	if(GLOB.PatreonsLoaded || GLOB.PatreonsLoading)
		return
	GLOB.PatreonsLoading = TRUE
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(load_patreons))

/proc/check_patreon_lvl(key)
	key = ckey(key)
	if(!key)
		return 0
	for(var/X in GLOB.temporary_donators)
		if(X == key)
			return GLOB.temporary_donators[X]
	if(!GLOB.PatreonsLoaded)
		queue_load_patreons()
	return patreon_level_from_cache(key)

/proc/get_patreon_manual(key)
	key = ckey(key)
	if(!key)
		return 0
	var/list/legacy_data = patreon_collect_legacy_entries()
	var/list/entries = legacy_data["entries"]
	return entries[key] || 0

#undef PATREONT1
#undef PATREONT2
#undef PATREONT3
#undef PATREONT4
#undef PATREONT5

GLOBAL_LIST_INIT(pleveloneverbs, world.pleveloneverbs())
GLOBAL_PROTECT(pleveloneverbs)
/world/proc/pleveloneverbs()
	return list(
	)

GLOBAL_LIST_INIT(pleveltwoverbs, world.pleveltwoverbs())
GLOBAL_PROTECT(pleveltwoverbs)
/world/proc/pleveltwoverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelthreeverbs, world.plevelthreeverbs())
GLOBAL_PROTECT(plevelthreeverbs)
/world/proc/plevelthreeverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelfourverbs, world.plevelfourverbs())
GLOBAL_PROTECT(plevelfourverbs)
/world/proc/plevelfourverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelfiveverbs, world.plevelfiveverbs())
GLOBAL_PROTECT(plevelfiveverbs)
/world/proc/plevelfiveverbs()
	return list(
	)

/client/proc/add_patreon_verbs()
	set waitfor = 0
	var/plev = check_patreon_lvl(ckey)

	if(plev > 1)
		add_verb(src, GLOB.pleveloneverbs)
	if(plev > 2)
		add_verb(src, GLOB.pleveltwoverbs)
	if(plev > 3)
		add_verb(src, GLOB.plevelthreeverbs)
	if(plev > 4)
		add_verb(src, GLOB.plevelfourverbs)
	if(plev > 5)
		add_verb(src, GLOB.plevelfiveverbs)

GLOBAL_LIST_EMPTY(hiderole)


GLOBAL_LIST_EMPTY(anonymize)

/mob/dead/new_player/verb/anonymize()
	set category = "Preferences.Options"
	set name = "Anonymize"
	if(!client)
		return
	if(get_playerquality(client.ckey) <= -5)
		client.prefs.anonymize = FALSE
		client.prefs.save_preferences()
		to_chat(src, span_warning("Your PQ is too low!"))
		return
//	if(!check_whitelist(client.ckey))
//		to_chat(src, span_warning("Whitelisted players only."))
//		return
	if(client.prefs.anonymize == TRUE)
		if(alert(src, "Disable Anonymize? (Not Recommended)", "ROGUETOWN", "YES", "NO") == "YES")
			if(GLOB.respawncounts[client.ckey])
				to_chat(src, span_warning("You have already spawned."))
				return
			client.prefs.anonymize = FALSE
			client.prefs.save_preferences()
			to_chat(src, "No longer anonymous.")
			GLOB.anonymize -= client.ckey
	else
		if(alert(src, "Enable Anonymize? This will hide your BYOND name from anyone except \
		Dungeon Masters while playing here, useful for dealing with negative OOC bias or \
		maintaining privacy from other BYOND users.", "ROGUETOWN", "YES", "NO") == "YES")
			if(GLOB.respawncounts[client.ckey])
				to_chat(src, span_warning("You have already spawned."))
				return
			client.prefs.anonymize = TRUE
			client.prefs.save_preferences()
			to_chat(src, "Anonymous... OK")
			GLOB.anonymize |= client.ckey

GLOBAL_LIST_EMPTY(temporary_donators)


/client/proc/patreonlevel()
	if(patreonlevel != -1)
		return patreonlevel
	else
		patreonlevel = check_patreon_lvl(ckey)
		return patreonlevel

/proc/patemail2ckey(input)
	if(!input)
		return
	var/json_file = file("data/patemail2ckey.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	var/list/donatorss = json[input]
	if(isnull(donatorss))
		return
	for(var/X in donatorss)
		return X
/*
/mob/dead/new_player/proc/register_patreon()
	set name = "RegisterPatreon"
	set category = "Register"
	if(client)
		if(client.patreonlevel())
			return
	var/name = input("Enter your patreon DISPLAY NAME exactly as it appears on Patreon.","ROGUETOWN") as text|null
	if(!name)
		return
	var/email = input("Enter your patreon EMAIL ADDRESS exactly as it appears on Patreon.","ROGUETOWN") as text|null
	if(!email)
		return
	if(!patreon_lookup(name) || !patreon_lookup(email) || !findtext(email, "@"))
		to_chat(src, span_warning("We couldn't find that name/email combo.</span> <span class='info'>Donator status is updated weekly before every playtest. If you have waited a week, seek help in our DISCORD SERVER (https://discord.gg/9uYTPsRMKa)"))
		return
//	var/saniemail = sanitize_simple(email,list("@"="AT","."="DOT"))
	var/fug = patemail2ckey(email)
	if(fug && (fug != ckey))
		to_chat(src, span_warning("That Patreon is already registered to a different player.</span> <span class='info'>Donator status is updated weekly before every playtest. If you have waited a week, seek help in our DISCORD SERVER (https://discord.gg/9uYTPsRMKa)"))
		return
	add_patreon(ckey,email)
	client.patreonlevel = -1
	to_chat(src, span_boldnotice("Patreon registered."))
	var/shown_patreon_level = client.patreonlevel()
	if(!shown_patreon_level)
		shown_patreon_level = "NONE"
	switch(shown_patreon_level)
		if(1)
			shown_patreon_level = "Silver"
		if(2)
			shown_patreon_level = "Gold"
		if(3)
			shown_patreon_level = "Mythril"
		if(4)
			shown_patreon_level = "Merchant"
		if(5)
			shown_patreon_level = "Lord"
	to_chat(src, span_info("Your Donator Level: [shown_patreon_level]"))
*/
/proc/add_patreon(key, email)
	key = ckey(key)
	if(!email || !key)
		return
	var/tier = 0
	var/csv_file = file(PATREON_FILE)
	if(fexists(csv_file))
		for(var/line in world.file2list(csv_file))
			if(findtext(line, email))
				tier = patreon_tier_from_csv_line(line)
				break
	if(tier)
		patreon_apply_level_to_cache(key, tier)
		db_set_donator_tier(key, tier, "patreon_register", key, "Registered through Patreon lookup")

	var/json_file = file("data/patemail2ckey.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	json[email] = list(key)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/proc/patreon_lookup(name)
	if(name == "Active patron")
		return FALSE
	var/csv_file = file(PATREON_FILE)
	if(fexists(csv_file))
		for(var/line in world.file2list(csv_file))
			if(findtext(line, name))
				if(findtext(line, "Active patron"))
					return TRUE

/datum/tgs_chat_command/donator
	name = "donator"
	help_text = "donator <set <ckey> <1-5>|remove <ckey>|get <ckey>|list tier|reload|import_configs force>"
	admin_only = TRUE

/datum/tgs_chat_command/donator/Run(datum/tgs_chat_user/sender, params)
	var/response = ""
	if(!donator_tgs_sender_in_configured_channel(sender))
		var/allowed_channel = CONFIG_GET(string/donator_command_channel)
		if(!allowed_channel)
			response += "Donator command channel is not configured. Set DONATOR_COMMAND_CHANNEL in config.txt."
		else
			response += "This command can only be used in the configured donator command channel."
		return donator_tgs_reply(response)

	if(!length(params))
		response += help_text
		return donator_tgs_reply(response)

	var/list/all_params = splittext(params, " ")
	if(length(all_params) < 1)
		response += help_text
		return donator_tgs_reply(response)

	switch(lowertext(all_params[1]))
		if("set")
			if(length(all_params) < 3)
				response += "Usage: donator set <ckey> <1-5>"
				return donator_tgs_reply(response)
			var/key = ckey(all_params[2])
			var/tier = normalize_donator_tier(all_params[3], 1)
			if(!key || tier < 1 || tier > 5)
				response += "Invalid ckey or tier. Tier must be 1-5."
				return donator_tgs_reply(response)
			if(!db_set_donator_tier(key, tier, DONATOR_SOURCE_TGS, "tgs", null))
				response += "Failed to set `[key]` donator tier. Check SQL logs."
				return donator_tgs_reply(response)
			load_patreons(TRUE)
			refresh_online_donator_cache(key)
			response += "`[key]` donator tier set to [tier]."
			return donator_tgs_reply(response)

		if("remove")
			if(length(all_params) < 2)
				response += "Usage: donator remove <ckey>"
				return donator_tgs_reply(response)
			var/key = ckey(all_params[2])
			if(!key)
				response += "Invalid ckey."
				return donator_tgs_reply(response)
			if(!db_remove_donator(key, "tgs"))
				response += "Failed to remove `[key]` from donators. Check SQL logs."
				return donator_tgs_reply(response)
			load_patreons(TRUE)
			refresh_online_donator_cache(key)
			response += "`[key]` has been deactivated in donators."
			return donator_tgs_reply(response)

		if("get")
			if(length(all_params) < 2)
				response += "Usage: donator get <ckey>"
				return donator_tgs_reply(response)
			var/key = ckey(all_params[2])
			if(!key)
				response += "Invalid ckey."
				return donator_tgs_reply(response)
			var/list/info = db_get_donator_info(key)
			if(!info)
				response += "`[key]` is not present in donators."
				return donator_tgs_reply(response)
			var/info_ckey = info["ckey"]
			var/info_tier = info["tier"]
			var/info_active = info["active"]
			var/info_source = info["source"]
			var/info_added_by = info["added_by"]
			var/info_updated_at = info["updated_at"]
			var/info_notes = info["notes"]
			response += "`[info_ckey]`: tier [info_tier], active [info_active], source `[info_source]`, added_by `[info_added_by]`, updated `[info_updated_at]`."
			if(info_notes)
				response += " Notes: [info_notes]"
			return donator_tgs_reply(response)

		if("list")
			var/tier_filter = 0
			if(length(all_params) >= 2)
				tier_filter = normalize_donator_tier(all_params[2], 1)
				if(tier_filter < 1 || tier_filter > 5)
					response += "Tier filter must be 1-5."
					return donator_tgs_reply(response)
			if(!SSdbcore.Connect())
				response += "Failed to connect to database."
				return donator_tgs_reply(response)
			var/sql = {"SELECT ckey, tier, source, updated_at FROM [format_table_name("donators")] WHERE active = 1"}
			var/list/query_params = list()
			if(tier_filter)
				sql += " AND tier = :tier"
				query_params["tier"] = tier_filter
			sql += " ORDER BY tier DESC, ckey ASC"
			var/datum/DBQuery/query_list_donators = SSdbcore.NewQuery(sql, query_params)
			if(!query_list_donators.Execute())
				response += "Failed to list donators.\n"
				response += query_list_donators.ErrorMsg()
				qdel(query_list_donators)
				return donator_tgs_reply(response)
			var/count = 0
			while(query_list_donators.NextRow())
				count++
				response += "`[query_list_donators.item[1]]` - tier [query_list_donators.item[2]], source `[query_list_donators.item[3]]`, updated `[query_list_donators.item[4]]`\n"
			qdel(query_list_donators)
			if(!count)
				response += "No active donators found."
			else
				response += "Total: [count]"
			return donator_tgs_reply(response)

		if("reload")
			GLOB.PatreonsLoaded = FALSE
			load_patreons(TRUE)
			refresh_online_donator_cache()
			response += "Donators reloaded. Active cached donators: [length(GLOB.allpatreons)]."
			return donator_tgs_reply(response)

		if("import_configs")
			var/force = FALSE
			if(length(all_params) >= 2 && lowertext(all_params[2]) == "force")
				force = TRUE
			var/imported = db_import_config_donators(force)
			if(imported < 0)
				response += "Failed to import legacy donators. Check SQL logs."
				return donator_tgs_reply(response)
			GLOB.PatreonsLoaded = FALSE
			load_patreons(TRUE)
			refresh_online_donator_cache()
			if(!imported && !force)
				response += "Donators table is not empty; import skipped. Use `donator import_configs force` to merge legacy configs."
			else
				response += "Imported or refreshed [imported] legacy donator entries. Active cached donators: [length(GLOB.allpatreons)]."
			return donator_tgs_reply(response)

		else
			response += help_text
			return donator_tgs_reply(response)

#undef PATREON_FILE
#undef DONATOR_SOURCE_CONFIG_IMPORT
#undef DONATOR_SOURCE_CSV_IMPORT
#undef DONATOR_SOURCE_TGS
