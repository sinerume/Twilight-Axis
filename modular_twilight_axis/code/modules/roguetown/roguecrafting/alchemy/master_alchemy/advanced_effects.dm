
/obj/structure/alch_prop
	name = "suspicious object"
	desc = "Something about this doesn't look right."
	icon = 'icons/roguetown/items/misc.dmi' 
	icon_state = "woodbucket" 
	density = TRUE
	anchored = TRUE

/datum/reagent/advanced
	name = "Advanced Reagent"
	metabolization_rate = 0.4

/datum/reagent/advanced/growth
	name = "Giant's Might"
	description = "A thick, muddy-brown liquid that feels unnaturally heavy. The bottle seems to pull down on your hand with significant weight."
	color = "#5a3a22"
	taste_description = "earth and raw iron"

/datum/reagent/advanced/growth/on_mob_add(mob/living/carbon/human/M)
	if(istype(M))
		M.dna.features["body_size"] = 1.5
		M.dna.update_body_size()
		ADD_TRAIT(M, TRAIT_BIGGUY, src)
/datum/reagent/advanced/growth/on_mob_delete(mob/living/carbon/human/M)
	if(istype(M))
		M.dna.features["body_size"] = 1.0
		M.dna.update_body_size()
		REMOVE_TRAIT(M, TRAIT_BIGGUY, src)

/datum/reagent/advanced/invisible
	name = "Void Essence"
	description = "A liquid that isn't just black—it actively devours the light around it. The container appears as a literal hole in space."
	color = "#29293f"
	taste_description = "the absolute void"

/datum/reagent/advanced/invisible/on_mob_life(mob/living/M)
	M.alpha = 0
	M.invisibility = 60
	..()

/datum/reagent/advanced/invisible/on_mob_delete(mob/living/M)
	M.alpha = 255
	M.invisibility = 0

/datum/reagent/advanced/paralysis
	name = "Spider's Kiss"
	description = "A viscous, dark purple syrup. It leaves thick, web-like trails against the glass that move on their own."
	color = "#4b0082"
	taste_description = "cloying bitterness"

/datum/reagent/advanced/paralysis/on_mob_life(mob/living/M)
	M.Paralyze(40)
	..()


/datum/reagent/advanced/sleep
	name = "Morpheus Draught"
	description = "A pale blue liquid with a faint, swirling white vapor constantly dancing over its surface."
	color = "#add8e6"
	taste_description = "honey and poppies"

/datum/reagent/advanced/sleep/on_mob_life(mob/living/M)
	M.Sleeping(100)
	..()

/datum/reagent/advanced/grace
	name = "Cat's Grace"
	description = "A shimmering golden oil that feels impossibly slippery. The container feels like it could slide from your hand at any moment."
	color = "#ffd700"
	taste_description = "creamy butter"

/datum/reagent/advanced/grace/on_mob_life(mob/living/M)
	ADD_TRAIT(M, TRAIT_NOFALLDAMAGE2, src)
	..()
/datum/reagent/advanced/grace/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_NOFALLDAMAGE2, src)


/datum/reagent/advanced/speed
	name = "Swift Feet"
	description = "A crackling yellow liquid resembling captured lightning. It vibrates with intense, suppressed energy."
	color = "#ffff00"
	taste_description = "citric acid"

/datum/reagent/advanced/speed/on_mob_add(mob/living/M)
	M.add_movespeed_modifier("swift_feet", multiplicative_slowdown = -1.5)

/datum/reagent/advanced/speed/on_mob_delete(mob/living/M)
	M.remove_movespeed_modifier("swift_feet")

/datum/reagent/advanced/elixir_of_life
	name = "Elixir of Life"
	description = "A shimmering, pearlescent liquid that seems to pulse with a golden light. It represents the ultimate harmony of body and soul."
	reagent_state = LIQUID
	color = "#ffd788" 
	taste_description = "eternal youth and fresh honey"
	scent_description = "morning dew"
	metabolization_rate = REAGENTS_METABOLISM * 1.5

/datum/reagent/advanced/elixir_of_life/on_mob_life(mob/living/carbon/M)
	if(!istype(M)) return ..()

	if(volume >= 60)
		M.reagents.remove_reagent(type, 2)

	if(!HAS_TRAIT(M, TRAIT_INFINITE_STAMINA))
		M.energy_add(120)

	if(volume > 0.99)
		M.stamina_add(-50)

	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = min(M.blood_volume + 50, BLOOD_VOLUME_NORMAL)

	M.heal_wounds(15) 

	if(volume > 0.99)
		M.adjustBruteLoss(-6  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustFireLoss(-6  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustOxyLoss(-5, 0)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5  * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustCloneLoss(-6  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustOrganLoss(ORGAN_SLOT_EYES, -2.5 * REAGENTS_EFFECT_MULTIPLIER)

	..()
	return 1

/datum/reagent/advanced/lycanthropy
	name = "Moon-Cursed Blood"
	description = "A thick, silver-tinted liquid that pulses with an inner ferocity. Coarse, dark hairs float within the solution, dissolving and reforming constantly."
	reagent_state = LIQUID
	color = "#c0c0c0"
	taste_description = "raw meat and cold iron"
	scent_description = "a wild beast in the rain"
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/advanced/lycanthropy/on_mob_life(mob/living/carbon/human/M)
	if(!istype(M) || M.stat == DEAD) return ..()

	var/datum/antagonist/werewolf/W = M.werewolf_infect_attempt()
	
	if(W)
		to_chat(M, span_userdanger("Вы чувствуете, как дикая ярость вскипает в вашей крови!"))
		holder.del_reagent(type)
	else
		if(prob(5))
			to_chat(M, span_warning("Ваша кровь отвергает серебристую примесь..."))
	
	..()
	return 1

/datum/reagent/advanced/night_vision
	name = "Night-Owl Fluid"
	description = "A toxic-green phosphorescent fluid. It pulses rhythmically, as if mimicking the beat of a distant heart."
	reagent_state = LIQUID
	color = "#00ff44"
	taste_description = "burning mint"
	metabolization_rate = REAGENTS_METABOLISM * 0.4

/datum/reagent/advanced/night_vision/on_mob_life(mob/living/carbon/human/M)
	if(!istype(M)) return ..()

	var/obj/item/organ/eyes/E = M.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		E.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		E.see_in_dark = 15
		E.sight_flags |= SEE_BLACKNESS
	

	M.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	M.see_in_dark = 15
	M.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_BLACKNESS)

	if(M.client && M.hud_used)
		var/atom/movable/screen/plane_master/lighting_plane = M.hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(lighting_plane)
			lighting_plane.alpha = 0
			
		var/atom/movable/screen/plane_master/weather_plane = M.hud_used.plane_masters["[WEATHER_EFFECT_PLANE]"]
		if(weather_plane)
			weather_plane.alpha = 0

	M.update_sight()
	..()
	return 1

/datum/reagent/advanced/night_vision/on_mob_delete(mob/living/carbon/human/M)
	if(!istype(M)) return ..()

	var/obj/item/organ/eyes/E = M.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		E.lighting_alpha = initial(E.lighting_alpha)
		E.see_in_dark = initial(E.see_in_dark)
		E.sight_flags &= ~SEE_BLACKNESS
	
	M.lighting_alpha = initial(M.lighting_alpha)
	M.see_in_dark = initial(M.see_in_dark)
	M.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_BLACKNESS)

	if(M.client && M.hud_used)
		var/atom/movable/screen/plane_master/lighting_plane = M.hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(lighting_plane)
			lighting_plane.alpha = 255
			
		var/atom/movable/screen/plane_master/weather_plane = M.hud_used.plane_masters["[WEATHER_EFFECT_PLANE]"]
		if(weather_plane)
			weather_plane.alpha = 255

	M.update_sight()
	..()


/datum/reagent/advanced/vampirism
	name = "Essence of the Night"
	reagent_state = LIQUID
	color = "#310000"
	description = "An incredibly thick, dark crimson liquid. It represents the ultimate curse of immortality."
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/advanced/vampirism/on_mob_life(mob/living/carbon/human/M)
	if(!istype(M) || !M.mind || M.stat == DEAD)
		return ..()

	if(M.mind.has_antag_datum(/datum/antagonist/vampire) || M.mind.has_antag_datum(/datum/antagonist/werewolf))
		holder.del_reagent(type)
		return ..()

	if(!length(GLOB.vampire_clans))
		for(var/clan_type in subtypesof(/datum/clan))
			var/datum/clan/clan_obj = new clan_type
			GLOB.vampire_clans[clan_type] = clan_obj
		sortList(GLOB.vampire_clans)

	var/datum/clan/target_clan = GLOB.vampire_clans[/datum/clan]
	if(!target_clan)
		target_clan = GLOB.vampire_clans[GLOB.vampire_clans[1]]

	var/datum/antagonist/vampire/ancillae/new_vamp = new /datum/antagonist/vampire/ancillae(
		incoming_clan = target_clan,
		forced_clan = TRUE,
		generation = GENERATION_ANCILLAE
	)

	if(M.mind.add_antag_datum(new_vamp))
		to_chat(M, span_userdanger("Вы чувствуете, как ваше сердце делает последний, мучительный удар и останавливается..."))
		M.visible_message(span_danger("Кожа [M] становится мертвенно-бледной!"))
		M.playsound_local(get_turf(M), 'sound/music/vampintro.ogg', 80, FALSE)
		
		ADD_TRAIT(M, TRAIT_DNR, "vampire_potion")

		holder.del_reagent(type)
	else
		qdel(new_vamp)
		holder.remove_reagent(type, 1)

	..()
	return 1
