	object_const_def
	const TRADECENTER_OPPONENT

TradeCenter_Object:
	db $e ; border block

	def_warp_events

	def_bg_events

	def_object_events
	object_event  2,  2, SPRITE_RED, STAY, 0, TEXT_TRADECENTER_OPPONENT

	def_warps_to TRADE_CENTER
