/datum/antagonist/bandit/freeman
	name = "Freeman"
	antagpanel_category = "Freeman"
	roundend_category = "freemans"
	show_name_in_check_antagonists = TRUE
	job_rank = ROLE_FREEMAN
	confess_lines = list(
		"ПЕСКИ АЛЬ-АШУРА БУДУТ СВОБОДНЫ!!",
		"СМЕРТЬ СУЛТАНУ!! ДА ЗДРАВСТВУЕТ АЛЬ-МАТТИОС!!",
		"НАШ ДЖИХАД ЗАКОНЧИТСЯ ВАШЕЙ СМЕРТЬЮ!!",
	)

/datum/antagonist/bandit/freeman/on_gain()
	. = ..()
	owner.special_role = name

/datum/antagonist/bandit/freeman/finalize_bandit()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/traitor.ogg', 60, FALSE, pressure_affected = FALSE)
	var/mob/living/carbon/human/H = owner.current
	if((!istype(H.patron, /datum/patron/inhumen)) || (istype(H.patron, /datum/patron/inhumen/zizo)))
		H.set_patron(/datum/patron/inhumen/matthios)
	H.verbs |= /mob/proc/haltyell_exhausting
	ADD_TRAIT(H, TRAIT_BANDITCAMP, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SEEPRICES, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_FREEMAN, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_OUTLANDER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_OUTLAW, TRAIT_GENERIC)
	to_chat(H, span_alertsyndie("Я - ФРИМЕН!"))
	to_chat(H, span_boldwarning("Да будет проклят Султан Аль-Ашура песками и Иблис! Когда-то вы владели этими землями: поля специй, торговые пути - всё это было частью вашего таваифа. Султан забрал ваши права и земли несколько лет назад - и теперь вы боретесь за свои права и свои земли, беспощадно убивая азебов и наёмных убийц. С тех самых пор как вы стали изгоем для цивилизации - вы стали куда более радикальных взглядов и нашли себе новых товарищей по вкусу. Быть может, вместе с ними вы сможете вернуть свои земли?"))

/datum/job/roguetown/freeman
	title = "Freeman"
	flag = BANDIT
	department_flag = ANTAGONIST
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	antag_job = TRUE
	
	tutorial = "Да будет проклят Султан Аль-Ашура песками и Иблис! Когда-то вы владели этими землями: поля специй, торговые пути - всё это было частью вашего таваифа. Султан забрал ваши права и земли несколько лет назад - и теперь вы боретесь за свои права и свои земли, беспощадно убивая азебов и наёмных убийц. С тех самых пор как вы стали изгоем для цивилизации - вы стали куда более радикальных взглядов и нашли себе новых товарищей по вкусу. Быть может, вместе с ними вы сможете вернуть свои земли?"

	outfit = null
	outfit_female = null

	obsfuscated_job = TRUE

	display_order = JDO_BANDIT
	announce_latejoin = FALSE
	min_pq = 25
	max_pq = null
	round_contrib_points = null

	advclass_cat_rolls = list(CTAG_FREEMAN = 20)
	PQ_boost_divider = 10

	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = FALSE
	job_reopens_slots_on_death = FALSE //no endless stream of freemans, unless the migration waves deem it so
	job_traits = list(TRAIT_SELF_SUSTENANCE, TRAIT_STEELHEARTED)//Bandits and knaves truly though
	vice_restrictions = list(/datum/charflaw/noeyer, /datum/charflaw/noeyel, /datum/charflaw/mute, /datum/charflaw/limbloss/arm_r, /datum/charflaw/limbloss/arm_l)
	same_job_respawn_delay = 30 MINUTES
	cmode_music = 'sound/music/combat_imperial_spellblade.ogg'
	job_subclasses = list(
		/datum/advclass/sahir_maradun,
		/datum/advclass/rih_al_sahra,
		/datum/advclass/faris_sarid,
		/datum/advclass/mujizat_musaid,
		/datum/advclass/sayyaf_hurr,
	)

/datum/job/roguetown/freeman/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(!H.mind)
			return
		H.ambushable = FALSE
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/unconvert_slave)

/datum/outfit/job/roguetown/freeman/pre_equip(mob/living/carbon/human/H)
	. = ..()
	H.verbs |= /mob/proc/haltyell_exhausting

/datum/outfit/job/roguetown/freeman/post_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit/freeman()
		H.mind.add_antag_datum(new_antag)
		H.grant_language(/datum/language/thievescant)
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, choose_name_popup), "BANDIT"), 5 SECONDS)
		var/wanted = list("I am a notorious criminal", "I am a nobody")
		var/wanted_choice = input("Are you a known criminal?") as anything in wanted
		switch(wanted_choice)
			if("I am a notorious criminal") //Extra challenge for those who want it
				bandit_select_bounty(H)
				ADD_TRAIT(H, TRAIT_KNOWNCRIMINAL, TRAIT_GENERIC)
			if("I am a nobody") //Nothing ever happens
				return

/datum/migrant_role/freeman
	name = "Freeman"
	greet_text = "Да будет проклят Султан Аль-Ашура песками и Иблис! Вы - один из фрименов, лишённых земель и прав. Настало время вернуть своё кровью."
	outfit = /datum/outfit/job/roguetown/freeman
	antag_datum = /datum/antagonist/bandit/freeman
	advclass_cat_rolls = list(CTAG_FREEMAN = 20)

/datum/migrant_role/freeman/after_spawn(mob/living/carbon/human/character)
	. = ..()
	character.ambushable = FALSE
	if(character.mind)
		character.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/unconvert_slave)

/datum/migrant_wave/freeman
	name = "Freemen"
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/freeman = 6,
	)
	spawn_landmark = "Bandit"
	greet_text = "Фримены выходят из-за дюн. Враги Султана собрались, чтобы вернуть то, что у них отняли."

/datum/round_event_control/antagonist/migrant_wave/freeman
	name = "Freeman Migration"
	typepath = /datum/round_event/migrant_wave/freeman
	wave_type = /datum/migrant_wave/freeman
	track = EVENT_TRACK_INTERVENTION
	max_occurrences = 2
	weight = 8
	earliest_start = 5 MINUTES
	min_players = 30
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
	)

/datum/round_event_control/antagonist/migrant_wave/freeman/canSpawnEvent(players_amt, gamemode, fake_check)
	if(SSmapping.config.map_name != "Desert Town")
		return FALSE

	var/datum/job/freeman_job = SSjob.GetJob("Freeman")
	if(!freeman_job)
		return FALSE
	if(freeman_job.total_positions >= 6)
		return FALSE

	return ..()

/datum/round_event_control/antagonist/migrant_wave/freeman/preRunEvent()
	var/datum/job/freeman_job = SSjob.GetJob("Freeman")
	if(!freeman_job)
		return EVENT_CANT_RUN
	if(freeman_job.total_positions >= 6)
		return EVENT_CANT_RUN

	return ..()

/datum/round_event/migrant_wave/freeman/start()
	var/datum/job/freeman_job = SSjob.GetJob("Freeman")
	if(!freeman_job)
		return
	if(freeman_job.total_positions >= 6)
		return

	var/old_positions = freeman_job.total_positions
	freeman_job.total_positions = max(freeman_job.total_positions, 6)
	freeman_job.spawn_positions = max(freeman_job.spawn_positions, 6)

	if(freeman_job.total_positions > old_positions)
		SSmapping.retainer.bandit_goal += 1 * rand(200, 400)
		SSrole_class_handler.bandits_in_round = TRUE
		freeman_job.always_show_on_latechoices = TRUE
		for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
			if(!player.client)
				continue
			to_chat(player, span_danger("Аль-Маттиос зовёт к джихаду! Неверные, отнявшие наши земли, будут убиты самым жестоким образом! Открыто шесть слотов фрименов."))

	..()
