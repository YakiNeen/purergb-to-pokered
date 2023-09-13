; PureRGBnote: ADDED: Someone who can purify a "Cursed" Haunter was added in this script

LavenderCuboneHouse_Script:
	jp EnableAutoTextBoxDrawing

LavenderCuboneHouse_TextPointers:
	def_text_pointers
	dw_const LavenderCuboneHouseCuboneText,       TEXT_LAVENDERCUBONEHOUSE_CUBONE
	dw_const LavenderCuboneHouseBrunetteGirlText, TEXT_LAVENDERCUBONEHOUSE_BRUNETTE_GIRL
	dw_const LightChannelerText,                  TEXT_LAVENDERCUBONEHOUSE_LIGHT_CHANNELER

LavenderCuboneHouseCuboneText:
	text_far _LavenderCuboneHouseCuboneText
	text_asm
	ld a, CUBONE
	call PlayCry
	rst TextScriptEnd

LavenderCuboneHouseBrunetteGirlText:
	text_asm
	CheckEvent EVENT_RESCUED_MR_FUJI
	jr nz, .rescued_mr_fuji
	ld hl, .PoorCubonesMotherText
	rst _PrintText
	jr .done
.rescued_mr_fuji
	ld hl, .TheGhostIsGoneText
	rst _PrintText
.done
	rst TextScriptEnd

.PoorCubonesMotherText:
	text_far _LavenderCuboneHouseBrunetteGirlPoorCubonesMotherText
	text_end

.TheGhostIsGoneText:
	text_far _LavenderCuboneHouseBrunetteGirlGhostIsGoneText
	text_end

LightChannelerText:
	text_asm
	CheckEvent EVENT_MET_LIGHT_CHANNELER
	call nz, .checkForHaunter
	jr c, .skipGreeting
	ld hl, LightChannelerGreeting
	rst _PrintText
	SetEvent EVENT_MET_LIGHT_CHANNELER
	call .checkForHaunter
	jp nc, .done
	ld hl, TextScriptPromptButton
	call TextCommandProcessor
.skipGreeting
	ld hl, LightChannelerHaunter
	rst _PrintText
	xor a
	ld [wCurrentMenuItem], a
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, LightChannelerHaunterNo
	jr nz, .no
	ld hl, LightChannelerHaunterYes
	rst _PrintText
	xor a ; NORMAL_PARTY_MENU
	ld [wPartyMenuTypeOrMessageID], a
	dec a
	ld [wUpdateSpritesEnabled], a
	call SaveScreenTilesToBuffer2
	call DisplayPartyMenu
	push af
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call ReloadTilesetTilePatterns
	call Delay3
	call LoadGBPal
	pop af
	ld hl, LightChannelerHaunterNo
	jr c, .no
	ld a, [wcf91]
	cp POWERED_HAUNTER
	jr nz, .no
	ld hl, TextScriptEndingText
	rst _PrintText
	call SaveScreenTilesToBuffer2
	ld hl, LightChannelerPurificationTime
	rst _PrintText
	; purification spell goes here
	call StopAllMusic
	call GBFadeOutToWhite
	ld a, $09
	ld [wFrequencyModifier], a
	ld a, $ff
	ld [wTempoModifier], a
	ld c, BANK(SFX_Not_Very_Effective)
	ld a, SFX_NOT_VERY_EFFECTIVE
	call PlayMusic
	call WaitForSoundToFinish
	call LoadScreenTilesFromBuffer2
	call Delay3
	call GBFadeInFromWhite
	ld a, GENGAR
	ld [wcf91], a
	call PlayCry
	callfar ChangePartyPokemonSpecies
	callfar CheckMonNickNameDefault
	call PlayDefaultMusic
	ld hl, LightChannelerPurificationComplete
.no
	rst _PrintText
.done
	rst TextScriptEnd
.checkForHaunter
	ld d, POWERED_HAUNTER
	jpfar FindPokemonInParty

LightChannelerGreeting:
	text_far _LightChannelerGreeting
	text_end

LightChannelerHaunter:
	text_far _LightChannelerHaunter
	text_end

LightChannelerHaunterNo:
	text_far _LightChannelerHaunterNo
	text_end

LightChannelerHaunterYes:
	text_far _LightChannelerHaunterYes
	text_end

LightChannelerPurificationTime:
	text_far _LightChannelerPurificationTime
	text_end

LightChannelerPurificationComplete:
	text_far _LightChannelerPurificationComplete
	text_end