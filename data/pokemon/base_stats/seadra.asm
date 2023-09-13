	db DEX_SEADRA ; pokedex id

	db  55,  65,  95,  85,  120
	;   hp  atk  def  spd  spc

	db WATER, DRAGON ; type
	db 95 ; catch rate
	db 155 ; base exp

	INCBIN "gfx/pokemon/front/seadra.pic", 0, 1 ; sprite dimensions
	dw SeadraPicFront, SeadraPicBackSW

	db BUBBLE, NO_MOVE, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	TOXIC,\
	PIN_MISSILE,\
	DOUBLE_EDGE,\
	BUBBLEBEAM,\
	AURORA_BEAM,\
	ICE_BEAM,\
	BLIZZARD,\
	HYPER_BEAM,\
	AMNESIA,\
	BARRIER,\
	DRAGON_RAGE,\
	MEGA_DRAIN,\
	KINESIS,\ ; FIREWALL
	REFLECT,\
	BIDE,\
	AGILITY,\
	BARRAGE,\
	FIRE_BLAST,\
	FLAMETHROWER,\
	LOVELY_KISS,\
	LIGHT_SCREEN,\
	SLUDGE,\
	GLARE,\
	SUBSTITUTE,\
	SURF,\
	FLASH
	; end

	dw BANK(SeadraPicFront), BANK(SeadraPicBack)

	dw 1, SeadraPicBack
