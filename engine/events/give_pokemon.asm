_GivePokemon::
; returns success in carry
; and whether the mon was added to the party in [wAddedToParty]
	call EnableAutoTextBoxDrawing
	xor a
	ld [wAddedToParty], a
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr c, .addToParty
	ld a, [wBoxCount]
	cp MONS_PER_BOX
	jr nc, .boxFull
; add to box
	xor a
	ld [wEnemyBattleStatus3], a
	ld a, [wcf91]
	ld [wEnemyMonSpecies2], a
	callfar LoadEnemyMonData
	call SetPokedexOwnedFlag
	callfar SendNewMonToBox
	ld hl, wStringBuffer
	ld a, [wCurrentBoxNum]
	and $7f
	cp 9
	jr c, .singleDigitBoxNum
	sub 9
	ld [hl], "1"
	inc hl
	add "0"
	jr .next
.singleDigitBoxNum
	add "1"
.next
	ld [hli], a
	ld [hl], "@"
	ld hl, SentToBoxText
	rst _PrintText
	callfar PrintRemainingBoxSpace ; PureRGBnote: ADDED: 
	call .clearAltPaletteData 
	scf
	ret
.boxFull
	ld hl, BoxIsFullText
	rst _PrintText
	push af
	call .clearAltPaletteData
	pop af
	and a
	ret
.addToParty
	call SetPokedexOwnedFlag
	call AddPartyMon
	call .clearAltPaletteData
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld [wAddedToParty], a
	scf
	ret
	; PureRGBnote: ADDED: if the pokemon being given was an alternate palette pokemon, 
	;                     we need to clear the flag to make sure the next pokemon given is not alternate palette.
.clearAltPaletteData 
	xor a
	ld [wIsAltPalettePkmnData], a
	ret

SetPokedexOwnedFlag:
	ld a, [wcf91]
	push af
	ld [wd11e], a
	predef IndexToPokedex
	ld a, [wd11e]
	and a
	ret z ; PureRGBnote: ADDED: do nothing for missingno to avoid glitchy results (missingno isn't part of the dex	)
	dec a
	ld c, a
	ld hl, wPokedexOwned
	ld b, FLAG_SET
	predef FlagActionPredef
	pop af
	ld [wd11e], a
	call GetMonName
	ld hl, GotMonText
	jp PrintText

GotMonText:
	text_far _GotMonText
	sound_get_item_1
	text_end

SentToBoxText:
	text_far _SentToBoxText
	text_end

BoxIsFullText:
	text_far _BoxIsFullText
	text_end
