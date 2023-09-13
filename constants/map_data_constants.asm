; width of east/west connections
; height of north/south connections
DEF MAP_BORDER EQU 3
DEF DEFER_SHOWING_MAP EQU %10000
DEF EXTRA_MUSIC_MAP   EQU %100000

	const_def 4
	const BIT_DEFER_SHOWING_MAP
	const BIT_EXTRA_MUSIC_MAP

; connection directions
	const_def
	shift_const EAST   ; 1
	shift_const WEST   ; 2
	shift_const SOUTH  ; 4
	shift_const NORTH  ; 8

; flower and water tile animations
	const_def
	const TILEANIM_NONE          ; 0
	const TILEANIM_WATER         ; 1
	const TILEANIM_WATER_FLOWER  ; 2
