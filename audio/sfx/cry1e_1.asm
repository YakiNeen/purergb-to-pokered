SFX_Cry1E_1_Ch5:
	duty_cycle_pattern 3, 3, 0, 0
	square_note 6, 15, 2, 1536
	square_note 6, 14, 2, 1600
	square_note 6, 13, 2, 1664
	square_note 6, 14, 2, 1728
	square_note 6, 13, 2, 1792
	square_note 6, 12, 2, 1856
	square_note 6, 11, 2, 1920
	square_note 8, 10, 1, 1984
	sound_ret

SFX_Cry1E_1_Ch6:
	duty_cycle_pattern 0, 1, 0, 1
	square_note 3, 0, 8, 1
	square_note 6, 12, 2, 1473
	square_note 6, 11, 2, 1538
	square_note 6, 10, 2, 1601
	square_note 6, 11, 2, 1666
	square_note 6, 10, 2, 1730
	square_note 6, 9, 2, 1793
	square_note 6, 10, 2, 1858
	square_note 8, 8, 1, 1921
	sound_ret

SFX_Cry1E_1_Ch8:
	noise_note 6, 0, 8, 1
	noise_note 5, 14, 2, 92
	noise_note 5, 12, 2, 76
	noise_note 5, 13, 2, 60
	noise_note 5, 11, 2, 44
	noise_note 5, 12, 2, 28
	noise_note 5, 10, 2, 27
	noise_note 5, 9, 2, 26
	noise_note 8, 8, 1, 24
	sound_ret

; PureRGBnote: ADDED: this replaces channel 8 when doing armored mewtwo's cry
SFX_Armored_Mewtwo_Cry1_Ch8:
	sound_call SFX_Cry1E_1_Ch8
	noise_note 10, 13, 3, $e0
	noise_note 14, 13, 6, $ff
	sound_ret