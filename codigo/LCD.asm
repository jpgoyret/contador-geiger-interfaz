;Fede: En este archivo pongo las funciones que se usan para manejar el LCD. En cada una detallo qué hacen, registros que usan, etc.

;Se hace una serie de definiciones previas para simplificar la lectura del código y la escritura también.

.EQU PUERTO_LCD = PORTD								;EL PUERTO D PARA ENVIAR LOS DATOS AL LCD
.EQU PIN_LCD = PIND									;PARA LEER DATOS DEL PUERTO D
.EQU PIN_ENABLE = 2									;EL PIN 5 DEL PUERTO D CONECTADO AL ENABLE
.EQU PIN_RS = 3										;EL PIN 4 DEL PUERTO D CONECTADO AL RS
.EQU DDR_LCD = DDRD									;REGISTRO PARA CONFIGURAR EL PUERTO QUE ENVIA LOS DATOS, COMO SALIDA



.EQU LCD_N_BITS = 0x28								;COMANDO DE INICIALIZACIÓN DEL LCD EN MODO 4 BITS
;.EQU LCD_N_BITS = 0x20								;COMANDO PARA INDICAT MODO DE 4 BITS, Y UNA LINEA DE ESCRITURA
.EQU LCD_DISPLAY_ON = 0x0C							;COMANDO PARA ENCENDER EL DISPLAY
.EQU LCD_CLR_SCREEN = 0x01							;COMANDO PARA LIMPIAR LA PANTALLA
.EQU LCD_HOME_SCREEN = 0x02							;COMANDO PARA PARARSE EN EL EXTREMO SUPERIOR IZQUIERDO DE LA PANTALLA
.EQU LCD_CURSOR_DERECHA = 0x18						;COMANDO PARA ESCRIBIR HACIA LA DERECHA EN LA PANTALLA
.EQU LCD_SHIFTEAR_CURSOR_DERECHA = 0x14				;COMANDO PARA MOVER EL CURSOR PARA ESCRIBIR, HACIA LA DERECHA
.EQU LCD_SHIFTEAR_CURSOR_IZQUIERDA = 0x10			;COMANDO PARA MOVER EL CURSOR PARA ESCRIBIR, HACIA LA IZQUIERDA
.EQU LCD_CAMBIAR_RENGLON = 0xC0						;COMANDO PARA ESCRIBIR EN EL RENGLÓN DE ABAJO

.EQU LCD_CURSOR_ON = 0x0F							;COMANDO PARA PONER EL CURSOR PARPADEANTE
.EQU LCD_CURSOR_OFF = 0x0C							;COMANDO PARA QUITAR EL CURSOR PARPADEANTE



.EQU FLECHA_IZQUIERDA_ASCII = 0x7F					;ASCII para la flecha para la izquierda
.EQU FLECHA_DERECHA_ASCII = 0x7E					;ASCII para la flecha para la derecha

; =======================================================================================================================
; =======================================================================================================================

;Se define una MACRO para la invocación de DELAYS para el LCD
.MACRO DELAY_LCD
	PUSH R16
	LDI R16, @0
	MOV R14, R16
	POP R16
DELAY_1:
	PUSH R16
	MOV R16, R14
	CPI R16, 0x00 
	BREQ END_DELAY_1
	POP R16
	RJMP DELAY_1
END_DELAY_1:
POP R16
.ENDMACRO

;Se define una macro para enviar comandos al LCD
.MACRO COMANDO_LCD
	PUSH R14
	PUSH R16
	LDI R16, @0
	MOV R14, R16
	POP R16
	CALL CMNDWRT_LCD
	POP R14
.ENDMACRO

; Se define una macro para enviar cadenas de caracteres desde la flash

.MACRO CADENA_FLASH_LCD
	PUSH ZH
	PUSH ZL
	LDI ZL, LOW(@0<<1)
	LDI ZH, HIGH(@0<<1)
	CALL STRING_WRT_LCD_FLASH
	POP ZL
	POP ZH
.ENDMACRO

; Se define una macro para borrar el renglón

.MACRO BORRAR_RENGLON
	CADENA_FLASH_LCD ESPACIO
.ENDMACRO 


; =======================================================================================================================
; =======================================================================================================================

;PUERTO D
;[D4][D5][D6][D7][RS][E][-][-]
;D4-D7: Por estos pines se envía el dato al LCD. Se va a usar el modo de escritura de 4 pines.
;RS: RS = 1 permite escribir datos en la pantalla, RS = 0 permite enviar comandos al LCD.
;E: Se envía un pulso de entre 500 y 300 ns en este pin, para que el LCD reciba el dato de los pines D4-D7.

;***************************LOS COMANDOS ESTÁN EN EL DATASHEET DEL LCD***************************

INIT_LCD:
;Función que realiza las tareas de inicialización del LCD. La inicialización consiste en el envío de una serie de comandos.
;Se inicializa con escritura por 4 bits, encendiendo el display y limpiando la pantalla. Por último se iniciliza para una escritura
;hacia la derecha y posicionando el cursor en el extremo superior izquierdo de la pantalla.
;Registros utilizados: R16, R14
	PUSH R16
	DELAY_LCD 0x96				;SE ESPERAN 15ms
	LDI R16, LCD_N_BITS			;CANTIDAD DE BITS A UTILIZAR PARA EL SCREEN, EN ESTE CASO 4 BITS
	MOV R14, R16
	CALL CMNDWRT_LCD			;SE ESCRIBE EL COMANDO EN EL LCD
	LDI R16, LCD_DISPLAY_ON		;ENCENDER DISPLAY
	MOV R14, R16
	CALL CMNDWRT_LCD			;SE ESCRIBE EL COMANDO EN EL LCD
	LDI R16, LCD_CLR_SCREEN		;COMANDO PARA LIMPIAR LA PANTALLA
	MOV R14, R16
	CALL CMNDWRT_LCD			;SE ESCRIBE EL COMANDO
	DELAY_LCD 0x14				;DELAY PARA QUE EL LCD EJECUTE EL COMANDO, 2ms
	LDI R16, LCD_CURSOR_DERECHA	;SHIFTEAR CURSOR A LA DERECHA
	MOV R14, R16
	CALL CMNDWRT_LCD			;ESCRIBO EN EL LCD
	LDI R16, LCD_HOME_SCREEN	;SE POSICIONA EL CURSOR EN EL EXTREMO SUPERIOR IZQUIERDO PARA COMENZAR A ESCRIBIR
	MOV R14, R16
	CALL CMNDWRT_LCD			;SE ENVÍA EL COMANDO
	DELAY_LCD 0x14				;SE HACE UN DELAY DE 2ms PARA QUE SE EJECUTE EL COMANDO
	POP R16
	RET
;************************************************************************************************
DATAWRT_LCD:
;Escribe un dato en la pantalla LCD, previamente cargado en el registro R16
;REGISTROS UTILIZADOS: R14, R21, R20
	PUSH R20					;SE COPIAN LOS DATOS PARA NO PERDERLOS
	PUSH R21
	;PUSH R14
	MOV R20, R14				;SE COPIA EL DATO A ENVIAR, DEL REGISTRO 16 AL REGISTRO 27
	ANDI R20, 0xF0				;SE APLICA UNA MASCARA 11110000 PARA QUEDARSE CON EL NIBBLE ALTO
	IN R21, PIN_LCD				;SE COPIA EL DATO DEL PUERTO
	ANDI R21, 0x0F				;SE ELIMINAN LOS DATOS DEL NIBBLE ALTO.
	OR R21, R20					;Y SE COLOCA EL DATO A ENVIAR, EN EL NIBBLE ALTO.
	OUT PUERTO_LCD, R21			;SE COLOCA EL DATO EN EL PUERTO
	SBI PUERTO_LCD, PIN_RS		;PIN RS EN 1, PARA PODER ESCRIBIR DATOS EN EL LCD
	SBI PUERTO_LCD, PIN_ENABLE	;SE PONE UN 1 EN ENABLE PARA EMPEZAR A ENVIAR EL DATO
	CALL SDELAY					;SE LLAMA A UN DELAY YA QUE EL PULSO DEBE TENER UN CIERTO ANCHO
	CBI PUERTO_LCD, PIN_ENABLE	;SE PONE EL ENABLE EN 0 PARA TERMINAR LA TRANSMISIÓN DEL NIBBLE ALTO

	MOV R20, R14				;SE COPIA EL DATO ORIGINAL NUEVAMENTE AL REGISTRO 27
	SWAP R20					;SE INVIERTEN LOS NIBBLES DEL DATO
	ANDI R20, 0xF0				;SE APLICA LA MASCARA NUEVAMENTE PARA RECUPERAR SOLO EL NIBBLE
	IN R21, PIN_LCD				;SE COPIA EL DATO DEL PUERTO
	ANDI R21, 0x0F				;SE ELIMINAN LOS DATOS DEL NIBBLE ALTO.
	OR R21, R20					;Y SE COLOCA EL DATO A ENVIAR, EN EL NIBBLE ALTO.
	OUT PUERTO_LCD, R21			;SE COLOCA EL DATO EN EL PUERTO
	SBI PUERTO_LCD, PIN_ENABLE	;SE PONE UN 1 EN ENABLE PARA EMPEZAR A ENVIAR EL DATO
	CALL SDELAY					;SE LLAMA A UN DELAY YA QUE EL PULSO DEBE TENER UN CIERTO ANCHO
	CBI PUERTO_LCD, PIN_ENABLE	;SE PONE EL ENABLE EN 0 PARA TERMINAR LA TRANSMISIÓN DEL NIBBLE ALTO

	DELAY_LCD 0x01				;SE PONE UN DELAY DE 60 us. SEGUN EL LIBRO ESTE DELAY VA CUANDO SE MANDAN COMANDOS, NO SE PORQUE LO PONE ACÁ					;SE RECUPERAN LOS DATOS
	;POP R14
	POP R21
	POP R20
	RET
;************************************************************************************************
CMNDWRT_LCD:
;Envía un comando a la pantalla LCD, previamente alojado en el R16.
;REGISTROS UTILIZADOS: R14, R21, R20
	PUSH R20					;SE COPIAN LOS DATOS PARA NO PERDERLOS
	PUSH R21
	;PUSH R14
	MOV R20, R14				;SE COPIA EL DATO A ENVIAR, DEL REGISTRO 16 AL REGISTRO 27
	ANDI R20, 0xF0				;SE APLICA UNA MASCARA 11110000 PARA QUEDARSE CON EL NIBBLE ALTO
	IN R21, PIN_LCD				;EL DATO DEL PUERTO, PARA NO PERDERLO
	ANDI R21, 0x0F				;ME QUEDO CON EL NIBBLE NO UTILIZADO CUANDO ENVÍO EL DATO
	OR R21, R20					;COMBINO EL DATO CON LA CONFIGURACION DEL RESTO DEL PUERTO
	OUT PUERTO_LCD, R21			;SE COLOCA EL DATO EN EL PUERTO 
	CBI PUERTO_LCD, PIN_RS		;PIN RS EN 0, PARA PODER ENVIAR DATOS AL LCD
	SBI PUERTO_LCD, PIN_ENABLE	;SE PONE UN 1 EN ENABLE PARA EMPEZAR A ENVIAR EL DATO
	CALL SDELAY					;SE LLAMA A UN DELAY YA QUE EL PULSO DEBE TENER UN CIERTO ANCHO
	CBI PUERTO_LCD, PIN_ENABLE	;SE PONE EL ENABLE EN 0 PARA TERMINAR LA TRANSMISIÓN DEL NIBBLE ALTO

	MOV R20, R14				;SE COPIA EL DATO ORIGINAL NUEVAMENTE AL REGISTRO 27
	SWAP R20					;SE INVIERTEN LOS NIBBLES DEL DATO
	ANDI R20, 0xF0				;SE APLICA LA MASCARA NUEVAMENTE PARA RECUPERAR SOLO EL NIBBLE
	IN R21, PIN_LCD				;EL DATO DEL PUERTO, PARA NO PERDERLO
	ANDI R21, 0x0F				;ME QUEDO CON LA PARTE QUE NO ES DE DATOS
	OR R21, R20					;COMBINO EL DATO A ENVIAR Y LA CONFIG DEL PUERTO
	OUT PUERTO_LCD, R21			;SE COLOCA EL DATO EN EL PUERTO 
	SBI PUERTO_LCD, PIN_ENABLE	;SE PONE UN 1 EN ENABLE PARA EMPEZAR A ENVIAR EL DATO
	CALL SDELAY					;SE LLAMA A UN DELAY YA QUE EL PULSO DEBE TENER UN CIERTO ANCHO
	CBI PUERTO_LCD, PIN_ENABLE	;SE PONE EL ENABLE EN 0 PARA TERMINAR LA TRANSMISIÓN DEL NIBBLE ALTO

	DELAY_LCD 0x01				;SE PONE UN DELAY DE 100 us. SEGUN EL LIBRO ESTE DELAY VA CUANDO SE MANDAN COMANDOS, NO SE PORQUE LO PONE ACÁ						;SE RECUPERAN LOS DATOS
	;POP R14
	POP R21
	POP R20
	RET
;************************************************************************************************
SDELAY:
;Delay de dos ciclos de máquina (para 16 megahertz, serían unos 125ns, sumados al call previo y al ret, un total de 625 ns).
;Este delay se utiliza para generar el pulso en el pin ENABLE, cuando se envía un dato/comando al LCD.
	NOP
	NOP
	RET
;************************************************************************************************
LCD_INTERRUPCION_OVERFLOW:
;Se ejecuta cuando ocurre un overflow del timer. Se revisa el registro 18. Si hay un valor distinto de cero
;Se decrementa en 1. Si no, no se hace nada
;Registros utilizados: R14, R16
	PUSH R16

	IN R16, SREG
	PUSH R16

	MOV R16, R14
	CPI R16, 0x00
	BREQ TRUE
	DEC R14
TRUE:
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;************************************************************************************************
; TODO: CAMBIAR DDRB PORQUE ES EL PUERTO QUE RECIBE LOS PULSOS
CONFIGURAR_PUERTOS_LCD:
	PUSH R16
	LDI R16, 0xFF
	OUT DDR_LCD, R16			;PUERTO DEL LCD COMO SALIDA
	LDI R16, 0xFE				;|O|O|O|O|O|O|O|I|
	OUT DDRB, R16				;Puerto B como salida para el LED
	POP R16
	RET

;************************************************************************************************
STRING_WRT_LCD:
;Función para escribir cadenas de caracteres en el LCD. Recibe el puntero a la posición de la string y la envía caracter por caracter al LCD. Recibe el
;puntero Z cargado en la posición del STRING para enviar el dato.
;Registros utilizados: R16
	PUSH R16
	PUSH R14

	ESCRIBIR_SIGUIENTE_CARACTER:
		LD R16, Z+							;Se carga el primer caracter al registro R16, que utiliza la función DATAWRT_LCD, para enviar el dato
		CPI R16, 0							;Si es 0 es porque terminé la string.
		BREQ END_STRING		
		MOV R14, R16
		CALL DATAWRT_LCD					;Se invoca a la función para escribir el dato
		RJMP ESCRIBIR_SIGUIENTE_CARACTER	;Se sigue escribiendo hasta terminar la string
	END_STRING:
		POP R14
		POP R16
		RET
;************************************************************************************************

STRING_WRT_LCD_FLASH:
;Función para escribir cadenas de caracteres en el LCD. Recibe el puntero a la posición de la string y la envía caracter por caracter al LCD. Recibe el
;puntero Z cargado en la posición del STRING para enviar el dato. LA STRING DEBE ESTAR EN FLASH!
;Registros utilizados: R16
	PUSH R16
	PUSH R14

	ESCRIBIR_SIGUIENTE_CARACTER_FLASH:
		LPM R16, Z+							;Se carga el primer caracter al registro R16, que utiliza la función DATAWRT_LCD, para enviar el dato
		CPI R16, 0							;Si es 0 es porque terminé la string.
		BREQ END_STRING_FLASH		
		MOV R14, R16
		CALL DATAWRT_LCD					;Se invoca a la función para escribir el dato
		RJMP ESCRIBIR_SIGUIENTE_CARACTER_FLASH	;Se sigue escribiendo hasta terminar la string
	END_STRING_FLASH:
		POP R14
		POP R16
		RET
;************************************************************************************************


MENSAJE_BIENVENIDA_LCD: .db "Contador Geiger", 0
MENSAJE_PROMEDIO_LCD: .db "Promedio:", 0
ESPACIO: .db "                ", 0