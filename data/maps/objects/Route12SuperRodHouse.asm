	object_const_def
	const ROUTE12SUPERRODHOUSE_FISHING_GURU
	const ROUTE12SUPERRODHOUSE_FISHING_GUIDE

Route12SuperRodHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 4
	warp_event  3,  7, LAST_MAP, 4

	def_bg_events

	def_object_events
	object_event  2,  4, SPRITE_FISHING_GURU, STAY, RIGHT, TEXT_ROUTE12SUPERRODHOUSE_FISHING_GURU
	object_event  3,  3, SPRITE_POKEDEX, STAY, NONE, TEXT_ROUTE12SUPERRODHOUSE_FISHING_GUIDE

	def_warps_to ROUTE_12_SUPER_ROD_HOUSE
