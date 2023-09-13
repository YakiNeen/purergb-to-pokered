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
	rst _CopyData
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
;;;;;;;;;; PureRGBnote: CHANGED: lift key is consumed upon unlocking the elevator, making it usable permanently 
	CheckEvent EVENT_USED_LIFT_KEY 
	jr nz, .startLift
	ld b, LIFT_KEY
	predef GetIndexOfItemInBag
	ld a, b
	cp $FF ; not in bag
	jr z, .no_key
	; if we have the LIFT_KEY, remove it from bag and unlock the elevator forever
	ld [wWhichPokemon], a ; load item index to be removed
	ld hl, wNumBagItems
	ld a, 1 ; one item
	ld [wItemQuantity], a
	call RemoveItemFromInventory
	SetEvent EVENT_USED_LIFT_KEY
    ld a, SFX_SWITCH
    rst _PlaySound
    call WaitForSoundToFinish
	ld hl, .UnlockedElevatorText
	rst _PrintText
.startLift
;;;;;;;;;;
	call RocketHideoutElevatorScript
	ld hl, RocketHideoutElevatorWarpMaps
	predef DisplayElevatorFloorMenu
	jr .text_script_end
.no_key
	ld hl, .AppearsToNeedKeyText
	rst _PrintText
.text_script_end
	rst TextScriptEnd

.UnlockedElevatorText:
	text_far _UnlockedElevatorText
	text_end

.AppearsToNeedKeyText:
	text_far _RocketHideoutElevatorAppearsToNeedKeyText
	text_waitbutton
	text_end
