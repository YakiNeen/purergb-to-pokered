	db DEX_FARFETCHD ; pokedex id

	db  90,  65,  55, 121,  58
	;   hp  atk  def  spd  spc

	db NORMAL, FLYING ; type
	db 85 ; catch rate
	db 130 ; base exp

	INCBIN "gfx/pokemon/front/farfetchd.pic", 0, 1 ; sprite dimensions
	dw FarfetchdPicFront, FarfetchdPicBackSW

	db PECK, SAND_ATTACK, LEER, MIRROR_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	RAZOR_WIND,\ ; ROOST
	LEECH_SEED,\
	PIN_MISSILE,\
	TOXIC,\
	BODY_SLAM,\
	SLASH,\
	DOUBLE_EDGE,\
	BUBBLEBEAM,\
	HYPER_BEAM,\
	AMNESIA,\
	HI_JUMP_KICK,\
	ROLLING_KICK,\
	BARRIER,\
	RAZOR_LEAF,\
	DIG,\
	SWORDS_DANCE,\
	REFLECT,\
	BIDE,\
	AGILITY,\
	BARRAGE,\
	SLAM,\ ; FILTHY SLAM
	KARATE_CHOP,\
	MEDITATE,\
	SKY_ATTACK,\
	LIGHT_SCREEN,\
	GLARE,\
	SUBSTITUTE,\
	CUT,\
	FLY,\
	SURF,\
	STRENGTH,\
	FLASH
	; end


	dw BANK(FarfetchdPicFront), BANK(FarfetchdPicBack)

	dw 1, FarfetchdPicBack
