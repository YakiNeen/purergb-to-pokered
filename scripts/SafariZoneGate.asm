; PureRGBnote: ADDED: lots of code pertaining to the new safari zone game types.

SafariZoneGate_Script:
	call EnableAutoTextBoxDrawing
	ld hl, SafariZoneGate_ScriptPointers
	ld a, [wSafariZoneGateCurScript]
	jp CallFunctionInTable

SafariZoneGate_ScriptPointers:
	def_script_pointers
	dw_const SafariZoneGateDefaultScript,                SCRIPT_SAFARIZONEGATE_DEFAULT
	dw_const SafariZoneGatePlayerMovingRightScript,      SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_RIGHT
	dw_const SafariZoneGateWouldYouLikeToJoinScript,     SCRIPT_SAFARIZONEGATE_WOULD_YOU_LIKE_TO_JOIN
	dw_const SafariZoneGatePlayerMovingUpScript,         SCRIPT_SAFARIZONEGATE_PLAYER_MOVING
	dw_const SafariZoneGatePlayerMovingDownScript,       SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	dw_const SafariZoneGateLeavingSafariScript,          SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	dw_const SafariZoneGateSetScriptAfterMoveScript,     SCRIPT_SAFARIZONEGATE_SET_SCRIPT_AFTER_MOVE
	dw_const SafariZoneGateScript7,                      SCRIPT_SAFARIZONEGATE_7
	EXPORT SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI ; used by engine/events/hidden_objects/safari_game.asm

SafariZoneGateDefaultScript:
	ld hl, .PlayerNextToSafariZoneWorker1CoordsArray
	call ArePlayerCoordsInArray
	ret nc
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_1
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	xor a
	ldh [hJoyHeld], a
	ld a, SPRITE_FACING_RIGHT
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, [wCoordIndex]
	cp $1
	jr z, .player_not_next_to_worker
	ld a, SCRIPT_SAFARIZONEGATE_WOULD_YOU_LIKE_TO_JOIN
	ld [wSafariZoneGateCurScript], a
	ret
.player_not_next_to_worker
	ld a, D_RIGHT
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_RIGHT
	ld [wSafariZoneGateCurScript], a
	ret

.PlayerNextToSafariZoneWorker1CoordsArray:
	dbmapcoord  3,  2
	dbmapcoord  4,  2
	db -1 ; end

SafariZoneGatePlayerMovingRightScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
SafariZoneGateWouldYouLikeToJoinScript:
	xor a
	ldh [hJoyHeld], a
	ld [wJoyIgnore], a
	call UpdateSprites
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_WOULD_YOU_LIKE_TO_JOIN
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ret

SafariZoneGatePlayerMovingUpScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateLeavingSafariScript:
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	CheckAndResetEvent EVENT_SAFARI_GAME_OVER
	jr z, .leaving_early
	ResetEventReuseHL EVENT_IN_SAFARI_ZONE
	call UpdateSprites
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, [wSafariType]
	and a
	jr nz, .rangerHuntDone
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_GOOD_HAUL_COME_AGAIN
	jr .doneSafari
.rangerHuntDone
	ld a, [wNumSafariBalls] ; if wNumSafariBalls = 0 at the end of Ranger Hunt safari, we've defeated all rangers and won
	and a
	jr z, .rangerHuntSuccess
	ld a, TEXT_SAFARIZONEGATE_FAILED_RANGER_HUNT
	jr .doneSafari
.rangerHuntSuccess
	ld a, TEXT_SAFARIZONEGATE_RANGER_HUNT_SUCCESS
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wNumSafariBalls], a
	ld a, D_DOWN
	ld c, $2
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_7
	ld [wSafariZoneGateCurScript], a
	ret
.doneSafari
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wNumSafariBalls], a
	ld a, D_DOWN
	ld c, $3
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
	ret
.leaving_early
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_LEAVING_EARLY
	ldh [hSpriteIndexOrTextID], a
	jp DisplayTextID

SafariZoneGatePlayerMovingDownScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_DEFAULT
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateSetScriptAfterMoveScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	call Delay3
	ld a, [wcf0d]
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateScript7:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, $9
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, D_DOWN
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
	ret	

SafariZoneEntranceAutoWalk:
	push af
	ld b, 0
	ld a, c
	ld [wSimulatedJoypadStatesIndex], a
	ld hl, wSimulatedJoypadStatesEnd
	pop af
	call FillMemory
	jp StartSimulatingJoypadStates

SafariZoneGateReturnSimulatedJoypadStateScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret

SafariZoneGate_TextPointers:
	def_text_pointers
	dw_const SafariZoneGateSafariZoneWorker1Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1
	dw_const SafariZoneGateSafariZoneWorker2Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER2
	dw_const SafariZoneGateSafariZoneWorker1Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_1
	dw_const SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_WOULD_YOU_LIKE_TO_JOIN
	dw_const SafariZoneGateSafariZoneWorker1LeavingEarlyText,       TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_LEAVING_EARLY
	dw_const SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText,  TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_GOOD_HAUL_COME_AGAIN
	dw_const SafariZoneEntranceText7,                               TEXT_SAFARIZONEGATE_FAILED_RANGER_HUNT
	dw_const SafariZoneEntranceText8,                               TEXT_SAFARIZONEGATE_RANGER_HUNT_SUCCESS
	dw_const SafariZoneEntranceText9,                               TEXT_SAFARIZONEGATE_OWED_HYPER_BALL

SafariZoneEntranceText1Get:
	text_far _SafariZoneGateSafariZoneWorker1Text
	text_end

SafariZoneEntranceHyperBallOwedText:
	text_far _SafariZoneEntranceHyperBallOwedText
	text_end

SafariZoneGateSafariZoneWorker1Text:
	text_asm
	CheckEvent EVENT_OWED_HYPER_BALL
	jr nz, .owedHyperBall1
	jr .default1
.owedHyperBall1
	ld hl, SafariZoneEntranceHyperBallOwedText
	rst _PrintText
	jr .done1
.default1
	ld hl, SafariZoneEntranceText1Get
	rst _PrintText
.done1
	rst TextScriptEnd
	

SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinTextGet:
	text_far _SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText
	text_end	

SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText:
	text_asm
	CheckEvent EVENT_OWED_HYPER_BALL
	jr nz, .owedHyperBall4
	jr .default4
.owedHyperBall4
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	call GiveHyperBall
	jp .CantPayWalkDown
.default4
	ld hl, SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinTextGet
	rst _PrintText
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .PleaseComeAgain
	xor a
	ldh [hMoney], a
	ld a, $05
	ldh [hMoney + 1], a
	ld a, $00
	ldh [hMoney + 2], a
	call HasEnoughMoney
	jr nc, .success
	ld hl, .NotEnoughMoneyText
	rst _PrintText
	jr .CantPayWalkDown

.success
	xor a
	ld [wPriceTemp], a
	ld a, $05
	ld [wPriceTemp + 1], a
	ld a, $00
	ld [wPriceTemp + 2], a
	ld hl, wPriceTemp + 2
	ld de, wPlayerMoney + 2
	ld c, 3
	predef SubBCDPredef
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld hl, .MakePaymentText
	rst _PrintText
	call AskGameType
	jr c, .PleaseComeAgain ; if we cancelled, don't continue
	ld a, D_UP
	ld c, 3
	call SafariZoneEntranceAutoWalk
	SetEvent EVENT_IN_SAFARI_ZONE
	ResetEventReuseHL EVENT_SAFARI_GAME_OVER
	ResetEventRange EVENT_BEAT_SAFARI_ZONE_CENTER_RANGER_0, EVENT_BEAT_SAFARI_ZONE_WEST_TRAINER_4 ;reset all trainers in the safari zone so they can be battled again
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING
	ld [wSafariZoneGateCurScript], a
	jr .done
.PleaseComeAgain
	ld hl, PleaseComeAgainText
	rst _PrintText
.CantPayWalkDown
	ld a, D_DOWN
	ld c, 1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
.done
	rst TextScriptEnd

.MakePaymentText
	text_far _SafariZoneGateSafariZoneWorker1ThatllBe500PleaseText
	text_end

.NotEnoughMoneyText
	text_far _SafariZoneGateSafariZoneWorker1NotEnoughMoneyText
	text_end

SafariZoneGateSafariZoneWorker1LeavingEarlyText:
	text_far _SafariZoneGateSafariZoneWorker1LeavingEarlyText
	text_asm
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .not_ready_to_leave
	ld hl, .ReturnSafariBallsText
	rst _PrintText
	xor a
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, D_DOWN
	ld c, $3
	call SafariZoneEntranceAutoWalk
	ResetEvents EVENT_SAFARI_GAME_OVER, EVENT_IN_SAFARI_ZONE
	ld a, $0
	ld [wcf0d], a
	jr .set_current_script
.not_ready_to_leave
	ld hl, .GoodLuckText
	rst _PrintText
	ld a, SPRITE_FACING_UP
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, D_UP
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	ld [wcf0d], a
.set_current_script
	ld a, SCRIPT_SAFARIZONEGATE_SET_SCRIPT_AFTER_MOVE
	ld [wSafariZoneGateCurScript], a
	rst TextScriptEnd

.ReturnSafariBallsText
	text_far _SafariZoneGateSafariZoneWorker1ReturnSafariBallsText
	text_end

.GoodLuckText
	text_far _SafariZoneGateSafariZoneWorker1GoodLuckText
	text_end

SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText:
	text_far _SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText
	text_end

SafariZoneEntranceText7:
	text_far _RangerHuntDoneFailText
	text_end

SafariZoneEntranceText8:
	text_asm 
	ld hl, .RangerHuntDoneSuccessText
	rst _PrintText
	SetEvent EVENT_OWED_HYPER_BALL
	rst TextScriptEnd

.RangerHuntDoneSuccessText
	text_far _RangerHuntDoneSuccessText
	text_end

SafariZoneGateSafariZoneWorker2Text:
	text_asm
	ld hl, .FirstTimeHereText
	rst _PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .YoureARegularHereText
	jr nz, .print_text
	call AskGameTypeExplanation
	jr c, .noSelection
	rst TextScriptEnd
.noSelection
	ld hl, PleaseComeAgainText
.print_text
	rst _PrintText
	rst TextScriptEnd

.FirstTimeHereText
	text_far _SafariZoneGateSafariZoneWorker2FirstTimeHereText
	text_end

.YoureARegularHereText
	text_far _SafariZoneGateSafariZoneWorker2YoureARegularHereText
	text_end

SafariZoneEntranceText9:
	text_asm
	call GiveHyperBall
	rst TextScriptEnd

AskGameType:
	ld hl, SafariZoneEntranceWhatGame
	rst _PrintText
	ld hl, SafariTypeOptions
	ld b, A_BUTTON | B_BUTTON
	call DisplayMultiChoiceTextBox
	jr nz, .goodbye
	ld hl, TextPointers_SafariGames
	ld a, [wCurrentMenuItem]
	add a
	call GetAddressFromPointerArray
	rst _PrintText
	and a
	ret
.goodbye
	; give back the 500 that was just deducted
	ld de, wPlayerMoney + 2
	ld hl, hMoney + 2 ; total price of items
	ld c, 3 ; length of money in bytes
	predef AddBCDPredef ; add total price to money
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID ; redraw money text box
	scf
	ret

TextPointers_SafariGames:
	dw SafariClassicPaidInfo
	dw SafariRangerHuntPaidInfo
	dw SafariFreeRoamPaidInfo

SafariZoneEntranceWhatGame:
	text_far _SafariZoneEntranceWhatGame
	text_end

PleaseComeAgainText:
	text_far _SafariZoneGateSafariZoneWorker1PleaseComeAgainText
	text_end

SafariClassicPaidInfo:
	text_asm
	ld hl, SafariZoneClassicText
	rst _PrintText
	ld hl, SafariZoneEntranceSafariBallsReceived
	rst _PrintText
	ld hl, SafariZonePAText
	rst _PrintText
	ld a, 30
	ld [wNumSafariBalls], a
	ld a, HIGH(702)
	ld [wSafariSteps], a
	ld a, LOW(702)
	ld [wSafariSteps + 1], a
	ld a, SAFARI_TYPE_CLASSIC
	ld [wSafariType], a
	call HideAllTrainers
	rst TextScriptEnd

SafariRangerHuntPaidInfo:
	text_asm
	ld hl, SafariZoneRangerHunt
	rst _PrintText
	ld hl, SafariZonePATextNoBalls
	rst _PrintText
	ld a, 5
	ld [wNumSafariBalls], a ; Number of Rangers (reused Safari Ball flag)
	ld a, HIGH(702)
	ld [wSafariSteps], a
	ld a, LOW(702)
	ld [wSafariSteps + 1], a
	ld a, SAFARI_TYPE_RANGER_HUNT
	ld [wSafariType], a
	call ShowAllTrainers
	rst TextScriptEnd

SafariFreeRoamPaidInfo:
	text_asm
	ld hl, SafariZoneFreeRoam
	rst _PrintText
	xor a
	ld [wNumSafariBalls], a
	ld a, SAFARI_TYPE_FREE_ROAM
	ld [wSafariType], a
	call ShowAllTrainers
	call HideRangers
	rst TextScriptEnd

SafariZoneClassicText:
	text_far _SafariZoneClassic
	text_end

SafariZoneEntranceSafariBallsReceived:
	text_far _SafariZoneEntranceSafariBallsReceived
	sound_get_item_1
	text_end

SafariZonePAText:
	text_far _SafariZoneEntranceText_75360
	text_end

SafariZoneRangerHunt:
	text_far _SafariZoneRangerHunt
	text_end

SafariZoneFreeRoam:
	text_far _SafariZoneFreeRoam
	text_end

SafariZonePATextNoBalls:
	text_far _SafariZonePATextNoBalls
	text_end

GiveHyperBall:
	lb bc, ITEM_RANGER_HUNT_COMPLETION_PRIZE_NEW, 1
	call GiveItem
	jr nc, .BagFull
	ld hl, ReceivedHyperBallText
	rst _PrintText
	ResetEvent EVENT_OWED_HYPER_BALL
	jr .done
.BagFull
	ld hl, HyperBallNoRoomText
	rst _PrintText
	jr .done
.done
	ret

ReceivedHyperBallText:
	text_far _ReceivedHyperBallText
	sound_get_key_item
	text_end

HyperBallNoRoomText:
	text_far _PewterGymTM34NoRoomText
	text_end

HideShowRangers:
	db HS_SAFARI_ZONE_NORTH_RANGER_0
	db HS_SAFARI_ZONE_WEST_RANGER_0
	db HS_SAFARI_ZONE_WEST_RANGER_1
	db HS_SAFARI_ZONE_CENTER_RANGER_0
	db HS_SAFARI_ZONE_EAST_RANGER_0
	db -1 ; end

HideShowTrainers:
	db HS_SAFARI_ZONE_EAST_RANGER_0     
	db HS_SAFARI_ZONE_EAST_TRAINER_0    
	db HS_SAFARI_ZONE_EAST_TRAINER_1    
	db HS_SAFARI_ZONE_EAST_TRAINER_2    
	db HS_SAFARI_ZONE_EAST_TRAINER_3    
	db HS_SAFARI_ZONE_NORTH_RANGER_0    
	db HS_SAFARI_ZONE_NORTH_TRAINER_0   
	db HS_SAFARI_ZONE_NORTH_TRAINER_1   
	db HS_SAFARI_ZONE_NORTH_TRAINER_2   
	db HS_SAFARI_ZONE_NORTH_TRAINER_3   
	db HS_SAFARI_ZONE_NORTH_TRAINER_4   
	db HS_SAFARI_ZONE_WEST_RANGER_0    
	db HS_SAFARI_ZONE_WEST_RANGER_1    
	db HS_SAFARI_ZONE_WEST_TRAINER_0   
	db HS_SAFARI_ZONE_WEST_TRAINER_1   
	db HS_SAFARI_ZONE_WEST_TRAINER_2   
	db HS_SAFARI_ZONE_WEST_TRAINER_3   
	db HS_SAFARI_ZONE_WEST_TRAINER_4   
	db HS_SAFARI_ZONE_CENTER_RANGER_0     
	db HS_SAFARI_ZONE_CENTER_TRAINER_0    
	db HS_SAFARI_ZONE_CENTER_TRAINER_1    
	db HS_SAFARI_ZONE_CENTER_TRAINER_2    
	db HS_SAFARI_ZONE_CENTER_TRAINER_3
	db -1 ; end 

ShowAllTrainers:
	ld hl, HideShowTrainers         ; table items to hide
	; fall through
ShowAllHl:
.loop
	ld a, [hli]                  ; read move from move table
	cp -1
	ret z
	ld [wMissableObjectIndex], a
	push hl
	predef ShowExtraObject
	pop hl
	jr .loop


HideAllTrainers:
	ld hl, HideShowTrainers         ; table items to hide
	jr HideAllHl

HideRangers:
	ld hl, HideShowRangers
	; fall through
HideAllHl:
.loop
	ld a, [hli]                  ; read move from move table
	cp -1
	ret z
	ld [wMissableObjectIndex], a
	push hl
	predef HideExtraObject
	pop hl
	jr .loop

AskGameTypeExplanation:
	ld hl, SafariZoneHelp
	rst _PrintText
	ld hl, SafariTypeOptions
	ld b, A_BUTTON | B_BUTTON
	call DisplayMultiChoiceTextBox
	jr nz, .goodbye
	ld hl, TextPointers_SafariExplanations
	ld a, [wCurrentMenuItem]
	add a
	call GetAddressFromPointerArray
	rst _PrintText
	and a
	ret
.goodbye
	scf
	ret

TextPointers_SafariExplanations:
	dw ExplanationText
	dw SafariZoneRangerHunt
	dw SafariZoneFreeRoam

SafariZoneHelp:
	text_far _SafariZoneHelp
	text_end

ExplanationText:
	text_far _SafariZoneGateSafariZoneWorker2SafariZoneExplanationText
	text_end