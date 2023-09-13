CustomListMenuTextMethods:
	dw GetMonNameListMenu

CustomListMenuGetEntryText::
	push hl
	ld a, [wListMenuCustomType]
	add a
	ld hl, CustomListMenuTextMethods
	call GetAddressFromPointerArray
	ld de, .return
	push de
	jp hl
.return
	pop hl
	ret

GetMonNameListMenu:
	jp GetMonName

CheckLoadHoverText::
	push af
	push bc
	push hl
	push de
	; wListMenuHoverTextType still loaded
	dec a
	add a
	ld hl, CustomListMenuHoverTextMethods
	call GetAddressFromPointerArray
	ld de, .return
	push de
	jp hl
.return
	pop de
	pop hl
	pop bc
	pop af
	ret

CustomListMenuHoverTextMethods:
	dw CheckLoadTmName
	dw CheckLoadTypes

GetListEntryID:
	ld a, [wListCount]
	and a
	jr z, .noText ;if the list is 0 entries, we only have CANCEL in the list, so don't load any TM info
	ld a, [wCurrentMenuItem]
	ld c, a
	ld a, [wListScrollOffset]
	add c
	ld c, a
	ld a, [wListCount]
	dec a
	cp c ; did the player select Cancel?
	jr c, .noText ; if so, don't display anything
	ld a, [wCurrentMenuItem]
	ld c, a
	ld a, [wListScrollOffset]
	add c
	ld c, a
	ld a, [wListMenuID]
	cp ITEMLISTMENU
	jr nz, .skipmulti 
	sla c ; item entries are 2 bytes long, so multiply by 2
.skipmulti
	ld a, [wListPointer]
	ld l, a
	ld a, [wListPointer + 1]
	ld h, a
	inc hl ; hl = beginning of list entries
	ld b, 0
	add hl, bc
	ld a, [hl] ; a = which item id it is now
	and a ; clear carry
	ret
.noText
	scf
	ret

CheckLoadTypes:
	call GetListEntryID
	jr c, .noText
	; a = which pokemon ID in the list is selected
	ld [wd0b5], a ; needed to make PrintMonType work
	ld a, 1
	ld [wListMenuHoverTextShown], a
	hlcoord 4, 13
	ld b, 3  ; height
	ld c, 14 ; width
	call TextBoxBorder
	callfar IsMonTypeRemapped
	ld a, $C0
	jr nc, .new
	ld a, $C2
.new
	hlcoord 5, 13
	ld [hli], a
	inc a
	ld [hl], a 
	hlcoord 5, 14
	ld de, MenuType1Text
	call PlaceString
	hlcoord 11, 14
	predef PrintMonType
	hlcoord 11, 16
	ld a, [hl]
	cp " "
	ret z ; if no type printed for the second type at this point, don't print "Type2:" on that line
	hlcoord 5, 16
	ld de, MenuType2Text
	jp PlaceString
.noText
	ld a, [wListMenuHoverTextShown]
	and a
	ret z
	hlcoord 4, 13
	lb bc, 16, 5
	predef LoadScreenTileAreaFromBuffer3
	call UpdateSprites
	xor a
	ld [wListMenuHoverTextShown], a
	ret

MenuType1Text:
	db "TYPE1:@"

MenuType2Text:
	db "TYPE2:@"

CustomListMenuHoverTextSaveScreenTileMethods:
	dw CheckSaveTMTextScreenTiles
	dw CheckSaveTypeTextScreenTiles

CheckSaveHoverTextScreenTiles::
	; wListMenuHoverTextType still loaded
	dec a
	add a
	ld hl, CustomListMenuHoverTextSaveScreenTileMethods
	call GetAddressFromPointerArray
	jp hl

CheckSaveTypeTextScreenTiles:
	; load some special tiles that are used when displaying this list menu
	ld hl, vChars1 tile $40
	ld de, OldNewTypes
	lb bc, BANK(OldNewTypes), 4
	call CopyVideoData
	; we need to save some tiles for later in case we display a TM text box above these tiles
	hlcoord 4, 13
	lb bc, 16, 5
	predef_jump SaveScreenTileAreaToBuffer3

CheckBadOffset::
	; in some cases we can end up near the end of the list with less than 3 entries showing like after depositing an item or pokemon
	; in this case we change the offset to avoid issues
	ld a, [wListCount] ; number of items in list, minus CANCEL (same value as max index value possible)
	cp 2
	ret c ; if less than 2 entries, no need to check
	; wListCount still loaded
	ld b, a ; wListCount in b
	ld a, [wListScrollOffset]
	and a
	ret z ; if scroll offset is 0, no need to check
	ld c, a
	ld a, b
	sub c
	cp 1
	jr z, .fixOffset
	ret
.fixOffset
	ld hl, wListScrollOffset
	dec [hl]
	ret

