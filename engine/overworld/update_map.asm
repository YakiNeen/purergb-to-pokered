; PureRGBnote: CHANGED: Replacetileblock was split up into two functions, one that redraws the map and one that does not.
; If we know something is offscreen then calling the noredraw version will cause less in-game lag.
; replaces a tile block with the one specified in [wNewTileBlockID]
; and redraws the map view if necessary
; b = Y
; c = X
ReplaceTileBlock:
	call GetPredefRegisters
	call ReplaceTileBlockCommon
	ret z
	call IsBCInHLTileBlockMapView
	ret c
	jp RedrawMapView 

ReplaceMultipleTileBlocks::
	call ReplaceMultipleTileBlocksNoRedraw
	ld a, d
	and a
	ret z
	jp RedrawMapView

ReplaceMultipleTileBlocksNoRedraw::
	ld h, d
	ld l, e
	ld d, 0
.loop
	ld b, [hl]
	inc hl
	ld c, [hl]
	inc hl
	ld a, [hli]
	ld [wNewTileBlockID], a
	push de
	push hl
	call ReplaceTileBlockCommon
	jr z, .popNoRedraw
	call IsBCInHLTileBlockMapView
	pop hl
	pop de
	jr c, .noRedraw
	inc d
.noRedraw
	ld a, [hl]
	cp -1
	jr nz, .loop
	ret
.popNoRedraw
	pop hl
	pop de
	jr .noRedraw

INCLUDE "engine/overworld/tile_block_replacements.asm"

ReplaceTileBlockNoRedraw:
	call GetPredefRegisters
	; fall through

ReplaceTileBlockCommon:
	ld hl, wOverworldMap
	ld a, [wCurMapWidth]
	add $6
	ld e, a
	ld d, $0
	add hl, de
	add hl, de
	add hl, de
	ld e, $3
	add hl, de
	ld e, a
	ld a, b
	and a
	jr z, .addX
; add width * Y
.addWidthYTimesLoop
	add hl, de
	dec b
	jr nz, .addWidthYTimesLoop
.addX
	add hl, bc ; add X
	ld a, [wNewTileBlockID]

	;shinpokerednote: FIXED: No point in wasting time if the new tile block is the same as the old one. 
	cp [hl]
	ret z

	ld [hl], a
	ld a, 1
	and a
	ret


RedrawMapView::
	ld a, [wIsInBattle]
	inc a
	ret z
	ldh a, [hAutoBGTransferEnabled]
	push af
	ldh a, [hTileAnimations]
	push af
	xor a
	ldh [hAutoBGTransferEnabled], a
	ldh [hTileAnimations], a
	call LoadCurrentMapView
	call RunDefaultPaletteCommand
	ld hl, wMapViewVRAMPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, -2 * BG_MAP_WIDTH
	add hl, de
	ld a, h
	and $3
	or $98
	ld a, l
	ld [wBuffer], a
	ld a, h
	ld [wBuffer + 1], a ; this copy of the address is not used
	ld a, 2
	ldh [hRedrawMapViewRowOffset], a
	ld c, SCREEN_HEIGHT / 2 ; number of rows of 2x2 tiles (this covers the whole screen)
.redrawRowLoop
	push bc
	push hl
	push hl
	ld hl, wTileMap - 2 * SCREEN_WIDTH
	ld de, SCREEN_WIDTH
	ldh a, [hRedrawMapViewRowOffset]
.calcWRAMAddrLoop
	add hl, de
	dec a
	jr nz, .calcWRAMAddrLoop
	call CopyToRedrawRowOrColumnSrcTiles
	pop hl
	ld de, BG_MAP_WIDTH
	ldh a, [hRedrawMapViewRowOffset]
	ld c, a
.calcVRAMAddrLoop
	add hl, de
	ld a, h
	and $3
	or $98
	dec c
	jr nz, .calcVRAMAddrLoop
	ldh [hRedrawRowOrColumnDest + 1], a
	ld a, l
	ldh [hRedrawRowOrColumnDest], a
	ld a, REDRAW_ROW
	ldh [hRedrawRowOrColumnMode], a
	rst _DelayFrame
	ld hl, hRedrawMapViewRowOffset
	inc [hl]
	inc [hl]
	pop hl
	pop bc
	dec c
	jr nz, .redrawRowLoop
	pop af
	ldh [hTileAnimations], a
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

; shinpokerednote: CHANGED: when replacing tileblocks, this new function is used instead and will decide whether to
; do a redraw map view or not afterwards. If the block is offscreen, it won't redraw the map.
; This speeds up most tileblock replacements.

IsBCInHLTileBlockMapView:
	push hl
	pop bc
	ld a, [wCurrentTileBlockMapViewPointer]
	ld l, a
	ld a, [wCurrentTileBlockMapViewPointer + 1]
	ld h, a		
	;hl now points to the upper left tile block in the map view
	;bc points to the tile block that was replaced
	;e is the number of bytes to add to get to the next row of the tile block map view
	ld d, 5
.loop
	call .CheckRow
	ret nc
	dec d
	ret z
	push de
	ld d, 0
	add hl, de
	pop de
	jr .loop

.CheckRow
	ld a, b
	sub h
	ret nz
	ld a, c
	sub l
	ret c
	
	push hl
	
	push bc
	ld bc, $0004
	add hl, bc
	pop bc
	
	ld a, h
	sub b
	jr nz, .next
	ld a, l
	sub c
.next
	pop hl
	ret
