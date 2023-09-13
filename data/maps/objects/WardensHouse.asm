	object_const_def
	const WARDENSHOUSE_WARDEN
	const WARDENSHOUSE_ITEM1
	const WARDENSHOUSE_BOULDER

WardensHouse_Object:
	db $17 ; border block

	def_warp_events
	warp_event  4,  7, LAST_MAP, 4
	warp_event  5,  7, LAST_MAP, 4

	def_bg_events
	bg_event  4,  3, TEXT_WARDENSHOUSE_DISPLAY_LEFT
	bg_event  5,  3, TEXT_WARDENSHOUSE_DISPLAY_RIGHT

	def_object_events
	object_event  2,  3, SPRITE_WARDEN, STAY, NONE, TEXT_WARDENSHOUSE_WARDEN
	object_event  8,  3, SPRITE_POKE_BALL, STAY, NONE, TEXT_WARDENSHOUSE_ITEM1, ITEM_WARDENS_HOUSE_BEHIND_BOULDER
	object_event  8,  4, SPRITE_BOULDER, STAY, BOULDER_MOVEMENT_BYTE_2, TEXT_WARDENSHOUSE_BOULDER

	def_warps_to WARDENS_HOUSE
