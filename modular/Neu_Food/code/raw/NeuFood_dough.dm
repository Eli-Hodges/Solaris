/* * * * * * * * * * * **
 *						*
 *		 NeuFood		*	- Basically add water to powder, then more powder
 *		 (Snacks)		*
 *						*
 * * * * * * * * * * * **/



/*	.................   Dough   ................... */
/obj/item/reagent_containers/food/snacks/rogue/dough_base
	name = "unfinished dough"
	desc = "With a little more ambition, you will conquer."
	icon_state = "dough_base"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/dough_base/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/powder/flour))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Kneading in more powder..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/dough(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/dough
	name = "dough"
	desc = "The triumph of all bakers."
	icon_state = "dough"
	slices_num = 2
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/doughslice
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bread
	w_class = WEIGHT_CLASS_NORMAL
	slice_sound = TRUE

/obj/item/reagent_containers/food/snacks/rogue/dough/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/butterslice))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
			to_chat(user, span_notice("Kneading butter into the dough..."))
			if(do_after(user,long_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/butterdough(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	if(istype(I, /obj/item/reagent_containers/powder/sugar))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
			to_chat(user, "<span class='notice'>Mixing sugar into the dough...</span>")
			if(do_after(user,long_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/sweetdough(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to roll it out!</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/raisins))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Kneading the dough and adding raisins..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/rbread_half(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/rollingpin.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Rolling [src] into cracker dough."))
			if(do_after(user,long_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw(loc)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	else
		return ..()

/*	.................   Smalldough   ................... */
/obj/item/reagent_containers/food/snacks/rogue/doughslice
	name = "smalldough"
	icon_state = "doughslice"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bun
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/doughslice/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
			to_chat(user, span_notice("Adding fresh cheese..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesebun_raw(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/doughslice))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Combining dough..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/dough(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	else
		return ..()

/*	.................   Butterdough   ................... */
/obj/item/reagent_containers/food/snacks/rogue/butterdough
	name = "butterdough"
	desc = "What is a triumph, to a legacy?"
	icon_state = "butterdough"
	color = "#feffc1"
	slices_num = 2
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/butterdoughslice
	w_class = WEIGHT_CLASS_NORMAL
	slice_sound = TRUE

/obj/item/reagent_containers/food/snacks/rogue/butterdough/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/egg))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Working cackleberry into the dough, shaping it into a cake..."))
			playsound(get_turf(user), 'modular/Neu_Food/sound/eggbreak.ogg', 100, TRUE, -1)
			if(do_after(user,long_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/cake_base(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	else
		return ..()

/*	.................   Butterdough piece   ................... */
/obj/item/reagent_containers/food/snacks/rogue/butterdoughslice
	name = "butterdough piece"
	desc = "A slice of pedigree, to create lines of history."
	icon_state = "butterdoughslice"
	color = "#feffc1"
	slices_num = 0
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/frybread
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/pastry
	w_class = WEIGHT_CLASS_NORMAL

// Dough + rolling pin on table = flat dough. RT got some similar proc for this.
/obj/item/reagent_containers/food/snacks/rogue/butterdoughslice/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/rollingpin.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Flattening [src]..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/piedough(loc)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/raisins))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Adding raisins to the dough..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/biscuit_raw(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to roll it out!"))
	if(I.get_sharpness())
		if(!isdwarf(user))
			to_chat(user, span_warning("You lack knowledge of dwarven pastries!"))
			return
		else
			if(isturf(loc)&& (found_table))
				playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
				to_chat(user, span_notice("Cutting the dough in strips and making a prezzel..."))
				if(do_after(user,short_cooktime, target = src))
					add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
					new /obj/item/reagent_containers/food/snacks/rogue/foodbase/prezzel_raw(loc)
					qdel(src)
			else
				to_chat(user, span_warning("You need to put [src] on a table to cut it!"))
	else
		..()

/*	.................   Piedough   ................... */
/obj/item/reagent_containers/food/snacks/rogue/piedough
	name = "piedough"
	desc = "The beginning of greater things to come."
	icon_state = "piedough"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/piebottom
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/piedough/attackby(obj/item/I, mob/living/user, params)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/truffles))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		to_chat(user, span_notice("Making a handpie..."))
		if(do_after(user,short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			var/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/mushroom/handpie= new(get_turf(user))
			user.put_in_hands(handpie)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/mince))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		to_chat(user, span_notice("Making a handpie..."))
		if(do_after(user,short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			var/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/mince/handpie= new(get_turf(user))
			user.put_in_hands(handpie)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		to_chat(user, span_notice("Making a handpie..."))
		if(do_after(user,short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			var/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/poison/handpie= new(get_turf(user))
			user.put_in_hands(handpie)
			qdel(I)
			qdel(src)
	else if(istype(I, /obj/item/reagent_containers/food/snacks/grown/berries/rogue))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		to_chat(user, span_notice("Making a handpie..."))
		if(do_after(user,short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			var/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/berry/handpie= new(get_turf(user))
			user.put_in_hands(handpie)
			qdel(I)
			qdel(src)
	else
		return ..()


/*	.................   Hardtack   ................... */
/obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	name = "raw hardtack"
	desc = "Doughy, soft, unacceptable."
	icon_state = "raw_tack"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = null

/obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	name = "hardtack"
	desc = "Very, very hard and dry."
	icon_state = "tack6"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_POOR
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	bitesize = 6
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/crackerscooked/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "tack5"
	if(bitecount == 2)
		icon_state = "tack4"
	if(bitecount == 3)
		icon_state = "tack3"
	if(bitecount == 4)
		icon_state = "tack2"
	if(bitecount == 5)
		icon_state = "tack1"


/*	.................   Bread   ................... */
/obj/item/reagent_containers/food/snacks/rogue/bread
	name = "bread loaf"
	desc = "One of the staple foods of the world, with the decline of magic, the loss of bread-duplication has led to mass famines around Grimoria."
	icon_state = "loaf6"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = DOUGH_NUTRITION)
	faretype = FARE_POOR
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1)
	slice_batch = FALSE
	slice_sound = TRUE
	rotprocess = SHELFLIFE_EXTREME

/obj/item/reagent_containers/food/snacks/rogue/bread/update_icon()
	if(slices_num)
		icon_state = "loaf[slices_num]"
	else
		icon_state = "loaf_slice"

/obj/item/reagent_containers/food/snacks/rogue/bread/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 5
		if(bitecount == 2)
			slices_num = 4
		if(bitecount == 3)
			slices_num = 3
		if(bitecount == 4)
			slices_num = 2
		if(bitecount == 5)
			changefood(slice_path, eater)

/*	.................   Breadslice & Toast   ................... */
/obj/item/reagent_containers/food/snacks/rogue/breadslice
	name = "sliced bread"
	desc = "A bit of comfort to start your day."
	icon_state = "loaf_slice"
	faretype = FARE_POOR
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	bitesize = 2
	rotprocess = SHELFLIFE_LONG
	dropshrink = 0.8

/obj/item/reagent_containers/food/snacks/rogue/breadslice/attackby(obj/item/I, mob/living/user, params)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/sandwich/salami/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheddarslice))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/sandwich/cheese/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/friedegg))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/sandwich/egg/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/fat/salo/slice))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/sandwich/salo/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
			var/obj/item/reagent_containers/food/snacks/rogue/sandwich/bacon/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	else
		return ..()

//this is a child so we can be used in sammies
/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	name = "toast"
	icon_state = "toast"
	faretype = FARE_NEUTRAL
	tastes = list("crispy bread" = 1)
	cooked_type = null
	bitesize = 2
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/attackby(obj/item/I, mob/user, params)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/butterslice))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/buttered/sammich= new(get_turf(user))
			user.put_in_hands(sammich)
			qdel(I)
			qdel(src)
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/buttered
	name = "buttered toast"
	icon_state = "toast_butter"
	faretype = FARE_NEUTRAL
	tastes = list("butter" = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)

// -------------- BREAD WITH FOOD ON IT (not american sandwich) -----------------
/obj/item/reagent_containers/food/snacks/rogue/sandwich
	desc = "A delightful piece of heaven, in every slice."
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	faretype = FARE_NEUTRAL
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff

/obj/item/reagent_containers/food/snacks/rogue/sandwich/salami
	tastes = list("salumoi" = 1,"bread" = 1)
	name = "salumoi bread"
	faretype = FARE_NEUTRAL
	icon_state = "bread_salami"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/rogue/sandwich/cheese
	tastes = list("cheese" = 1,"bread" = 1)
	name = "cheese bread"
	faretype = FARE_NEUTRAL
	icon_state = "bread_cheese"
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/rogue/sandwich/egg
	tastes = list("cheese" = 1,"cackleberry" = 1)
	name = "cackleberry toast"
	faretype = FARE_NEUTRAL
	icon_state = "bread_egg"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/rogue/sandwich/salo
	tastes = list("salty fat" = 1)
	name = "salo bread"
	faretype = FARE_IMPOVERISHED
	icon_state = "bread_salo"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/rogue/sandwich/bacon
	tastes = list("bacon" = 1)
	name = "bacon bread"
	icon_state = "bread_bacon"
	foodtype = GRAIN | MEAT


/*	.................   Bread bun   ................... */
/obj/item/reagent_containers/food/snacks/rogue/bun
	name = "bun"
	desc = "Portable, quaint and entirely consumable"
	icon_state = "bun"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_POOR
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1)
	bitesize = 2
	rotprocess = SHELFLIFE_EXTREME

/obj/item/reagent_containers/food/snacks/rogue/bun/attackby(obj/item/I, mob/living/user, params)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 50, TRUE, -1)
		to_chat(user, span_notice("Pushing the wiener through the bun..."))
		if(do_after(user,short_cooktime, target = src))
			var/obj/item/reagent_containers/food/snacks/rogue/bun_grenz/hotdog= new(get_turf(user))
			user.put_in_hands(hotdog)
			qdel(I)
			qdel(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge))
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 100, TRUE, -1)
		to_chat(user, "<span class='notice'>Stuffing the bun with cheese...</span>")
		if(do_after(user,short_cooktime, target = src))
			user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
			new /obj/item/reagent_containers/food/snacks/rogue/bun_raston(loc)
			qdel(I)
			qdel(src)
	else
		return ..()


/*	.................   Cheese bun   ................... */
/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesebun_raw
	name = "raw cheese bun"
	desc = "Portable, quaint and entirely consumable"
	icon_state = "cheesebun_raw"
	color = "#ecce61"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cheesebun
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/rogue/cheesebun
	name = "fresh cheese bun"
	desc = "A treat. Cheese! For everyone!"
	faretype = FARE_FINE
	icon_state = "cheesebun"
	list_reagents = list(/datum/reagent/consumable/nutriment = SMALLDOUGH_NUTRITION+FRESHCHEESE_NUTRITION)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("crispy bread and cream cheese" = 1)
	foodtype = GRAIN | DAIRY
	bitesize = 2
	rotprocess = SHELFLIFE_DECENT

/obj/item/reagent_containers/food/snacks/rogue/frybread
	name = "frybread"
	desc = "Flatbread fried at high heat with butter to give it a crispy outside. Staple of the elven kitchen."
	icon_state = "frybread"
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	tastes = list("crispy bread with a soft inside" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 3
	eat_effect = /datum/status_effect/buff/foodbuff

/*	.................   Pastry   ................... */
/obj/item/reagent_containers/food/snacks/rogue/pastry
	name = "pastry"
	desc = "Favored among children and sweetlovers."
	icon_state = "pastry"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	tastes = list("crispy butterdough" = 1)
	faretype = FARE_FINE
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 3
	rotprocess = SHELFLIFE_EXTREME
	eat_effect = /datum/status_effect/buff/foodbuff

/obj/item/reagent_containers/food/snacks/rogue/sweetdough
	name = "sweet dough"
	desc = ""
	icon_state = "sweetdough"
	slices_num = 4
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/uncookedfinecake
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/plaincake
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("sweetened dough" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = SHELFLIFE_SHORT

/obj/item/reagent_containers/food/snacks/rogue/uncookedfinecake
	name = "uncooked fine cake"
	desc = ""
	icon_state = "finecake"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/finecake
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1,"sugar" = 1)
	foodtype = GRAIN
	slice_batch = FALSE
	rotprocess = SHELFLIFE_SHORT
	eat_effect = /datum/status_effect/debuff/uncookedfood

/obj/item/reagent_containers/food/snacks/rogue/finecake
	name = "finecake"
	desc = ""
	icon_state = "finecake3"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("delicate, melt in your mouth sweetness" = 1)
	foodtype = GRAIN
	bitesize = 3
	rotprocess = SHELFLIFE_EXTREME
	eat_effect = /datum/status_effect/buff/foodbuff
	faretype = FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/finecake/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "finecake2"
	if(bitecount == 2)
		icon_state = "finecake1"

/obj/item/reagent_containers/food/snacks/rogue/plaincake
	name = "plain cake"
	desc = ""
	icon_state = "plaincake"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/plaincakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 40)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("crispy sweetened dough with a sugar glaze and hints of rosewater" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 6
	rotprocess = SHELFLIFE_EXTREME
	dropshrink = 0.80

/obj/item/reagent_containers/food/snacks/rogue/plaincakeslice
	name = "plain cake slice"
	desc = ""
	icon_state = "plaincakeslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("crispy sweetened dough with a sugar glaze and hints of rosewater" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 3
	rotprocess = null
	dropshrink = 0.60

/obj/item/reagent_containers/food/snacks/rogue/sweetdough/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (60 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (100 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/food/snacks/egg))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, "<span class='notice'>Working cackleberry into the dough, shaping it into a cake...</span>")
			playsound(get_turf(user), 'modular/Neu_Food/sound/eggbreak.ogg', 100, TRUE, -1)
			if(do_after(user,long_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/cake_base(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work it!</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/applejam))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, "<span class='notice'>Working apple jam into the dough, shaping it into a tart...</span>")
			if(do_after(user,long_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/uncookedappletart(loc)
				new /obj/item/reagent_containers/glass/beaker/jar(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work it!</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/berryjam))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, "<span class='notice'>Working berry jam into the dough, shaping it into a tart...</span>")
			if(do_after(user,long_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/uncookedberrytart(loc)
				new /obj/item/reagent_containers/glass/beaker/jar(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work it!</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/pumpkinspice))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, "<span class='notice'>Working pumpkin spice into the dough...</span>")
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading_alt.ogg', 100, TRUE, -1)
			if(do_after(user,long_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/pumpkindough(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work it!</span>")
	else
		return ..()

/*	.................      Tarts    ................... */

/obj/item/reagent_containers/food/snacks/rogue/uncookedappletart
	name = "uncooked apple tart"
	desc = ""
	icon_state = "uncookedappletart"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/appletart
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("crispy sweetened dough with a sugar glaze and hints of rosewater" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/debuff/uncookedfood
	bitesize = 6
	rotprocess = 30 MINUTES
	dropshrink = 0.80

/obj/item/reagent_containers/food/snacks/rogue/appletart
	name = "apple tart"
	desc = ""
	icon_state = "appletart"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/appletartslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("A crispy dough with delicate, sweet apple filling" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 6
	dropshrink = 0.80
	faretype = FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/appletartslice
	name = "apple tart slice"
	desc = ""
	icon_state = "appletartslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("Soft, sweet filling, with a flaky dough" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 3
	rotprocess = null
	dropshrink = 0.60
	faretype = FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/uncookedberrytart
	name = "uncooked berry tart"
	desc = ""
	icon_state = "uncookedberrytart"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/berrytart
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("crispy sweetened dough with a sugar glaze and hints of rosewater" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/debuff/uncookedfood
	bitesize = 6
	rotprocess = 30 MINUTES
	dropshrink = 0.80
	faretype = FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/berrytart
	name = "berry tart"
	desc = ""
	icon_state = "berrytart"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/berrytartslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("A crispy dough with delicate, sweet berry filling" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 6
	dropshrink = 0.80
	faretype = FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/berrytartslice
	name = "berry tart slice"
	desc = ""
	icon_state = "berrytartslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("Soft, sweet filling, with a flaky dough" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 3
	rotprocess = null
	dropshrink = 0.60
	faretype = FARE_LAVISH

/*	.................   Sweetroll   ................... */

/obj/item/reagent_containers/food/snacks/rogue/sweetroll
	name = "sweetroll"
	desc = ""
	icon_state = "sweetroll"
	dropshrink = 0.75
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("sugar and crispy dough" = 1)
	foodtype = SUGAR
	rotprocess = SHELFLIFE_EXTREME
	eat_effect = /datum/status_effect/buff/foodbuff
	faretype = FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/pastry/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (60 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (100 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/powder/sugar))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, "<span class='notice'>Adding the sugar...</span>")
			if(do_after(user,short_cooktime, target = src))
				user.mind.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/sweetroll(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work it.</span>")
	else
		return ..()	

/*	.................   Biscuit   ................... */
/obj/item/reagent_containers/food/snacks/rogue/foodbase/biscuit_raw
	name = "uncooked raisin biscuit"
	icon_state = "biscuit_raw"
	color = "#ecce61"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/biscuit
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = null

/obj/item/reagent_containers/food/snacks/rogue/biscuit
	name = "biscuit"
	desc = "A treat made for a wretched dog like you."
	icon_state = "biscuit"
	faretype = FARE_POOR
	filling_color = "#F0E68C"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT+SNACK_POOR)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 3
	tastes = list("crispy butterdough" = 1, "raisins" = 1)
	eat_effect = /datum/status_effect/buff/foodbuff

/obj/item/reagent_containers/food/snacks/rogue/cookie		//It's a biscuit.......
	name = "cookie of smiles"
	icon_state = "cookie"
	color = "#ecce61"
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = null

/*	.................   Prezzel   ................... */
/obj/item/reagent_containers/food/snacks/rogue/foodbase/prezzel_raw
	name = "uncooked prezzel"
	icon_state = "prezzel_raw"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/prezzel
	w_class = WEIGHT_CLASS_NORMAL
	eat_effect = null

/obj/item/reagent_containers/food/snacks/rogue/prezzel
	name = "prezzel"
	desc = "The next best thing since sliced bread, naturally, made by a dwarf."
	icon_state = "prezzel"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_FINE
	tastes = list("crispy butterdough" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 3
	eat_effect = /datum/status_effect/buff/foodbuff


/*	.................   Raisin bread   ................... */
/obj/item/reagent_containers/food/snacks/rogue/rbread_half
	name = "half-done raisin dough"
	desc = "Add more raisins!"
	icon_state = "dough_raisin"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/rbread_half/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/raisins))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Adding the last of the raisins, puffing up the dough for baking."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked
	name = "loaf of raisins"
	icon_state = "raisinbreaduncooked"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/raisinbread
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/raisinbread
	name = "raisin loaf"
	desc = "Bread enhanced with sweet raisins for a perfect addition to any meal."
	icon_state = "raisinbread6"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_AVERAGE)
	faretype = FARE_NEUTRAL
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1,"dried fruit" = 1)
	slice_batch = FALSE
	slice_sound = TRUE
	rotprocess = SHELFLIFE_EXTREME
	eat_effect = /datum/status_effect/buff/foodbuff

/obj/item/reagent_containers/food/snacks/rogue/raisinbread/update_icon()
	if(slices_num)
		icon_state = "raisinbread[slices_num]"
	else
		icon_state = "raisinbread_slice"

/obj/item/reagent_containers/food/snacks/rogue/raisinbread/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 5
		if(bitecount == 2)
			slices_num = 4
		if(bitecount == 3)
			slices_num = 3
		if(bitecount == 4)
			slices_num = 2
		if(bitecount == 5)
			changefood(slice_path, eater)

/obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	name = "raisin loaf slice"
	icon_state = "raisinbread_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT-1)
	w_class = WEIGHT_CLASS_NORMAL
	faretype = FARE_NEUTRAL
	cooked_type = null
	tastes = list("spelt" = 1,"dried fruit" = 1)
	bitesize = 2
	rotprocess = SHELFLIFE_LONG
	eat_effect = /datum/status_effect/buff/foodbuff
	dropshrink = 0.8

/*	.................   Pumpkin Bread   ................... */
/obj/item/reagent_containers/food/snacks/rogue/pumpkindough
	name = "pumpkin dough"
	desc = "A sweetened dough with pumpkin spice."
	icon_state = "pumpkindough"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/pumpkinbread
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | SUGAR
	rotprocess = SHELFLIFE_SHORT

/obj/item/reagent_containers/food/snacks/rogue/pumpkinbread
	name = "pumpkin bread"
	desc = "A sweetened bread with pumpkin spice."
	icon_state = "pumpkinbread"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pumpkinbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("sweetened dough with pumpkin spice"=1)
	foodtype = GRAIN | SUGAR
	faretype = FARE_LAVISH
	slice_batch = TRUE
	slice_sound = TRUE
	rotprocess = SHELFLIFE_LONG
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 16

/obj/item/reagent_containers/food/snacks/rogue/pumpkinbreadslice
	name = "pumpkin bread slice"
	desc = "A slice of sweetened bread with pumpkin spice."
	icon_state = "pumpkinbreadslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	faretype = FARE_FINE
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = null
	tastes = list("sweetened dough with pumpkin spice"=1)
	foodtype = GRAIN | SUGAR
	bitesize = 3
	eat_effect = /datum/status_effect/buff/foodbuff
	rotprocess = SHELFLIFE_LONG
	plateable = TRUE


/*	.................   Cake   ................... */
/obj/item/reagent_containers/food/snacks/rogue/cake_base
	name = "cake base"
	desc = "With this sweet thing, you shall make them sing."
	icon_state = "cake"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | DAIRY
	rotprocess = SHELFLIFE_LONG

/obj/item/reagent_containers/food/snacks/rogue/cake_base/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Spreading fresh cheese on the cake..."))
			if(do_after(user,long_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/honey))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Slathering the cake with delicious spider honey..."))
			if(do_after(user,long_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/hcakeuncooked(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	else
		return ..()

// -------------- SPIDER-HONEY CAKE (Zybantu) -----------------
/obj/item/reagent_containers/food/snacks/rogue/hcakeuncooked
	name = "unbaked cake"
	icon_state = "honeycakeuncook"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/hcake
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | DAIRY | SUGAR
	rotprocess = SHELFLIFE_DECENT

/obj/item/reagent_containers/food/snacks/rogue/hcake
	name = "honeyed cake"
	desc = "Cake glazed with honey, a delicious sweet treat."
	icon_state = "honeycake"
	slices_num = 8
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/hcakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("cake"=1, "delicious honeyfrosting"=1)
	foodtype = GRAIN | DAIRY | SUGAR
	faretype = FARE_LAVISH
	slice_batch = TRUE
	slice_sound = TRUE
	rotprocess = SHELFLIFE_LONG
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 16

/obj/item/reagent_containers/food/snacks/rogue/hcakeslice
	name = "honeyed cake slice"
	icon_state = "honeycakeslice"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_FINE
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = null
	foodtype = GRAIN | DAIRY | SUGAR
	bitesize = 3
	eat_effect = /datum/status_effect/buff/foodbuff
	rotprocess = SHELFLIFE_LONG
	plateable = TRUE

/obj/item/reagent_containers/food/snacks/rogue/hcakeslice/plated
	icon_state = "honeycakeslice_plated"
	rotprocess = SHELFLIFE_EXTREME
	faretype = FARE_LAVISH
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	trash = /obj/item/cooking/platter

// -------------- CHEESECAKE -----------------

/obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked
	name = "unbaked cake of cheese"
	icon_state = "cheesecakeuncook"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/ccake
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtype = GRAIN | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	rotprocess = SHELFLIFE_DECENT

/obj/item/reagent_containers/food/snacks/rogue/ccake
	name = "cheesecake"
	desc = "Humenity's favored creation."
	icon_state = "cheesecake"
	slices_num = 8
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	faretype = FARE_FINE
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("cake"=1, "creamy cheese"=1)
	foodtype = GRAIN | DAIRY | SUGAR
	slice_batch = TRUE
	slice_sound = TRUE
	rotprocess = SHELFLIFE_LONG
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 16

/obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	name = "cheesecake slice"
	icon_state = "cheesecake_slice"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	w_class = WEIGHT_CLASS_NORMAL
	faretype = FARE_FINE
	cooked_type = null
	foodtype = GRAIN | DAIRY | SUGAR
	bitesize = 2
	eat_effect = /datum/status_effect/buff/foodbuff
	rotprocess = SHELFLIFE_LONG
	plateable = TRUE

/obj/item/reagent_containers/food/snacks/rogue/ccakeslice/plated
	icon_state = "cheesecake_slice_plated"
	rotprocess = SHELFLIFE_EXTREME
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1)
	faretype = FARE_LAVISH
	trash = /obj/item/cooking/platter

/* maybe split up spider honey cake WIP
	desc = "A cake glazed with spider-honey, a favorite dish among the Dark Elf nobility in Grimoria. Symbol of authority, a delicious residue covers the sweet cake which causes playful stinging and numbness in the mouth."
*/
