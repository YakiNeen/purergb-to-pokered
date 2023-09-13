JumpMoveEffect:
	call _JumpMoveEffect
	ld b, $1
	ret

_JumpMoveEffect:
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveEffect]
	jr z, .next1
	ld a, [wEnemyMoveEffect]
.next1
	dec a ; subtract 1, there is no special effect for 00
	add a ; x2, 16bit pointers
	ld hl, MoveEffectPointerTable
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl ; jump to special effect handler

INCLUDE "data/moves/effects_pointers.asm"

SleepEffect:
	ld de, wEnemyMonStatus
	ld bc, wEnemyBattleStatus2
	ldh a, [hWhoseTurn]
	and a
	jp z, .sleepEffect
	ld de, wBattleMonStatus
	ld bc, wPlayerBattleStatus2

.sleepEffect
	ld a, [bc]
	bit NEEDS_TO_RECHARGE, a ; does the target need to recharge? (hyper beam)
	res NEEDS_TO_RECHARGE, a ; target no longer needs to recharge
	ld [bc], a
	jr nz, .setSleepCounter ; if the target had to recharge, all hit tests will be skipped
	                        ; including the event where the target already has another status
	ld a, [de]
	ld b, a
	and $7
	jr z, .notAlreadySleeping ; can't affect a mon that is already asleep
	ld hl, AlreadyAsleepText
	jp PrintText
.notAlreadySleeping
	ld a, b
	and a
	jr nz, .didntAffect ; can't affect a mon that is already statused
	push de
	call MoveHitTest ; apply accuracy tests
	pop de
	ld a, [wMoveMissed]
	and a
	jr nz, .didntAffect
.setSleepCounter
; set target's sleep counter to a random number between 1 and 7
	call BattleRandom
	and $7
	jr z, .setSleepCounter
	ld [de], a
	call PlayCurrentMoveAnimation2
	ld hl, FellAsleepText
	jp PrintText
.didntAffect
	jp PrintDidntAffectText

FellAsleepText:
	text_far _FellAsleepText
	text_end

AlreadyAsleepText:
	text_far _AlreadyAsleepText
	text_end

PoisonEffect:
	ld hl, wEnemyMonStatus
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .poisonEffect
	ld hl, wBattleMonStatus
	ld de, wEnemyMoveEffect
.poisonEffect
	call CheckTargetSubstitute
	jr nz, .noEffect ; can't poison a substitute target
	ld a, [hli]
	ld b, a
	and a
	jr nz, .noEffect ; miss if target is already statused
	ld a, [hli]
	cp POISON ; can't poison a poison-type target
	jr z, .noEffect
	ld a, [hld]
	cp POISON ; can't poison a poison-type target
	jr z, .noEffect
	ld a, [de]
	cp POISON_SIDE_EFFECT1
	ld b, 20 percent + 1 ; chance of poisoning
	jr z, .sideEffectTest
	cp POISON_SIDE_EFFECT2
	ld b, 40 percent + 1 ; chance of poisoning
	jr z, .sideEffectTest
	push hl
	push de
	call MoveHitTest ; apply accuracy tests
	pop de
	pop hl
	ld a, [wMoveMissed]
	and a
	jr nz, .didntAffect
	jr .inflictPoison
.sideEffectTest
	call BattleRandom
	cp b ; was side effect successful?
	ret nc
.inflictPoison
	dec hl
	set 3, [hl] ; mon is now poisoned
	push de
	dec de
	ldh a, [hWhoseTurn]
	and a
	ld b, SHAKE_SCREEN_ANIM
	ld hl, wPlayerBattleStatus3
	ld a, [de]
	ld de, wPlayerToxicCounter
	jr nz, .ok
	ld b, SHAKE_ENEMY_HUD_ANIM
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
.ok
	cp TOXIC
	jr nz, .normalPoison ; done if move is not Toxic
	set BADLY_POISONED, [hl] ; else set Toxic battstatus
	xor a
	ld [de], a
	ld hl, BadlyPoisonedText
	jr .continue
.normalPoison
	ld hl, PoisonedText
.continue
	pop de
	ld a, [de]
	cp POISON_EFFECT
	jr z, .regularPoisonEffect
	ld a, b
	call PlayBattleAnimation2
	jp PrintText
.regularPoisonEffect
	call PlayCurrentMoveAnimation2
	jp PrintText
.noEffect
	ld a, [de]
	cp POISON_EFFECT
	ret nz
.didntAffect
	ld c, 50
	rst _DelayFrames
	jp PrintDidntAffectText

PoisonedText:
	text_far _PoisonedText
	text_end

BadlyPoisonedText:
	text_far _BadlyPoisonedText
	text_end

DrainHPEffect:
	jpfar DrainHPEffect_

;ExplodeEffect:
;	ld hl, wBattleMonHP
;	ld de, wPlayerBattleStatus2
;	ldh a, [hWhoseTurn]
;	and a
;	jr z, .faintUser
;	ld hl, wEnemyMonHP
;	ld de, wEnemyBattleStatus2
;.faintUser
;	xor a
;	ld [hli], a ; set the mon's HP to 0
;	ld [hli], a
;	inc hl
;	ld [hl], a ; set mon's status to 0
;	ld a, [de]
;	res SEEDED, a ; clear mon's leech seed status
;	ld [de], a
;	ret

FreezeBurnParalyzeEffect:
	xor a
	ld [wAnimationType], a
	call CheckTargetSubstitute ; test bit 4 of d063/d068 flags [target has substitute flag]
	ret nz ; return if they have a substitute, can't effect them
	ldh a, [hWhoseTurn]
	and a
	jp nz, .opponentAttacker
	ld a, [wEnemyMonStatus]
	and a
	jp nz, CheckDefrost ; can't inflict status if opponent is already statused

;;;;;;;;;; PureRGBnote: CHANGED: ADDED: tweak how some moves behave when applying burn/freeze/paralyze status

	ld a, [wPlayerMoveNum]
	cp SOLARBEAM
	ld b, FIRE ; NEW: solarbeam can't burn fire types
	jr z, .doComparison1

	ld a, [wPlayerMoveType]
	cp NORMAL ; NEW: body slam can apply status to any pokemon type
	jr z, .skipTypeComparison1
	cp BUG ; NEW: vicegrip can apply status to any pokemon type
	jr z, .skipTypeComparison1
	ld b, a
.doComparison1
;;;;;;;;;;
	ld a, [wEnemyMonType1]
	cp b ; do target type 1 and move type match?
	ret z  ; return if they match (an ice move can't freeze an ice-type etc.)
	ld a, [wEnemyMonType2]
	cp b ; do target type 2 and move type match?
	ret z  ; return if they match
.skipTypeComparison1
	ld a, [wPlayerMoveEffect]
	cp PARALYZE_SIDE_EFFECT1 + 1
	ld b, 10 percent + 1
	jr c, .regular_effectiveness
; extra effectiveness
	ld b, 30 percent + 1
	sub BURN_SIDE_EFFECT2 - BURN_SIDE_EFFECT1 ; treat extra effective as regular from now on
.regular_effectiveness
	push af
	call BattleRandom ; get random 8bit value for probability test
	cp b
	pop bc
	ret nc ; do nothing if random value is >= 1A or 4D [no status applied]
	ld a, b ; what type of effect is this?
	cp BURN_SIDE_EFFECT1
	jr z, .burn1
	cp FREEZE_SIDE_EFFECT
	jr z, .freeze1
; .paralyze1
	ld a, 1 << PAR
	ld [wEnemyMonStatus], a
	call QuarterSpeedDueToParalysis ; quarter speed of affected mon
	ld a, SHAKE_ENEMY_HUD_ANIM
	call PlayBattleAnimation
	jp PrintMayNotAttackText ; print paralysis text
.burn1
	ld a, 1 << BRN
	ld [wEnemyMonStatus], a
	call HalveAttackDueToBurn ; halve attack of affected mon
	ld a, SHAKE_ENEMY_HUD_ANIM
	call PlayBattleAnimation
	jp PrintBurnText
.freeze1
	call ClearHyperBeam ; resets hyper beam (recharge) condition from target
	ld a, 1 << FRZ
	ld [wEnemyMonStatus], a
	ld a, SHAKE_ENEMY_HUD_ANIM
	call PlayBattleAnimation
	jp PrintFrozenText
.opponentAttacker
	ld a, [wBattleMonStatus] ; mostly same as above with addresses swapped for opponent
	and a
	jp nz, CheckDefrost

;;;;;;;;;; PureRGBnote: CHANGED: ADDED: tweak how some moves behave when applying burn/freeze/paralyze status
	ld a, [wEnemyMoveNum]
	cp SOLARBEAM
	ld b, FIRE ; NEW: solarbeam can't burn fire types
	jr z, .doComparison2
	
	ld a, [wEnemyMoveType]
	cp NORMAL ; NEW: body slam can apply status to any pokemon type
	jr z, .skipTypeComparison2
	cp BUG ; NEW: vicegrip can apply status to any pokemon type
	jr z, .skipTypeComparison2
	ld b, a
.doComparison2
;;;;;;;;;;
	ld a, [wBattleMonType1]
	cp b
	ret z
	ld a, [wBattleMonType2]
	cp b
	ret z
.skipTypeComparison2
	ld a, [wEnemyMoveEffect]
	cp PARALYZE_SIDE_EFFECT1 + 1
	ld b, 10 percent + 1
	jr c, .regular_effectiveness2
; extra effectiveness
	ld b, 30 percent + 1
	sub BURN_SIDE_EFFECT2 - BURN_SIDE_EFFECT1 ; treat extra effective as regular from now on
.regular_effectiveness2
	push af
	call BattleRandom
	cp b
	pop bc
	ret nc
	ld a, b
	cp BURN_SIDE_EFFECT1
	jr z, .burn2
	cp FREEZE_SIDE_EFFECT
	jr z, .freeze2
; .paralyze2
	ld a, 1 << PAR
	ld [wBattleMonStatus], a
	call QuarterSpeedDueToParalysis
	jp PrintMayNotAttackText
.burn2
	ld a, 1 << BRN
	ld [wBattleMonStatus], a
	call HalveAttackDueToBurn
	jp PrintBurnText
.freeze2
; hyper beam bits aren't reset for opponent's side
	ld a, 1 << FRZ
	ld [wBattleMonStatus], a
	jp PrintFrozenText

PrintBurnText:
	ld hl, BurnedText
	jp PrintText

BurnedText:
	text_far _BurnedText
	text_end

PrintFrozenText:
	ld hl, FrozenText
	jp PrintText

FrozenText:
	text_far _FrozenText
	text_end

CheckDefrost:
; any fire-type move that has a chance inflict burn (all but Fire Spin) will defrost a frozen target
	and 1 << FRZ ; are they frozen?
	ret z ; return if so
	ldh a, [hWhoseTurn]
	and a
	jr nz, .opponent
	;player [attacker]
	ld a, [wPlayerMoveType]
	sub FIRE
	ret nz ; return if type of move used isn't fire
	ld [wEnemyMonStatus], a ; set opponent status to 00 ["defrost" a frozen monster]
	ld hl, wEnemyMon1Status
	ld a, [wEnemyMonPartyPos]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	xor a
	ld [hl], a ; clear status in roster
	ld hl, FireDefrostedText
	jr .common
.opponent
	ld a, [wEnemyMoveType] ; same as above with addresses swapped
	sub FIRE
	ret nz
	ld [wBattleMonStatus], a
	ld hl, wPartyMon1Status
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	xor a
	ld [hl], a
	ld hl, FireDefrostedText
.common
	rst _PrintText
	farjp CheckDefrostMove


FireDefrostedText:
	text_far _FireDefrostedText
	text_end

; PureRGBnote: ADDED: increases attack, special, and speed as a move effect. Used with Meditate.
AttackSpecialSpeedUpEffect:
	;values for the enemy's turn
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .next
	; values for the player's turn
	ld de, wEnemyMoveEffect
.next
	ld a, SPECIAL_UP1_EFFECT
	ld [de], a
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_UP_SIDE_EFFECT
	ld [de], a ; we do the side effect for the second+third stat because it won't run the animation
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, SPEED_UP_SIDE_EFFECT
	ld [de], a 
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_SPECIAL_SPEED_UP1
	ld [de], a
	ret

; PureRGBnote: ADDED: increases both attack and defense as a move effect, used with bide
AttackDefenseUpEffect:
	;values for the enemy's turn
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .next
	; values for the player's turn
	ld de, wEnemyMoveEffect
.next
	ld a, DEFENSE_UP1_EFFECT
	ld [de], a
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_UP_SIDE_EFFECT
	ld [de], a ; we do the side effect for the second stat because it won't run the animation
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_DEFENSE_UP1_EFFECT
	ld [de], a
	ret

; PureRGBnote: ADDED: increases both accuracy and attack as a move effect, used with sharpen
AccuracyAttackUpEffect:
	;values for the enemy's turn
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .next
	; values for the player's turn
	ld de, wEnemyMoveEffect
.next
	ld a, ACCURACY_UP1_EFFECT
	ld [de], a
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_UP_SIDE_EFFECT
	ld [de], a ; we do the side effect for the second stat because it won't run the animation
	push de
	call StatModifierUpEffect ; stat modifier raising function
	pop de
	ld a, ATTACK_ACCURACY_UP1_EFFECT
	ld [de], a
	ret

StatModifierUpEffect:
	ld hl, wPlayerMonStatMods
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .statModifierUpEffect
	ld hl, wEnemyMonStatMods
	ld de, wEnemyMoveEffect
.statModifierUpEffect
	ld a, [de]
;;;;;;;;;; PureRGBnote: ADDED: need to decide which stat is being modified here and store it so we can apply correct badge boosts if necessary
	push af
	call MapEffectToStat
	ld [wWhatStat], a
	pop af
	call MapSideEffectToStatMod
	cp $ff
	jr z, .loadDefault
	jr .continue 
.loadDefault
	ld a, [de]
.continue
	ld d, a
;;;;;;;;;;
	sub ATTACK_UP1_EFFECT
	cp EVASION_UP1_EFFECT + $3 - ATTACK_UP1_EFFECT ; covers all +1 effects
	jr c, .incrementStatMod
	sub ATTACK_UP2_EFFECT - ATTACK_UP1_EFFECT ; map +2 effects to equivalent +1 effect
.incrementStatMod
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	inc b ; increment corresponding stat mod
	ld a, $d
	cp b ; can't raise stat past +6 ($d or 13)
	jp c, PrintNothingHappenedText
;;;;;;;;;; PureRGBnote: ADDED: need to decide which stat is being modified here and store it so we can apply correct badge boosts if necessary
	ld a, d ; remapped stat mod
;;;;;;;;;;
	cp ATTACK_UP1_EFFECT + $8 ; is it a +2 effect?
	jr c, .ok
	inc b ; if so, increment stat mod again
	ld a, $d
	cp b ; unless it's already +6
	jr nc, .ok
	ld b, a
.ok
	ld [hl], b
	ld a, c
	cp $4
	jr nc, UpdateStatDone ; jump if mod affected is evasion/accuracy
	push hl
	ld hl, wBattleMonAttack + 1
	ld de, wPlayerMonUnmodifiedAttack
	ldh a, [hWhoseTurn]
	and a
	jr z, .pointToStats
	ld hl, wEnemyMonAttack + 1
	ld de, wEnemyMonUnmodifiedAttack
.pointToStats
	push bc
	sla c
	ld b, $0
	add hl, bc ; hl = modified stat
	ld a, c
	add e
	ld e, a
	jr nc, .checkIf999
	inc d ; de = unmodified (original) stat
.checkIf999
	pop bc
	; check if stat is already 999
	ld a, [hld]
	sub LOW(MAX_STAT_VALUE)
	jr nz, .recalculateStat
	ld a, [hl]
	sbc HIGH(MAX_STAT_VALUE)
	jp z, RestoreOriginalStatModifier
.recalculateStat ; recalculate affected stat
                 ; paralysis and burn penalties, as well as badge boosts are ignored
	push hl
	push bc
	ld hl, StatModifierRatios
	dec b
	sla b
	ld c, b
	ld b, $0
	add hl, bc
	pop bc
	xor a
	ldh [hMultiplicand], a
	ld a, [de]
	ldh [hMultiplicand + 1], a
	inc de
	ld a, [de]
	ldh [hMultiplicand + 2], a
	ld a, [hli]
	ldh [hMultiplier], a
	call Multiply
	ld a, [hl]
	ldh [hDivisor], a
	ld b, $4
	call Divide
	pop hl
; cap at MAX_STAT_VALUE (999)
	ldh a, [hProduct + 3]
	sub LOW(MAX_STAT_VALUE)
	ldh a, [hProduct + 2]
	sbc HIGH(MAX_STAT_VALUE)
	jp c, UpdateStat
	ld a, HIGH(MAX_STAT_VALUE)
	ldh [hMultiplicand + 1], a
	ld a, LOW(MAX_STAT_VALUE)
	ldh [hMultiplicand + 2], a

UpdateStat:
	ldh a, [hProduct + 2]
	ld [hli], a
	ldh a, [hProduct + 3]
	ld [hl], a
	pop hl
UpdateStatDone:
	ld b, c
	inc b
	call PrintStatText
	ld hl, wPlayerBattleStatus2
	ld de, wPlayerMoveNum
	ld bc, wPlayerMonMinimized
	ldh a, [hWhoseTurn]
	and a
	jr z, .playerTurn
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyMoveNum
	ld bc, wEnemyMonMinimized
.playerTurn
;;;;;;;;;; PureRGBnote: ADDED: certain stat modifiers don't need to do the animation here
	push de
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .playerTurn2
	ld de, wEnemyMoveEffect
.playerTurn2
	ld a, [de]
	pop de
	cp ATTACK_UP_SIDE_EFFECT
	jr z, .skipAnimation
	cp SPEED_UP_SIDE_EFFECT
	jr z, .skipAnimation
;;;;;;;;;;
	ld a, [de]
	cp MINIMIZE
	jr nz, .notMinimize
 ; if a substitute is up, slide off the substitute and show the mon pic before
 ; playing the minimize animation
	bit HAS_SUBSTITUTE_UP, [hl]
	push af
	push bc
	ld hl, HideSubstituteShowMonAnim
	ld b, BANK(HideSubstituteShowMonAnim)
	push de
	call nz, Bankswitch
	pop de
.notMinimize
	call PlayCurrentMoveAnimation
.skipAnimation
	ld a, [de]
	cp MINIMIZE
	jr nz, .applyBadgeBoostsAndStatusPenalties
	pop bc
	ld a, $1
	ld [bc], a
	ld hl, ReshowSubstituteAnim
	ld b, BANK(ReshowSubstituteAnim)
	pop af
	call nz, Bankswitch
.applyBadgeBoostsAndStatusPenalties
	ldh a, [hWhoseTurn]
	and a
	call z, ApplyBadgeBoostsForSpecificStat ; whenever the player uses a stat-up move, badge boosts get reapplied again to every stat,
	                             ; even to those not affected by the stat-up move (will be boosted further)
	                             ; PureRGBnote: FIXED: badge boosts only applied to the specific stat being modified
	ld hl, MonsStatsRoseText
	rst _PrintText

; these always run on the opponent, and run regardless of what stat was modified
;;;;;;;;;;; PureRGBnote: FIXED: These ran on the opponent's stats erroneously
;;;;;;;;;;; PureRGBnote: FIXED: These only run if the specific stat burn or paralyze affect is being modified
	ldh a, [hWhoseTurn]
	push af
	xor 1 ; flip the turn temporarily to make these run on whoever's turn it currently is instead of the opponent correctly
	ldh [hWhoseTurn], a
	ld a, [wWhatStat]
	cp MOD_SPEED
	call z, QuarterSpeedDueToParalysis ; apply speed penalty to the player whose turn it is, if it's paralyzed
	ld a, [wWhatStat]
	cp MOD_ATTACK
	call z, HalveAttackDueToBurn ; apply attack penalty to the player whose turn it is, if it's burned
	pop af
	ldh [hWhoseTurn], a
	ld a, $ff
	ld [wWhatStat], a ; no longer modifying a stat
	ret
;;;;;;;;;;

RestoreOriginalStatModifier:
	pop hl
	dec [hl]

PrintNothingHappenedText:
	ld hl, NothingHappenedText
	jp PrintText

MonsStatsRoseText:
	text_far _MonsStatsRoseText
	text_asm
	ld hl, GreatlyRoseText
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveEffect]
	jr z, .playerTurn
	ld a, [wEnemyMoveEffect]
.playerTurn
;;;;;;;;;; PureRGBnote: ADDED: these specific effects don't use "greatly rose" text
	cp ATTACK_UP_SIDE_EFFECT
	jp z, .rose
	cp SPEED_UP_SIDE_EFFECT
	jp z, .rose
;;;;;;;;;;
	cp ATTACK_DOWN1_EFFECT
	ret nc
.rose
	ld hl, RoseText
	ret

GreatlyRoseText:
	text_pause
	text_far _GreatlyRoseText
; fallthrough
RoseText:
	text_far _RoseText
	text_end

StatModifierDownEffect:
	ld hl, wEnemyMonStatMods
	ld de, wPlayerMoveEffect
	ld bc, wEnemyBattleStatus1
	ldh a, [hWhoseTurn]
	and a
	jr z, .statModifierDownEffect
	ld hl, wPlayerMonStatMods
	ld de, wEnemyMoveEffect
	ld bc, wPlayerBattleStatus1
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .statModifierDownEffect
;;;;;;;;;; PureRGBnote: ADDED: after obtaining the thunderbadge, remove the 25% miss rate for opponents using stat down moves
	ld a, [wObtainedBadges]
	bit BIT_THUNDERBADGE, a
	jr nz, .statModifierDownEffect
;;;;;;;;;;
	; hardcoded 25% miss rate for opponents using stat down effect moves (feature in the original game) 
	call BattleRandom
	cp 25 percent + 1 ; chance to miss by in regular battle
	jp c, MoveMissed
.statModifierDownEffect
	call CheckTargetSubstitute ; can't hit through substitute
	jp nz, MoveMissed
	ld a, [de]
;;;;;;;;;; PureRGBnote: ADDED: need to decide which stat is being modified here and store it so we can apply correct badge boosts if necessary
	call MapEffectToStat
	ld [wWhatStat], a
	ld a, [de]
;;;;;;;;;;
	cp ATTACK_DOWN_SIDE_EFFECT
	jr c, .nonSideEffect
	call BattleRandom
	cp 33 percent + 1 ; chance for side effects
	jp nc, CantLowerAnymore
	ld a, [de]
	sub ATTACK_DOWN_SIDE_EFFECT ; map each stat to 0-3
	jr .decrementStatMod
.nonSideEffect ; non-side effects only
	push hl
	push de
	push bc
	call MoveHitTest ; apply accuracy tests
	pop bc
	pop de
	pop hl
	ld a, [wMoveMissed]
	and a
	jp nz, MoveMissed
	ld a, [bc]
	bit INVULNERABLE, a ; fly/dig
	jp nz, MoveMissed
	ld a, [de]
	sub ATTACK_DOWN1_EFFECT
	cp EVASION_DOWN1_EFFECT + $3 - ATTACK_DOWN1_EFFECT ; covers all -1 effects
	jr c, .decrementStatMod
	sub ATTACK_DOWN2_EFFECT - ATTACK_DOWN1_EFFECT ; map -2 effects to corresponding -1 effect
.decrementStatMod
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	dec b ; dec corresponding stat mod
	jp z, CantLowerAnymore ; if stat mod is 1 (-6), can't lower anymore
	ld a, [de]
	cp ATTACK_DOWN2_EFFECT - $16 ; $24
	jr c, .ok
	cp EVASION_DOWN2_EFFECT + $5 ; $44
	jr nc, .ok
	dec b ; stat down 2 effects only (dec mod again)
	jr nz, .ok
	inc b ; increment mod to 1 (-6) if it would become 0 (-7)
.ok
	ld [hl], b ; save modified mod
	ld a, c
	cp $4
	jr nc, UpdateLoweredStatDone ; jump for evasion/accuracy
	push hl
	push de
	ld hl, wEnemyMonAttack + 1
	ld de, wEnemyMonUnmodifiedAttack
	ldh a, [hWhoseTurn]
	and a
	jr z, .pointToStat
	ld hl, wBattleMonAttack + 1
	ld de, wPlayerMonUnmodifiedAttack
.pointToStat
	push bc
	sla c
	ld b, $0
	add hl, bc ; hl = modified stat
	ld a, c
	add e
	ld e, a
	jr nc, .noCarry
	inc d ; de = unmodified stat
.noCarry
	pop bc
	ld a, [hld]
	sub $1 ; can't lower stat below 1 (-6)
	jr nz, .recalculateStat
	ld a, [hl]
	and a
	jp z, CantLowerAnymore_Pop
.recalculateStat
; recalculate affected stat
; paralysis and burn penalties, as well as badge boosts are ignored
	push hl
	push bc
	ld hl, StatModifierRatios
	dec b
	sla b
	ld c, b
	ld b, $0
	add hl, bc
	pop bc
	xor a
	ldh [hMultiplicand], a
	ld a, [de]
	ldh [hMultiplicand + 1], a
	inc de
	ld a, [de]
	ldh [hMultiplicand + 2], a
	ld a, [hli]
	ldh [hMultiplier], a
	call Multiply
	ld a, [hl]
	ldh [hDivisor], a
	ld b, $4
	call Divide
	pop hl
	ldh a, [hProduct + 3]
	ld b, a
	ldh a, [hProduct + 2]
	or b
	jp nz, UpdateLoweredStat
	ldh [hMultiplicand + 1], a
	ld a, $1
	ldh [hMultiplicand + 2], a

UpdateLoweredStat:
	ldh a, [hProduct + 2]
	ld [hli], a
	ldh a, [hProduct + 3]
	ld [hl], a
	pop de
	pop hl
UpdateLoweredStatDone:
	ld b, c
	inc b
	push de
	call PrintStatText
	pop de
	ld a, [de]
	cp $44
	jr nc, .ApplyBadgeBoostsAndStatusPenalties
	call PlayCurrentMoveAnimation2
.ApplyBadgeBoostsAndStatusPenalties
	ldh a, [hWhoseTurn]
	and a
	call nz, ApplyBadgeBoostsForSpecificStat ; whenever the opponent uses a stat-down move, badge boosts get reapplied again to every stat,
	                              ; even to those not affected by the stat-up move (will be boosted further)
	                             ; PureRGBnote: FIXED: badge boosts only applied to the specific stat being modified
	ld hl, MonsStatsFellText
	rst _PrintText

; These where probably added given that a stat-down move affecting speed or attack will override
; the stat penalties from paralysis and burn respectively.
; But they are always called regardless of the stat affected by the stat-down move.
;;;;;;;;;; PureRGBnote: FIXED: These only run if the specific stat burn or paralyze affect is being modified
	ld a, [wWhatStat]
	cp MOD_SPEED
	call z, QuarterSpeedDueToParalysis ; apply speed penalty to the player whose turn it is, if it's paralyzed
	ld a, [wWhatStat]
	cp MOD_ATTACK
	call z, HalveAttackDueToBurn ; apply attack penalty to the player whose turn it is, if it's burned
	ld a, $ff
	ld [wWhatStat], a ; no longer modifying a stat
	ret
;;;;;;;;;;


CantLowerAnymore_Pop:
	pop de
	pop hl
	inc [hl]

CantLowerAnymore:
	ld a, [de]
	cp ATTACK_DOWN_SIDE_EFFECT
	ret nc
	ld hl, NothingHappenedText
	jp PrintText

MoveMissed:
	ld a, [de]
	cp $44
	ret nc
	jp ConditionalPrintButItFailed

MonsStatsFellText:
	text_far _MonsStatsFellText
	text_asm
	ld hl, FellText
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveEffect]
	jr z, .playerTurn
	ld a, [wEnemyMoveEffect]
.playerTurn
; check if the move's effect decreases a stat by 2
	cp HAZE_EFFECT + 1 ; PureRGBnote: CHANGED: bide effect was removed so use the equivalent
	ret c
	cp ATTACK_DOWN_SIDE_EFFECT
	ret nc
	ld hl, GreatlyFellText
	ret

GreatlyFellText:
	text_pause
	text_far _GreatlyFellText
; fallthrough
FellText:
	text_far _FellText
	text_end

PrintStatText:
	ld hl, StatModTextStrings
	ld c, "@"
.findStatName_outer
	dec b
	jr z, .foundStatName
.findStatName_inner
	ld a, [hli]
	cp c
	jr z, .findStatName_outer
	jr .findStatName_inner
.foundStatName
	ld de, wStringBuffer
	ld bc, $a
	jp CopyData

INCLUDE "data/battle/stat_mod_names.asm"
INCLUDE "data/battle/stat_modifiers.asm"
INCLUDE "data/battle/stat_mod_stat_mapping.asm"

;BideEffect: ; PureRGBnote: CHANGED: Bide effect switched to a stat buff
;	ld hl, wPlayerBattleStatus1
;	ld de, wPlayerBideAccumulatedDamage
;	ld bc, wPlayerNumAttacksLeft
;	ldh a, [hWhoseTurn]
;	and a
;	jr z, .bideEffect
;	ld hl, wEnemyBattleStatus1
;	ld de, wEnemyBideAccumulatedDamage
;	ld bc, wEnemyNumAttacksLeft
;.bideEffect
;	set STORING_ENERGY, [hl] ; mon is now using bide
;	xor a
;	ld [de], a
;	inc de
;	ld [de], a
;	ld [wPlayerMoveEffect], a
;	ld [wEnemyMoveEffect], a
;	call BattleRandom
;	and $1
;	inc a
;	inc a
;	ld [bc], a ; set Bide counter to 2 or 3 at random
;	ldh a, [hWhoseTurn]
;	add XSTATITEM_ANIM
;	jp PlayBattleAnimation2

ThrashPetalDanceEffect:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ldh a, [hWhoseTurn]
	and a
	jr z, .thrashPetalDanceEffect
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
.thrashPetalDanceEffect
	set THRASHING_ABOUT, [hl] ; mon is now using thrash/petal dance
	call BattleRandom
	and $1
	inc a
	inc a
	ld [de], a ; set thrash/petal dance counter to 2 or 3 at random
	ld a, SHRINKING_SQUARE_ANIM
	jp PlayBattleAnimation2

TeleportEffect:
	jpfar _TeleportEffect

TeleportWildPokemon::
.rejectionSampleLoop
	call BattleRandom
	cp e
	jr nc, .rejectionSampleLoop
	srl d
	srl d
	cp d
	ret

TwoToFiveAttacksEffect:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ld bc, wPlayerNumHits
	ldh a, [hWhoseTurn]
	and a
	jr z, .twoToFiveAttacksEffect
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
	ld bc, wEnemyNumHits
.twoToFiveAttacksEffect
	bit ATTACKING_MULTIPLE_TIMES, [hl] ; is mon attacking multiple times?
	ret nz
	set ATTACKING_MULTIPLE_TIMES, [hl] ; mon is now attacking multiple times
	ld hl, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .setNumberOfHits
	ld hl, wEnemyMoveEffect
.setNumberOfHits
	ld a, [hl]
	cp BONEMERANG_EFFECT
	jr z, .bonemerang
	cp TWINEEDLE_EFFECT
	jr z, .twineedle
	cp TWO_OR_THREE_ATTACKS_EFFECT ; PureRGBnote: ADDED: effect that has a 50% chance of 2 or 3 attacks each
	jr z, .twoOrThree
	cp ATTACK_TWICE_EFFECT
	ld a, $2 ; number of hits it's always 2 for ATTACK_TWICE_EFFECT
	jr z, .saveNumberOfHits
; for TWO_TO_FIVE_ATTACKS_EFFECT 3/8 chance for 2 and 3 hits, and 1/8 chance for 4 and 5 hits
	call BattleRandom
	and $3
	cp $2
	jr c, .gotNumHits
; if the number of hits was greater than 2, re-roll again for a lower chance
	call BattleRandom
	and $3
;;;;;;;;;; PureRGBnote: ADDED: effect that does 2 or 3 hits with a 50% chance of both results. Used for Spike Cannon.
	jr .gotNumHits
.twoOrThree
	call BattleRandom
	and 1 ; can either be 0 or 1 which maps to 2 or 3 hits
;;;;;;;;;;
.gotNumHits
	inc a
	inc a
.saveNumberOfHits
	ld [de], a
	ld [bc], a
	ret
.twineedle
	ld a, POISON_SIDE_EFFECT1 ; this is also the value 2, which is how many hits twineedle will do
	ld [hl], a ; set Twineedle's effect to poison effect
	jr .saveNumberOfHits
.bonemerang
	ld a, SPEED_DOWN_SIDE_EFFECT 
	ld [hl], a ; make bonemerang a 30% chance of speed down move
	ld a, 2
	jr .saveNumberOfHits

FlinchSideEffect:
	call CheckTargetSubstitute
	ret nz
	ld hl, wEnemyBattleStatus1
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .flinchSideEffect
	ld hl, wPlayerBattleStatus1
	ld de, wEnemyMoveEffect
.flinchSideEffect
	ld a, [de]
	cp FLINCH_SIDE_EFFECT1
	ld b, 10 percent + 1 ; chance of flinch (FLINCH_SIDE_EFFECT1)
	jr z, .gotEffectChance
	ld b, 30 percent + 1 ; chance of flinch otherwise
.gotEffectChance
	call BattleRandom
	cp b
	ret nc
	set FLINCHED, [hl] ; set mon's status to flinching
	call ClearHyperBeam
	ret

OneHitKOEffect:
	jpfar OneHitKOEffect_


; PureRGBnote: CHANGED: modified this subroutine a bit since fly and dig are the only possibilities after changes
ChargeEffect:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerMoveEffect
	ldh a, [hWhoseTurn]
	and a
	jr z, .chargeEffect
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyMoveEffect
.chargeEffect
	set CHARGING_UP, [hl]
	set INVULNERABLE, [hl] ; mon is now invulnerable to typical attacks (fly/dig)
	ld a, [de]
	dec de ; de contains enemy or player MOVENUM
	cp FLY_EFFECT
	ld b, DIG_DOWN_ANIM ; dig is the only other option
	jr nz, .finish
	ld b, FLY_ANIM_PART1 ; load fly's first part animation
.finish
	xor a
	ld [wAnimationType], a
	ld a, b
	call PlayBattleAnimation
	ld a, [de]
	ld [wChargeMoveNum], a
	ld hl, ChargeMoveEffectText
	jp PrintText

ChargeMoveEffectText:
	text_far _ChargeMoveEffectText
	text_asm
	ld a, [wChargeMoveNum]
	cp RAZOR_WIND
	ld hl, MadeWhirlwindText
	jr z, .gotText
	cp SOLARBEAM
	ld hl, TookInSunlightText
	jr z, .gotText
	cp SKULL_BASH
	ld hl, LoweredItsHeadText
	jr z, .gotText
	cp SKY_ATTACK
	ld hl, SkyAttackGlowingText
	jr z, .gotText
	cp FLY
	ld hl, FlewUpHighText
	jr z, .gotText
	cp DIG
	ld hl, DugAHoleText
.gotText
	ret

MadeWhirlwindText:
	text_far _MadeWhirlwindText
	text_end

TookInSunlightText:
	text_far _TookInSunlightText
	text_end

LoweredItsHeadText:
	text_far _LoweredItsHeadText
	text_end

SkyAttackGlowingText:
	text_far _SkyAttackGlowingText
	text_end

FlewUpHighText:
	text_far _FlewUpHighText
	text_end

DugAHoleText:
	text_far _DugAHoleText
	text_end

TrappingEffect:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ldh a, [hWhoseTurn]
	and a
	jr z, .trappingEffect
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
.trappingEffect
	bit USING_TRAPPING_MOVE, [hl]
	ret nz
	call ClearHyperBeam ; since this effect is called before testing whether the move will hit,
                        ; the target won't need to recharge even if the trapping move missed
	set USING_TRAPPING_MOVE, [hl] ; mon is now using a trapping move

;;;;;;;;;;;;;;;;; PureRGBnote: CHANGED: trapping moves do 2-3 turns maximum but a bit more damage to compensate.	
.reroll
	call BattleRandom 	
	and %11
	cp %11
	jr z, .reroll ; only want 3 possible results, not 4
	and a ; 2/3 chance for 2 attacks (results 01 and 11), 1/3 chance for 3 (result 0)
	ld a, 2
	jr nz, .setTrappingCounter
	ld a, 3
.setTrappingCounter
	dec a
;;;;;;;;;;;;;;;;;
	ld [de], a
	ret

MistEffect:
	jpfar MistEffect_

FocusEnergyEffect:
	jpfar FocusEnergyEffect_

RecoilEffect:
	jpfar DefaultRecoilEffect_

BigRecoilEffect:
	jpfar BigRecoilEffect_ ; PureRGBnote: ADDED: recoil effect that does 1/2 of the damage done to the user.

ConfusionSideEffect:
	call BattleRandom
	cp 10 percent ; chance of confusion
	ret nc
	jr ConfusionSideEffectSuccess

ConfusionBigSideEffect: ; PureRGBnote: ADDED: confusion effect that has a 30% chance of applying confusion
	call BattleRandom
	cp 30 percent ; chance of confusion
	ret nc
	jr ConfusionSideEffectSuccess

ConfusionEffect:
	call CheckTargetSubstitute
	jr nz, ConfusionEffectFailed
	call MoveHitTest
	ld a, [wMoveMissed]
	and a
	jr nz, ConfusionEffectFailed

ConfusionSideEffectSuccess:
	ldh a, [hWhoseTurn]
	and a
	ld hl, wEnemyBattleStatus1
	ld bc, wEnemyConfusedCounter
	ld a, [wPlayerMoveEffect]
	jr z, .confuseTarget
	ld hl, wPlayerBattleStatus1
	ld bc, wPlayerConfusedCounter
	ld a, [wEnemyMoveEffect]
.confuseTarget
	bit CONFUSED, [hl] ; is mon confused?
	jr nz, ConfusionEffectFailed
	set CONFUSED, [hl] ; mon is now confused
	push af
	call BattleRandom
	and $3
	inc a
	inc a
	ld [bc], a ; confusion status will last 2-5 turns
	pop af
;;;;;;;;;; PureRGBnote: ADDED: confusion effect that has a 30% chance of applying confusion
	cp CONFUSION_BIG_SIDE_EFFECT
	jr z, .done
	cp CONFUSION_SIDE_EFFECT
	jr z, .done
	call PlayCurrentMoveAnimation2
;;;;;;;;;;
.done
	ld hl, BecameConfusedText
	jp PrintText

BecameConfusedText:
	text_far _BecameConfusedText
	text_end

ConfusionEffectFailed:
	cp CONFUSION_BIG_SIDE_EFFECT
	ret z
	cp CONFUSION_SIDE_EFFECT
	ret z
	ld c, 50
	rst _DelayFrames
	jp ConditionalPrintButItFailed

BurnEffect:
	jpfar BurnEffect_

ParalyzeEffect:
	jpfar ParalyzeEffect_

SubstituteEffect:
	jpfar SubstituteEffect_

HyperBeamEffect:
	ld hl, wPlayerBattleStatus2
	ldh a, [hWhoseTurn]
	and a
	jr z, .hyperBeamEffect
	ld hl, wEnemyBattleStatus2
.hyperBeamEffect
	set NEEDS_TO_RECHARGE, [hl] ; mon now needs to recharge
	ret

ClearHyperBeam:
	push hl
	ld hl, wEnemyBattleStatus2
	ldh a, [hWhoseTurn]
	and a
	jr z, .playerTurn
	ld hl, wPlayerBattleStatus2
.playerTurn
	res NEEDS_TO_RECHARGE, [hl] ; mon no longer needs to recharge
	pop hl
	ret

;RageEffect: ; PureRGBnote: CHANGED: rage effect was changed so don't need this
	;ret
	;ld hl, wPlayerBattleStatus2
	;ldh a, [hWhoseTurn]
	;and a
	;jr z, .player
	;ld hl, wEnemyBattleStatus2
;.player
	;set USING_RAGE, [hl] ; mon is now in "rage" mode
	;ret

MimicEffect:
	ld c, 50
	rst _DelayFrames
	call MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, .mimicMissed
	ldh a, [hWhoseTurn]
	and a
	ld hl, wBattleMonMoves
	ld a, [wPlayerBattleStatus1]
	jr nz, .enemyTurn
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr nz, .letPlayerChooseMove
	ld hl, wEnemyMonMoves
	ld a, [wEnemyBattleStatus1]
.enemyTurn
	bit INVULNERABLE, a
	jr nz, .mimicMissed
.getRandomMove
	push hl
	call BattleRandom
	and $3
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jr z, .getRandomMove
	ld d, a
	ldh a, [hWhoseTurn]
	and a
	ld hl, wBattleMonMoves
	ld a, [wPlayerMoveListIndex]
	jr z, .playerTurn
	ld hl, wEnemyMonMoves
	ld a, [wEnemyMoveListIndex]
	jr .playerTurn
.letPlayerChooseMove
	ld a, [wEnemyBattleStatus1]
	bit INVULNERABLE, a
	jr nz, .mimicMissed
	ld a, [wCurrentMenuItem]
	push af
	ld a, $1
	ld [wMoveMenuType], a
	call MoveSelectionMenu
	call LoadScreenTilesFromBuffer1
	ld hl, wEnemyMonMoves
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, $0
	add hl, bc
	ld d, [hl]
	pop af
	ld hl, wBattleMonMoves
.playerTurn
	ld c, a
	ld b, $0
	add hl, bc
	ld a, d
	ld [hl], a
	ld [wd11e], a
	push af
	call GetMoveName
	call PlayCurrentMoveAnimation
	ld hl, MimicLearnedMoveText
	rst _PrintText
;;;;;;;;;; PureRGBnote: CHANGED: Now immediately use the move
	ld a, [hWhoseTurn]
	and a
	ld hl, wPlayerSelectedMove
	ld de, wPlayerMoveNum
	jr z, .playerTurn2
	ld hl, wEnemySelectedMove
	ld de, wEnemyMoveNum
.playerTurn2
	pop af
	ld [hl], a
	call ReloadMoveData
	ld a, [hWhoseTurn]
	and a
	jp z, CheckIfPlayerNeedsToChargeUp
	jp CheckIfEnemyNeedsToChargeUp
;;;;;;;;;;
.mimicMissed
	ld c, 50
	rst _DelayFrames
	jp PrintButItFailedText_

MimicLearnedMoveText:
	text_far _MimicLearnedMoveText
	text_end

LeechSeedEffect:
	jpfar LeechSeedEffect_

SplashEffect:
	call PlayCurrentMoveAnimation
	jp PrintNoEffectText

;;;;;;;;;; PureRGBnote: CHANGED: this function was updated to disable the previous move used by the opponent
;;;;;;;;;;                       or a random one if they haven't used any move yet. 
DisableEffect:
	call MoveHitTest
	ld a, [wMoveMissed]
	and a
	jp nz, .moveMissed
	ld de, wEnemyDisabledMove
	ld hl, wEnemyMonMoves
	ld a, [wEnemyLastSelectedMoveDisable]
	ld b, a
	ldh a, [hWhoseTurn]
	and a
	jr z, .disableEffect
	ld de, wPlayerDisabledMove
	ld hl, wBattleMonMoves
	ld a, [wPlayerLastSelectedMoveDisable]
	ld b, a
.disableEffect
; no effect if target already has a move disabled
	ld a, [de]
	and a
	jr nz, .moveMissed
.pickMoveToDisable
	ld a, b ; load the player or enemy's previously used move
	and a 
	jr z, .doRandomSelection ; if this value is 0, they haven't selected a move yet or are unable to act, so randomly select a move instead
	ld [wd11e], a ; store move ID 
	ld c, 0
.findPreviousMoveIndex
	ld a, [hl]
	inc hl
	inc c ; c will be move index 1-4
	cp b
	jr nz, .findPreviousMoveIndex
	jr .finishDisabling
.doRandomSelection
	push hl
	call BattleRandom
	and $3
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jr z, .pickMoveToDisable ; loop until a non-00 move slot is found
	ld [wd11e], a ; store move number	
	push hl
	ldh a, [hWhoseTurn]
	and a
	ld hl, wBattleMonPP
	jr nz, .enemyTurn
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	pop hl ; wEnemyMonMoves
	jr nz, .playerTurnNotLinkBattle
; .playerTurnLinkBattle
	push hl
	ld hl, wEnemyMonPP
.enemyTurn
	push hl
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	inc hl
	or [hl]
	and $3f
	pop hl ; wBattleMonPP or wEnemyMonPP
	jr z, .moveMissedPopHL ; nothing to do if all moves have no PP left
	add hl, bc
	ld a, [hl]
	pop hl
	and a
	jr z, .pickMoveToDisable ; pick another move if this one had 0 PP
.playerTurnNotLinkBattle
	inc c ; move 1-4 will be disabled
.finishDisabling
; non-link battle enemies have unlimited PP so the previous checks aren't needed
	call BattleRandom
	and $7
	cp 7
	jr z, .finishDisabling ; redo randomization if we have a value of 7 so we can't have 9 turns disabled
	inc a ; 1-7 turns disabled
	inc a ; 2-8 turns disabled
	swap c
	add c ; map disabled move to high nibble of wEnemyDisabledMove / wPlayerDisabledMove
	ld [de], a
	call PlayCurrentMoveAnimation2
	ld hl, wPlayerDisabledMoveNumber
	ldh a, [hWhoseTurn]
	and a
	jr nz, .printDisableText
	inc hl ; wEnemyDisabledMoveNumber
.printDisableText
	ld a, [wd11e] ; move number
	ld [hl], a
	call GetMoveName
	ld hl, MoveWasDisabledText
	jp PrintText
.moveMissedPopHL
	pop hl
.moveMissed
	ld c, 50
	rst _DelayFrames
	jp PrintButItFailedText_
;;;;;;;;;;

MoveWasDisabledText:
	text_far _MoveWasDisabledText
	text_end

PayDayEffect:
	jpfar PayDayEffect_

TriAttackEffect:
	call BattleRandom
	ld d, a
	jpfar TriAttackEffect_

HazeEffect:
	jpfar HazeEffect_

HealEffect:
	jpfar HealEffect_

TransformEffect:
	jpfar TransformEffect_

ReflectLightScreenEffect:
	jpfar ReflectLightScreenEffect_

NothingHappenedText:
	text_far _NothingHappenedText
	text_end

PrintNoEffectText:
	ld hl, NoEffectText
	jp PrintText

NoEffectText:
	text_far _NoEffectText
	text_end

ConditionalPrintButItFailed:
	ld a, [wMoveDidntMiss]
	and a
	ret nz ; return if the side effect failed, yet the attack was successful

PrintButItFailedText_:
	ld hl, ButItFailedText
	jp PrintText

ButItFailedText:
	text_far _ButItFailedText
	text_end

PrintDidntAffectText:
	ld hl, DidntAffectText
	jp PrintText

DidntAffectText:
	text_far _DidntAffectText
	text_end

IsUnaffectedText:
	text_far _IsUnaffectedText
	text_end

PrintMayNotAttackText:
	ld hl, ParalyzedMayNotAttackText
	jp PrintText

ParalyzedMayNotAttackText:
	text_far _ParalyzedMayNotAttackText
	text_end

CheckTargetSubstitute:
	push hl
	ld hl, wEnemyBattleStatus2
	ldh a, [hWhoseTurn]
	and a
	jr z, .next1
	ld hl, wPlayerBattleStatus2
.next1
	bit HAS_SUBSTITUTE_UP, [hl]
	pop hl
	ret

PlayCurrentMoveAnimation2:
; animation at MOVENUM will be played unless MOVENUM is 0
; plays wAnimationType 3 or 6
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveNum]
	jr z, .notEnemyTurn
	ld a, [wEnemyMoveNum]
.notEnemyTurn
	and a
	ret z
;;;;;;;;;; PureRGBnote: ADDED: set the flag that makes the animation code mark this move as seen in the movedex
	push hl
	ld hl, wBattleFunctionalFlags
	set 0, [hl]
	pop hl
;;;;;;;;;;

PlayBattleAnimation2:
; play animation ID at a and animation type 6 or 3
	ld [wAnimationID], a
	ldh a, [hWhoseTurn]
	and a
	ld a, $6
	jr z, .storeAnimationType
	ld a, $3
.storeAnimationType
	ld [wAnimationType], a
	jp PlayBattleAnimationGotID

PlayCurrentMoveAnimation:
; animation at MOVENUM will be played unless MOVENUM is 0
; resets wAnimationType
	xor a
	ld [wAnimationType], a
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveNum]
	jr z, .notEnemyTurn
	ld a, [wEnemyMoveNum]
.notEnemyTurn
	and a
	ret z
;;;;;;;;;; PureRGBnote: ADDED: set the flag that makes the animation code mark this move as seen in the movedex
	push hl
	ld hl, wBattleFunctionalFlags
	set 0, [hl]
	pop hl
;;;;;;;;;;

PlayBattleAnimation:
; play animation ID at a and predefined animation type
	ld [wAnimationID], a

PlayBattleAnimationGotID:
; play animation at wAnimationID
	push hl
	push de
	push bc
	predef MoveAnimation
	callfar Func_78e98 ; shinpokerednote: gbcnote: functions from pokemon yellow related to gbc color
	pop bc
	pop de
	pop hl
	ret

SuperFangEffect:
	ldh a, [hWhoseTurn]
	and a
	ld hl, wEnemyMonHP
	jr z, .playerTurn
	ld hl, wBattleMonHP
.playerTurn
; set the damage to half the target's HP
; PureRGBnote: CHANGED: now 2/3 the target's HP
	ld a, 3
	ldh [hDivisor], a
	ld de, wDamage ; we'll store the whole opponent's current HP in the damage variable for now
	ld a, [hli]
	ldh [hDividend], a
	ld [de], a
	inc de
	ld a, [hl]
	ldh [hDividend + 1], a
	ld [de], a
	ld b, 2
	call Divide
	ldh a, [hQuotient + 2]
	ld b, a
	ldh a, [hQuotient + 3]
	ld c, a
	ld hl, wDamage ; subtract 1/3 of the mon's current HP from their current HP value to obtain 2/3 resultant damage
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld e, a
	; subtract bc from de
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	; de = resultant value
	ld a, d
	ld hl, wDamage
	ld [hli], a
	ld a, e
	ld [hl], a
	and a
	or d
	ret nz
; make sure Super Fang's damage is always at least 1
	ld a, 1
	ld [hl], a
	ret