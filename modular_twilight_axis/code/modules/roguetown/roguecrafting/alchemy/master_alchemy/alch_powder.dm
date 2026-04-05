/obj/item/reagent_containers/powder/alchemical
	name = "alchemical powder"
	desc = "A finely ground substance, heavily infused with alchemical essences. Its purpose depends entirely on its composition."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "flour"
	volume = 15
	possible_transfer_amounts = list()
	spillable = FALSE

/obj/item/reagent_containers/powder/alchemical/Initialize()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/reagent_containers/powder/alchemical/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !target.reagents)
		return
	
	if(istype(target, /obj/item/reagent_containers/food) || istype(target, /obj/item/reagent_containers/glass))
		to_chat(user, span_notice("Я аккуратно подмешиваю порошок в [target]..."))
		
		var/list/poison_data = list()
		
		for(var/datum/reagent/R in reagents.reagent_list)
			poison_data[R.type] = R.volume
		
		target.reagents.add_reagent(/datum/reagent/advanced/hidden_dust, 0.1, poison_data)
		
		qdel(src)
		return

/obj/item/reagent_containers/powder/alchemical/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !target.reagents)
		return
	
	if(istype(target, /obj/item/reagent_containers/food) || istype(target, /obj/item/reagent_containers/glass))
		to_chat(user, span_notice("Я аккуратно подмешиваю порошок в [target]..."))
		
		var/list/poison_data = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			poison_data[R.type] = R.volume
		
		target.reagents.add_reagent(/datum/reagent/advanced/hidden_dust, 0.1, poison_data)
		
		qdel(src)
		return

/datum/reagent/advanced/hidden_dust
	name = "осадок"
	color = "#FFFFFF"
	alpha = 255
	metabolization_rate = 0
	var/list/payload_reagents = list()

/datum/reagent/advanced/hidden_dust/on_new(list/data)
	if(islist(data))
		payload_reagents = data.Copy()

/datum/reagent/advanced/hidden_dust/on_merge(list/data)
	if(islist(data))
		for(var/reag_type in data)
			payload_reagents[reag_type] += data[reag_type]

/datum/reagent/advanced/hidden_dust/on_mob_add(mob/living/carbon/M)
	if(!istype(M) || !payload_reagents || !length(payload_reagents))
		return ..()

	for(var/reag_type in payload_reagents)
		var/vol = payload_reagents[reag_type]
		M.reagents.add_reagent(reag_type, vol)

	spawn(1)
		if(holder)
			holder.del_reagent(type)
	
	return ..()
