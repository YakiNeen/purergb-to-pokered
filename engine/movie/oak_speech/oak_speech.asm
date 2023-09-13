PrepareOakSpeech:
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, [wOptions]
	push af
	; Retrieve BIT_DEBUG_MODE set in DebugMenu for StartNewGameDebug.
	; BUG: StartNewGame carries over bit 5 from previous save files,
	; which causes CheckForceBikeOrSurf to not return.
	; To fix this in debug builds, reset bit 5 here or in StartNewGame.
	; In non-debug builds, the instructions can be removed.
	ld a, [wd732]
	push af
;;;;;;;;;; PureRGBnote: ADDED: these new options variables need to be preserved when starting a new game.
	ld a, [wSpriteOptions]
	push af
	ld a, [wSpriteOptions2]
	push af
	ld a, [wSpriteOptions3]
	push af
	ld a, [wSpriteOptions4]
	push af
	ld a, [wOptions2]
	push af
	ld a, [wOptions3]
	push af
	ld hl, wPlayerName
	ld bc, wBoxDataEnd - wPlayerName
	xor a
	call FillMemory
	ld hl, wSpriteDataStart
	ld bc, wSpriteDataEnd - wSpriteDataStart
	xor a
	call FillMemory
	pop af
	ld [wOptions3], a
	pop af
	ld [wOptions2], a
	pop af
	ld [wSpriteOptions4], a
	pop af
	ld [wSpriteOptions3], a
	pop af
	ld [wSpriteOptions2], a
	pop af
	ld [wSpriteOptions], a
;;;;;;;;;;
	pop af
	res 5, a ; prevent forced bike state on new game
	ld [wd732], a
	pop af
	ld [wOptions], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld a, [wOptionsInitialized]
	and a
	call z, InitOptions
	; These debug names are used for StartNewGameDebug.
	; TestBattle uses the debug names from DebugMenu.
	; A variant of this process is performed in PrepareTitleScreen.
	ld hl, DebugNewGamePlayerName
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	rst _CopyData
	ld hl, DebugNewGameRivalName
	ld de, wRivalName
	ld bc, NAME_LENGTH
	jp CopyData

; PureRGBnote: CHANGED: this subroutine was modified to make debug mode (wd732 bit 1 = non-zero) skip through it quickly to start debugging faster
OakSpeech:
	callfar GBCSetCPU1xSpeed ; shinpokerednote: ADDED: GBC double speed cpu mode messes up oak speech, stay at 1x speed
	ld a, SFX_STOP_ALL_MUSIC
	rst _PlaySound
IF DEF(_DEBUG)
	ld a, [wd732]
	bit 1, a
	jr nz, .skipMusic
ENDC
	ld a, BANK(Music_Routes2)
	ld c, a
	ld a, MUSIC_ROUTES2
	call PlayMusic
.skipMusic
	call ClearScreen
	call LoadTextBoxTilePatterns
	call PrepareOakSpeech
	predef InitPlayerData2
	call RunDefaultPaletteCommand	; shinpokerednote: gbcnote: reinitialize the default palette in case the pointers got cleared
	ld hl, wNumBoxItems
	ld a, ITEM_INITIAL_PC_ITEM
	ld [wcf91], a
	ld a, 1
	ld [wItemQuantity], a
	call AddItemToInventory
	ld a, [wDefaultMap]
	ld [wDestinationMap], a
	call PrepareForSpecialWarp
	xor a
	ldh [hTileAnimations], a
	ld a, [wd732]
	bit BIT_DEBUG_MODE, a
	jp nz, .skipSpeech
	ld de, ProfOakPic
	lb bc, BANK(ProfOakPic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, OakSpeechText1
	rst _PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld a, NIDORINO
	ld [wd0b5], a
	ld [wcf91], a
	call GetMonHeader
	hlcoord 6, 4
	call LoadFlippedFrontSpriteByMonIndex
	call MovePicLeft
	ld hl, OakSpeechText2
	rst _PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, BANK(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call MovePicLeft
	ld hl, IntroducePlayerText
	rst _PrintText
	call ChoosePlayerName
	call GBFadeOutToWhite
	call ClearScreen
	ld de, Rival1Pic
	lb bc, BANK(Rival1Pic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, IntroduceRivalText
	rst _PrintText
	call ChooseRivalName
;.skipSpeech
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, BANK(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld a, [wd72d]
	and a
	jr nz, .next
	ld hl, OakSpeechText3
	rst _PrintText
.next
	ldh a, [hLoadedROMBank]
	push af
	ld a, SFX_SHRINK
	rst _PlaySound
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ld c, 4
	rst _DelayFrames
	ld de, RedSprite
	ld hl, vSprites
	lb bc, BANK(RedSprite), $0C
	call CopyVideoData
	ld de, ShrinkPic1
	lb bc, BANK(ShrinkPic1), $00
	call IntroDisplayPicCenteredOrUpperRight
	ld c, 4
	rst _DelayFrames
	ld de, ShrinkPic2
	lb bc, BANK(ShrinkPic2), $00
	call IntroDisplayPicCenteredOrUpperRight
	call ResetPlayerSpriteData
.skipSpeech
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(Music_PalletTown)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, 10
	ld [wAudioFadeOutControl], a
	ld a, SFX_STOP_ALL_MUSIC
	ld [wNewSoundID], a
	rst _PlaySound
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
IF DEF(_DEBUG)
	ld a, [wd732]
	bit 1, a
	jr nz, .skipDelay
ENDC
	ld c, 20
	rst _DelayFrames
	hlcoord 6, 5
	ld b, 7
	ld c, 7
	call ClearScreenArea
	call LoadTextBoxTilePatterns
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	ld c, 50
	rst _DelayFrames
	call GBFadeOutToWhite
.skipDelay
	jp ClearScreen
OakSpeechText1:
	text_far _OakSpeechText1
	text_end
OakSpeechText2:
	text_far _OakSpeechText2A
	; BUG: The cry played does not match the sprite displayed. PureRGBnote: FIXED: Plays nidorino's cry now.
	sound_cry_nidorina
	text_far _OakSpeechText2B
	text_end
IntroducePlayerText:
	text_far _IntroducePlayerText
	text_end
IntroduceRivalText:
	text_far _IntroduceRivalText
	text_end
OakSpeechText3:
	text_far _OakSpeechText3
	text_end

FadeInIntroPic:
	ld hl, IntroFadePalettes
	ld b, 6
.next
	ld a, [hli]
	ldh [rBGP], a
	call UpdateGBCPal_BGP ; shinpokerednote: gbcnote: gbc color code from yellow 
	ld c, 10
	rst _DelayFrames
	dec b
	jr nz, .next
	ret

IntroFadePalettes:
	db %01010100
	db %10101000
	db %11111100
	db %11111000
	db %11110100
	db %11100100

MovePicLeft:
	ld a, 119
	ldh [rWX], a
	rst _DelayFrame

	ld a, %11100100
	ldh [rBGP], a
	call UpdateGBCPal_BGP ; shinpokerednote: gbcnote: gbc color code from yellow 
.next
	rst _DelayFrame
	ldh a, [rWX]
	sub 8
	cp $FF
	ret z
	ldh [rWX], a
	jr .next

DisplayPicCenteredOrUpperRight:
	call GetPredefRegisters
IntroDisplayPicCenteredOrUpperRight:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a, b
	call UncompressSpriteFromDE
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	rst _CopyData
	ld de, vFrontPic
	call InterlaceMergeSpriteBuffers
	pop bc
	ld a, c
	and a
	hlcoord 15, 1
	jr nz, .next
	hlcoord 6, 4
.next
	xor a
	ldh [hStartTileID], a
	predef_jump CopyUncompressedPicToTilemap
