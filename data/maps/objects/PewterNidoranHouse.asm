	object_const_def
	const PEWTERNIDORANHOUSE_NIDORAN
	const PEWTERNIDORANHOUSE_LITTLE_BOY
	const PEWTERNIDORANHOUSE_MIDDLE_AGED_MAN

PewterNidoranHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 4
	warp_event  3,  7, LAST_MAP, 4

	def_bg_events

	def_object_events
	object_event  4,  5, SPRITE_MONSTER, STAY, LEFT, PEWTERNIDORANHOUSE_NIDORAN
	object_event  3,  5, SPRITE_LITTLE_BOY, STAY, RIGHT, PEWTERNIDORANHOUSE_LITTLE_BOY
	object_event  1,  2, SPRITE_MIDDLE_AGED_MAN, STAY, NONE, PEWTERNIDORANHOUSE_MIDDLE_AGED_MAN

	def_warps_to PEWTER_NIDORAN_HOUSE
