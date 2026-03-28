GLOBAL_DATUM_INIT(alchemy_dynamic_manager, /datum/alchemy_dynamic_manager, new)

/datum/alchemy_dynamic_manager
	var/list/round_recipes = list()

/datum/alchemy_dynamic_manager/New()
	addtimer(CALLBACK(src, PROC_REF(generate_random_hints)), 20)

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
