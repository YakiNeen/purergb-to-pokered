	db DEX_KANGASKHAN ; pokedex id

	db 115,  95,  80,  90,  40
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 65 ; catch rate
	db 175 ; base exp

	INCBIN "gfx/pokemon/front/kangaskhan.pic", 0, 1 ; sprite dimensions
	dw KangaskhanPicFront, KangaskhanPicBackSW

	db COMET_PUNCH, RAGE, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	ICE_PUNCH,\
	FIRE_PUNCH,\
	TOXIC,\
	BODY_SLAM,\
	SLASH,\
	DOUBLE_EDGE,\
	BUBBLEBEAM,\
	AURORA_BEAM,\
	ICE_BEAM,\
	BLIZZARD,\
	HYPER_BEAM,\
	HI_JUMP_KICK,\
	THUNDERPUNCH,\
	ROLLING_KICK,\
	SOLARBEAM,\
	THUNDERBOLT,\
	THUNDER,\
	EARTHQUAKE,\
	DIG,\
	SWORDS_DANCE,\
	BIDE,\
	BARRAGE,\
	FIRE_BLAST,\
	FLAMETHROWER,\
	SLAM,\ ; FILTHY SLAM
	KARATE_CHOP,\
	MEDITATE,\
	ROCK_SLIDE,\
	GLARE,\
	SUBSTITUTE,\
	CUT,\
	SURF,\
	STRENGTH
	; end


	dw BANK(KangaskhanPicFront), BANK(KangaskhanPicBack)

	dw 1, KangaskhanPicBack
