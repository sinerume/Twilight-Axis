/datum/alch_grid_recipe
	var/name = "Unknown"
	var/result_type = null
	var/result_icon = null
	var/result_icon_state = null
	var/list/grid = list(
		null, null, null,
		null, null, null,
		null, null, null
	)



/datum/alch_grid_recipe/silver
	name = "Трансмутация серебра"
	result_type = /obj/item/rogueore/silver
	result_icon = 'icons/roguetown/items/ore.dmi'
	result_icon_state = "oresilv1"
	grid = list(
		/obj/item/rogueore/iron, /obj/item/rogueore/iron, /obj/item/rogueore/iron,
		/obj/item/rogueore/iron, /obj/item/rogueore/gold, /obj/item/rogueore/iron,
		/obj/item/rogueore/iron, /obj/item/rogueore/iron, /obj/item/rogueore/iron 
	)

/datum/alch_grid_recipe/philosophorum
	name = "Философский камень"
	result_type = /obj/item/philosophers_stone
	result_icon = 'modular_twilight_axis/code/modules/roguetown/roguecrafting/alchemy/master_alchemy/alch.dmi'
	result_icon_state = "soulstone"
	grid = list(
		/obj/item/alch/waterdust, /obj/item/reagent_containers/lux_impure, /obj/item/alch/earthdust,
		/obj/item/alch/magicdust, /obj/item/alch/viscera, /obj/item/alch/magicdust,
		/obj/item/alch/airdust, /obj/item/reagent_containers/lux, /obj/item/alch/firedust

	)
