Version_GFX:
IF (DEF(_RED) || DEF(_GREEN)) ; PureRGBnote: GREENBUILD: uses the same tile as red which contains GREEN already.
	INCBIN "gfx/title/red_version.1bpp" ; 10 tiles
ENDC
IF DEF(_BLUE)
	INCBIN "gfx/title/blue_version.1bpp" ; 8 tiles
ENDC
Version_GFXEnd:
