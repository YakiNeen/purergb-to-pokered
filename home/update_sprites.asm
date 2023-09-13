UpdateSprites::
	ld a, [wUpdateSpritesEnabled]
	dec a
	ret nz
	ld hl, hFlagsFFFA
	set 0, [hl]	;shinpokerednote: FIXED: do not allow OAM updates  in vblank while updating sprites
	homecall _UpdateSprites
	ld hl, hFlagsFFFA
	res 0, [hl] ;shinpokerednote: FIXED: allow OAM updates again
	ret
