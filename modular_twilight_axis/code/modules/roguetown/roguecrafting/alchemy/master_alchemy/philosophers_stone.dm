/obj/item/philosophers_stone
	name = "Great Philosopher's Stone"
	desc = "A pulsating, blood-red gem. It feels warm, almost like it has a pulse of its own."
	icon = 'modular_twilight_axis/code/modules/roguetown/roguecrafting/alchemy/master_alchemy/alch.dmi'
	icon_state = "soulstone"
	
	var/charges = 0
	var/max_charges = 100
	var/mob/living/carbon/human/bound_soul = null 
	var/regen_rate = 0.033 

/obj/item/philosophers_stone/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/philosophers_stone/Destroy()
	if(bound_soul && !QDELETED(bound_soul))
		REMOVE_TRAIT(bound_soul, TRAIT_PHILOSOPHER_BOUND, src)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/philosophers_stone/process(delta_time)
	if(bound_soul && !QDELETED(bound_soul) && bound_soul.stat != DEAD)
		if(charges < max_charges)
			charges = min(charges + (regen_rate * delta_time), max_charges)
	else
		if(charges > 0)
			charges = max(charges - 0.2, 0)

/obj/item/philosophers_stone/attack_self(mob/living/carbon/human/user)
	if(!istype(user)) return
	

	if(bound_soul)
		to_chat(user, span_warning(bound_soul == user ? "Ваши души уже переплетены." : "Этот камень уже поглотил чужую жизнь."))
		return

	if(HAS_TRAIT(user, TRAIT_PHILOSOPHER_BOUND))
		to_chat(user, span_warning("Ваша душа уже переплетена с другим артефактом. Вы не можете выдержать ношу двух Камней!"))
		return

	user.visible_message(span_danger("[user] вскрывает вену и прижимает Камень к ране!"), \
						span_notice("Вы чувствуете, как ваша жизненная энергия всасывается в холодную грань камня..."))
	
	if(do_after(user, 50, target = src))

		if(HAS_TRAIT(user, TRAIT_PHILOSOPHER_BOUND) || bound_soul)
			return

		bound_soul = user
		charges = max_charges
		

		ADD_TRAIT(user, TRAIT_DNR, src)
		ADD_TRAIT(user, TRAIT_PHILOSOPHER_BOUND, src)

		to_chat(user, span_userdanger("КОНТРАКТ ПОДПИСАН. Камень наполнился вашей кровью. Трейт DNR получен: ваша следующая смерть будет окончательной."))
		update_icon()

/obj/item/philosophers_stone/proc/consume_soul()
	if(!bound_soul || QDELETED(bound_soul)) return

	var/mob/living/carbon/human/victim = bound_soul

	to_chat(victim, span_userdanger("ВЫ ПОТРАТИЛИ БОЛЬШЕ, ЧЕМ МОГЛИ ОТДАТЬ. ВАША ДУША РАЗОРВАНА ВМЕСТЕ С КАМНЕМ!"))

	victim.death()
	
	qdel(src)
