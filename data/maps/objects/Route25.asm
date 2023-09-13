	object_const_def
	const ROUTE25_YOUNGSTER1
	const ROUTE25_YOUNGSTER2
	const ROUTE25_COOLTRAINER_M
	const ROUTE25_COOLTRAINER_F1
	const ROUTE25_YOUNGSTER3
	const ROUTE25_COOLTRAINER_F2
	const ROUTE25_HIKER1
	const ROUTE25_HIKER2
	const ROUTE25_HIKER3
	const ROUTE25_ITEM1

Route25_Object:
	db $2c ; border block

	def_warp_events
	warp_event 45,  5, BILLS_HOUSE, 1

	def_bg_events
	bg_event 43,  5, TEXT_ROUTE25_BILL_SIGN
	bg_event 53,  7, TEXT_ROUTE25_TRAINER_TIPS

	def_object_events
	object_event 14,  4, SPRITE_YOUNGSTER, STAY, DOWN, TEXT_ROUTE25_YOUNGSTER1, OPP_YOUNGSTER, 5
	object_event 18,  7, SPRITE_YOUNGSTER, STAY, UP, TEXT_ROUTE25_YOUNGSTER2, OPP_YOUNGSTER, 6
	object_event 24,  6, SPRITE_COOLTRAINER_M, STAY, DOWN, TEXT_ROUTE25_COOLTRAINER_M, OPP_JR_TRAINER_M, 10
	object_event 18, 10, SPRITE_COOLTRAINER_F, STAY, RIGHT, TEXT_ROUTE25_COOLTRAINER_F1, OPP_LASS, 9
	object_event 32,  5, SPRITE_YOUNGSTER, STAY, LEFT, TEXT_ROUTE25_YOUNGSTER3, OPP_YOUNGSTER, 7
	object_event 37,  6, SPRITE_COOLTRAINER_F, STAY, DOWN, TEXT_ROUTE25_COOLTRAINER_F2, OPP_LASS, 10
	object_event  8,  6, SPRITE_HIKER, STAY, RIGHT, TEXT_ROUTE25_HIKER1, OPP_HIKER, 2
	object_event 23, 11, SPRITE_HIKER, STAY, UP, TEXT_ROUTE25_HIKER2, OPP_HIKER, 3
	object_event 13,  9, SPRITE_HIKER, STAY, RIGHT, TEXT_ROUTE25_HIKER3, OPP_HIKER, 4
	object_event 22,  4, SPRITE_POKE_BALL, STAY, NONE, TEXT_ROUTE25_ITEM1, TM_ROUTE_25_CUT_ALCOVE

	def_warps_to ROUTE_25
