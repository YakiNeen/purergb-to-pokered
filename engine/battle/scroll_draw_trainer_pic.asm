_ScrollTrainerPicAfterBattle:
; Load the enemy trainer's pic and scrolls it into
; the screen from the right.
; TODO: optional trainer colors
	xor a
	ld [wEnemyMonSpecies2], a
	ld b, SET_PAL_BATTLE
	call RunPaletteCommand
	callfar _LoadTrainerPic
	xor a
	ld [wWhichTrainerClass], a ; PureRGBnote: ADDED: clear trainer class from variable used in bank checking for trainer sprites
	hlcoord 19, 0
	ld c, $0
.scrollLoop
	inc c
	ld a, c
	cp 7
	ret z
	ld d, $0
	push bc
	push hl
.drawTrainerPicLoop
	call DrawTrainerPicColumn
	inc hl
	ld a, 7
	add d
	ld d, a
	dec c
	jr nz, .drawTrainerPicLoop
	ld c, 4
	rst _DelayFrames
	pop hl
	pop bc
	dec hl
	jr .scrollLoop

; write one 7-tile column of the trainer pic to the tilemap
DrawTrainerPicColumn:
	push hl
	push de
	push bc
	ld e, 7
.loop
	ld [hl], d
	ld bc, SCREEN_WIDTH
	add hl, bc
	inc d
	dec e
	jr nz, .loop
	pop bc
	pop de
	pop hl
	ret
