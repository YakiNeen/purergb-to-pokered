; shinpokerednote: ADDED: this function handles quick-use of fishing and biking on pressing select.
; PureRGBnote: at the moment fishing with select is commented out since we've made it easier to select from the item menu the rod repeatedly.
CheckForRodBike::
	;callfar IsNextTileShoreOrWater	;unsets carry if player is facing water or shore
	;jr c, .nofishing
	;ld hl, TilePairCollisionsWater
	;call CheckForTilePairCollisions
	;jr c, .nofishing
	;are rods in the bag?
	;ld b, SUPER_ROD
	;push bc
	;call IsItemInBag
	;pop bc
	;jr nz, .start
	;ld b, GOOD_ROD
	;push bc
	;call IsItemInBag
	;pop bc
	;jr nz, .start
	;ld b, OLD_ROD
	;push bc
	;call IsItemInBag
	;pop bc
	;jr nz, .start

;.nofishing
	;do nothing if forced to ride bike
	ld a, [wd732]
	bit 5, a
	ret nz
	; do nothing if surfing
	ld a, [wWalkBikeSurfState]
	cp 2
	ret z
	;else check if bike is in bag
	ld b, BICYCLE
	push bc
	call IsItemInBag
	pop bc
	ret z

.start
	ld a, [wWalkBikeSurfState]
	cp 1
	jr z, .gotOff
	CheckEvent EVENT_SAW_GOT_ON_BIKE_TEXT
	jp z, PrepareText
	jr .sawText
.gotOff
	CheckEvent EVENT_SAW_GOT_OFF_BIKE_TEXT
	jp z, PrepareText
.sawText
	call IsBikeRidingAllowed
	jp nc, PrepareText
	call UseBike
	jp LoadPlayerSpriteGraphics ; instant bike usage

PrepareText:
	;initialize a text box without drawing anything special
	ld a, 1
	ld [wAutoTextBoxDrawingControl], a
	callfar DisplayTextIDInit

	call UseBike
	
	;use $ff value loaded into hSpriteIndexOrTextID to make DisplayTextID display nothing and close any text
	ld a, $FF
	ldh [hSpriteIndexOrTextID], a
	jp DisplayTextID

UseBike:
	;determine item to use
	ld a, BICYCLE
	ld [wcf91], a	;load item to be used
	ld [wd11e], a	;load item so its name can be grabbed
	call GetItemName	;get the item name into de register
	call CopyToStringBuffer ; copy name from de to wcf4b so it shows up in text
	jp UseItem	;use the item
	