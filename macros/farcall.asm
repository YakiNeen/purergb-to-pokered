MACRO farcall
	ld b, BANK(\1)
	ld hl, \1
	rst _Bankswitch ; pureRGBnote: CHANGED: using a rst vector here saves a bunch of space
ENDM

MACRO callfar
	ld hl, \1
	ld b, BANK(\1)
	rst _Bankswitch ; pureRGBnote: CHANGED: using a rst vector here saves a bunch of space
ENDM

MACRO farjp
	ld b, BANK(\1)
	ld hl, \1
	jp Bankswitch
ENDM

MACRO jpfar
	ld hl, \1
	ld b, BANK(\1)
	jp Bankswitch
ENDM

MACRO callbs	; shinpokerednote: audionote: added from pokeyellow
	ld a, BANK(\1)
	call BankswitchCommon
	call \1
ENDM

MACRO homecall
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(\1)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call \1
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
ENDM

MACRO homecall_sf ; homecall but save flags by popping into bc instead of af
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(\1)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call \1
	pop bc
	ld a, b
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
ENDM
