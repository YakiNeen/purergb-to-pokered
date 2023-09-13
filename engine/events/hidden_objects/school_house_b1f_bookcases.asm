; PureRGBnote: ADDED: text for bookcases on the new basement floor of viridian city's schoolhouse

SchoolB1FLeftBookcaseA:
	ld a, 0
	jp DoBookcaseJump

SchoolB1FLeftBookcaseB:
	ld a, 1
	jp DoBookcaseJump

SchoolB1FRightBookcaseA:
	ld a, 2
	jp DoBookcaseJump

SchoolB1FRightBookcaseB:
	ld a, 3
	jp DoBookcaseJump

DoBookcaseJump:
	ld [wHiddenObjectFunctionArgument], a
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	tx_pre_jump ViridianSchoolB1FBookcasesTexts

ViridianSchoolB1FBookcasesTexts::
	text_asm
	ld a, [wHiddenObjectFunctionArgument]
	add a
	ld d, 0
	ld e, a
	ld hl, SchoolHouseB1FBookcaseTextPointers
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	rst _PrintText
	rst TextScriptEnd

SchoolHouseB1FBookcaseTextPointers:
	dw SchoolB1FLeftBookcaseAText
	dw SchoolB1FLeftBookcaseBText
	dw SchoolB1FRightBookcaseAText
	dw SchoolB1FRightBookcaseBText


SchoolB1FLeftBookcaseAText:
	text_far _SchoolB1FLeftBookcaseA
	text_far _FlippedToARandomPage
	text_far _SchoolB1FLeftBookcaseA2
	text_end

SchoolB1FLeftBookcaseBText:
	text_far _SchoolB1FLeftBookcaseB
	text_far _FlippedToARandomPage
	text_far _SchoolB1FLeftBookcaseB2
	text_end

SchoolB1FRightBookcaseAText:
	text_far _SchoolB1FRightBookcaseA
	text_far _FlippedToARandomPage
	text_far _SchoolB1FRightBookcaseA2
	text_end

SchoolB1FRightBookcaseBText:
	text_far _SchoolB1FRightBookcaseB
	text_far _FlippedToARandomPage
	text_far _SchoolB1FRightBookcaseB2
	text_end
