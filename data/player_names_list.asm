IF DEF(_RED)
DefaultNamesPlayerList:
	db "NEW NAME@"
	db "RED@"
	db "ASH@"
	db "JACK@"

DefaultNamesRivalList:
	db "NEW NAME@"
	db "BLUE@"
	db "GARY@"
	db "JOHN@"
ENDC

IF DEF(_BLUE)
DefaultNamesPlayerList:
	db "NEW NAME@"
	db "BLUE@"
	db "GARY@"
	db "JOHN@"

DefaultNamesRivalList:
	db "NEW NAME@"
	db "RED@"
	db "ASH@"
	db "JACK@"
ENDC

IF DEF(_GREEN) ; PureRGBnote: GREENBUILD: default names specific to pokemon green
DefaultNamesPlayerList:
	db "NEW NAME@"
	db "GREEN@"
	db "ASH@"
	db "MIKE@"

DefaultNamesRivalList:
	db "NEW NAME@"
	db "BLUE@"
	db "GARY@"
	db "GABE@"
ENDC

