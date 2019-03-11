; ==================================================================
; Archivo: eeprom.asm
; Descripcion: funciones relacionadas con el uso de la memoria EEPROM

; Usos de la memoria EEPROM:
; 1) Guardar los registros de configuracion del contador Geiger en
;    en memoria para reconfigurar el dispositivo con dichos valores
;    en caso de reiniciarse
;
; ==================================================================

.undef T0
.def T0 = R16

; ==================================================================
; Decripcion: almacena en memoria RAM la ultima configuracion del dispositivo
; Recibe: registros de configuracion
; Devuelve: -
GUARDAR_CONFIGURACION_EEMPROM:
	CLR R17
	CLR R18

	LDS R19, REGISTRO_VENTANA_TIEMPO
	CALL GUARDAR_REGISTRO_EEPROM
	
	INC R17
	LDS R19, VENTANAS_A_MEDIR_RAM
	CALL GUARDAR_REGISTRO_EEPROM

	INC R17	
	LDS R19, VENTANAS_A_MEDIR_RAM+1
	CALL GUARDAR_REGISTRO_EEPROM

	INC R17	
	LDS R19, VENTANAS_A_MEDIR_RAM+2
	CALL GUARDAR_REGISTRO_EEPROM

	INC R17	
	LDS R19, REGISTRO_UMBRAL
	CALL GUARDAR_REGISTRO_EEPROM

	INC R17	
	LDS R19, REGISTRO_UMBRAL+1
	CALL GUARDAR_REGISTRO_EEPROM

	INC R17	
	LDS R19, REGISTRO_UMBRAL+2
	CALL GUARDAR_REGISTRO_EEPROM
	
	INC R17
	LDS R19, REGISTRO_CONF_GENERAL
	CALL GUARDAR_REGISTRO_EEPROM

	RET

; ==================================================================
; Descripcion: guarda un byte en memoria EEPROM
; Recibe: 
; -> R17: LSB de la direccion de memoria
; -> R18: MSB de la direccion de memoria
; -> R19: byte a guardar
; Devuelve: -
GUARDAR_REGISTRO_EEPROM:
; Esperar a que el dato anterior se haya escrito
_BUCLE_GUARDAR_REGISTRO_EEPROM:
	IN T0, EECR
	SBRC T0, EEPE
	RJMP _BUCLE_GUARDAR_REGISTRO_EEPROM

	OUT EEARH, R18
	OUT EEARL, R17
	
	OUT EEDR, R19

	CLR T0
	ORI T0, (1<<EEMPE)
	OUT EECR, T0	

	CLR T0
	ORI T0, (1<<EEPE)
	OUT EECR, T0

	RET

; ==================================================================
; Decripcion: configura el dispositivo (mediante registros en RAM) a partir
; de la ultima configuracion almacenada en EEPROM
; Recibe: registros de configuracion
; Devuelve: -
CARGAR_CONFIGURACION_EEPROM:
	CLR R17
	CLR R18
	
	CALL LEER_REGISTRO_EEPROM
	STS REGISTRO_VENTANA_TIEMPO, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS VENTANAS_A_MEDIR_RAM, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS VENTANAS_A_MEDIR_RAM+1, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS VENTANAS_A_MEDIR_RAM+2, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS REGISTRO_UMBRAL, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS REGISTRO_UMBRAL+1, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS REGISTRO_UMBRAL+2, R19
	INC R17

	CALL LEER_REGISTRO_EEPROM
	STS REGISTRO_CONF_GENERAL, R19

	RET

; ==================================================================
; Decripcion: devuelve el dato almacenado en un registro de memoria EEPROM
; Recibe: 
; -> R17: LSB de la direccion de memoria
; -> R18: MSB de la direccion de memoria
; Devuelve: 
; -> R19: byte leido
LEER_REGISTRO_EEPROM:
_BUCLE_CARGAR_REGISTRO_EEPROM:
	IN T0, EECR
	SBRC T0, EEPE
	RJMP _BUCLE_GUARDAR_REGISTRO_EEPROM

	OUT EEARH, R18
	OUT EEARL, R17

	CLR T0
	ORI T0, (1<<EERE)
	OUT EECR, T0		
	
	IN R19, EEDR

	RET