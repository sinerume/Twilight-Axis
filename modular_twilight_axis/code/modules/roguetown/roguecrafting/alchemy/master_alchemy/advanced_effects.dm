
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
