; PureRGBnote: ADDED: new trainers in this location. Only after defeating giovanni on 11F though.

SilphCo1F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, SilphCo1FTrainerHeaders
	ld de, SilphCo1F_ScriptPointers
	ld a, [wSilphCo1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wSilphCo1FCurScript], a
	ret

SilphCo1F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_SILPHCO1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_SILPHCO1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_SILPHCO1F_END_BATTLE

SilphCo1F_TextPointers:
	def_text_pointers
	dw_const SilphCo1FTrainer1Text,         TEXT_SILPHCO1F_FIREFIGHTER1
	dw_const SilphCo1FTrainer2Text,         TEXT_SILPHCO1F_SOLDIER1
	dw_const SilphCo1FTrainer3Text,         TEXT_SILPHCO1F_SOLDIER2
	dw_const SilphCo1FTrainer4Text,         TEXT_SILPHCO1F_FIREFIGHTER2
	dw_const SilphCo1FLinkReceptionistText, TEXT_SILPHCO1F_LINK_RECEPTIONIST

SilphCo1FTrainerHeaders:
	def_trainers 0
SilphCo1FTrainerHeader0:
	trainer EVENT_BEAT_SILPH_CO_1F_TRAINER_0, 0, SilphCo1FBattleText1, SilphCo1FEndBattleText1, SilphCo1FAfterBattleText1
SilphCo1FTrainerHeader1:
	trainer EVENT_BEAT_SILPH_CO_1F_TRAINER_1, 0, SilphCo1FBattleText2, SilphCo1FEndBattleText2, SilphCo1FAfterBattleText2
SilphCo1FTrainerHeader2:
	trainer EVENT_BEAT_SILPH_CO_1F_TRAINER_2, 0, SilphCo1FBattleText3, SilphCo1FEndBattleText3, SilphCo1FAfterBattleText3
SilphCo1FTrainerHeader3:
	trainer EVENT_BEAT_SILPH_CO_1F_TRAINER_3, 0, SilphCo1FBattleText4, SilphCo1FEndBattleText4, SilphCo1FAfterBattleText4
	db -1 ;end

SilphCo1FTrainer1Text:
	text_asm
	ld hl, SilphCo1FTrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd

SilphCo1FBattleText1:
	text_far _SilphCo1FBattleText1
	text_end

SilphCo1FEndBattleText1:
	text_far _SilphCo1FEndBattleText1
	text_end

SilphCo1FAfterBattleText1:
	text_far _SilphCo1FAfterBattleText1
	text_end

SilphCo1FTrainer2Text:
	text_asm
	ld hl, SilphCo1FTrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd

SilphCo1FBattleText2:
	text_far _SilphCo1FBattleText2
	text_end

SilphCo1FEndBattleText2:
	text_far _SilphCo1FEndBattleText2
	text_end

SilphCo1FAfterBattleText2:
	text_far _SilphCo1FAfterBattleText2
	text_end

SilphCo1FTrainer3Text:
	text_asm
	ld hl, SilphCo1FTrainerHeader2
	call TalkToTrainer
	rst TextScriptEnd

SilphCo1FBattleText3:
	text_far _SilphCo1FBattleText3
	text_end

SilphCo1FEndBattleText3:
	text_far _SilphCo1FEndBattleText3
	text_end

SilphCo1FAfterBattleText3:
	text_far _SilphCo1FAfterBattleText3
	text_end

SilphCo1FTrainer4Text:
	text_asm
	ld hl, SilphCo1FTrainerHeader3
	call TalkToTrainer
	rst TextScriptEnd

SilphCo1FBattleText4:
	text_far _SilphCo1FBattleText4
	text_end

SilphCo1FEndBattleText4:
	text_far _SilphCo1FEndBattleText4
	text_end

SilphCo1FAfterBattleText4:
	text_far _SilphCo1FAfterBattleText4
	text_end

SilphCo1FLinkReceptionistText:
	text_far _SilphCo1FLinkReceptionistText
	text_end
