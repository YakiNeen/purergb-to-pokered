	object_const_def
	const NAMERATERSHOUSE_NAME_RATER

NameRatersHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 6
	warp_event  3,  7, LAST_MAP, 6

	def_bg_events

	def_object_events
	object_event  5,  3, SPRITE_SILPH_PRESIDENT, STAY, LEFT, TEXT_NAMERATERSHOUSE_NAME_RATER

	def_warps_to NAME_RATERS_HOUSE
