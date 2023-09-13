	object_const_def
	const PEWTERSPEECHHOUSE_GAMBLER
	const PEWTERSPEECHHOUSE_YOUNGSTER
	const PEWTERSPEECHHOUSE_LOST_WALLET_BEAUTY

PewterSpeechHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 6
	warp_event  3,  7, LAST_MAP, 6

	def_bg_events

	def_object_events
	object_event  2,  3, SPRITE_GAMBLER, STAY, RIGHT, TEXT_PEWTERSPEECHHOUSE_GAMBLER
	object_event  4,  5, SPRITE_YOUNGSTER, STAY, NONE, TEXT_PEWTERSPEECHHOUSE_YOUNGSTER
	object_event  5,  1, SPRITE_BEAUTY, STAY, NONE, TEXT_PEWTERSPEECHHOUSE_LOST_WALLET_BEAUTY

	def_warps_to PEWTER_SPEECH_HOUSE
