;
; Pruebas_UART.asm
;
; Created: 15/10/2018 21:53:12
; Author : Juan Pablo Goyret
; Descripcion: archivo para realizar pruebas sobre transmision UART

.include "m328pdef.inc"
.include "macros.inc"

; ===================================================================
; ========================= Variables globales ======================
; ===================================================================

; EVENTO: registro reservado para identificar eventos en el sistema que determinen
; acciones dentro de las maquinas de estados
; IMPORTANTE: la activacion de cada bit del registro simboliza la ocurrencia
; de un evento especifico. Si el bit esta en 0, entonces no ha ocurrido
; el evento
; Eventos asociados a cada bit:                                   
;    0  Timeout recibiendo una cadena                
;    1  Overflow de buffer recibiendo una cadena
;    2  Iniciar una lectura. Es equivalente a la recepcion de un comando READ? por UART
;    3  Abortar una lectura. Es equivalente a la recepcion de un comando ABORt por UART
;    4  Ha llegado un pulso
;	 5  Se estan enviando datos por UART
;    6  Se ha superado el umbral de pulsos configurado
;    7  Se ha presionado una tecla
.def EVENTO = R25

; EVENTO2: registro en RAM reservado para identificar eventos en el sistema que determinen
; acciones dentro de las maquinas de estados
; IMPORTANTE: la activacion de cada bit del registro simboliza la ocurrencia
; de un evento especifico. Si el bit esta en 0, entonces no ha ocurrido
; el evento
; Eventos asociados a cada bit:                                   
;    0  Se ha recibido un caracter
;    1  Se ha terminado de recibir una cadena
;    2  El sistema se encuentra ocupado durante un pedido externo
;	 3  Indica la disminucion del registro que almacena el multiplicador de ventana          
.dseg
EVENTO2: .BYTE 1
.cseg


; Constantes para identificar cada bit de EVENTO
.equ TIMEOUT_UART = 0
.equ OV_BUFFER_RX_UART = 1
.equ COMENZAR_MEDICION = 2
.equ DETENER_MEDICION = 3
.equ PULSO_RECIBIDO = 4
.equ ENVIANDO_DATOS_UART = 5
.equ UMBRAL_SUPERADO = 6
.equ TECLA_PRESIONADA = 7

; Constantes para identificar cada bit de EVENTO2
.equ BIT_CARACTER_RECIBIDO = 0
.equ BIT_FIN_CADENA = 1
.equ SISTEMA_OCUPADO = 2
.equ BIT_MUL_VENTANA_DEC = 3

; ESTADO: variable para identificar el estado de las maquinas de estados
; IMPORTANTE: cada bit, al estar activado, indica que la maquina debe estar
; en un estado especifico. Dos bits no pueden estar activos al mismo tiempo.
;
; Estados asociados a cada bit:
; --> De 0 a 3 inclusive con estados de la maquina de estados de la UART
;    0  Estado oscioso de la UART   
;    1  Recibiendo una cadena
;    2  Intepretando una cadena
;    3  Se produjo un error en la recepcion de datos por UART
; --> De 4 a 7 inclusive son estados de la maquina de estados para realizar mediciones
;    4  Estado oscioso del sistema de mediciones
;	 5  ACTUALMENTE SIN USO
;    6  Midiendo devolviendo los tiempos de llegada de cada pulso
;	 7  Midiendo sin devolver los tiempos de llegada de cada pulso
.def ESTADO = R24

.def BOTONES_TECLADO = R16							; Se enciende determinaod bit, dependiendo del botón pulsado

; Constantes para identificar cada bit de ESTADO
.equ EST_OSCIOSO_UART = 0
.equ EST_RECIBIENDO_CADENA = 1
.equ EST_INTERPRETANDO_CADENA = 2
.equ EST_ERROR_UART = 3
.equ EST_OSCIOSO_MEDICION = 4
.equ EST_MEDIR_DEVOLVER_TIEMPOS = 6
.equ EST_MEDIR_DEVOLVER_TOTAL = 7

;MULTIPLICADOR PARA AMPLIAR EL OCR1A
.DEF MUL_DE_VENTANA = R15

; ===================================================================
; ========================= Codigo principal ========================
; ===================================================================

.org 0
	JMP INICIO

; Interrupcion de buffer de RX lleno
.org URXCaddr
	JMP USART_RX

; Interrupcion de buffer de TX vacio
.org UDREaddr
	JMP USART_UDRE

; Interrupcion de overflow del timer0
.org OVF0addr
	JMP OVERFLOW_TIMER0

.org OVF2addr							;Interrupción por overflow del timer 2
	JMP LCD_INTERRUPCION_OVERFLOW			

.org ICP1addr							;Interrupción por detección de flanco de en el ICP1			
	JMP INTERRUPCION_PULSO_DETECTADO

.org OC1Aaddr							;Interrupción por comparación del TIMER 1
	JMP INTERRUPCION_FIN_VENTANA

.org ACIaddr
	JMP INTERRUPCION_COMPARADOR

.org ADCCaddr
		RJMP ADC_ISR

.org INT_VECTORS_SIZE

.include "teclado.asm"
.include "eeprom.asm"
.include "timer0.asm"
.include "uart.asm"
.include "scpi.asm"
.include "LCD.asm"
.include "TIMER_2.asm"
.include "TIMER_1.asm"
.include "Mediciones.asm"
.include "Uso_general.asm"
.include "configuracion.asm"
.include "maquina_estados_uart.asm"
.include "maquina_estados_mediciones.asm"
.include "maquina_estados_LCD.asm"
.include "pulsos_registro_desplazamiento.asm"
.include "comparador.asm"

INICIO:

	; No hay eventos por procesar al comenzar el programa
	CLR EVENTO
	STS EVENTO2, EVENTO

	; Hace que las maquinas de estado comiencen en estado oscioso
	CLR ESTADO
	SBR ESTADO, (1<<EST_OSCIOSO_MEDICION)
	SBR ESTADO, (1<<EST_OSCIOSO_UART)

	; Inicializar el stack
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	; Borrar el registro de motivos del timer0
	LDS R16, MOTIVO_TIMER0
	CLR R16
	STS MOTIVO_TIMER0, R16

	; Limpiar el contenido del registro de desplazamiento para enviar los tiempos de los pulsos
	CLR CANT_CARACTERES_GUARDADOS

	; Cargar configuracion del dispositivo por default
	CALL CARGAR_CONFIGURACION_EEPROM
;	CALL CONFIGURAR_REGISTROS_DEFAULT


	; === Inicializar puertos ===
	; Puertos del LCD
	CALL CONFIGURAR_PUERTOS_LCD

	; Configurar perifericos, timers, etc y sus interrupciones
	CLI
	CALL CONF_COMPARADOR
	CALL CONF_ADC
	; Configurar UART
	CALL INICIALIZAR_UART
	CALL ACTIVAR_TX_RX
	CALL ACTIVAR_INT_RX
	CALL ACTIVAR_ISR_TIMER0_OV	
	CALL INIT_TIMER_2			;Inicializo el TIMER 2, para las interrupciones del LCD
	CALL INIT_TIMER_1			;Inicializo el TIMER 1, para captar los pulsos de las mediciones
	SEI							;Prendo interrupciones globales, para poder inicializar el LCD
	
	CALL INIT_LCD				;Inicializo el LCD

	; Enviar mensaje de prueba por UART
	LDI R18, LOW(MENSAJE_TX)
	LDI R19, HIGH(MENSAJE_TX)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

/*	; Mensaje de bienvenida
	LDI ZL, LOW(MENSAJE_BIENVENIDA_LCD<<1)
	LDI ZH, HIGH(MENSAJE_BIENVENIDA_LCD<<1)
	CALL STRING_WRT_LCD_FLASH*/

	; Se configura para comenzar en el menú principal

	LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL							; Se habilita la escritura en ambos renglones del LCD, y se entra en el menú principal,
																	; mostrando en el segundo renglón la opción de entrar al menú de umbral.
	
	
BUCLE_PRINCIPAL:
	
	CALL VERIFICAR_APAGADO_TUBO

	CLR R16
	; =======================================================================
	; Si se ha presionado una tecla, entonces identificarla

	SBRC EVENTO, TECLA_PRESIONADA
	CALL ADC_LEER_TECLA
	; LA TECLA PRESIONADA QUEDA ALMACENADA EN LOS REGISTROS R18 Y R19 PERO SOLO
	; DE FORMA TEMPORAL. LA MAQUINA DE ESTADOS DEL LCD DEBE SER COLOCADA INMEDIATAMENTE
	; DEBAJO DE CODIGO PORQUE SINO OTRA FUNCION PODRIA BORRAR LOS VALORES DE R18 Y R19



	; =======================================================================
	; MAQUINAS DE ESTADO	
	; =======================================================================
	; =======================================================================
	; Maquina de estados dedicada a mostrar por pantalla al usuario, los menús correspondientes

	CPI ESTADOS_LCD, MIDIENDO_LCD
	BREQ SKIPEAR_MAQUINA_ESTADOS_LCD

	CALL MAQUINA_ESTADOS_LCD

	SKIPEAR_MAQUINA_ESTADOS_LCD:
	; =======================================================================
	; Maquina de estados dedicada a la gestion de las mediciones
	CALL MAQUINA_ESTADOS_MEDICIONES

	; =======================================================================
	; Maquina de estados dedicada a la recepcion de una cadena por UART
	 CALL MAQUINA_ESTADOS_UART

	; =======================================================================

	; =======================================================================
	; FIN MAQUINAS DE ESTADO	
	; =======================================================================

	RJMP BUCLE_PRINCIPAL
	RJMP END

END: RJMP END