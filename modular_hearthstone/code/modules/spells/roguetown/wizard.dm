#define PRESTI_CLEAN "presti_clean"
#define PRESTI_SPARK "presti_spark"
#define PRESTI_MOTE "presti_mote"

GLOBAL_LIST_EMPTY(wizard_spells_list)

/obj/effect/proc_holder/spell/targeted/touch/prestidigitation
	name = "Prestidigitation"
	desc = "A few basic tricks many apprentices use to practice basic manipulation of the arcane."
	clothes_req = FALSE
	drawmessage = "I prepare to perform a minor arcane incantation."
	dropmessage = "I release my minor arcane focus."
	school = "transmutation"
	overlay_state = "prestidigitation"
	chargedrain = 0
	chargetime = 0
	releasedrain = 5 // this influences -every- cost involved in the spell's functionality, if you want to edit specific features, do so in handle_cost
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	hand_path = /obj/item/melee/touch_attack/prestidigitation

/obj/item/melee/touch_attack/prestidigitation
	name = "\improper prestidigitating touch"
	desc = "You recall the following incantations you've learned:\n \
	<b>Touch</b>: Use your arcane powers to scrub an object or something clean, like using soap. Also known as the Apprentice's Woe.\n \
	<b>Shove</b>: Will forth a spark on an item of your choosing (or in front of you, if used on the ground) to ignite flammable items and things like torches, lanterns or campfires. \n \
	<b>Use</b>: Conjure forth an orbiting mote of magelight to light your way."
	catchphrase = null
	possible_item_intents = list(INTENT_HELP, INTENT_DISARM, /datum/intent/use)
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "pulling"
	icon_state = "grabbing_greyscale"
	color = "#3FBAFD" // this produces green because the icon base is yellow but someone else can fix that if they want
	var/obj/effect/wisp/prestidigitation/mote
	var/cleanspeed = 35 // adjust this down as low as 15 depending on magic skill
	var/motespeed = 20 // mote summoning speed
	var/sparkspeed = 30 // spark summoning speed
	var/spark_cd = 0
	var/xp_interval = 150 // really don't want people to spam this too much for xp - they will, but the intent is for them to not
	var/xp_cooldown = 0

/obj/item/melee/touch_attack/prestidigitation/Initialize()
	. = ..()
	mote = new(src)

/obj/item/melee/touch_attack/prestidigitation/Destroy()
	if (mote)
		qdel(mote)
	return ..()

/obj/item/melee/touch_attack/prestidigitation/attack_self()
	qdel(src)

/obj/item/melee/touch_attack/prestidigitation/afterattack(atom/target, mob/living/carbon/user, proximity)
	var/fatigue_used
	switch (user.used_intent.type)
		if (INTENT_HELP) // Clean something like a bar of soap
			fatigue_used = handle_cost(user, PRESTI_CLEAN)
			if (clean_thing(target, user))
				handle_xp(user, fatigue_used, TRUE) // cleaning ignores the xp cooldown because it awards comparatively little
		if (INTENT_DISARM) // Snap your fingers and produce a spark
			fatigue_used = handle_cost(user, PRESTI_SPARK)
			if (create_spark(user, target))
				handle_xp(user, fatigue_used)
		if (/datum/intent/use) // Summon an orbiting arcane mote for light
			fatigue_used = handle_cost(user, PRESTI_MOTE)
			if (handle_mote(user))
				handle_xp(user, fatigue_used)

/obj/item/melee/touch_attack/prestidigitation/proc/handle_cost(mob/living/carbon/human/user, action)
	// handles fatigue/stamina deduction, this stuff isn't free - also returns the cost we took to use for xp calculations
	var/obj/effect/proc_holder/spell/targeted/touch/prestidigitation/base_spell = attached_spell
	var/fatigue_used = base_spell.get_fatigue_drain() //note that as our skills/stats increases, our fatigue drain DECREASES, so this means less xp, too. which is what we want since this is a basic spell, not a spam-for-xp-forever kinda beat
	var/extra_fatigue = 0 // extra fatigue isn't considered in xp calculation
	switch (action)
		if (PRESTI_CLEAN)
			fatigue_used *= 0.2 // going to be spamming a lot of this probably
		if (PRESTI_SPARK)
			extra_fatigue = 5 // just a bit of extra fatigue on this one
		if (PRESTI_MOTE)
			extra_fatigue = 15 // same deal here

	user.rogfat_add(fatigue_used + extra_fatigue)

	var/skill_level = user.mind?.get_skill_level(attached_spell.associated_skill)
	if (skill_level >= SKILL_LEVEL_EXPERT)
		fatigue_used = 0 // we do this after we've actually changed fatigue because we're hard-capping the raises this gives to Expert

	return fatigue_used

/obj/item/melee/touch_attack/prestidigitation/proc/handle_xp(mob/living/carbon/human/user, fatigue, ignore_cooldown = FALSE)
	if (!ignore_cooldown)
		if (world.time < xp_cooldown + xp_interval)
			return

	xp_cooldown = world.time

	var/obj/effect/proc_holder/spell/targeted/touch/prestidigitation/base_spell = attached_spell
	if (user)
		adjust_experience(user, base_spell.associated_skill, fatigue)

/obj/item/melee/touch_attack/prestidigitation/proc/handle_mote(mob/living/carbon/human/user)
	// adjusted from /obj/item/wisp_lantern & /obj/item/wisp
	if (!mote)
		return // should really never happen

	//let's adjust the light power based on our skill, too
	var/skill_level = user.mind?.get_skill_level(attached_spell.associated_skill)
	var/mote_power = clamp(4 + (skill_level - 3), 4, 7) // every step above journeyman should get us 1 more tile of brightness
	mote.set_light_range(mote_power)
	if(mote.light_system == STATIC_LIGHT)
		mote.update_light()

	if (mote.loc == src)
		user.visible_message(span_notice("[user] holds open the palm of [user.p_their()] hand and concentrates..."), span_notice("I hold open the palm of my hand and concentrate on my arcane power..."))
		if (do_after(user, src.motespeed, target = user))
			mote.orbit(user, 1, TRUE, 0, 48, TRUE)
			return TRUE
		return FALSE
	else
		user.visible_message(span_notice("[user] wills \the [mote.name] back into [user.p_their()] hand and closes it, extinguishing its light."), span_notice("I will \the [mote.name] back into my palm and close it."))
		mote.forceMove(src)
		return TRUE

/obj/item/melee/touch_attack/prestidigitation/proc/create_spark(mob/living/carbon/human/user, atom/thing)
	// adjusted from /obj/item/flint
	if (world.time < spark_cd + sparkspeed)
		return FALSE
	spark_cd = world.time

	playsound(user, 'sound/foley/finger-snap.ogg', 100, FALSE)
	user.flash_fullscreen("whiteflash")
	flick("flintstrike", src)

	if (isturf(thing) || !user.Adjacent(thing))
		var/datum/effect_system/spark_spread/S = new()
		var/turf/front = get_step(user, user.dir)
		S.set_up(1, 1, front)
		S.start()
		user.visible_message(span_notice("[user] snaps [user.p_their()] fingers, producing a spark!"), span_notice("I will forth a tiny spark with a snap of my fingers."))
	else
		thing.spark_act()
		user.visible_message(span_notice("[user] snaps [user.p_their()] fingers, and a spark leaps forth towards [thing]!"), span_notice("I will forth a tiny spark and direct it towards [thing]."))

	return TRUE

/obj/item/melee/touch_attack/prestidigitation/proc/clean_thing(atom/target, mob/living/carbon/human/user)
	// adjusted from /obj/item/soap in clown_items.dm, some duplication unfortunately (needed for flavor)

	// let's adjust the clean speed based on our skill level
	var/skill_level = user.mind?.get_skill_level(attached_spell.associated_skill)
	cleanspeed = initial(cleanspeed) - (skill_level * 3) // 3 cleanspeed per skill level, from 35 down to a maximum of 17 (pretty quick)

	if (istype(target, /obj/structure/roguewindow))
		user.visible_message(span_notice("[user] gestures at \the [target.name], tiny motes of arcane power running across its surface..."), span_notice("I begin to clean \the [target.name] with my arcane power..."))
		if (do_after(user, src.cleanspeed, target = target))
			wash_atom(target,CLEAN_MEDIUM)
			to_chat(user, span_notice("I render \the [target.name] clean."))
			return TRUE
		return FALSE
	else if (istype(target, /obj/effect/decal/cleanable))
		user.visible_message(span_notice("[user] gestures at \the [target.name], arcane power slowly scouring it away..."), span_notice("I begin to scour \the [target.name] away with my arcane power..."))
		if (do_after(user, src.cleanspeed, target = target))
			wash_atom(get_turf(target),CLEAN_MEDIUM)
			to_chat(user, span_notice("I expunge \the [target.name] with my mana."))
			return TRUE
		return FALSE
	else
		user.visible_message(span_notice("[user] gestures at \the [target.name], tiny motes of arcane power surging over [target.p_them()]..."), span_notice("I begin to clean \the [target.name] with my arcane power..."))
		if (do_after(user, src.cleanspeed, target = target))
			wash_atom(target,CLEAN_MEDIUM)
			to_chat(user, span_notice("I render \the [target.name] clean."))
			return TRUE
		return FALSE

// Intents for prestidigitation

/obj/effect/wisp/prestidigitation
	name = "minor magelight mote"
	desc = "A tiny display of arcane power used to illuminate."
	pixel_x = 20
	light_outer_range =  4
	light_color = "#3FBAFD"

	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "wisp"

//A spell to choose new spells, upon spawning or gaining levels
/obj/effect/proc_holder/spell/self/learnspell
	name = "Attempt to learn a new spell"
	desc = "Weave a new spell"
	school = "transmutation"
	overlay_state = "book1"
	chargedrain = 0
	chargetime = 0

/obj/effect/proc_holder/spell/self/learnspell/cast(list/targets, mob/user = usr)
	. = ..()
	//list of spells you can learn, it may be good to move this somewhere else eventually
	//TODO: make GLOB list of spells, give them a true/false tag for learning, run through that list to generate choices
	var/list/choices = list()
	var/list/obj/effect/proc_holder/spell/spell_choices = list(/obj/effect/proc_holder/spell/invoked/projectile/fireball,
		/obj/effect/proc_holder/spell/invoked/projectile/lightningbolt,
		/obj/effect/proc_holder/spell/invoked/projectile/fetch,
		/obj/effect/proc_holder/spell/invoked/projectile/spitfire,
		/obj/effect/proc_holder/spell/invoked/forcewall_weak,
		/obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe,
		/obj/effect/proc_holder/spell/self/message,
		/obj/effect/proc_holder/spell/invoked/push_spell,
		/obj/effect/proc_holder/spell/invoked/blade_burst,
		/obj/effect/proc_holder/spell/targeted/touch/nondetection,
//		/obj/effect/proc_holder/spell/invoked/knock,
		/obj/effect/proc_holder/spell/invoked/haste,
		/obj/effect/proc_holder/spell/invoked/featherfall,
		/obj/effect/proc_holder/spell/targeted/touch/darkvision,
		/obj/effect/proc_holder/spell/invoked/longstrider,
		/obj/effect/proc_holder/spell/invoked/invisibility,
		/obj/effect/proc_holder/spell/invoked/blindness,
		/obj/effect/proc_holder/spell/invoked/projectile/acidsplash5e,
//		/obj/effect/proc_holder/spell/invoked/frostbite5e,
		/obj/effect/proc_holder/spell/invoked/guidance,
		/obj/effect/proc_holder/spell/invoked/fortitude,
		/obj/effect/proc_holder/spell/invoked/snap_freeze,
		/obj/effect/proc_holder/spell/invoked/projectile/frostbolt,
		/obj/effect/proc_holder/spell/invoked/projectile/arcanebolt,
		/obj/effect/proc_holder/spell/invoked/gravity,
		/obj/effect/proc_holder/spell/invoked/projectile/repel,
		/obj/effect/proc_holder/spell/invoked/poisonspray5e,
		/obj/effect/proc_holder/spell/targeted/touch/lesserknock,
		/obj/effect/proc_holder/spell/invoked/counterspell,
		/obj/effect/proc_holder/spell/invoked/enlarge,
		/obj/effect/proc_holder/spell/invoked/leap,
		/obj/effect/proc_holder/spell/invoked/blink,
		/obj/effect/proc_holder/spell/invoked/mirror_transform,
		/obj/effect/proc_holder/spell/invoked/mindlink
	)

	for(var/i = 1, i <= spell_choices.len, i++)
		choices["[spell_choices[i].name]: [spell_choices[i].cost]"] = spell_choices[i]

	choices = sortList(choices)

	var/choice = input("Choose a spell, points left: [user.mind.spell_points - user.mind.used_spell_points]") as null|anything in choices
	var/obj/effect/proc_holder/spell/item = choices[choice]

	if(!item)
		return     // user canceled;
	if(alert(user, "[item.desc]", "[item.name]", "Learn", "Cancel") == "Cancel") //gives a preview of the spell's description to let people know what a spell does
		return
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == item.type)
			to_chat(user,span_warning("You already know this one!"))
			return	//already know the spell
	if(item.cost > user.mind.spell_points - user.mind.used_spell_points)
		to_chat(user,span_warning("You do not have enough experience to create a new spell."))
		return		// not enough spell points
	else
		user.mind.used_spell_points += item.cost
		user.mind.AddSpell(new item)
		addtimer(CALLBACK(user.mind, TYPE_PROC_REF(/datum/mind, check_learnspell)), 2 SECONDS) //self remove if no points
		return TRUE

//forcewall
/obj/effect/proc_holder/spell/invoked/forcewall_weak
	name = "Forcewall"
	desc = "Conjure a wall of arcane force, preventing anyone and anything other than you from moving through it."
	school = "transmutation"
	releasedrain = 30
	chargedrain = 1
	chargetime = 15
	charge_max = 35 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	clothes_req = FALSE
	active = FALSE
	sound = 'sound/blank.ogg'
	overlay_state = "forcewall"
	range = 7
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	var/wall_type = /obj/structure/forcefield_weak/caster
	xp_gain = TRUE
	cost = 1

//adapted from forcefields.dm, this needs to be destructible
/obj/structure/forcefield_weak
	desc = "A wall of pure arcane force."
	name = "Arcane Wall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "forcefield"
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	opacity = 0
	density = TRUE
	max_integrity = 100
	CanAtmosPass = ATMOS_PASS_DENSITY
	var/timeleft = 20 SECONDS

/obj/structure/forcefield_weak/Initialize()
	. = ..()
	if(timeleft)
		QDEL_IN(src, timeleft) //delete after it runs out

/obj/effect/proc_holder/spell/invoked/forcewall_weak/cast(list/targets,mob/user = usr)
	var/turf/front = get_turf(targets[1])
	new wall_type(front, user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(front, WEST), user)
		new wall_type(get_step(front, EAST), user)
	else
		new wall_type(get_step(front, NORTH), user)
		new wall_type(get_step(front, SOUTH), user)
	user.visible_message("[user] mutters an incantation and a wall of arcane force manifests out of thin air!")
	return TRUE

/obj/structure/forcefield_weak
	var/mob/caster

/obj/structure/forcefield_weak/caster/Initialize(mapload, mob/summoner)
	. = ..()
	caster = summoner

/obj/structure/forcefield_weak/caster/CanPass(atom/movable/mover, turf/target)	//only the caster can move through this freely
	if(mover == caster)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check(chargecost = 0))
			return TRUE
	return FALSE

// no slowdown status effect defined, so this just immobilizes for now
/obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe
	name = "Ensnare"
	desc = "Tendrils of arcane force hold anyone in a small area in place for a short while."
	cost = 1
	xp_gain = TRUE
	releasedrain = 20
	chargedrain = 1
	chargetime = 20
	charge_max = 25 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE	
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	range = 6
	overlay_state = "ensnare"
	var/area_of_effect = 1
	var/duration = 5 SECONDS
	var/delay = 0.8 SECONDS

/obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe/cast(list/targets, mob/user = usr)
	var/turf/T = get_turf(targets[1])

	for(var/turf/affected_turf in view(area_of_effect, T))
		if(affected_turf.density)
			continue
		new /obj/effect/temp_visual/slowdown_spell_aoe(affected_turf)

	addtimer(CALLBACK(src, PROC_REF(apply_slowdown), T, area_of_effect, duration, user), delay)
	playsound(T,'sound/magic/webspin.ogg', 50, TRUE)
	return TRUE
/obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe/proc/apply_slowdown(turf/T, area_of_effect, duration)
	for(var/mob/living/simple_animal/hostile/animal in range(area_of_effect, T))
		animal.Paralyze(duration, updating = TRUE, ignore_canstun = TRUE)	//i think animal movement is coded weird, i cant seem to stun them
	for(var/mob/living/L in range(area_of_effect, T))
		if(L.anti_magic_check())
			visible_message(span_warning("The tendrils of force can't seem to latch onto [L] "))  //antimagic needs some testing
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			return
		L.Immobilize(duration)
		L.OffBalance(duration)
		L.visible_message("<span class='warning'>[L] is held by tendrils of arcane force!</span>")
		new /obj/effect/temp_visual/slowdown_spell_aoe/long(get_turf(L))

/obj/effect/temp_visual/slowdown_spell_aoe
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	duration = 1 SECONDS

/obj/effect/temp_visual/slowdown_spell_aoe/long
	duration = 3 SECONDS

/obj/effect/proc_holder/spell/self/message
	name = "Message"
	desc = "Latch onto the mind of one who is familiar to you, whispering a message into their head."
	cost = 1
	xp_gain = TRUE
	releasedrain = 30
	charge_max = 60 SECONDS
	warnie = "spellwarning"
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "message"
	var/identify_difficulty = 15 //the stat threshold needed to pass the identify check

/obj/effect/proc_holder/spell/self/message/cast(list/targets, mob/user)
	. = ..()

	var/list/eligible_players = list()

	if(user.mind.known_people.len)
		for(var/people in user.mind.known_people)
			eligible_players += people
	else
		to_chat(user, span_warning("I don't know anyone."))
		revert_cast()
		return
	eligible_players = sortList(eligible_players)
	var/input = input(user, "Who do you wish to contact?", src) as null|anything in eligible_players
	if(isnull(input))
		to_chat(user, span_warning("No target selected."))
		revert_cast()
		return
	for(var/mob/living/carbon/human/HL in GLOB.human_list)
		if(HL.real_name == input)
			var/message = input(user, "You make a connection. What are you trying to say?")
			if(!message)
				revert_cast()
				return
			if(alert(user, "Send anonymously?", "", "Yes", "No") == "No") //yes or no popup, if you say No run this code
				identify_difficulty = 0 //anyone can clear this

			var/identified = FALSE
			if(HL.STAPER >= identify_difficulty) //quick stat check
				if(HL.mind)
					if(HL.mind.do_i_know(name=user.real_name)) //do we know who this person is?
						identified = TRUE // we do
						to_chat(HL, "Arcane whispers fill the back of my head, resolving into [user]'s voice: <font color=#7246ff>[message]</font>")

			if(!identified) //we failed the check OR we just dont know who that is
				to_chat(HL, "Arcane whispers fill the back of my head, resolving into an unknown [user.gender == FEMALE ? "woman" : "man"]'s voice: <font color=#7246ff>[message]</font>")

			user.visible_message("[user] mutters an incantation and their mouth briefly flashes white.")
			user.whisper(message)
			log_game("[key_name(user)] sent a message to [key_name(HL)] with contents [message]")
			// maybe an option to return a message, here?
			return TRUE
	to_chat(user, span_warning("I seek a mental connection, but can't find [input]."))
	revert_cast()
	return

/obj/effect/proc_holder/spell/invoked/push_spell
	name = "Repulse"
	desc = "Conjure forth a wave of energy, repelling anyone around you."
	cost = 1
	xp_gain = TRUE
	releasedrain = 50
	chargedrain = 1
	chargetime = 5
	charge_max = 30 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "repulse"
	var/stun_amt = 5
	var/maxthrow = 3
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG
	var/push_range = 1

/obj/effect/proc_holder/spell/invoked/push_spell/cast(list/targets, mob/user)
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	playsound(user, 'sound/magic/repulse.ogg', 80, TRUE)
	user.visible_message("[user] mutters an incantation and a wave of force radiates outward!")
	for(var/turf/T in view(push_range, user))
		new /obj/effect/temp_visual/kinetic_blast(T)
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored)
			continue

		if(ismob(AM))
			var/mob/M = AM
			if(M.anti_magic_check())
				continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Paralyze(10)
				M.adjustBruteLoss(5)
				to_chat(M, "<span class='danger'>You're slammed into the floor by [user]!</span>")
		else
			new sparkle_path(get_turf(AM), get_dir(user, AM)) //created sparkles will disappear on their own
			if(isliving(AM))
				var/mob/living/M = AM
				M.Paralyze(stun_amt)
				to_chat(M, "<span class='danger'>You're thrown back by [user]!</span>")
			AM.safe_throw_at(throwtarget, ((CLAMP((maxthrow - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1,user, force = repulse_force)//So stuff gets tossed around at the same time.

/obj/effect/proc_holder/spell/invoked/blade_burst
	name = "Blade Burst"
	desc = "Summon a storm of arcane force in an area, wounding anything in that location after a delay."
	cost = 1
	range = 7
	xp_gain = TRUE
	releasedrain = 30
	chargedrain = 1
	chargetime = 20
	charge_max = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "blade_burst"
	var/delay = 14
	var/damage = 125 //if you get hit by this it's your fault
	var/area_of_effect = 1

/obj/effect/temp_visual/trap
	icon = 'icons/effects/effects.dmi'
	icon_state = "trap"
	light_outer_range = 2
	duration = 14
	layer = MASSIVE_OBJ_LAYER

/obj/effect/temp_visual/blade_burst
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	name = "rippeling arcane energy"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER


/obj/effect/proc_holder/spell/invoked/blade_burst/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1])

	for(var/turf/affected_turf in view(area_of_effect, T))
		if(affected_turf.density)
			continue
		new /obj/effect/temp_visual/trap(affected_turf)
	playsound(T, 'sound/magic/blade_burst.ogg', 80, TRUE, soundping = TRUE)

	sleep(delay)
	var/play_cleave = FALSE

	for(var/turf/affected_turf in view(area_of_effect, T))
		new /obj/effect/temp_visual/blade_burst(affected_turf)
		for(var/mob/living/L in affected_turf.contents)
			play_cleave = TRUE
			L.adjustBruteLoss(damage)
			playsound(affected_turf, "genslash", 80, TRUE)
			to_chat(L, "<span class='userdanger'>You're cut by arcane force!</span>")

	if(play_cleave)
		playsound(T, 'sound/combat/newstuck.ogg', 80, TRUE, soundping = TRUE)

	return TRUE

/obj/effect/proc_holder/spell/targeted/touch/nondetection
	name = "Nondetection"
	desc = "Consume a handful of ash and shroud a target that you touch from divination magic for 1 hour."
	clothes_req = FALSE
	drawmessage = "I prepare to form a magical shroud."
	dropmessage = "I release my arcane focus."
	school = "abjuration"
	charge_max = 30 SECONDS
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	hand_path = /obj/item/melee/touch_attack/nondetection
	xp_gain = TRUE
	cost = 1

/obj/item/melee/touch_attack/nondetection
	name = "\improper arcane focus"
	desc = "Touch a creature to cover them in an anti-scrying shroud for 1 hour, consumes some ash as a catalyst."
	catchphrase = null
	possible_item_intents = list(INTENT_HELP)
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "pulling"
	icon_state = "grabbing_greyscale"
	color = "#3FBAFD"

/obj/item/melee/touch_attack/nondetection/attack_self()
	attached_spell.remove_hand()

/obj/effect/proc_holder/spell/targeted/touch/nondetection/proc/add_buff_timer(mob/living/user)
	addtimer(CALLBACK(src, PROC_REF(remove_buff), user), wait = 1 HOURS)

/obj/effect/proc_holder/spell/targeted/touch/nondetection/proc/remove_buff(mob/living/user)
	REMOVE_TRAIT(user, TRAIT_ANTISCRYING, MAGIC_TRAIT)
	to_chat(user, span_warning("I feel my anti-scrying shroud failing."))

/obj/item/melee/touch_attack/nondetection/afterattack(atom/target, mob/living/carbon/user, proximity)
	var/obj/effect/proc_holder/spell/targeted/touch/nondetection/base_spell = attached_spell
	var/requirement = FALSE
	var/obj/item/sacrifice

	if(isliving(target))

		var/mob/living/spelltarget = target

		for(var/obj/item/I in user.held_items)
			if(istype(I, /obj/item/ash))
				requirement = TRUE
				sacrifice = I

		if(!requirement)
			to_chat(user, span_warning("I require some ash in a free hand."))
			return

		if(!do_after(user, 5 SECONDS, target = spelltarget))
			return

		qdel(sacrifice)
		ADD_TRAIT(spelltarget, TRAIT_ANTISCRYING, MAGIC_TRAIT)
		if(spelltarget != user)
			user.visible_message("[user] draws a glyph in the air and blows some ash onto [spelltarget].")
		else
			user.visible_message("[user] draws a glyph in the air and covers themselves in ash.")

		base_spell.add_buff_timer(spelltarget)
		attached_spell.remove_hand()
	return

/obj/effect/proc_holder/spell/targeted/touch/darkvision
	name = "Darkvision"
	desc = "Enhance the night vision of a target you touch for 15 minutes."
	clothes_req = FALSE
	drawmessage = "I prepare to grant Darkvision."
	dropmessage = "I release my arcane focus."
	school = "transmutation"
	charge_max = 1 MINUTES
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	hand_path = /obj/item/melee/touch_attack/darkvision
	xp_gain = TRUE
	cost = 2

/obj/item/melee/touch_attack/darkvision
	name = "\improper arcane focus"
	desc = "Touch a creature to grant them Darkvision for 15 minutes."
	catchphrase = null
	possible_item_intents = list(INTENT_HELP)
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "pulling"
	icon_state = "grabbing_greyscale"
	color = "#3FBAFD"

/obj/item/melee/touch_attack/darkvision/attack_self()
	attached_spell.remove_hand()

/obj/item/melee/touch_attack/darkvision/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(isliving(target))
		var/mob/living/spelltarget = target
		if(!do_after(user, 5 SECONDS, target = spelltarget))
			return
		spelltarget.apply_status_effect(/datum/status_effect/buff/darkvision)
		user.rogfat_add(80)
		if(spelltarget != user)
			user.visible_message("[user] draws a glyph in the air and touches [spelltarget] with an arcane focus.")
		else
			user.visible_message("[user] draws a glyph in the air and touches themselves with an arcane focus.")
		attached_spell.remove_hand()
	return

/obj/effect/proc_holder/spell/invoked/knock
	name = "Knock"
	desc = "Force open adjacent doors, windows and most containers."
	cost = 1
	xp_gain = TRUE
	school = "transmutation"
	releasedrain = 60
	chargedrain = 0
	chargetime = 5 SECONDS
	charge_max = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/invoked/knock/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/misc/chestopen.ogg', 100, TRUE, -1)
	for(var/turf/T in range(1, usr))
		for(var/obj/structure/mineral_door/door in T.contents)
			INVOKE_ASYNC(src, PROC_REF(open_door), door)
		for(var/obj/structure/closet/C in T.contents)
			INVOKE_ASYNC(src, PROC_REF(open_closet), C)
		for(var/obj/structure/roguewindow/openclose/W in T.contents)
			INVOKE_ASYNC(src, PROC_REF(open_window), W)

/obj/effect/proc_holder/spell/invoked/knock/proc/open_door(obj/structure/mineral_door/door)
	if(istype(door))
		door.force_open()
		door.locked = FALSE

/obj/effect/proc_holder/spell/invoked/knock/proc/open_closet(obj/structure/closet/C)
	C.locked = FALSE
	C.open()

/obj/effect/proc_holder/spell/invoked/knock/proc/open_window(obj/structure/roguewindow/openclose/W)
	if(istype(W))
		W.force_open()

//ports -- todo: sfx

/obj/effect/proc_holder/spell/invoked/projectile/acidsplash5e
	name = "Acid Splash"
	desc = "A slow-moving glob of acid that sprays over an area upon impact."
	range = 8
	projectile_type = /obj/projectile/magic/acidsplash5e
	overlay_state = "null"
	sound = list('sound/magic/whiteflame.ogg')
	active = FALSE

	releasedrain = 30
	chargedrain = 1
	chargetime = 3
	charge_max = 15 SECONDS //cooldown

	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	antimagic_allowed = FALSE //can you use it if you are antimagicked?
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane //can be arcane, druidic, blood, holy
	cost = 1

	xp_gain = TRUE
	miracle = FALSE

/obj/effect/proc_holder/spell/self/acidsplash5e/cast(mob/user = usr)
	var/mob/living/target = user
	target.visible_message(span_warning("[target] hurls a caustic bubble!"), span_notice("You hurl a caustic bubble!"))
	. = ..()

/obj/projectile/magic/acidsplash5e //port. todo: the sounds these came with aren't good and drink_blood sounds like ur slurpin pintle
	name = "acid bubble"
	icon_state = "green_laser"
	damage = 10
	damage_type = BURN
	flag = "magic"
	range = 15
	speed = 15 //higher is slower
	var/aoe_range = 1

/obj/projectile/magic/acidsplash5e/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/turf/T = get_turf(src)
	playsound(src, 'sound/misc/drink_blood.ogg', 100)

	for(var/mob/living/L in range(aoe_range, get_turf(src))) //apply damage over time to mobs
		if(!L.anti_magic_check())
			var/mob/living/carbon/M = L
			M.apply_status_effect(/datum/status_effect/buff/acidsplash5e)
			new /obj/effect/temp_visual/acidsplash5e(get_turf(M))
	for(var/turf/turfs_in_range in range(aoe_range+1, T)) //make a splash
		new /obj/effect/temp_visual/acidsplash5e(T)

/datum/status_effect/buff/acidsplash5e
	id = "acid splash"
	alert_type = /atom/movable/screen/alert/status_effect/buff/acidsplash5e
	duration = 20 SECONDS

/datum/status_effect/buff/acidsplash5e/on_apply()
	. = ..()
	owner.playsound_local(get_turf(owner), 'sound/misc/lava_death.ogg', 35, FALSE, pressure_affected = FALSE)
	owner.visible_message(span_warning("[owner] is covered in acid!"), span_danger("I am covered in acid!"))
	owner.emote("scream")

/datum/status_effect/buff/acidsplash5e/tick()
	var/mob/living/target = owner
	target.adjustFireLoss(3)

/atom/movable/screen/alert/status_effect/buff/acidsplash5e
	name = "Acid Burn"
	desc = "My skin is burning!"
	icon_state = "debuff"

/obj/effect/temp_visual/acidsplash5e
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter2"
	name = "horrible acrid brine"
	desc = "Best not touch this."
	randomdir = TRUE
	duration = 1 SECONDS
	layer = ABOVE_ALL_MOB_LAYER


/obj/effect/proc_holder/spell/invoked/frostbite5e
	name = "Frostbite"
	desc = "Freeze your enemy with an icy blast that does low damage, but reduces the target's Speed for a considerable length of time."
	overlay_state = "null"
	releasedrain = 50
	chargetime = 3
	charge_max = 25 SECONDS
	//chargetime = 10
	//charge_max = 30 SECONDS
	range = 7
	warnie = "spellwarning"
	movement_interrupt = FALSE
	no_early_release = FALSE
	chargedloop = null
	sound = 'sound/magic/whiteflame.ogg'
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane //can be arcane, druidic, blood, holy
	cost = 1

	xp_gain = TRUE
	miracle = FALSE

	invocation = ""
	invocation_type = "shout" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/frostbite5e/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))
		var/mob/living/carbon/target = targets[1]
		target.apply_status_effect(/datum/status_effect/buff/frostbite5e/) //apply debuff
		target.adjustFireLoss(12) //damage
		target.adjustBruteLoss(12)

/datum/status_effect/buff/frostbite5e
	id = "frostbite"
	alert_type = /atom/movable/screen/alert/status_effect/buff/frostbite5e
	duration = 20 SECONDS
	effectedstats = list("speed" = -2)

/atom/movable/screen/alert/status_effect/buff/frostbite5e
	name = "Frostbite"
	desc = "I can feel myself slowing down."
	icon_state = "debuff"
	color = "#00fffb" //talk about a coder sprite

/datum/status_effect/buff/frostbite5e/on_apply()
	. = ..()
	var/mob/living/target = owner
	target.update_vision_cone()
	var/newcolor = rgb(136, 191, 255)
	target.add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, newcolor), 20 SECONDS)
	target.add_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT, update=TRUE, priority=100, multiplicative_slowdown=4, movetypes=GROUND)

/datum/status_effect/buff/frostbite5e/on_remove()
	var/mob/living/target = owner
	target.update_vision_cone()
	target.remove_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT, TRUE)
	. = ..()

/obj/effect/proc_holder/spell/invoked/snap_freeze // to do: get scroll icon
	name = "Snap Freeze"
	desc = "Freeze the air in a small area in an instant, slowing and mildly damaging those affected."
	cost = 2
	xp_gain = TRUE
	releasedrain = 30
	overlay = 'icons/effects/effects.dmi'
	overlay_state = "shieldsparkles"
	chargedrain = 1
	chargetime = 15
	charge_max = 13 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	range = 7
	var/delay = 6
	var/damage = 50 // less then fireball, more then lighting bolt
	var/area_of_effect = 2

/obj/effect/temp_visual/trapice
	icon = 'icons/effects/effects.dmi'
	icon_state = "blueshatter"
	light_outer_range = 2
	light_color = "#4cadee"
	duration = 6
	layer = MASSIVE_OBJ_LAYER

/obj/effect/temp_visual/snap_freeze
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	name = "rippeling arcane ice"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER


/obj/effect/proc_holder/spell/invoked/snap_freeze/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1])

	for(var/turf/affected_turf in view(area_of_effect, T))
		if(affected_turf.density)
			continue
		new /obj/effect/temp_visual/trapice(affected_turf)
	playsound(T, 'sound/combat/wooshes/blunt/wooshhuge (2).ogg', 80, TRUE, soundping = TRUE) // it kinda sounds like cold wind idk

	sleep(delay)
	var/play_cleave = FALSE

	for(var/turf/affected_turf in view(area_of_effect, T))
		new /obj/effect/temp_visual/snap_freeze(affected_turf)
		for(var/mob/living/L in affected_turf.contents)
			if(L.anti_magic_check())
				visible_message(span_warning("The ice fades away around you. [L] "))  //antimagic needs some testing
				playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
				return 
			play_cleave = TRUE
			L.adjustFireLoss(damage)
			L.apply_status_effect(/datum/status_effect/buff/frostbite5e/)
			playsound(affected_turf, "genslash", 80, TRUE)
			to_chat(L, "<span class='userdanger'>The air chills your bones!</span>")

	if(play_cleave)
		playsound(T, 'sound/combat/newstuck.ogg', 80, TRUE, soundping = TRUE) // this also kinda sounds like ice ngl

	return TRUE


/obj/effect/proc_holder/spell/invoked/projectile/frostbolt // to do: get scroll icon
	name = "Frost Bolt"
	desc = "A ray of frozen energy, slowing the first thing it touches and lightly damaging it."
	range = 8
	projectile_type = /obj/projectile/magic/frostbolt
	overlay_state = "null"
	sound = list('sound/magic/whiteflame.ogg')
	active = FALSE

	releasedrain = 30
	chargedrain = 1
	chargetime = 3
	charge_max = 13 SECONDS //cooldown

	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	antimagic_allowed = FALSE //can you use it if you are antimagicked?
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane //can be arcane, druidic, blood, holy
	cost = 1

	xp_gain = TRUE
	miracle = FALSE

/obj/effect/proc_holder/spell/self/frostbolt/cast(mob/user = usr)
	var/mob/living/target = user
	target.visible_message(span_warning("[target] hurls a frosty beam!"), span_notice("You hurl a frosty beam!"))
	. = ..()

/obj/projectile/magic/frostbolt
	name = "Frost Dart"
	icon_state = "ice_2"
	damage = 25
	damage_type = BURN
	flag = "magic"
	range = 10
	speed = 12 //higher is slower
	var/aoe_range = 0

/obj/projectile/magic/frostbolt/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(target))
			var/mob/living/L = target
			L.apply_status_effect(/datum/status_effect/buff/frostbite5e)
			new /obj/effect/temp_visual/snap_freeze(get_turf(L))
	qdel(src)


/obj/effect/proc_holder/spell/invoked/projectile/arcanebolt //makes you confused for 2 seconds,
	name = "Arcane Bolt"
	desc = "Shoot out a rapid bolt of arcane magic that hits on impact. Little damage, but disorienting."
	clothes_req = FALSE
	range = 12
	projectile_type = /obj/projectile/energy/rogue3
	overlay_state = "force_dart"
	sound = list('sound/magic/vlightning.ogg')
	active = FALSE
	releasedrain = 20
	chargedrain = 1
	chargetime = 7
	charge_max = 20 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	cost = 1

/obj/projectile/energy/rogue3
	name = "Arcane Bolt"
	icon_state = "arcane_barrage"
	damage = 30
	damage_type = BRUTE
	armor_penetration = 10
	woundclass = BCLASS_SMASH
	nodamage = FALSE
	flag = "magic"
	hitsound = 'sound/combat/hits/blunt/shovel_hit2.ogg'
	speed = 1

/obj/projectile/energy/rogue3/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/living/carbon/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		M.confused += 3
		playsound(get_turf(target), 'sound/combat/hits/blunt/shovel_hit2.ogg', 100) //CLANG
	else
		return

/obj/effect/proc_holder/spell/invoked/gravity // to do: get scroll icon
	name = "Gravity"
	desc = "Weighten space around someone, crushing them and knocking them to the floor. Stronger opponents will resist and be off-balanced."
	cost = 1
	overlay_state = "hierophant"
	xp_gain = TRUE
	releasedrain = 20
	chargedrain = 1
	chargetime = 7
	charge_max = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	range = 7
	var/delay = 3
	var/damage = 0 // damage based off your str 
	var/area_of_effect = 0



/obj/effect/proc_holder/spell/invoked/gravity/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1])

	for(var/turf/affected_turf in view(area_of_effect, T))
		if(affected_turf.density)
			continue
			

	for(var/turf/affected_turf in view(area_of_effect, T))
		new /obj/effect/temp_visual/gravity(affected_turf)
		playsound(T, 'sound/magic/gravity.ogg', 80, TRUE, soundping = FALSE)
		for(var/mob/living/L in affected_turf.contents) 
			if(L.anti_magic_check())
				visible_message(span_warning("The gravity fades away around you [L] "))  //antimagic needs some testing
				playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
				return 

			if(L.STASTR <= 11)
				L.adjustBruteLoss(30)
				L.Knockdown(5)
				to_chat(L, "<span class='userdanger'>You're magically weighed down, losing your footing!</span>")
			else
				L.OffBalance(10)
				L.adjustBruteLoss(15)
				to_chat(L, "<span class='userdanger'>You're magically weighed down, and your strength resist!</span>")
			
			

/obj/effect/temp_visual/gravity
	icon = 'icons/effects/effects.dmi'
	icon_state = "hierophant_squares"
	name = "gravity magic"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 3 SECONDS
	layer = MASSIVE_OBJ_LAYER
	light_outer_range = 2
	light_color = COLOR_PALE_PURPLE_GRAY


/obj/effect/proc_holder/spell/invoked/projectile/repel
	name = "Repel"
	desc = "Shoot out a magical bolt that pushes out the target struck away from the caster."
	clothes_req = FALSE
	range = 10
	projectile_type = /obj/projectile/magic/repel
	overlay_state = ""
	sound = list('sound/magic/unmagnet.ogg')
	active = FALSE
	releasedrain = 7
	chargedrain = 0
	chargetime = 20
	charge_max = 15 SECONDS
	warnie = "spellwarning"
	overlay_state = "fetch"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	cost = 1
	xp_gain = TRUE

/obj/projectile/magic/repel
	name = "bolt of repeling"
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	range = 15

/obj/effect/proc_holder/spell/invoked/projectile/cast(list/targets, mob/living/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/proj = H.get_active_held_item()
		if(isobj(proj))
			var/obj/I = proj
			if(I && H.in_throw_mode)
				var/atom/throw_target = get_edge_target_turf(H, get_dir(user,get_step(user,user.dir)))
				if(throw_target)
					H.dropItemToGround(I)
					if(I)	//In case it's something that gets qdel'd on drop
						I.throw_at(throw_target, 7, 4)
						H.throw_mode_off()

/obj/projectile/magic/repel/on_hit(target)

	var/atom/throw_target = get_edge_target_turf(firer, get_dir(firer, target)) //ill be real I got no idea why this worked.
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check() || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		L.throw_at(throw_target, 7, 4)
	else
		if(isitem(target))
			var/obj/item/I = target
			var/mob/living/carbon/human/carbon_firer
			if (ishuman(firer))
				carbon_firer = firer
				if (carbon_firer?.can_catch_item())
					throw_target = get_edge_target_turf(firer, get_dir(firer, target))
			I.throw_at(throw_target, 7, 4)

/obj/effect/proc_holder/spell/invoked/poisonspray5e
	name = "Aerosolize" //once again renamed to fit better :)
	desc = "Turns a container of liquid into a smoke containing the reagents of that liquid."
	overlay_state = "null"
	releasedrain = 50
	chargetime = 3
	charge_max = 20 SECONDS
	//chargetime = 10
	//charge_max = 30 SECONDS
	range = 6
	warnie = "spellwarning"
	movement_interrupt = FALSE
	no_early_release = FALSE
	chargedloop = null
	sound = 'sound/magic/whiteflame.ogg'
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane //can be arcane, druidic, blood, holy
	cost = 1

	xp_gain = TRUE
	miracle = FALSE

	invocation = ""
	invocation_type = "shout" //can be none, whisper, emote and shout
	
/obj/effect/proc_holder/spell/invoked/poisonspray5e/cast(list/targets, mob/living/user)
	var/turf/T = get_turf(targets[1]) //check for turf
	if(T)
		var/obj/item/held_item = user.get_active_held_item() //get held item
		var/obj/item/reagent_containers/con = held_item //get held item
		if(con)
			if(con.spillable)
				if(con.reagents.total_volume > 0)
					var/datum/reagents/R = con.reagents
					var/datum/effect_system/smoke_spread/chem/smoke = new
					smoke.set_up(R, 1, T, FALSE)
					smoke.start()

					user.visible_message(span_warning("[user] sprays the contents of the [held_item], creating a cloud!"), span_warning("You spray the contents of the [held_item], creating a cloud!"))
					con.reagents.clear_reagents() //empty the container
					playsound(user, 'sound/magic/webspin.ogg', 100)
				else
					to_chat(user, "<span class='warning'>The [held_item] is empty!</span>")
					revert_cast()
			else
				to_chat(user, "<span class='warning'>I can't get access to the contents of this [held_item]!</span>")
				revert_cast()
		else
			to_chat(user, "<span class='warning'>I need to hold a container to cast this!</span>")
			revert_cast()
	else
		to_chat(user, "<span class='warning'>I couldn't find a good place for this!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/targeted/touch/lesserknock
	name = "Lesser Knock"
	desc = "A simple spell used to focus the arcane into an instrument for lockpicking. Can be dispelled by using it on anything that isn't a locked/unlocked door."
	clothes_req = FALSE
	drawmessage = "I prepare to perform a minor arcane incantation."
	dropmessage = "I release my minor arcane focus."
	school = "transmutation"
	overlay_state = "rune4"
	chargedrain = 0
	chargetime = 0
	releasedrain = 5 // this influences -every- cost involved in the spell's functionality, if you want to edit specific features, do so in handle_cost
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	hand_path = /obj/item/melee/touch_attack/lesserknock
	cost = 1
	
/obj/item/melee/touch_attack/lesserknock
	name = "Spectral Lockpick"
	desc = "A faintly glowing lockpick that appears to be held together by the mysteries of the arcane. To dispel it, simply use it on anything that isn't a door."
	catchphrase = null
	possible_item_intents = list(/datum/intent/use)
	icon = 'icons/roguetown/items/keys.dmi'
	icon_state = "lockpick"
	color = "#3FBAFD" // spooky magic blue color that's also used by presti
	picklvl = 1
	max_integrity = 30
	destroy_sound = 'sound/items/pickbreak.ogg'
	resistance_flags = FIRE_PROOF

/obj/item/melee/touch_attack/lesserknock/attack_self()
	qdel(src)

/obj/effect/proc_holder/spell/invoked/counterspell
	name = "Counterspell"
	desc = "Briefly nullify the arcane energy surrounding a target. Either preventing magic from being used outright, or preventing most magics from affecting the subject."
	cost = 1
	releasedrain = 35
	chargedrain = 1
	chargetime = 30
	charge_max = 80 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/wind
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "rune2"

/obj/effect/proc_holder/spell/invoked/counterspell/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/carbon/target = targets[1]
		if(HAS_TRAIT(target, TRAIT_COUNTERCOUNTERSPELL))
			to_chat(user, "<span class='warning'>They've counterspelled my counterspell immediately! It's not going to work on them!</span>")
			revert_cast()
			return
		ADD_TRAIT(target, TRAIT_SPELLCOCKBLOCK, MAGIC_TRAIT)
		ADD_TRAIT(target, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
		to_chat(target, span_warning("I feel as if my connection to the Arcane disappears entirely. The air feels still..."))
		target.visible_message("[target]'s arcane aura seems to fade.")
		addtimer(CALLBACK(src, PROC_REF(remove_buff), target), wait = 20 SECONDS)
		return TRUE
	

/obj/effect/proc_holder/spell/invoked/counterspell/proc/remove_buff(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_SPELLCOCKBLOCK, MAGIC_TRAIT)
	REMOVE_TRAIT(target, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	to_chat(target, span_warning("I feel my connection to the arcane surround me once more."))
	target.visible_message("[target]'s arcane aura seems to return once more.")
	
/obj/effect/proc_holder/spell/invoked/enlarge
	name = "Enlarge Person"
	desc = "For a time, enlarges your target to a giant hulking version of themselves capable of bashing into doors. Does not work on folk who are already large."
	cost = 1
	releasedrain = 35
	chargedrain = 1
	chargetime = 30
	charge_max = 120 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/wind
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "rune1"
	range = 7

/obj/effect/proc_holder/spell/invoked/enlarge/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/carbon/target = targets[1]
		if(HAS_TRAIT(target,TRAIT_BIGGUY))
			to_chat(user, "<span class='warning'>They're too big to enlarge!</span>")
			revert_cast()
			return
		ADD_TRAIT(target, TRAIT_BIGGUY, MAGIC_TRAIT)
		target.transform = target.transform.Scale(1.25, 1.25)
		target.transform = target.transform.Translate(0, (0.25 * 16))
		target.update_transform()
		to_chat(target, span_warning("I feel taller than usual, and like I could run through a door!"))
		target.visible_message("[target]'s body grows in size!")
		addtimer(CALLBACK(src, PROC_REF(remove_buff), target), wait = 60 SECONDS)
		return TRUE
	

/obj/effect/proc_holder/spell/invoked/enlarge/proc/remove_buff(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_BIGGUY, MAGIC_TRAIT)
	target.transform = target.transform.Translate(0, -(0.25 * 16))
	target.transform = target.transform.Scale(1/1.25, 1/1.25)      
	target.update_transform()
	to_chat(target, span_warning("I feel smaller all of a sudden."))
	target.visible_message("[target]'s body shrinks quickly!")
	
/obj/effect/proc_holder/spell/invoked/leap
	name = "Leap"
	desc = "You empower your target's legs to allow them to leap to great heights. This allows your target to jump up floor levels, however does not prevent the damage from falling down one."
	cost = 1
	releasedrain = 35
	chargedrain = 1
	chargetime = 30
	charge_max = 120 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/wind
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "rune5"
	range = 7

/obj/effect/proc_holder/spell/invoked/leap/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/carbon/target = targets[1]
		if(HAS_TRAIT(target,TRAIT_ZJUMP))
			to_chat(user, "<span class='warning'>They're already able to jump that high!</span>")
			revert_cast()
			return
		ADD_TRAIT(target, TRAIT_ZJUMP, MAGIC_TRAIT)
		to_chat(target, span_warning("My legs feel stronger! I feel like I can jump up high!"))
		addtimer(CALLBACK(src, PROC_REF(remove_buff), target), wait = 20 SECONDS)
		return TRUE
	

/obj/effect/proc_holder/spell/invoked/leap/proc/remove_buff(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_ZJUMP, MAGIC_TRAIT)
	to_chat(target, span_warning("My legs feel remarkably weaker."))
	target.Immobilize(5)

/obj/effect/proc_holder/spell/invoked/mirror_transform  // Changed from targeted to invoked
	name = "Mirror Transform"
	desc = "Temporarily grants you the ability to use mirrors to change your appearance."
	clothes_req = FALSE
	charge_type = "recharge"
	associated_skill = /datum/skill/magic/arcane
	cost = 2
	xp_gain = TRUE
	// Fix invoked spell variables
	releasedrain = 35
	chargedrain = 1  // Fixed from chargeddrain to chargedrain
	chargetime = 10
	charge_max = 300 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/wind
	overlay_state = "mirror"

/obj/effect/proc_holder/spell/invoked/mirror_transform/cast(list/targets, mob/user)  // Changed to match invoked spell pattern
	if(!isliving(targets[1]))
		return
	var/mob/living/carbon/human/H = targets[1]
	if(!istype(H))
		return

	ADD_TRAIT(H, TRAIT_MIRROR_MAGIC, TRAIT_GENERIC)
	H.visible_message(span_notice("[H]'s reflection shimmers briefly."), span_notice("You feel a connection to mirrors forming..."))
	
	addtimer(CALLBACK(src, PROC_REF(remove_mirror_magic), H), 5 MINUTES)
	return TRUE  // Return TRUE for successful cast

/obj/effect/proc_holder/spell/invoked/mirror_transform/proc/remove_mirror_magic(mob/living/carbon/human/H)
	if(!QDELETED(H))
		REMOVE_TRAIT(H, TRAIT_MIRROR_MAGIC, TRAIT_GENERIC)
		to_chat(H, span_warning("Your connection to mirrors fades away."))

/obj/effect/proc_holder/spell/invoked/shadowstep
	name = "Shadowstep"
	desc = "Project your shadow to swap places with it, teleporting several feet away."
	cost = 1
	xp_gain = TRUE
	releasedrain = 30
	warnie = "spellwarning"
	movement_interrupt = TRUE
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "shadowstep"
	chargedrain = 1
	chargetime = 0 SECONDS
	charge_max = 30 SECONDS
	var/area_of_effect = 1
	var/max_range = 7
	var/turf/destination_turf
	var/turf/user_turf
	var/mutable_appearance/tile_effect
	var/mutable_appearance/target_effect
	var/datum/looping_sound/invokeshadow/shadowloop

//Resets the tile and turf effects.
/obj/effect/proc_holder/spell/invoked/shadowstep/proc/reset(silent = FALSE)
	if(tile_effect && destination_turf)
		destination_turf.cut_overlay(tile_effect)
		qdel(tile_effect)
		destination_turf = null
	if(user_turf && target_effect)
		user_turf.cut_overlay(target_effect)
		qdel(target_effect)
		user_turf = null
	update_icon()

/obj/effect/proc_holder/spell/invoked/shadowstep/proc/check_path(turf/Tu, turf/Tt)
	var/dist = get_dist(Tt, Tu)
	var/last_dir
	var/turf/last_step
	if(Tu.z > Tt.z) 
		last_step = get_step_multiz(Tu, DOWN)
	else if(Tu.z < Tt.z)
		last_step = get_step_multiz(Tu, UP)
	else 
		last_step = locate(Tu.x, Tu.y, Tu.z)
	var/success = FALSE
	for(var/i = 0, i <= dist, i++)
		last_dir = get_dir(last_step, Tt)
		var/turf/Tstep = get_step(last_step, last_dir)
		if(!Tstep.density)
			success = TRUE
			var/list/cont = Tstep.GetAllContents(/obj/structure/roguewindow)
			for(var/obj/structure/roguewindow/W in cont)
				if(W.climbable && !W.opacity)	//It's climbable and can be seen through
					success = TRUE
					continue
				else if(!W.climbable)
					success = FALSE
					return success
		else
			success = FALSE
			return success
		last_step = Tstep
	return success

//Successful teleport, complete reset.
/obj/effect/proc_holder/spell/invoked/shadowstep/proc/tp(mob/user)
	if(destination_turf)
		if(do_teleport(user, destination_turf, no_effects=TRUE))
			log_admin("[user.real_name]([key_name(user)] Shadowstepped from X:[user_turf.x] Y:[user_turf.y] Z:[user_turf.z] to X:[destination_turf.x] Y:[destination_turf.y] Z:[destination_turf.z] in area: [get_area(destination_turf)]")
			if(user.m_intent == MOVE_INTENT_SNEAK)
				playsound(user_turf, 'sound/magic/shadowstep.ogg', 20, FALSE)
				playsound(destination_turf, 'sound/magic/shadowstep.ogg', 20, FALSE)
			else
				playsound(user_turf, 'sound/magic/shadowstep.ogg', 100, FALSE)
				playsound(destination_turf, 'sound/magic/shadowstep.ogg', 100, FALSE)
			reset(silent = TRUE)

/obj/effect/proc_holder/spell/invoked/shadowstep/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1])
	if(!istransparentturf(T))
		var/reason
		if(max_range >= get_dist(user, T) && !T.density)
			if(check_path(get_turf(user), T))	//We check for opaque turfs or non-climbable windows in the way via a simple pathfind.
				if(get_dist(user, T) < 2 && user.z == T.z)
					to_chat(user, span_info("Too close!"))
					revert_cast()
					return
				to_chat(user, span_info("I begin to meld with the shadows.."))
				lockon(T, user)
				if(do_after(user, 5 SECONDS))
					tp(user)
				else
					reset(silent = TRUE)
					revert_cast()
				return
			else
				to_chat(user, span_info("The path is blocked!"))
				revert_cast()
				return
		else if(get_dist(user, T) > max_range)
			reason = "It's too far."
			revert_cast()
		else if (T.density)
			reason = "It's a wall!"
			revert_cast()
		to_chat(user, span_info("I cannot shadowstep there! "+"[reason]"))
	else
		to_chat(user, span_info("I cannot shadowstep there!"))
		revert_cast()
	. = ..()

//Plays affects at target Turf
/obj/effect/proc_holder/spell/invoked/shadowstep/proc/lockon(turf/T, mob/user)
	if(user.m_intent == MOVE_INTENT_SNEAK)
		playsound(T, 'sound/magic/shadowstep_destination.ogg', 20, FALSE, 5)
	else
		playsound(T, 'sound/magic/shadowstep_destination.ogg', 100, FALSE, 5)
	tile_effect = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "curse", layer = 18)
	target_effect = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "curse", layer = 18)
	user_turf = get_turf(user)
	destination_turf = T
	user_turf.add_overlay(target_effect)
	destination_turf.add_overlay(tile_effect)

/obj/effect/proc_holder/spell/invoked/blink
	name = "Blink"
	desc = "Teleport to a targeted location within your field of view. Limited to a range of 5 tiles. Only works on the same plane as the caster."
	school = "conjuration"
	cost = 1
	releasedrain = 30
	chargedrain = 1
	chargetime = 1.5 SECONDS
	charge_max = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "rune6"
	xp_gain = TRUE
	invocation = "SHIFT THROUGH SPACE!"
	invocation_type = "shout"
	var/max_range = 5
	var/phase = /obj/effect/temp_visual/blink

/obj/effect/temp_visual/blink
	icon = 'icons/effects/effects.dmi'
	icon_state = "hierophant_blast"
	name = "teleportation magic"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 4 SECONDS
	layer = MASSIVE_OBJ_LAYER
	light_outer_range = 2
	light_color = COLOR_PALE_PURPLE_GRAY

/obj/effect/temp_visual/blink/Initialize(mapload, new_caster)
	. = ..()
	var/turf/src_turf = get_turf(src)
	playsound(src_turf,'sound/magic/blink.ogg', 65, TRUE, -5)

/obj/effect/proc_holder/spell/invoked/blink/cast(list/targets, mob/user = usr)
	var/turf/T = get_turf(targets[1])
	var/turf/start = get_turf(user)
	
	if(!T)
		to_chat(user, span_warning("Invalid target location!"))
		revert_cast()
		return

	if(T.teleport_restricted == TRUE)
		to_chat(user, span_warning("I can't teleport here!"))

	if(T.z != start.z)
		to_chat(user, span_warning("I can only teleport on the same plane!"))

		revert_cast()
		return
	
	if(istransparentturf(T))
		to_chat(user, span_warning("I cannot teleport to the open air!"))
		revert_cast()
		return

	if(T.density)
		to_chat(user, span_warning("I cannot teleport into a wall!"))
		revert_cast()
		return

	// Check range limit
	var/distance = get_dist(start, T)
	if(distance > max_range)
		to_chat(user, span_warning("That location is too far away! I can only blink up to [max_range] tiles."))
		revert_cast()
		return
	
	// Display a more obvious preparation message
	user.visible_message(span_warning("<b>[user]'s body begins to shimmer with arcane energy as [user.p_they()] prepare[user.p_s()] to blink!</b>"), 
						span_notice("<b>I focus my arcane energy, preparing to blink across space!</b>"))
		
	// Check if there's a wall in the way, but exclude the target turf
	var/list/turf_list = getline(start, T)
	// Remove the last turf (target location) from the check
	if(length(turf_list) > 0)
		turf_list.len--
	
	for(var/turf/turf in turf_list)
		if(turf.density)
			to_chat(user, span_warning("I cannot blink through walls!"))
			revert_cast()
			return
			
	// Check for doors and bars in the path
	for(var/turf/traversal_turf in turf_list)
		// Check for mineral doors
		for(var/obj/structure/mineral_door/door in (traversal_turf.contents + T.contents))
			if(door.density)
				to_chat(user, span_warning("I cannot blink through doors!"))
				revert_cast()
				return
				
		// Check for windows
		for(var/obj/structure/roguewindow/window in (traversal_turf.contents + T.contents))
			if(window.density && !window.climbable)
				to_chat(user, span_warning("I cannot blink through windows!"))
				revert_cast()
				return
				
		// Check for bars
		for(var/obj/structure/bars/bars in (traversal_turf.contents + T.contents))
			if(bars.density)
				to_chat(user, span_warning("I cannot blink through bars!"))
				revert_cast()
				return

		// Check for gates
		for (var/obj/structure/gate/gate in (traversal_turf.contents + T.contents))
			if(gate.density)
				to_chat(user, span_warning("I cannot blink through gates!"))
				revert_cast()
				return

	var/obj/spot_one = new phase(start, user.dir)
	var/obj/spot_two = new phase(T, user.dir)

	spot_one.Beam(spot_two, "purple_lightning", time = 1.5 SECONDS)
	playsound(T, 'sound/magic/blink.ogg', 25, TRUE)

	if(user.buckled) // don't stay remote-buckled to the guillotine/pillory
		user.buckled.unbuckle_mob(user, TRUE)
	do_teleport(user, T, channel = TELEPORT_CHANNEL_MAGIC)
	
	user.visible_message(span_danger("<b>[user] vanishes in a mysterious purple flash!</b>"), span_notice("<b>I blink through space in an instant!</b>"))
	return TRUE
/*	- Teleporting to Lumby, lumby drop 500g
/obj/effect/proc_holder/spell/self/recall
	name = "Recall"
	desc = "Memorize your current location, allowing you to return to it after a delay."
	school = "transmutation"
	charge_type = "none" // Changed from "recharge" to "none"
	charge_max = 0 // Changed from 3 MINUTES
	charge_counter = 0 // Changed from 3 MINUTES
	clothes_req = FALSE
	cost = 2
	invocation = "RETURN TO MY MARKED GROUND!"
	invocation_type = "shout"
	cooldown_min = 0 // Changed from 3 MINUTES
	associated_skill = /datum/skill/magic/arcane
	xp_gain = TRUE
	action_icon_state = "recall"
	
	var/turf/marked_location = null
	var/recall_delay = 10 SECONDS

/obj/effect/proc_holder/spell/self/recall/cast(mob/user = usr)
	if(!istype(user, /mob/living/carbon/human))
		return FALSE
		
	var/mob/living/carbon/human/H = user
	
	// First cast - mark the location
	if(!marked_location)
		var/turf/T = get_turf(H)
		marked_location = T
		
		// Add sparkle effect when marking location
		var/datum/effect_system/spark_spread/sparks = new()
		sparks.set_up(3, 1, H)
		sparks.start()
		
		H.visible_message(span_warning("<b>[H] begins to glow slightly as [H.p_they()] mark[H.p_s()] [H.p_their()] location!</b>"), 
						span_notice("<b>I imprint this location into my arcane memory. I can now recall to this spot.</b>"))
		return TRUE
		
	// Subsequent casts - begin channeling
	H.visible_message(span_warning("<b>[H] closes [H.p_their()] eyes and begins glowing with increasing intensity as [H.p_they()] focus[H.p_es()] on recall magic!</b>"), 
					span_notice("<b>I begin channeling the recall spell, focusing on my marked location...</b>"))
	
	// Play a distinctive magical sound that everyone can hear when channeling begins
	playsound(get_turf(H), 'sound/magic/timestop.ogg', 80, TRUE, soundping = TRUE)
	
	// Add sparkle effect during channeling
	var/datum/effect_system/spark_spread/channeling_sparks = new()
	channeling_sparks.set_up(2, 1, H)
	channeling_sparks.start()
	
	if(do_after(H, recall_delay, target = H, progress = TRUE))
		// Add more intense sparkle effect before teleport
		var/datum/effect_system/spark_spread/sparks = new()
		sparks.set_up(5, 1, H)
		sparks.start()
		
		// Get any grabbed mobs
		var/list/to_teleport = list(H)
		if(H.pulling && isliving(H.pulling))
			to_teleport += H.pulling
			
		// Teleport caster and grabbed mob if any
		for(var/mob/living/L in to_teleport)
			do_teleport(L, marked_location, no_effects = FALSE, channel = TELEPORT_CHANNEL_MAGIC)
			
		H.visible_message(span_danger("<b>[H] disappears in a blinding shower of arcane sparks and energy!</b>"), 
						span_notice("<b>I complete the recall spell, teleporting back to my marked location!</b>"))
		playsound(H, 'sound/magic/unmagnet.ogg', 50, TRUE)
		
		// Visual effects at both locations
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(3, marked_location)
		smoke.start()
		
		// Additional sparkle effect at destination
		sparks.set_up(5, 1, H)
		sparks.start()
		
		return TRUE
	else
		to_chat(H, span_warning("Your concentration was broken!"))
		return FALSE
*/
/obj/effect/proc_holder/spell/invoked/mindlink
	name = "Mindlink"
	desc = "Establish a telepathic link with an ally for one minute. Use ,y before a message to communicate telepathically."
	clothes_req = FALSE
	overlay_state = "mindlink"
	associated_skill = /datum/skill/magic/arcane
	cost = 2
	xp_gain = TRUE
	charge_max = 5 MINUTES
	invocation = "MENTIS NEXUS!"
	invocation_type = "whisper"
	
	// Charged spell variables
	chargedloop = /datum/looping_sound/invokegen
	chargedrain = 1
	chargetime = 20
	releasedrain = 25
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	warnie = "spellwarning"
	range = 7

/obj/effect/proc_holder/spell/invoked/mindlink/cast(list/targets, mob/living/user)
	. = ..()
	if(!istype(user))
		return
	
	var/list/possible_targets = list()
	if(user.client)
		possible_targets += user  // Always add self first
		
	if(user.mind?.known_people)  // Only check known_people if it exists
		for(var/mob/living/L in GLOB.player_list)
			if((L.client && L != user) && (L.real_name in user.mind.known_people))
				possible_targets += L
	
	if(!length(possible_targets))
		to_chat(user, span_warning("You have no known people to establish a mindlink with!"))
		return FALSE

	var/mob/living/first_target = input(user, "Choose the first person to link", "Mindlink") as null|anything in possible_targets
	if(!first_target)
		return FALSE
		
	var/mob/living/second_target = input(user, "Choose the second person to link", "Mindlink") as null|anything in possible_targets
	if(!second_target)
		return FALSE

	if(first_target == second_target)
		to_chat(user, span_warning("You cannot link someone to themselves!"))
		return FALSE

	user.visible_message(span_notice("[user] touches their temples and concentrates..."), span_notice("I establish a mental connection between [first_target] and [second_target]..."))
	
	// Create the mindlink
	var/datum/mindlink/link = new(first_target, second_target)
	GLOB.mindlinks += link
	
	to_chat(first_target, span_notice("A mindlink has been established with [second_target]! Use ,y before a message to communicate telepathically."))
	to_chat(second_target, span_notice("A mindlink has been established with [first_target]! Use ,y before a message to communicate telepathically."))
	
	addtimer(CALLBACK(src, PROC_REF(break_link), link), 3 MINUTES)
	return TRUE

/obj/effect/proc_holder/spell/invoked/mindlink/proc/break_link(datum/mindlink/link)
	if(!link)
		return
	
	to_chat(link.owner, span_warning("The mindlink with [link.target] fades away..."))
	to_chat(link.target, span_warning("The mindlink with [link.owner] fades away..."))
	
	GLOB.mindlinks -= link
	qdel(link)




#undef PRESTI_CLEAN
#undef PRESTI_SPARK
#undef PRESTI_MOTE


