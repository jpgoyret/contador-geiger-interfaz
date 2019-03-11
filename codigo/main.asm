; ==================================================================
; Archivo: main.asm
; ==================================================================

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

; Constantes para identificar cada bit de ESTADO
.equ EST_OSCIOSO_UART = 0
.equ EST_RECIBIENDO_CADENA = 1
.equ EST_INTERPRETANDO_CADENA = 2
.equ EST_ERROR_UART = 3
.equ EST_OSCIOSO_MEDICION = 4
.equ EST_MEDIR_DEVOLVER_TIEMPOS = 6
.equ EST_MEDIR_DEVOLVER_TOTAL = 7


; MUL_DE_VENTANA: multiplicador que permite ampliar el registro OCR1A (registro
; comparador del timer1)
.def MUL_DE_VENTANA = R15

; ===================================================================
; ========================= Interrupciones ==========================
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

;Interrupción por overflow del timer 2
.org OVF2addr
	JMP LCD_INTERRUPCION_OVERFLOW			

;Interrupción por detección de flanco de en el ICP1	
.org ICP1addr	
	JMP INTERRUPCION_PULSO_DETECTADO

;Interrupción por comparación del TIMER 1
.org OC1Aaddr
	JMP INTERRUPCION_FIN_VENTANA

; Interrupcion del comparador analogico
.org ACIaddr
	JMP INTERRUPCION_COMPARADOR

; Interrupcion de conversion por ADC completa
.org ADCCaddr
		RJMP ADC_ISR

; ===================================================================
; ========================= Codigo principal ========================
; ===================================================================


.org INT_VECTORS_SIZE

; ========================== Dependencias ========================== 
.include "Uso_general.asm"
.include "configuracion.asm"
.include "eeprom.asm"
.include "perifericos/adc.asm"
.include "perifericos/teclado.asm"
.include "perifericos/comparador.asm"
.include "perifericos/LCD.asm"
.include "com_serie/uart.asm"
.include "com_serie/scpi.asm"
.include "timers/TIMER_0.asm"
.include "timers/TIMER_2.asm"
.include "timers/TIMER_1.asm"
.include "mediciones/Mediciones.asm"
.include "mediciones/pulsos_registro_desplazamiento.asm"
.include "maquinas_de_estado/maquina_estados_uart.asm"
.include "maquinas_de_estado/maquina_estados_mediciones.asm"
.include "maquinas_de_estado/maquina_estados_LCD.asm"
; ========================== Fin dependencias ======================

INICIO:

	; No hay eventos por procesar al comenzar el programa
	CLR EVENTO
	STS EVENTO2, EVENTO

	; Las maquinas de estado comienzan en estado oscioso
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

	; Configurar puertos del LCD
	CALL CONFIGURAR_PUERTOS_LCD

	; ====== Configurar timers y com. serie ===========
	CLI
	
	; Configurar el comparador
	CALL CONF_COMPARADOR

	; Configurar el ADC
	CALL CONF_ADC
	
	; Configurar UART
	CALL INICIALIZAR_UART
	CALL ACTIVAR_TX_RX
	CALL ACTIVAR_INT_RX
	
	; Activar las interrupcion por overflow del TIMER 0 
	; para detectar timeouts en la comunicacion serie
	CALL ACTIVAR_ISR_TIMER0_OV	
	
	;Inicializar el TIMER 2 para las interrupciones del LCD
	CALL INIT_TIMER_2
	
	;Inicializar el TIMER 1 para captar los pulsos de las mediciones
	CALL INIT_TIMER_1
	SEI	

	; ====== Fin configurar timers y com. serie ===========
	
	; Inicializar la pantalla LCD
	CALL INIT_LCD

	; Enviar mensaje de bienvenida por UART
	LDI R18, LOW(MENSAJE_UART_INICIAL)
	LDI R19, HIGH(MENSAJE_UART_INICIAL)
	CALL CARGAR_BUFFER
	CALL ACTIVAR_INT_TX_UDRE0	

	; Configurar pantalla LCD para comenzar en el menú principal:
	; Se habilita la escritura en ambos renglones del LCD, y se entra en el menú principal,
	; mostrando en el segundo renglón la opción de entrar al menú de umbral.
	LDI ESTADOS_LCD, VOLVER_MENU_PRINCIPAL
	
	
BUCLE_PRINCIPAL:
	
	; =================== CHEQUEAR TUBO ====================================
	; Chequear si la configuracion almacenada indica que el tubo debe estar activado.
	; De ser asi, activarlo. Sino, desactivarlo. 
	CALL VERIFICAR_APAGADO_TUBO
	; =================== FIN CHEQUEAR TUBO ================================


	CLR R16

	; =============================== ADC ==================================
	; Si se ha presionado una tecla, entonces identificarla

	SBRC EVENTO, TECLA_PRESIONADA
	CALL ADC_LEER_TECLA
	; LA TECLA PRESIONADA QUEDA ALMACENADA EN LOS REGISTROS R18 Y R19 PERO SOLO
	; DE FORMA TEMPORAL. LA MAQUINA DE ESTADOS DEL LCD DEBE SER COLOCADA INMEDIATAMENTE
	; DEBAJO DE ESTE CODIGO PORQUE SINO OTRA FUNCION PODRIA 
	; BORRAR LOS VALORES DE R18 Y R19
	; =============================== FIN ADC ==============================


	; =======================================================================
	; ====================== MAQUINAS DE ESTADO =============================
	; =======================================================================

	
	; ================== Maquina de estados del LDC =========================
	; Maquina de estados dedicada a mostrar por pantalla los menús correspondientes
	; al usuario

	CPI ESTADOS_LCD, MIDIENDO_LCD
	BREQ _SKIPEAR_MAQUINA_ESTADOS_LCD

	CALL MAQUINA_ESTADOS_LCD

_SKIPEAR_MAQUINA_ESTADOS_LCD:

	; ================== Maquina de estados de las mediciones ===============
	; Maquina de estados dedicada a la gestion de las mediciones
	CALL MAQUINA_ESTADOS_MEDICIONES

	; ================== Maquina de estados de UART =========================
	; Maquina de estados dedicada a la recepcion o envio de una cadena por UART
	 CALL MAQUINA_ESTADOS_UART


	; =======================================================================
	; ======================= FIN MAQUINAS DE ESTADO =======================	
	; =======================================================================

	RJMP BUCLE_PRINCIPAL
	RJMP END

END: RJMP END