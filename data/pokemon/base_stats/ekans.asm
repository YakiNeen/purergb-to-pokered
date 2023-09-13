	db DEX_EKANS ; pokedex id

	db  35,  60,  44,  55,  40
	;   hp  atk  def  spd  spc

	db POISON, POISON ; type
	db 255 ; catch rate
	db 90 ; base exp

	INCBIN "gfx/pokemon/front/ekans.pic", 0, 1 ; sprite dimensions
	dw EkansPicFront, EkansPicBackSW

	db WRAP, LEER, POISON_STING, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	PIN_MISSILE,\
	TOXIC,\
	BODY_SLAM,\
	SLASH,\
	DOUBLE_EDGE,\
	BARRIER,\
	EARTHQUAKE,\
	DIG,\
	MEGA_DRAIN,\
	KINESIS,\ ; FIREWALL
	SWORDS_DANCE,\
	REFLECT,\
	BIDE,\
	BARRAGE,\
	SLAM,\ ; FILTHY SLAM
	KARATE_CHOP,\
	LOVELY_KISS,\
	LIGHT_SCREEN,\
	SLUDGE,\
	ROCK_SLIDE,\
	GLARE,\
	SUBSTITUTE,\
	CUT,\
	STRENGTH,\
	FLASH
	; end


	dw BANK(EkansPicFront), BANK(EkansPicBack)

	dw 1, EkansPicBack
