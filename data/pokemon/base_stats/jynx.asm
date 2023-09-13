	db DEX_JYNX ; pokedex id

	db  70,  50,  75,  95, 105
	;   hp  atk  def  spd  spc

	db ICE, PSYCHIC_TYPE ; type
	db 75 ; catch rate
	db 137 ; base exp

	INCBIN "gfx/pokemon/front/jynx.pic", 0, 1 ; sprite dimensions
	dw JynxPicFront, JynxPicBackSW

	db POUND, LOVELY_KISS, LICK, DOUBLESLAP ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	ICE_PUNCH,\
	FIRE_PUNCH,\
	TOXIC,\
	BODY_SLAM,\
	DOUBLE_EDGE,\
	BUBBLEBEAM,\
	AURORA_BEAM,\
	ICE_BEAM,\
	BLIZZARD,\
	HYPER_BEAM,\
	AMNESIA,\
	THUNDERPUNCH,\
	ROLLING_KICK,\
	BARRIER,\
	CRABHAMMER,\
	PSYCHIC_M,\
	MEGA_DRAIN,\
	REFLECT,\
	BIDE,\
	BARRAGE,\
	KARATE_CHOP,\
	MEDITATE,\
	LOVELY_KISS,\
	LIGHT_SCREEN,\
	PSYBEAM,\
	GLARE,\
	SUBSTITUTE,\
	SURF,\
	FLASH
	; end


	dw BANK(JynxPicFront), BANK(JynxPicBack)

	dw 1, JynxPicBack
