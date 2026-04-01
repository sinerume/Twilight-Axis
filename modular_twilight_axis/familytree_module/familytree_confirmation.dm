/datum/controller/subsystem/familytree/proc/offer_setspouse_reset(mob/living/carbon/human/H, status)
	if(!H?.client)
		return
	var/result = tgui_alert(H, "Вы уже 30 минут ожидаете фаворита '[H.setspouse]', но он не найден.\n\nХотите сбросить предпочтение по нику и искать пару по текущим настройкам?", "Семейная система", list("Да, сбросить", "Нет, продолжить ждать"))

	if(!H || QDELETED(H))
		return

	if(result == "Да, сбросить")
		ftlog("SETSPOUSE RESET: [H.real_name] cleared setspouse '[H.setspouse]'")
		H.setspouse = ""
		H.familytree_assignment_scheduled = FALSE
		run_local_assignment(H, status)
	else
		ftlog("SETSPOUSE KEEP: [H.real_name] continues waiting for '[H.setspouse]'")
		H.familytree_assignment_scheduled = TRUE
		addtimer(CALLBACK(src, PROC_REF(run_local_assignment), H, status), 60 SECONDS)

/datum/controller/subsystem/familytree/proc/request_family_confirmation(mob/living/carbon/human/H, datum/callback/on_accept, confirm_type = "family")
	if(!H?.client)
		on_accept.Invoke()
		return
	if(H.familytree_opted_out)
		ftlog("CONFIRM SKIP: [H.real_name] opted out")
		return

	INVOKE_ASYNC(src, PROC_REF(do_family_confirmation), H, on_accept, confirm_type)

/datum/controller/subsystem/familytree/proc/do_family_confirmation(mob/living/carbon/human/H, datum/callback/on_accept, confirm_type = "family")
	if(!H?.client)
		on_accept.Invoke()
		return

	var/msg = "Вам нашли пару!\n\nХотите продолжить?\n\nОтказавшись, вы потеряете возможность найти семью в этом раунде."

	var/result = tgui_alert(H, msg, "Семейная система", list("Да", "Нет"))

	if(!H || QDELETED(H))
		return

	if(result == "Да")
		ftlog("CONFIRM ACCEPT: [H.real_name] type=[confirm_type]")
		on_accept.Invoke()
	else
		ftlog("CONFIRM REJECT: [H.real_name] type=[confirm_type] opted out permanently")
		H.familytree_opted_out = TRUE
		unsubscribe_familytree_human(H, "player declined [confirm_type] assignment")
		to_chat(H, span_warning("Вы отказались от участия в семейной системе на этот раунд."))
