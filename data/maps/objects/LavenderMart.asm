	object_const_def
	const LAVENDERMART_CLERK
	const LAVENDERMART_BALDING_GUY
	const LAVENDERMART_COOLTRAINER_M
	const LAVENDERMART_TM_KID

LavenderMart_Object:
	db $0 ; border block

	def_warp_events
	warp_event  3,  7, LAST_MAP, 4
	warp_event  4,  7, LAST_MAP, 4

	def_bg_events

	def_object_events
	object_event  0,  5, SPRITE_CLERK, STAY, RIGHT, TEXT_LAVENDERMART_CLERK 
	object_event  3,  4, SPRITE_BALDING_GUY, STAY, NONE, TEXT_LAVENDERMART_BALDING_GUY 
	object_event  7,  2, SPRITE_COOLTRAINER_M, STAY, NONE, TEXT_LAVENDERMART_COOLTRAINER_M 
	object_event  1,  7, SPRITE_LITTLE_BOY, STAY, NONE, TEXT_LAVENDERMART_TM_KID

	def_warps_to LAVENDER_MART
