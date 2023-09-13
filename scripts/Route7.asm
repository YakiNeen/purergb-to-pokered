; PureRGBnote: ADDED: new trainers on this route.

Route7_Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route7TrainerHeaders
	ld de, Route7_ScriptPointers
	ld a, [wRoute7CurScript]
	call ExecuteCurMapScriptInTable
	ld [wRoute7CurScript], a
	ret

Route7_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_ROUTE7_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_ROUTE7_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_ROUTE7_END_BATTLE

Route7_TextPointers:
	def_text_pointers
	dw_const Route7Gambler1Text,            TEXT_ROUTE7_GAMBLER1
	dw_const Route7Gambler2Text,            TEXT_ROUTE7_GAMBLER2
	dw_const Route7UndergroundPathSignText, TEXT_ROUTE7_UNDERGROUND_PATH_SIGN

Route7TrainerHeaders:
	def_trainers 1
Route7TrainerHeader0:
	trainer EVENT_BEAT_ROUTE_7_TRAINER_0, 1, Route7BattleText1, Route7EndBattleText1, Route7AfterBattleText1
Route7TrainerHeader1:
	trainer EVENT_BEAT_ROUTE_7_TRAINER_1, 1, Route7BattleText2, Route7EndBattleText2, Route7AfterBattleText2
	db -1 ; end

Route7Gambler1Text:
	text_asm
	ld hl, Route7TrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd

Route7BattleText1:
	text_far _Route7BattleText1
	text_end

Route7EndBattleText1:
	text_far _Route7EndBattleText1
	text_end

Route7AfterBattleText1:
	text_far _Route7AfterBattleText1
	text_end

Route7Gambler2Text:
	text_asm
	ld hl, Route7TrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd

Route7BattleText2:
	text_far _Route7BattleText2
	text_end

Route7EndBattleText2:
	text_far _Route7EndBattleText2
	text_end

Route7AfterBattleText2:
	text_far _Route7AfterBattleText2
	text_end

Route7UndergroundPathSignText:
	text_far _Route7UndergroundPathSignText
	text_end
