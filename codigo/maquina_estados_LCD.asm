; Maquina de estados para mostrar los menús en el LCD

.DEF ESTADOS_LCD = R22
; [7][6][5][4][3][2][1][0]
; Bits 7 y 6: indican si se debe escribir o no en el lcd

; Bit 5: Estado configurar duración de ventana

; Bit 4: Indica si estoy en el Menú Principal o no
; Bit 3: Estado configurar Buzzer/LED de umbral
; Bit 2: Estado configurar largo de medición

; Bit 1: Indica si estoy en el estado de medición o no

; Bit 0: Estado cambiar umbral

; Para la presentación del Menú principal, se va a mostrar como:

/*		==================			==================
		= Menú principal =	 -->	= Menú principal =
		= <Conf Umbral>  =	<--		= <Conf Vent  >  =
		==================			==================*/

; Sucede que, dado que se cuenta con un teclado con flechas para recorrer los menús, 
; para respetar un orden de los submenús disponibles, se deben definir subestados dentro
; del menú principal. Por ejemplo en el primer dibujo, si se presiona la tecla 
; flecha derecha, se cambia al segundo dibujo. Pero si luego se presiona la tecla 
; izquierda, se cambia de nuevo al primer dibujo. Son estados diferentes.
; Este problema se encara de la siguiente forma:

; Si se tiene en el registro ESTADOS_LCD = XX000001. Como el bit 4 está en 0, entonces
; quiere decir que no estoy en el menú principal. Como el bit 0 está en 1, entonces estoy
; en el menú cambiar umbral. En cambio si ESTADOS_LCD = XX010001. Ahora el bit 4 está
; en 1, por lo que estoy en el menú principal y como el bit 0 está en 1, estoy mostrando
; el mensaje del primer dibujo.

; Entonces:
; XX 01 0001 -> Menú principal, se muestra en el segundo renglón Configurar Umbral
; XX 11 0000 -> Menú principal, se muestra en el segundo renglón Configurar Ventana
; XX 01 0100 -> Menú principal, se muestra en el segundo renglón Configurar tiempo total de medición
; XX 01 1000 -> Menú principal, se muestra en el segundo renglón Configurar o no el uso del Buzzer/LED de superación de umbral

; XX 10 0001 -> Menú Configurar Ventana, se muestra en el esgundo renglón, 1ms
; XX 10 0010 -> Menú Configurar Ventana, se muestra en el segundo renglón, 10ms
; XX 10 0100 -> Menú Configurar Ventana, se muestra en el segundo renglón, 100ms
; XX 10 1000 -> Menú Configurar Ventana, se muestra en el segundo renglón, 1000ms

; XX 00 0001 -> Menú Configurar Umbral

; XX 00 0100 -> Menú Configurar Tiempo Total de Medición

; XX 00 1000 -> Menú Configurar uso o no del Buzzer, no
; XX 00 1001 -> Menú Configurar uso o no del Buzzer, sí


; XX 00 0010 -> Comenzar la medición

; XX 00 0000 -> Se está midiendo, por lo que no se permite el acceso al menú LCD

; 11 11 1111 -> Se terminó de medir

;************************************************************************************************

.EQU ESCRIBIR_PRIMER_RENGLON = 7					; Bit que indica que se puede escribir en el primer renglón: 1=sí, 0=no
.EQU ESCRIBIR_SEGUNDO_RENGLON = 6					; Bit que indica que se puede escribir en el segundo renglón: 1=sí, 0=no

.EQU CONF_VENTANA_LCD = 5							; 1 = estoy en el menú de configurar la ventana
.EQU MENU_PRINCIPAL_LCD = 4							; 1 = estoy en el menú principal, 0 = no estoy en el menú principal

.EQU CONF_BUZZER_LCD = 3							; 1 = estoy en el menu de configurar el buzzer, 0 = no estoy ahí
.EQU CONF_TIEMPO_TOTAL_LCD = 2						; 1 = estoy en el menú de configurar el tiempo de medición

.EQU COMENZAR_MEDICION_LCD = 1						; 1 = estado midiendo, 0 = no midiendo

.EQU CONF_UMBRAL_LCD = 0							; 1 = estoy en el menú de configurar el umbral

;************************************************************************************************
; Bits para el menú de ventana

.EQU VENTANA_LCD_1ms = 0
.EQU VENTANA_LCD_10ms = 1
.EQU VENTANA_LCD_100ms = 2
.EQU VENTANA_LCD_1000ms = 3
;************************************************************************************************
; Bits para el menú de Buzzer/LED

.EQU BUZZER_LCD_SI = 0

;************************************************************************************************
; Valores para el menú del tiempo

.EQU CURSOR_POS_1_TIEMPO = 0x01
.EQU CURSOR_POS_2_TIEMPO = 0x02
.EQU CURSOR_POS_3_TIEMPO = 0x03
.EQU CURSOR_POS_4_TIEMPO = 0x04
.EQU CURSOR_POS_5_TIEMPO = 0x05
;************************************************************************************************
; Valores para el menú del umbral

.EQU CURSOR_POS_1_UMBRAL = 0x01
.EQU CURSOR_POS_2_UMBRAL = 0x02
.EQU CURSOR_POS_3_UMBRAL = 0x03
.EQU CURSOR_POS_4_UMBRAL = 0x04
.EQU CURSOR_POS_5_UMBRAL = 0x05


;************************************************************************************************
; Valores para entrar a los diferentes menús
.EQU ENTRAR_MENU_UMBRAL = 0xC1
.EQU ENTRAR_MENU_VENTANA = 0xE1
.EQU ENTRAR_MENU_TIEMPO_TOTAL = 0xC4
.EQU ENTRAR_MENU_COMENZAR_MEDICION = 0xC2
.EQU ENTRAR_MENU_BUZZER = 0xC8
.EQU VOLVER_MENU_PRINCIPAL = 0xD1

.EQU MIDIENDO_LCD = 0x00
.EQU MEDICION_FINALIZADA_LCD = 0xFF
;************************************************************************************************
; Botones del registro del teclado

.EQU BOTON_OK = 1
.EQU BOTON_CANCELAR = 0
.EQU BOTON_INFERIOR = 2
.EQU BOTON_DERECHO = 3
.EQU BOTON_SUPERIOR = 4
.EQU BOTON_IZQUIERDA = 5
.EQU BOTON_ERROR = 7
;************************************************************************************************
.dseg
; RAM MENU UMBRAL================================================================================
MENU_UMBRAL_ASCII: .byte 6							; Se va a escribir la cadena ascii que se muestra por pantalla, del valor del umbral a setear
MENU_UMBRAL_POSICION_CURSOR: .byte 1				; Este byte indica el peso del valor que se quiere modificar (decena,centena,unidad,etc...)
													; [7][6][5][4][3][2][1][0] -> 
													; 0 = primer posicion, 1 = segunda posicion, 2 = tercer posicion, 3 = cuarta posicion, 4 = quinta posicion

; RAM MENU TIEMPO TOTAL==========================================================================

MENU_TIEMPO_TOTAL_ASCII: .byte 6					; El ascii del valor del tiempo total a setear

MENU_TIEMPO_TOTAL_POSICION_CURSOR: .byte 1			; Idem el byte de la posición del cursor para el umbral

;************************************************************************************************
.cseg
;************************************************************************************************


MAQUINA_ESTADOS_LCD:
; Máquina de estados del LCD, para saber qué menú se está visualizando.

	CPI ESTADOS_LCD, MEDICION_FINALIZADA_LCD
	BREQ EST_MENU_FIN_MEDICION

	SBRC ESTADOS_LCD, MENU_PRINCIPAL_LCD
	RJMP EST_MENU_PRINCIPAL
	
	SBRC ESTADOS_LCD, CONF_VENTANA_LCD
	RJMP EST_CONFIG_VENTANA

	SBRC ESTADOS_LCD, CONF_BUZZER_LCD
	RJMP EST_CONF_BUZZER

	SBRC ESTADOS_LCD, CONF_UMBRAL_LCD
	RJMP EST_CONF_UMBRAL

	SBRC ESTADOS_LCD, CONF_TIEMPO_TOTAL_LCD
	RJMP EST_CONFIGURAR_TIEMPO_TOTAL

	SBRC ESTADOS_LCD, COMENZAR_MEDICION_LCD
	RJMP EST_COMENZAR_MEDICION




RET

;************************************************************************************************

EST_MENU_FIN_MEDICION:

	SBRC BOTONES_TECLADO, BOTON_OK
	LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL

	RET

;************************************************************************************************

EST_MENU_PRINCIPAL:

	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON			; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_MENU_PRINCIPAL

	COMANDO_LCD LCD_HOME_SCREEN							; Se escribe en el renglón superior
	BORRAR_RENGLON										; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN							; Se posiciona al extremo superior izquierdo
	CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL				; Se escribe el mensaje de menú principal
		
	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)			; Se deshabilita la opción de describir en el primer renglón

SEGUIR_1_MENU_PRINCIPAL:
	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON
	RJMP SEGUIR_2_MENU_PRINCIPAL

	COMANDO_LCD LCD_CAMBIAR_RENGLON
	BORRAR_RENGLON
	COMANDO_LCD LCD_CAMBIAR_RENGLON
	CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_UMBRAL
	SBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)
	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)

SEGUIR_2_MENU_PRINCIPAL:
	;SBRS BOTONES_TECLADO, BOTON_ERROR
	CALL ACCION_BOTON_MENU_PRINCIPAL					; Se va a chequear en un registro, si se presionó algún botón, y que acción tomar, para el menú principal
	
RET

;************************************************************************************************
EST_CONF_UMBRAL:

	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON					; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_CONF_UMBRAL

	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	BORRAR_RENGLON												; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	CADENA_FLASH_LCD MENSAJE_MENU_UMBRAL						; Se muestra el texto que indica que me encuentro en el menú de cambio de umbral

	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se deshabilita la opción de escribir en el primer renglón

	PUSH R29
	PUSH R17
	PUSH R16
	PUSH XH
	PUSH XL

	LDS R29, REGISTRO_UMBRAL
	LDS R17, REGISTRO_UMBRAL+1
	LDS R16, REGISTRO_UMBRAL+2
	LDI XL, LOW(MENU_UMBRAL_ASCII)
	LDI XH, HIGH(MENU_UMBRAL_ASCII)

	CALL DEC_TO_ASCII_24_BITS

	POP XL
	POP XH
	POP R16
	POP R17
	POP R29

	PUSH R17													; Se inicializa el cursor en la posición de unidades
	LDI R17, CURSOR_POS_1_UMBRAL
	STS MENU_UMBRAL_POSICION_CURSOR, R17
	POP R17 
	
SEGUIR_1_CONF_UMBRAL:
	
	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON						; Si está en 0 se saltea la escritura del segundo renglón
	RJMP SEGUIR_2_CONF_UMBRAL

	COMANDO_LCD LCD_CAMBIAR_RENGLON									; Me paro en el segundo renglón
	BORRAR_RENGLON													; Se limpia el renglón
	COMANDO_LCD LCD_CAMBIAR_RENGLON									; Me paro en el extremo izquierdo del segundo renglón
	COMANDO_LCD LCD_CURSOR_ON
	PUSH ZH
	PUSH ZL
	LDI ZL, LOW(MENU_UMBRAL_ASCII)									; Se va a escribir lo que haya previamente cargado en el puntero Z
	LDI ZH, HIGH(MENU_UMBRAL_ASCII)
	CALL STRING_WRT_LCD
	POP ZL
	POP ZH

	PUSH R17
	LDS R17, MENU_UMBRAL_POSICION_CURSOR							; Se carga donde se encuentra el cursor
	SIGO_SHIFTEO_UMBRAL:
		CPI R17, 0x00
		BREQ LISTO_SHIFTEO_UMBRAL
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_IZQUIERDA
		DEC R17
		RJMP SIGO_SHIFTEO_UMBRAL

	LISTO_SHIFTEO_UMBRAL:	
	POP R17
											
	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)					; Se deshabilita la escritura del segundo renglón

SEGUIR_2_CONF_UMBRAL:

CALL ACCION_BOTON_CONF_UMBRAL										; Si se presionó un boton, se toma una acción en base a ese botón
	


RET

;************************************************************************************************
EST_CONFIG_VENTANA:
	
	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON					; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_CONF_VENTANA

	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	BORRAR_RENGLON												; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	CADENA_FLASH_LCD MENSAJE_MENU_VENTANA						; Se muestra el texto que indica que me encuentro en el menú de cambio de umbral

	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se deshabilita la opción de escribir en el primer renglón

SEGUIR_1_CONF_VENTANA:

	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON					; Si está en 0 se saltea la escritura del segundo renglón
	RJMP SEGUIR_2_CONF_VENTANA

	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el segundo renglón
	BORRAR_RENGLON												; Se limpia el renglón
	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el extremo izquierdo del segundo renglón

	CADENA_FLASH_LCD MENSAJE_1_ms

	;CALL STRING_WRT_FLASH										; Se va a escribir lo que haya previamente cargado en el puntero Z
	SBR ESTADOS_LCD, (1<<VENTANA_LCD_1ms)													; El puntero Z se carga en la toma de decisiones en función del botón presionado
	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)					; Se deshabilita la escritura del segundo renglón

SEGUIR_2_CONF_VENTANA:

CALL ACCION_BOTON_CONF_VENTANA									; Se debe tomar una accion en base al boton presionado por el usuario

RET
;************************************************************************************************
EST_CONFIGURAR_TIEMPO_TOTAL:

	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON					; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_CONF_TIEMPO

	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	BORRAR_RENGLON												; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	CADENA_FLASH_LCD MENSAJE_MENU_TIEMPO						; Se muestra el texto que indica que me encuentro en el menú de cambio de umbral

	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se deshabilita la opción de escribir en el primer renglón

	PUSH R29
	PUSH R17
	PUSH R16
	PUSH XH
	PUSH XL

	LDS R29, VENTANAS_A_MEDIR_RAM
	LDS R17, VENTANAS_A_MEDIR_RAM+1
	LDS R16, VENTANAS_A_MEDIR_RAM+2
	LDI XL, LOW(MENU_TIEMPO_TOTAL_ASCII)
	LDI XH, HIGH(MENU_TIEMPO_TOTAL_ASCII)

	CALL DEC_TO_ASCII_24_BITS

	POP XL
	POP XH
	POP R16
	POP R17
	POP R29

	PUSH R17													; Se inicializa el cursor en la posición de unidades
	LDI R17, CURSOR_POS_1_TIEMPO
	STS MENU_TIEMPO_TOTAL_POSICION_CURSOR, R17
	POP R17 
	
SEGUIR_1_CONF_TIEMPO:
	
	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON					; Si está en 0 se saltea la escritura del segundo renglón
	RJMP SEGUIR_2_CONF_TIEMPO

	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el segundo renglón
	BORRAR_RENGLON												; Se limpia el renglón
	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el extremo izquierdo del segundo renglón
	COMANDO_LCD LCD_CURSOR_ON
	PUSH ZH
	PUSH ZL
	LDI ZL, LOW(MENU_TIEMPO_TOTAL_ASCII)								; Se va a escribir lo que haya previamente cargado en el puntero Z
	LDI ZH, HIGH(MENU_TIEMPO_TOTAL_ASCII)
	CALL STRING_WRT_LCD
	POP ZL
	POP ZH

	PUSH R17
	LDS R17, MENU_TIEMPO_TOTAL_POSICION_CURSOR						; Se carga donde se encuentra el cursor
	SIGO_SHIFTEO:
		CPI R17, 0x00
		BREQ LISTO_SHIFTEO
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_IZQUIERDA
		DEC R17
		RJMP SIGO_SHIFTEO

	LISTO_SHIFTEO:	
	POP R17
											
	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)					; Se deshabilita la escritura del segundo renglón

SEGUIR_2_CONF_TIEMPO:

CALL ACCION_BOTON_CONF_TIEMPO									; Si se presionó un boton, se toma una acción en base a ese botón

RET
;************************************************************************************************
EST_COMENZAR_MEDICION:

	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON					; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_COMENZAR_MEDICION

	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	BORRAR_RENGLON												; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	CADENA_FLASH_LCD MENSAJE_MENU_MIDIENDO						; Se muestra el texto que indica que me encuentro en el menú de cambio de umbral

	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se deshabilita la opción de escribir en el primer renglón

SEGUIR_1_COMENZAR_MEDICION:
	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON					; Escribo el segundo renglón
	RJMP SEGUIR_2_COMENZAR_MEDICION

	COMANDO_LCD LCD_CAMBIAR_RENGLON
	BORRAR_RENGLON
	COMANDO_LCD LCD_CAMBIAR_RENGLON
	
	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)	

	SEGUIR_2_COMENZAR_MEDICION:

	LDI ESTADOS_LCD, MIDIENDO_LCD											; Se carga el estado de estar midiendo. Durante este estado no se entrará al menú de 
																			; la pantalla LCD
	
	SBR ESTADO, (1<<EST_OSCIOSO_MEDICION)									; Bits necesarios para poder comenzar a medir
	SBR EVENTO, (1<<COMENZAR_MEDICION)

RET
;************************************************************************************************
EST_CONF_BUZZER:

	SBRS ESTADOS_LCD, ESCRIBIR_PRIMER_RENGLON					; Si está en 0 el bit que habilita escribir el primer renglón, se saltea la escritura
	RJMP SEGUIR_1_CONF_BUZZER

	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	BORRAR_RENGLON												; Se borra el primer renglón
	COMANDO_LCD LCD_HOME_SCREEN									; Se posiciona en el primer renglón
	CADENA_FLASH_LCD MENSAJE_MENU_BUZZER						; Se muestra el texto que indica que me encuentro en el menú de cambio de umbral

	CBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se deshabilita la opción de escribir en el primer renglón

SEGUIR_1_CONF_BUZZER:

	SBRS ESTADOS_LCD, ESCRIBIR_SEGUNDO_RENGLON					; Si está en 0 se saltea la escritura del segundo renglón
	RJMP SEGUIR_2_CONF_BUZZER

	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el segundo renglón
	BORRAR_RENGLON												; Se limpia el renglón
	COMANDO_LCD LCD_CAMBIAR_RENGLON								; Me paro en el extremo izquierdo del segundo renglón

	CADENA_FLASH_LCD MENSAJE_BUZZER_NO

	CBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)					; Se deshabilita la escritura del segundo renglón

SEGUIR_2_CONF_BUZZER:

	CALL ACCION_BOTON_CONF_BUZZER									; Se debe tomar una accion en base al boton presionado por el usuario

RET
;************************************************************************************************
; Menú de toma de acciones en función del botón presionado, en cada menú


ACCION_BOTON_MENU_PRINCIPAL:
; Menú donde se toma una decisión en base al botón presionado, 
; dentro del menú principal

	SBRS BOTONES_TECLADO, BOTON_IZQUIERDA						; Salteo si no se presionó el boton izquierda
	RJMP CHEQUEAR_BOTON_DERECHO_MENU_PRINCIPAL
; ======================================================
		SBRS ESTADOS_LCD, CONF_UMBRAL_LCD							; Salteo si no estaba mostrando la opción de entrar al menú de umbral
		RJMP ACCION_MENU_PRINCIPAL_IZQ_VENTANA

		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
		BORRAR_RENGLON											; Se limpia el segundo renglón
		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro al inicio del segundo renglón

		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_MEDIR			; Escribo la opción de poder entrar a medir
		CBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)						; Se quita la opción de poder ingresar al menú de umbral
		SBR ESTADOS_LCD, (1<<COMENZAR_MEDICION_LCD)					; Se setea la opción de poder ingresar al menú para comenzar la medición
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_IZQ_VENTANA:

		SBRS ESTADOS_LCD, CONF_VENTANA_LCD						; Salteo si no estaba mostrando la opción de comenzar la medición
		RJMP ACCION_MENU_PRINCIPAL_IZQ_LARGO_TOTAL

		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
		BORRAR_RENGLON											; Se limpia el segundo renglón
		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro al inicio del segundo renglón
		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_UMBRAL			; Escribo la opción de poder configurar el umbral
		CBR ESTADOS_LCD, (1<<CONF_VENTANA_LCD)
		SBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_IZQ_LARGO_TOTAL:

		SBRS ESTADOS_LCD, CONF_TIEMPO_TOTAL_LCD
		RJMP ACCION_MENU_PRINCIPAL_IZQ_BUZZER

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON
		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_VENTANA
		CBR ESTADOS_LCD, (1<<CONF_TIEMPO_TOTAL_LCD)
		SBR ESTADOS_LCD, (1<<CONF_VENTANA_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_IZQ_BUZZER:

		SBRS ESTADOS_LCD, CONF_BUZZER_LCD
		RJMP ACCION_MENU_PRINCIPAL_IZQ_COMENZAR_MEDICION

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON
		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_DURACION
		CBR ESTADOS_LCD, (1<<CONF_BUZZER_LCD)
		SBR ESTADOS_LCD, (1<<CONF_TIEMPO_TOTAL_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_IZQ_COMENZAR_MEDICION:

		SBRS ESTADOS_LCD, COMENZAR_MEDICION_LCD
		RJMP CHEQUEAR_BOTON_DERECHO_MENU_PRINCIPAL

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON
		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_BUZZER
		CBR ESTADOS_LCD, (1<<COMENZAR_MEDICION_LCD)
		SBR ESTADOS_LCD, (1<<CONF_BUZZER_LCD)
		RET
; ======================================================

	CHEQUEAR_BOTON_DERECHO_MENU_PRINCIPAL:

	SBRS BOTONES_TECLADO, BOTON_DERECHO
	RJMP CHEQUEAR_BOTON_ARRIBA_MENU_PRINCIPAL

; ======================================================
		SBRS ESTADOS_LCD, CONF_UMBRAL_LCD							; Salteo si no estaba mostrando la opción de entrar al menú de umbral
		RJMP ACCION_MENU_PRINCIPAL_DER_VENTANA

		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
		BORRAR_RENGLON											; Se limpia el segundo renglón
		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro al inicio del segundo renglón

		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_VENTANA			; Escribo la opción de poder entrar a medir
		CBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)						; Se quita la opción de poder ingresar al menú de umbral
		SBR ESTADOS_LCD, (1<<CONF_VENTANA_LCD)						; Se setea la opción de poder ingresar al menú para comenzar la medición
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_DER_VENTANA:

		SBRS ESTADOS_LCD, CONF_VENTANA_LCD						; Salteo si no estaba mostrando la opción de comenzar la medición
		RJMP ACCION_MENU_PRINCIPAL_DER_LARGO_TOTAL

		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
		BORRAR_RENGLON											; Se limpia el segundo renglón
		COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro al inicio del segundo renglón

		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_DURACION		; Escribo la opción de poder configurar el umbral
		CBR ESTADOS_LCD, (1<<CONF_VENTANA_LCD)
		SBR ESTADOS_LCD, (1<<CONF_TIEMPO_TOTAL_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_DER_LARGO_TOTAL:

		SBRS ESTADOS_LCD, CONF_TIEMPO_TOTAL_LCD
		RJMP ACCION_MENU_PRINCIPAL_DER_BUZZER

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON

		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_BUZZER
		CBR ESTADOS_LCD, (1<<CONF_TIEMPO_TOTAL_LCD)
		SBR ESTADOS_LCD, (1<<CONF_BUZZER_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_DER_BUZZER:

		SBRS ESTADOS_LCD, CONF_BUZZER_LCD
		RJMP ACCION_MENU_PRINCIPAL_DER_COMENZAR_MEDICION

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON
		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_MEDIR
		CBR ESTADOS_LCD, (1<<CONF_BUZZER_LCD)
		SBR ESTADOS_LCD, (1<<COMENZAR_MEDICION_LCD)
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_DER_COMENZAR_MEDICION:

		SBRS ESTADOS_LCD, COMENZAR_MEDICION_LCD
		RJMP CHEQUEAR_BOTON_ARRIBA_MENU_PRINCIPAL

		COMANDO_LCD LCD_CAMBIAR_RENGLON
		BORRAR_RENGLON
		COMANDO_LCD LCD_CAMBIAR_RENGLON

		CADENA_FLASH_LCD MENSAJE_MENU_PRINCIPAL_UMBRAL
		CBR ESTADOS_LCD, (1<<COMENZAR_MEDICION_LCD)
		SBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)
		RET
; ======================================================
	CHEQUEAR_BOTON_ARRIBA_MENU_PRINCIPAL:

	SBRS BOTONES_TECLADO, BOTON_SUPERIOR
	RJMP CHEQUEAR_BOTON_ABAJO_MENU_PRINCIPAL
	RET															; Para el caso del menú principal, el botón superior no activa nada

	CHEQUEAR_BOTON_ABAJO_MENU_PRINCIPAL:

	SBRS BOTONES_TECLADO, BOTON_INFERIOR
	RJMP CHEQUEAR_BOTON_OK_MENU_PRINCIPAL
	RET															; Para el caso del menú principal, el botón inferior no activa nada

	CHEQUEAR_BOTON_OK_MENU_PRINCIPAL:
	SBRS BOTONES_TECLADO, BOTON_OK
	RJMP CHEQUEAR_BOTON_CANCELAR_MENU_PRINCIPAL

; ======================================================
		SBRS ESTADOS_LCD, CONF_UMBRAL_LCD							; Salteo si no estaba mostrando la opción de entrar al menú de umbral
		RJMP ACCION_MENU_PRINCIPAL_OK_VENTANA

		LDI ESTADOS_LCD, ENTRAR_MENU_UMBRAL							; Se setean los estados para entrar al menú de umbral
		
/*		CBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se setea que ya no se está en el menu principal
		SBR ESTADOS_LCD, (1<<CONF_UMBRAL_LCD)						; Se setea que se quiere entrar al menu de configurar el umbral
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)				; Se habilita que se escriba en el primer renglon*/
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_OK_VENTANA:	
		SBRS ESTADOS_LCD, CONF_VENTANA_LCD
		RJMP ACCION_MENU_PRINCIPAL_OK_DURACION


		LDI ESTADOS_LCD, ENTRAR_MENU_VENTANA
/*		CBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)					; Se indica que ya no estoy en el menu principal
		SBR ESTADOS_LCD, (1<<CONF_VENTANA_LCD)						; Se indica que ahora voy a estar en el menú de configuracion de ventana
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)				; Se habilita la escritura del primer renglon
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_OK_DURACION:
		SBRS ESTADOS_LCD, CONF_TIEMPO_TOTAL_LCD
		RJMP ACCION_MENU_PRINCIPAL_OK_BUZZER

		LDI ESTADOS_LCD, ENTRAR_MENU_TIEMPO_TOTAL

/*		CBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se indica que ya no se está en el el menú principal
		SBR ESTADOS_LCD, (1<<CONF_TIEMPO_TOTAL_LCD)					; Se indica que ahora estoy en el menú de configurar buzzer
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)				; Se habilita la escritura del primer renglón
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/

		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_OK_BUZZER:
		SBRS ESTADOS_LCD, CONF_BUZZER_LCD
		RJMP ACCION_MENU_PRINCIPAL_OK_MEDIR

		LDI ESTADOS_LCD, ENTRAR_MENU_BUZZER

/*		CBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se inhabilita que estoy en el menú principal
		SBR ESTADOS_LCD, (1<<CONF_BUZZER_LCD)						; Se habilita que se va a entrar en el menú de configurar el buzzer
		SBR EStADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)					; Se habilita la escritura del primer renglón*/
		RET
; ======================================================
		ACCION_MENU_PRINCIPAL_OK_MEDIR:
		SBRS ESTADOS_LCD, COMENZAR_MEDICION_LCD
		RJMP NO_ACCION_MENU_PRINCIPAL_OK

		LDI ESTADOS_LCD, ENTRAR_MENU_COMENZAR_MEDICION

/*		CBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se inhabilita que estoy en el menú principal
		SBR ESTADOS_LCD, (1<<COMENZAR_MEDICION_LCD)					; Se habilita que se entra en el menú medir
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)				; Se habilita la inscripción del primer renglón
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		RET

		NO_ACCION_MENU_PRINCIPAL_OK:
; ======================================================
	CHEQUEAR_BOTON_CANCELAR_MENU_PRINCIPAL:

	SBRS BOTONES_TECLADO, BOTON_CANCELAR
	RJMP NO_BOTON_MENU_PRINCIPAL

	RET															; En particular en el menú principal, no se toma ninguna acción, si se presiona cancelar
	NO_BOTON_MENU_PRINCIPAL:
RET
;************************************************************************************************
ACCION_BOTON_CONF_VENTANA:

	SBRS BOTONES_TECLADO, BOTON_IZQUIERDA							; Si estoy en la ventana y presiono el botón izquierdo, entro aquí
	RJMP CHEQUEAR_BOTON_DERECHO_VENTANA
		
		SBRS ESTADOS_LCD, VENTANA_LCD_1ms							; Si no estoy en la posición de mostrar 1 ms, salteo esta parte				
		RJMP BOTON_IZQUIERDA_VENTANA_10ms							; Sigo comprobando si estoy en la posición de mostrar 10ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_1000_ms						; Se escribe el mensaje de 1000ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_1000ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_1ms)

			RJMP NO_ACCION_VENTANA

		BOTON_IZQUIERDA_VENTANA_10ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_10ms
		RJMP BOTON_IZQUIERDA_VENTANA_100ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_1_ms							; Se escribe el mensaje de 1_ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_1ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_10ms)

			RJMP NO_ACCION_VENTANA
		
		BOTON_IZQUIERDA_VENTANA_100ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_100ms
		RJMP BOTON_IZQUIERDA_VENTANA_1000ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_10_ms							; Se escribe el mensaje de 10 ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_10ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_100ms)

			RJMP NO_ACCION_VENTANA
			
		BOTON_IZQUIERDA_VENTANA_1000ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_1000ms
		RJMP CHEQUEAR_BOTON_DERECHO_VENTANA

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_100_ms							; Se escribe el mensaje de 100ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_100ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_1000ms)

			RJMP NO_ACCION_VENTANA

	CHEQUEAR_BOTON_DERECHO_VENTANA:

	SBRS BOTONES_TECLADO, BOTON_DERECHO
	RJMP CHEQUEAR_BOTON_SUPERIOR_VENTANA

		SBRS ESTADOS_LCD, VENTANA_LCD_1ms										; Si no estoy en la posición de mostrar 1 ms, salteo esta parte				
		RJMP BOTON_DERECHA_VENTANA_10ms							; Sigo comprobando si estoy en la posición de mostrar 10ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_10_ms							; Se escribe el mensaje de 10 ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_10ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_1ms)

			RJMP NO_ACCION_VENTANA

		BOTON_DERECHA_VENTANA_10ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_10ms
		RJMP BOTON_DERECHA_VENTANA_100ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_100_ms							; Se escribe el mensaje de 100 ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_100ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_10ms)

			RJMP NO_ACCION_VENTANA
		
		BOTON_DERECHA_VENTANA_100ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_100ms
		RJMP BOTON_DERECHA_VENTANA_1000ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_1000_ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_1000ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_100ms)

			RJMP NO_ACCION_VENTANA
			
		BOTON_DERECHA_VENTANA_1000ms:
		SBRS ESTADOS_LCD, VENTANA_LCD_1000ms
		RJMP CHEQUEAR_BOTON_SUPERIOR_VENTANA

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_1_ms

			SBR ESTADOS_LCD, (1<<VENTANA_LCD_1ms)
			CBR ESTADOS_LCD, (1<<VENTANA_LCD_1000ms)

			RJMP NO_ACCION_VENTANA

		
		
	CHEQUEAR_BOTON_SUPERIOR_VENTANA:
	SBRS BOTONES_TECLADO, BOTON_SUPERIOR
	RJMP CHEQUEAR_BOTON_INFERIOR_VENTANA

			RJMP NO_ACCION_VENTANA


	CHEQUEAR_BOTON_INFERIOR_VENTANA:
	SBRS BOTONES_TECLADO, BOTON_INFERIOR
	RJMP CHEQUEAR_BOTON_OK_VENTANA

		RJMP NO_ACCION_VENTANA

	CHEQUEAR_BOTON_OK_VENTANA:
	SBRS BOTONES_TECLADO, BOTON_OK
	RJMP CHEQUEAR_BOTON_CANCELAR_VENTANA
	PUSH R16

		VENTANA_GUARDAR_1_ms:

		SBRS ESTADOS_LCD, VENTANA_LCD_1ms							; Si el usuario está visulizando 1 ms, se guarda dicha configuración
		RJMP VENTANA_GUARDAR_10_ms

			LDI R16, VENTANA_1ms
			RJMP VENTANA_GUARDAR_SEGUIR

		VENTANA_GUARDAR_10_ms:										; Si el usuario está visulizando 10 ms, se guarda dicha configuración
		SBRS ESTADOS_LCD, VENTANA_LCD_10ms
		RJMP VENTANA_GUARDAR_100_ms

			LDI R16, VENTANA_10ms
			RJMP VENTANA_GUARDAR_SEGUIR

		VENTANA_GUARDAR_100_ms:										; Si el usuario está visulizando 100 ms, se guarda dicha configuración
		SBRS ESTADOS_LCD, VENTANA_LCD_100ms
		RJMP VENTANA_GUARDAR_1000ms

			LDI R16, VENTANA_100ms
			RJMP VENTANA_GUARDAR_SEGUIR

		VENTANA_GUARDAR_1000ms:										; Si el usuario está visulizando 1000 ms, se guarda dicha configuración
		SBRS ESTADOS_LCD, VENTANA_LCD_1000ms
		RJMP VENTANA_GUARDAR_SEGUIR

			LDI R16, VENTANA_1000ms
			RJMP VENTANA_GUARDAR_SEGUIR

		VENTANA_GUARDAR_SEGUIR:

		STS REGISTRO_VENTANA_TIEMPO, R16
		POP R16

		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)					; Configuro que vuelvo al menú principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Indico que puedo escribir nuevamente en el segundo renglón*/
		RJMP NO_ACCION_VENTANA

	CHEQUEAR_BOTON_CANCELAR_VENTANA:
	SBRS BOTONES_TECLADO, BOTON_CANCELAR
	RJMP NO_ACCION_VENTANA
		
		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Configuro que vuelvo al menú principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Indico que puedo escribir nuevamente en el segundo renglón*/
		RJMP NO_ACCION_VENTANA
		

	NO_ACCION_VENTANA:

RET

;************************************************************************************************
ACCION_BOTON_CONF_TIEMPO:

	PUSH R17
	LDS R17, MENU_TIEMPO_TOTAL_POSICION_CURSOR					; Se carga el dato de la posición del cursor

	SBRS BOTONES_TECLADO, BOTON_IZQUIERDA
	RJMP CHEQUEAR_BOTON_DERECHO_TIEMPO

		; Se chequea donde está el cursor, y donde debería estar ahora
		CPI R17, CURSOR_POS_5_TIEMPO							; Si me encuentro en la posición más significativa, entonces no hago nada, ya que no puedo mover cursor
		BRNE TIEMPO_INCREMENTAR_CURSOR
		RJMP NO_ACCION_TIEMPO

		TIEMPO_INCREMENTAR_CURSOR:
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_IZQUIERDA				; Si no, incremento el valor de la posición del cursor.
		INC R17
		RJMP NO_ACCION_TIEMPO

	CHEQUEAR_BOTON_DERECHO_TIEMPO:								; Idem botón izquierdo pero para el botón derecho

	SBRS BOTONES_TECLADO, BOTON_DERECHO
	RJMP CHEQUEAR_BOTON_SUPERIOR_TIEMPO

		CPI R17, CURSOR_POS_1_TIEMPO
		BRNE TIEMPO_DECREMENTAR_CURSOR
		RJMP NO_ACCION_TIEMPO

		TIEMPO_DECREMENTAR_CURSOR:
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_DERECHA
		DEC R17
		RJMP NO_ACCION_TIEMPO

	CHEQUEAR_BOTON_SUPERIOR_TIEMPO:										; Se utiliza para incrementar el total del valor de la cantidad de ventanas a medir
	SBRS BOTONES_TECLADO, BOTON_SUPERIOR
	RJMP CHEQUEAR_BOTON_INFERIOR_TIEMPO
		
		PUSH ZL
		PUSH ZH

		LDI ZL, LOW(MENU_TIEMPO_TOTAL_ASCII)							; Se levanta el ASCII de la cantidad de ventanas a medir, para modificarlo según corresponda
		LDI ZH, HIGH(MENU_TIEMPO_TOTAL_ASCII)

		CPI R17, CURSOR_POS_1_TIEMPO									; Chequeo si se está en la posición menos significativa
		BRNE CHEQUEO_POS_2_TIEMPO_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_5_TIEMPO -1							; Se corre el cursor hasta la posición menos significativa
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO


		CHEQUEO_POS_2_TIEMPO_ARRIBA:

		CPI R17, CURSOR_POS_2_TIEMPO
		BRNE CHEQUEO_POS_3_TIEMPO_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_4_TIEMPO -1							; Se corre el cursor hasta la posición de las decenas
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_3_TIEMPO_ARRIBA:

		CPI R17, CURSOR_POS_3_TIEMPO
		BRNE CHEQUEO_POS_4_TIEMPO_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_3_TIEMPO -1							; Se corre el cursor hasta la posición de las centenas
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_4_TIEMPO_ARRIBA:

		CPI R17, CURSOR_POS_4_TIEMPO
		BRNE CHEQUEO_POS_5_TIEMPO_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_2_TIEMPO -1							; Se corre el cursor hasta la posición de las unidades de mil
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_5_TIEMPO_ARRIBA:

		CPI R17, CURSOR_POS_5_TIEMPO
		BRNE BOTON_SUPERIOR_TIEMPO_SEGUIR

			ADIW ZH:ZL, CURSOR_POS_1_TIEMPO -1							; Se corre el cursor hasta la posición de las decenas de mil
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO

		BOTON_SUPERIOR_CAMBIAR_VALOR_TIEMPO:							; Por último, se modifica el valor correspondiente y se guarda
			
			PUSH R18
			LD R18, Z													; Se carga el caracter ascii correspondiente
			CPI R18, '9'												; Si el caracter es un 9 ascii, no se puede incrementar más
			BREQ BOTON_SUPERIOR_TIEMPO_0

			INC R18

			RJMP BOTON_SUPERIOR_TIEMPO_SEGUIR

			BOTON_SUPERIOR_TIEMPO_0:
				LDI R18, '0'											; Se carga un 0 ascii
				
		BOTON_SUPERIOR_TIEMPO_SEGUIR:
			ST Z, R18													; Se guarda el dato incrementado
			POP R18														; Se recuperan los datos que había en los registros originalmente
			POP ZH
			POP ZL

			SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Se habilita la escritura en el segundo renglón
			RJMP NO_ACCION_TIEMPO

	CHEQUEAR_BOTON_INFERIOR_TIEMPO:
	SBRS BOTONES_TECLADO, BOTON_INFERIOR
	RJMP CHEQUEAR_BOTON_OK_TIEMPO

		PUSH ZL
		PUSH ZH

		LDI ZL, LOW(MENU_TIEMPO_TOTAL_ASCII)							; Se levanta el ASCII de la cantidad de ventanas a medir, para modificarlo según corresponda
		LDI ZH, HIGH(MENU_TIEMPO_TOTAL_ASCII)

		CPI R17, CURSOR_POS_1_TIEMPO									; Chequeo si se está en la posición menos significativa
		BRNE CHEQUEO_POS_2_TIEMPO_ABAJO

			ADIW ZH:ZL, CURSOR_POS_5_TIEMPO -1							; Se corre el cursor hasta la posición menos significativa
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO


		CHEQUEO_POS_2_TIEMPO_ABAJO:

		CPI R17, CURSOR_POS_2_TIEMPO
		BRNE CHEQUEO_POS_3_TIEMPO_ABAJO

			ADIW ZH:ZL, CURSOR_POS_4_TIEMPO -1							; Se corre el cursor hasta la posición de las decenas
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_3_TIEMPO_ABAJO:

		CPI R17, CURSOR_POS_3_TIEMPO
		BRNE CHEQUEO_POS_4_TIEMPO_ABAJO

			ADIW ZH:ZL, CURSOR_POS_3_TIEMPO -1							; Se corre el cursor hasta la posición de las centenas
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_4_TIEMPO_ABAJO:

		CPI R17, CURSOR_POS_4_TIEMPO
		BRNE CHEQUEO_POS_5_TIEMPO_ABAJO

			ADIW ZH:ZL, CURSOR_POS_2_TIEMPO -1							; Se corre el cursor hasta la posición de las unidades de mil
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO

		CHEQUEO_POS_5_TIEMPO_ABAJO:

		CPI R17, CURSOR_POS_5_TIEMPO
		BRNE BOTON_INFERIOR_TIEMPO_SEGUIR

			ADIW ZH:ZL, CURSOR_POS_1_TIEMPO -1							; Se corre el cursor hasta la posición de las decenas de mil
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO

		BOTON_INFERIOR_CAMBIAR_VALOR_TIEMPO:							; Por último, se modifica el valor correspondiente y se guarda
			
			PUSH R18
			LD R18, Z													; Se carga el caracter ascii correspondiente
			CPI R18, '0'												; Si el caracter es un 0 ascii, no se puede decrementar más
			BREQ BOTON_INFERIOR_TIEMPO_9

			DEC R18

			RJMP BOTON_INFERIOR_TIEMPO_SEGUIR

			BOTON_INFERIOR_TIEMPO_9:
				LDI R18, '9'											; Se carga un 9 ascii
				
		BOTON_INFERIOR_TIEMPO_SEGUIR:
			ST Z, R18													; Se guarda el dato incrementado
			POP R18														; Se recuperan los datos que había en los registros originalmente
			POP ZH
			POP ZL

			SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Se habilita la escritura en el segundo renglón
			RJMP NO_ACCION_TIEMPO


	CHEQUEAR_BOTON_OK_TIEMPO:
	SBRS BOTONES_TECLADO, BOTON_OK
	RJMP CHEQUEAR_BOTON_CANCELAR_TIEMPO

		PUSH XH
		PUSH XL
		PUSH YH
		PUSH YL
		PUSH R16

		LDI XL, LOW(MENU_TIEMPO_TOTAL_ASCII)							; Se carga el puntero de donde se encuentra guardado del valor modificado
		LDI XH, HIGH(MENU_TIEMPO_TOTAL_ASCII)
		LDI YL, LOW(VENTANAS_A_MEDIR_RAM)								; Se carga el puntero donde se quiere guardar el valor convertido a hexa
		LDI YH, HIGH(VENTANAS_A_MEDIR_RAM)
		LDI R16, MAX_NUM_DIGITOS_5										; Se carga cuantos digitos se quiere convertir a hexa
		CALL TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS			; Se guarda el valor de la cantidad de ventanas a medir, modificado

		POP R16
		POP YL
		POP YH
		POP XL
		POP XH

		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL

/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se configura para regresar al menpu principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		COMANDO_LCD LCD_CURSOR_OFF
		
		RJMP NO_ACCION_TIEMPO

	CHEQUEAR_BOTON_CANCELAR_TIEMPO:
	SBRS BOTONES_TECLADO, BOTON_CANCELAR
	RJMP NO_ACCION_TIEMPO
		
		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		COMANDO_LCD LCD_CURSOR_OFF
		

	NO_ACCION_TIEMPO:

	STS MENU_TIEMPO_TOTAL_POSICION_CURSOR, R17
	POP R17
	
RET
;************************************************************************************************
ACCION_BOTON_CONF_UMBRAL:

	PUSH R17
	LDS R17, MENU_UMBRAL_POSICION_CURSOR					; Se carga el dato de la posición del cursor

	SBRS BOTONES_TECLADO, BOTON_IZQUIERDA
	RJMP CHEQUEAR_BOTON_DERECHO_UMBRAL

		; Se chequea donde está el cursor, y donde debería estar ahora
		CPI R17, CURSOR_POS_5_UMBRAL							; Si me encuentro en la posición más significativa, entonces no hago nada, ya que no puedo mover cursor
		BRNE TIEMPO_INCREMENTAR_CURSOR_UMBRAL
		RJMP NO_ACCION_UMBRAL

		TIEMPO_INCREMENTAR_CURSOR_UMBRAL:
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_IZQUIERDA				; Si no, incremento el valor de la posición del cursor.
		INC R17
		RJMP NO_ACCION_UMBRAL

	CHEQUEAR_BOTON_DERECHO_UMBRAL:								; Idem botón izquierdo pero para el botón derecho

	SBRS BOTONES_TECLADO, BOTON_DERECHO
	RJMP CHEQUEAR_BOTON_SUPERIOR_UMBRAL

		CPI R17, CURSOR_POS_1_UMBRAL
		BRNE UMBRAL_DECREMENTAR_CURSOR
		RJMP NO_ACCION_UMBRAL

		UMBRAL_DECREMENTAR_CURSOR:
		COMANDO_LCD LCD_SHIFTEAR_CURSOR_DERECHA
		DEC R17
		RJMP NO_ACCION_UMBRAL

	CHEQUEAR_BOTON_SUPERIOR_UMBRAL:										; Se utiliza para incrementar el total del valor de la cantidad de ventanas a medir
	SBRS BOTONES_TECLADO, BOTON_SUPERIOR
	RJMP CHEQUEAR_BOTON_INFERIOR_UMBRAL
		
		PUSH ZL
		PUSH ZH

		LDI ZL, LOW(MENU_UMBRAL_ASCII)							; Se levanta el ASCII de la cantidad de ventanas a medir, para modificarlo según corresponda
		LDI ZH, HIGH(MENU_UMBRAL_ASCII)

		CPI R17, CURSOR_POS_1_UMBRAL									; Chequeo si se está en la posición menos significativa
		BRNE CHEQUEO_POS_2_UMBRAL_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_5_UMBRAL -1							; Se corre el cursor hasta la posición menos significativa
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL


		CHEQUEO_POS_2_UMBRAL_ARRIBA:

		CPI R17, CURSOR_POS_2_UMBRAL
		BRNE CHEQUEO_POS_3_UMBRAL_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_4_UMBRAL -1							; Se corre el cursor hasta la posición de las decenas
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_3_UMBRAL_ARRIBA:

		CPI R17, CURSOR_POS_3_UMBRAL
		BRNE CHEQUEO_POS_4_UMBRAL_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_3_UMBRAL -1							; Se corre el cursor hasta la posición de las centenas
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_4_UMBRAL_ARRIBA:

		CPI R17, CURSOR_POS_4_UMBRAL
		BRNE CHEQUEO_POS_5_UMBRAL_ARRIBA

			ADIW ZH:ZL, CURSOR_POS_2_UMBRAL -1							; Se corre el cursor hasta la posición de las unidades de mil
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_5_UMBRAL_ARRIBA:

		CPI R17, CURSOR_POS_5_UMBRAL
		BRNE BOTON_SUPERIOR_UMBRAL_SEGUIR

			ADIW ZH:ZL, CURSOR_POS_1_UMBRAL -1							; Se corre el cursor hasta la posición de las decenas de mil
			RJMP BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL

		BOTON_SUPERIOR_CAMBIAR_VALOR_UMBRAL:							; Por último, se modifica el valor correspondiente y se guarda
			
			PUSH R18
			LD R18, Z													; Se carga el caracter ascii correspondiente
			CPI R18, '9'												; Si el caracter es un 9 ascii, no se puede incrementar más
			BREQ BOTON_SUPERIOR_UMBRAL_0

			INC R18

			RJMP BOTON_SUPERIOR_UMBRAL_SEGUIR

			BOTON_SUPERIOR_UMBRAL_0:
				LDI R18, '0'											; Se carga un 0 ascii
				
		BOTON_SUPERIOR_UMBRAL_SEGUIR:
			ST Z, R18													; Se guarda el dato incrementado
			POP R18														; Se recuperan los datos que había en los registros originalmente
			POP ZH
			POP ZL

			SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Se habilita la escritura en el segundo renglón
			RJMP NO_ACCION_UMBRAL

	CHEQUEAR_BOTON_INFERIOR_UMBRAL:
	SBRS BOTONES_TECLADO, BOTON_INFERIOR
	RJMP CHEQUEAR_BOTON_OK_UMBRAL

		PUSH ZL
		PUSH ZH

		LDI ZL, LOW(MENU_UMBRAL_ASCII)							; Se levanta el ASCII de la cantidad de ventanas a medir, para modificarlo según corresponda
		LDI ZH, HIGH(MENU_UMBRAL_ASCII)

		CPI R17, CURSOR_POS_1_UMBRAL									; Chequeo si se está en la posición menos significativa
		BRNE CHEQUEO_POS_2_UMBRAL_ABAJO

			ADIW ZH:ZL, CURSOR_POS_5_UMBRAL -1							; Se corre el cursor hasta la posición menos significativa
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL


		CHEQUEO_POS_2_UMBRAL_ABAJO:

		CPI R17, CURSOR_POS_2_UMBRAL
		BRNE CHEQUEO_POS_3_UMBRAL_ABAJO

			ADIW ZH:ZL, CURSOR_POS_4_UMBRAL -1							; Se corre el cursor hasta la posición de las decenas
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_3_UMBRAL_ABAJO:

		CPI R17, CURSOR_POS_3_UMBRAL
		BRNE CHEQUEO_POS_4_UMBRAL_ABAJO

			ADIW ZH:ZL, CURSOR_POS_3_UMBRAL -1							; Se corre el cursor hasta la posición de las centenas
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_4_UMBRAL_ABAJO:

		CPI R17, CURSOR_POS_4_UMBRAL
		BRNE CHEQUEO_POS_5_UMBRAL_ABAJO

			ADIW ZH:ZL, CURSOR_POS_2_UMBRAL -1							; Se corre el cursor hasta la posición de las unidades de mil
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL

		CHEQUEO_POS_5_UMBRAL_ABAJO:

		CPI R17, CURSOR_POS_5_UMBRAL
		BRNE BOTON_INFERIOR_UMBRAL_SEGUIR

			ADIW ZH:ZL, CURSOR_POS_1_UMBRAL -1							; Se corre el cursor hasta la posición de las decenas de mil
			RJMP BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL

		BOTON_INFERIOR_CAMBIAR_VALOR_UMBRAL:							; Por último, se modifica el valor correspondiente y se guarda
			
			PUSH R18
			LD R18, Z													; Se carga el caracter ascii correspondiente
			CPI R18, '0'												; Si el caracter es un 0 ascii, no se puede decrementar más
			BREQ BOTON_INFERIOR_UMBRAL_9

			DEC R18

			RJMP BOTON_INFERIOR_UMBRAL_SEGUIR

			BOTON_INFERIOR_UMBRAL_9:
				LDI R18, '9'											; Se carga un 9 ascii
				
		BOTON_INFERIOR_UMBRAL_SEGUIR:
			ST Z, R18													; Se guarda el dato incrementado
			POP R18														; Se recuperan los datos que había en los registros originalmente
			POP ZH
			POP ZL

			SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Se habilita la escritura en el segundo renglón
			RJMP NO_ACCION_UMBRAL


	CHEQUEAR_BOTON_OK_UMBRAL:
	SBRS BOTONES_TECLADO, BOTON_OK
	RJMP CHEQUEAR_BOTON_CANCELAR_UMBRAL

		PUSH XH
		PUSH XL
		PUSH YH
		PUSH YL
		PUSH R16

		LDI XL, LOW(MENU_UMBRAL_ASCII)							; Se carga el puntero de donde se encuentra guardado del valor modificado
		LDI XH, HIGH(MENU_UMBRAL_ASCII)
		LDI YL, LOW(REGISTRO_UMBRAL)								; Se carga el puntero donde se quiere guardar el valor convertido a hexa
		LDI YH, HIGH(REGISTRO_UMBRAL)
		LDI R16, MAX_NUM_DIGITOS_5										; Se carga cuantos digitos se quiere convertir a hexa
		CALL TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS			; Se guarda el valor de la cantidad de ventanas a medir, modificado

		POP R16
		POP YL
		POP YH
		POP XL
		POP XH

		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL

/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Se configura para regresar al menpu principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		COMANDO_LCD LCD_CURSOR_OFF
		
		RJMP NO_ACCION_UMBRAL

	CHEQUEAR_BOTON_CANCELAR_UMBRAL:
	SBRS BOTONES_TECLADO, BOTON_CANCELAR
	RJMP NO_ACCION_UMBRAL
		
		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)*/
		COMANDO_LCD LCD_CURSOR_OFF
		

	NO_ACCION_UMBRAL:

	STS MENU_UMBRAL_POSICION_CURSOR, R17
	POP R17



RET
;************************************************************************************************
ACCION_BOTON_CONF_BUZZER:

	SBRS BOTONES_TECLADO, BOTON_IZQUIERDA
	RJMP CHEQUEAR_BOTON_DERECHO_BUZZER

		SBRS ESTADOS_LCD, BUZZER_LCD_SI
		RJMP BOTON_IZQUIERDA_BUZZER_NO

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_BUZZER_NO						; Se escribe el mensaje de 1000ms

			CBR ESTADOS_LCD, (1<<BUZZER_LCD_SI)

			RJMP NO_ACCION_BUZZER
			
		BOTON_IZQUIERDA_BUZZER_NO:
		SBRC ESTADOS_LCD, BUZZER_LCD_SI
		RJMP CHEQUEAR_BOTON_DERECHO_BUZZER

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_BUZZER_SI						; Se escribe el mensaje de 1_ms

			SBR ESTADOS_LCD, (1<<BUZZER_LCD_SI)

			RJMP NO_ACCION_BUZZER

	CHEQUEAR_BOTON_DERECHO_BUZZER:
	SBRS BOTONES_TECLADO, BOTON_DERECHO
	RJMP CHEQUEAR_BOTON_SUPERIOR_BUZZER

		SBRS ESTADOS_LCD, BUZZER_LCD_SI						; Si no estoy en la posición de mostrar 1 ms, salteo esta parte				
		RJMP BOTON_DERECHA_BUZZER_NO							; Sigo comprobando si estoy en la posición de mostrar 10ms

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_BUZZER_NO							; Se escribe el mensaje de 10 ms

			CBR ESTADOS_LCD, (1<<BUZZER_LCD_SI)

			RJMP NO_ACCION_BUZZER

		BOTON_DERECHA_BUZZER_NO:
		SBRC ESTADOS_LCD, BUZZER_LCD_SI
		RJMP CHEQUEAR_BOTON_SUPERIOR_BUZZER

			COMANDO_LCD LCD_CAMBIAR_RENGLON							; Me paro en el segundo renglón
			BORRAR_RENGLON											; Se limpia el segundo renglón
			COMANDO_LCD LCD_CAMBIAR_RENGLON

			CADENA_FLASH_LCD MENSAJE_BUZZER_SI							; Se escribe el mensaje de 100 ms

			SBR ESTADOS_LCD, (1<<BUZZER_LCD_SI)

			RJMP NO_ACCION_BUZZER

	CHEQUEAR_BOTON_SUPERIOR_BUZZER:
	SBRS BOTONES_TECLADO, BOTON_SUPERIOR
	RJMP CHEQUEAR_BOTON_INFERIOR_BUZZER

			RJMP NO_ACCION_BUZZER

	CHEQUEAR_BOTON_INFERIOR_BUZZER:
	SBRS BOTONES_TECLADO, BOTON_INFERIOR
	RJMP CHEQUEAR_BOTON_OK_BUZZER

		RJMP NO_ACCION_BUZZER

	CHEQUEAR_BOTON_OK_BUZZER:
	SBRS BOTONES_TECLADO, BOTON_OK
	RJMP CHEQUEAR_BOTON_CANCELAR_BUZZER

	PUSH R16
	LDS R16, REGISTRO_CONF_GENERAL

		BUZZER_GUARDAR_SI:

		SBRS ESTADOS_LCD, BUZZER_LCD_SI						; Si el usuario está visulizando 1 ms, se guarda dicha configuración
		RJMP BUZZER_GUARDAR_NO

			SBR R16, (1<<BIT_SENAL_SONORA)
			RJMP BUZZER_GUARDAR_SEGUIR

		BUZZER_GUARDAR_NO:										; Si el usuario está visulizando 10 ms, se guarda dicha configuración
		SBRC ESTADOS_LCD, BUZZER_LCD_SI
		RJMP NO_ACCION_BUZZER

			CBR R16, (1<<BIT_SENAL_SONORA)
			RJMP BUZZER_GUARDAR_SEGUIR

		BUZZER_GUARDAR_SEGUIR:
		STS REGISTRO_CONF_GENERAL, R16
		POP R16
		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)					; Configuro que vuelvo al menú principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Indico que puedo escribir nuevamente en el segundo renglón*/
		RJMP NO_ACCION_BUZZER

	CHEQUEAR_BOTON_CANCELAR_BUZZER:
	SBRS BOTONES_TECLADO, BOTON_CANCELAR
	RJMP NO_ACCION_BUZZER
		
		LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
/*		SBR ESTADOS_LCD, (1<<MENU_PRINCIPAL_LCD)						; Configuro que vuelvo al menú principal
		SBR ESTADOS_LCD, (1<<ESCRIBIR_PRIMER_RENGLON)
		SBR ESTADOS_LCD, (1<<ESCRIBIR_SEGUNDO_RENGLON)				; Indico que puedo escribir nuevamente en el segundo renglón*/
		RJMP NO_ACCION_BUZZER
		
	NO_ACCION_BUZZER:

RET




;************************************************************************************************
;************************************************************************************************
; Mensajes que se utilizan durante la interfaz LCD
; ================================================
MENSAJE_MENU_PRINCIPAL: .db "Menu principal", 0
MENSAJE_MENU_PRINCIPAL_UMBRAL: .db FLECHA_IZQUIERDA_ASCII, " Conf umbral  ", FLECHA_DERECHA_ASCII, 0
MENSAJE_MENU_PRINCIPAL_VENTANA: .db FLECHA_IZQUIERDA_ASCII, " Conf ventana ", FLECHA_DERECHA_ASCII, 0
MENSAJE_MENU_PRINCIPAL_DURACION: .db FLECHA_IZQUIERDA_ASCII, "Conf duracion ", FLECHA_DERECHA_ASCII, 0
MENSAJE_MENU_PRINCIPAL_BUZZER: .db FLECHA_IZQUIERDA_ASCII, "Config. Buzz ", FLECHA_DERECHA_ASCII, 0
MENSAJE_MENU_PRINCIPAL_MEDIR: .db FLECHA_IZQUIERDA_ASCII, "    Medir     ", FLECHA_DERECHA_ASCII, 0
; ================================================
MENSAJE_MENU_UMBRAL: .db "Umbral ?", 0
; ================================================
MENSAJE_MENU_VENTANA: .db "Ventana ?", 0
MENSAJE_1_ms: .db FLECHA_IZQUIERDA_ASCII,"     1 ms     ",FLECHA_DERECHA_ASCII, 0
MENSAJE_10_ms: .db FLECHA_IZQUIERDA_ASCII,"     10 ms    ",FLECHA_DERECHA_ASCII, 0
MENSAJE_100_ms: .db FLECHA_IZQUIERDA_ASCII,"    100 ms    ",FLECHA_DERECHA_ASCII, 0
MENSAJE_1000_ms: .db FLECHA_IZQUIERDA_ASCII,"    1000 ms   ",FLECHA_DERECHA_ASCII, 0
; ================================================
MENSAJE_MENU_TIEMPO: .db "Repetir ventana?", 0
; ================================================
MENSAJE_MENU_BUZZER: .db "Conf. buzzer", 0
MENSAJE_BUZZER_NO: .db FLECHA_IZQUIERDA_ASCII,"  Buzzer des. ",FLECHA_DERECHA_ASCII, 0
MENSAJE_BUZZER_SI: .db FLECHA_IZQUIERDA_ASCII,"  Buzzer act. ",FLECHA_DERECHA_ASCII, 0
; ================================================
MENSAJE_MENU_MIDIENDO: .db "Midiendo...", 0
; ================================================