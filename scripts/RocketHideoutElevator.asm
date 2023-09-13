RocketHideoutElevator_Script:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	push hl
	call nz, RocketHideoutElevatorGetWarpsScript
	pop hl
	bit 7, [hl]
	res 7, [hl]
	call nz, RocketHideoutElevatorShakeScript
	xor a
	ld [wAutoTextBoxDrawingControl], a
	inc a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret

RocketHideoutElevatorGetWarpsScript:
	ld hl, wWarpEntries
	ld a, [wWarpedFromWhichWarp]
	ld b, a
	ld a, [wWarpedFromWhichMap]
	ld c, a
	call .SetWarpEntries

.SetWarpEntries:
	inc hl
	inc hl
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ret

RocketHideoutElevatorScript:
	ld hl, RocketHideoutElavatorFloors
	call LoadItemList
	ld hl, RocketHideoutElevatorWarpMaps
	ld de, wElevatorWarpMaps
	ld bc, RocketHideoutElevatorWarpMapsEnd - RocketHideoutElevatorWarpMaps
	call CopyData
	ret

RocketHideoutElavatorFloors:
	db 3 ; #
	db FLOOR_B1F
	db FLOOR_B2F
	db FLOOR_B4F
	db -1 ; end

; These specify where the player goes after getting out of the elevator.
RocketHideoutElevatorWarpMaps:
	; warp number, map id
	db 4, ROCKET_HIDEOUT_B1F
	db 4, ROCKET_HIDEOUT_B2F
	db 2, ROCKET_HIDEOUT_B4F
RocketHideoutElevatorWarpMapsEnd:

RocketHideoutElevatorShakeScript:
	call Delay3
	farcall ShakeElevator
	ret

RocketHideoutElevator_TextPointers:
	def_text_pointers
	dw_const RocketHideoutElevatorText, TEXT_ROCKETHIDEOUTELEVATOR

RocketHideoutElevatorText:
	text_asm
	ld b, LIFT_KEY
	call IsItemInBag
	jr z, .no_key
	call RocketHideoutElevatorScript
	ld hl, RocketHideoutElevatorWarpMaps
	predef DisplayElevatorFloorMenu
	jr .text_script_end
.no_key
	ld hl, .AppearsToNeedKeyText
	call PrintText
.text_script_end
	jp TextScriptEnd

.AppearsToNeedKeyText:
	text_far _RocketHideoutElevatorAppearsToNeedKeyText
	text_waitbutton
	text_end
