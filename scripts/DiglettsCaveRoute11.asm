DiglettsCaveRoute11_Script:
	ld a, ROUTE_11
	ld [wLastMap], a
	jp EnableAutoTextBoxDrawing

DiglettsCaveRoute11_TextPointers:
	def_text_pointers
	dw_const DiglettsCaveRoute11GamblerText, TEXT_DIGLETTSCAVEROUTE11_GAMBLER

DiglettsCaveRoute11GamblerText:
	text_far _DiglettsCaveRoute11GamblerText
	text_end
