GiveItem::
; Give player quantity c of item b,
; and copy the item's name to wStringBuffer.
; Return carry on success.
	ld a, b
	ld [wd11e], a
	ld [wcf91], a
	ld a, c
	ld [wItemQuantity], a
	ld hl, wNumBagItems
	call AddItemToInventory
	ret nc
	call GetItemName
	call CopyToStringBuffer
	scf
	ret

; PureRGBnote: ADDED: when giving a pokemon we can make it alternate palette by calling a different function
GivePokemonAltPalette::
	ld a, 1
	jr GivePokemonCommon
GivePokemon::
; Give the player monster b at level c.
	xor a
GivePokemonCommon:
	ld [wIsAltPalettePkmnData], a
	ld a, b
	ld [wcf91], a
	ld a, c
	ld [wCurEnemyLVL], a
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	farjp _GivePokemon
