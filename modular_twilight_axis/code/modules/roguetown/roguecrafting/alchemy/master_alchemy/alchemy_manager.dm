GLOBAL_LIST_EMPTY(alchemy_recipe_lookup)
GLOBAL_DATUM_INIT(alchemy_dynamic_manager, /datum/alchemy_dynamic_manager, new)
GLOBAL_LIST_EMPTY(alchemy_transmute_index) 
GLOBAL_LIST_EMPTY(alchemy_icon_cache)
GLOBAL_VAR_INIT(alchemy_index_initialized, FALSE)

/datum/alchemy_dynamic_manager
	var/list/round_recipes = list()

/datum/alchemy_dynamic_manager/New()
	addtimer(CALLBACK(src, PROC_REF(generate_random_hints)), 20)

/datum/alchemy_dynamic_manager/proc/initialize_alchemy()
	generate_random_hints()
	build_transmute_index()

/datum/alchemy_dynamic_manager/proc/build_transmute_index()
	var/list/index = list()


	GLOB.alchemy_recipe_lookup = list()


	for(var/path in subtypesof(/datum/anvil_recipe))
		var/datum/anvil_recipe/AR = path
		if(initial(AR.abstract_type) == path) continue
		
		var/atom/created_path = initial(AR.created_item)
		if(!created_path || !ispath(created_path, /obj/item)) continue
		
		var/list/materials = list()
		var/req_bar = initial(AR.req_bar)
		if(req_bar) materials |= req_bar
		var/list/add_items = initial(AR.additional_items)
		if(length(add_items)) materials |= add_items

		var/list/recipe_data = list(
			"name" = initial(AR.name),
			"cost" = 20 + (initial(AR.craftdiff) * 10),
			"ref" = "[path]",
			"result_type" = created_path,
			"category" = "Кузня"
		)

		for(var/mat in materials)
			if(!index[mat]) index[mat] = list()
			index[mat] += list(recipe_data)
		
		GLOB.alchemy_recipe_lookup["[path]"] = recipe_data

	for(var/datum/crafting_recipe/CR in GLOB.crafting_recipes)
		if(!length(CR.reqs)) continue

		var/atom/created_path = null
		if(islist(CR.result))
			if(length(CR.result)) 
				created_path = CR.result[1]
		else
			created_path = CR.result
		
		if(!created_path || !ispath(created_path, /obj/item)) 
			continue

		var/list/recipe_data = list(
			"name" = CR.name,
			"cost" = 15 + (CR.craftdiff * 8),
			"ref" = "\ref[CR]",
			"result_type" = created_path,
			"category" = "Ремесло"
		)

		for(var/mat in CR.reqs)
			if(!index[mat]) index[mat] = list()
			index[mat] += list(recipe_data)
		
		GLOB.alchemy_recipe_lookup["\ref[CR]"] = recipe_data

	GLOB.alchemy_transmute_index = index


/proc/get_cached_alchemy_icon(atom/path)
	var/path_str = "[path]"
	if(GLOB.alchemy_icon_cache[path_str])
		return GLOB.alchemy_icon_cache[path_str]
	
	var/icon/I = icon(initial(path.icon), initial(path.icon_state), frame = 1)
	var/base64 = "data:image/png;base64,[icon2base64(I)]"
	GLOB.alchemy_icon_cache[path_str] = base64
	return base64

/datum/alchemy_dynamic_manager/proc/generate_random_hints()
	var/list/advanced_potions = subtypesof(/datum/alch_cauldron_recipe/advanced)
	var/list/all_smells = list("wet moss", "purity", "death", "doom", "sweet berries", "power", "fear", "fresh air", "earth", "fire", "authority")
	var/list/used_signatures = list()

	for(var/path in advanced_potions)
		
		var/list/recipe_reqs = list("strong" = list(), "medium" = list(), "light" = list())
		var/signature = ""
		var/attempts = 0
		
		while(attempts < 100)
			attempts++
			var/list/available = all_smells.Copy()
			
			var/s_smell = pick_n_take(available) 
			var/m_smell = pick_n_take(available) 
			var/l_smell = pick_n_take(available) 
				
			signature = "[s_smell]-[m_smell]-[l_smell]"
			
			if(!(signature in used_signatures))
				used_signatures += signature
				recipe_reqs["strong"] += s_smell
				recipe_reqs["medium"] += m_smell
				recipe_reqs["light"] += l_smell
				break
				
		round_recipes[path] = recipe_reqs
		
/proc/find_recipe_data_in_index(target_path)
	if(!target_path)
		return null

	var/target_str = "[target_path]" 
	
	for(var/mat_type in GLOB.alchemy_transmute_index)
		var/list/recipes_for_mat = GLOB.alchemy_transmute_index[mat_type]
		
		for(var/list/recipe_data in recipes_for_mat)
			if(recipe_data["ref"] == target_str)
				return recipe_data
				
	return null
