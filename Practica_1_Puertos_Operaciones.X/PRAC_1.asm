;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		    
;		    PRACTICA 1: USO DE PUERTOS Y OPERACIONES
;   
;	FECHA: 06/09/22
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
		;#INCLUDE <../ENCABEZADO.asm>
		#INCLUDE <../ENCABEZADO.inc>
		; NOS ENCONTRAMOS EN EL REGISTRO 1    
;   DEFINIMOS LA VARIABLES/REGISTROS DE RAM QUE USAREMOS
    
REG1    EQU	    0X20
REG2    EQU	    0X21
RESU    EQU	    0X22
RESU2   EQU	    0X23 
AUX     EQU	    0X24
		
;   SOLO HABRAN DOS PUERTOS CONFIGURADOS DE SALIDA, EL PUERTO B ES CONFIGURADO
;   COMO 0X0F, UNA MITAD DE ENTRADAS Y LA OTRA DE SALIDAS, MIENTRAS QUE EL
;   PUERTO B TIENE TODOS SUS PINES COMO SALIDAS
		    CLRF	TRISC
		    MOVLW	0X0F
		    MOVWF	TRISB
		    
		    BCF		STATUS,RP0	    ; BANCO 0
		    
;   INICIO DEL PROGRAMA PRINCIPAL
		    
		    ; Test
;		    MOVLW	0x0F
;		    MOVWF	PORTC
;		    MOVLW	B'10000000'
;		    MOVWF	PORTB
;		    GOTO	$
		    
		    MOVLW	0X00
		    MOVWF	PORTC
		    
		    MOVLW	b'00000000'
		    MOVWF	PORTB
		    
		    BTFSS	PORTB,0
		    GOTO	$-1
		    
		    MOVF	PORTD,W
		    MOVWF	REG1		; GUARDAMOS EL PRIMER VALORES
		    MOVF	REG1,W
		    MOVWF	PORTC
		    
		    ;	AHORA EL uC DEBE ESPERAR HASTA QUE ALGUNA DE LAS
		    ;	ENTRADAS EN PB.1,2,3 SEA 1
		    
ELECCION:	    BTFSC	PORTB,1
		    GOTO	PB1_HIGH
		    BTFSC	PORTB,2
		    GOTO	PB2_HIGH
		    BTFSC	PORTB,3
		    GOTO	PB3_HIGH
		    GOTO	ELECCION

CONTINUA:	    MOVF	RESU,W
		    MOVWF	PORTC
		    
		    ;	AHORA HAY QUE ESPERAR HASTA QUE PB.0 = 1
		    BTFSS	PORTB,0
		    GOTO	$-1
		    GOTO	DIVISION
		    
;		    FIN DEL PROGRAMA
FIN:		    GOTO	$
		    
    
PB1_HIGH:	    MOVF	PORTD,W
		    MOVWF	REG2		; GUARDAMOS EL SEGUNDO VALOR
		    
		    ;	REALIZAMOS LA OPERACION QUE SE NOS SOLICITA
		    ;	RESU = REG1 + REG2
		    MOVF	REG1,W
		    ADDWF	REG2,W
		    MOVWF	RESU
		    MOVLW	B'10000000'	; SE PRECARGA EL VALOR PARA B7=1
		    BTFSC	STATUS,C
		    MOVWF	PORTB
		    GOTO	CONTINUA

PB2_HIGH:	    MOVF	PORTD,W
		    MOVWF	REG2		; GUARDAMOS EL SEGUNDO VALOR
		    
		    ;	REALIZAMOS LA OPERACION QUE SE NOS SOLICITA
		    ;	RESU = REG1 - REG2
		    MOVF	REG2,W
		    SUBWF	REG1,W
		    MOVWF	RESU 
		    BTFSS	STATUS,C	; SI OCURRIO UN ACARREO SE DIRIGE 
		    GOTO	NEGATIVO	; HACIA LA SUBRUTINA
FIN_RESTA:	    GOTO	CONTINUA
		    
NEGATIVO:	    MOVLW	B'10000000'	; SE PRECARGA EL VALOR PARA B7=1
		    MOVWF	PORTB
		    MOVF	RESU,W
		    SUBLW	.0
		    MOVWF	RESU
		    MOVF	RESU,W
		    MOVWF	PORTC
		    GOTO	FIN_RESTA
		    
PB3_HIGH:	    MOVF	PORTD,W
		    MOVWF	REG2		; GUARDAMOS EL SEGUNDO VALOR
		    
		    ;	REALIZAMOS LA OPERACION QUE SE NOS SOLICITA
		    ;	RESU = REG1*REG2
		    MOVLW	0X00
		    MOVWF	RESU
		    MOVF	REG2,W
		    MOVWF	AUX		; AUX = REG2
		    
		    ; VERIFICAMOS SI ALGUNO DE LOS REG SON CERO
		    MOVLW	0XFF
		    ANDWF	REG1,W
		    BTFSC	STATUS,Z
		    GOTO	CONTINUA
		    MOVLW	0XFF
		    ANDWF	REG2,W
		    BTFSC	STATUS,Z
		    GOTO	CONTINUA
		    ;	ALGORITMO DE MULTIPLICACION: REG1*REG2
MULTI:		    MOVF	REG1,W
		    ADDWF	RESU,F
		    MOVLW	B'10000000'	
		    BTFSC	STATUS,C	; OCURRIO UN ACARREO?
		    MOVWF	PORTB
		    DECF	AUX,F
		    BTFSS	STATUS,Z
		    GOTO	MULTI
		    GOTO	CONTINUA
		    
	    
DIVISION:	    ;MOVF	PORTD,W		; GUARDAMOS REG2
		    ;MOVWF	REG2
		    MOVLW       0X00		; lIMPIAMOS EL ACARREO
		    MOVWF	PORTB
		    MOVF	REG1,W		; RESU2 = REG1/REG2
		    MOVWF	AUX
		    MOVLW	0X00
		    MOVWF	RESU2
		    ; VERIFICAMOS SI ALGUNO DE LOS REG SON CERO
		    MOVLW	0XFF
		    ANDWF	REG2,W		
		    BTFSC	STATUS,Z	; ES CERO EL DENOMINADOR?
		    GOTO	DIV_CERO
		    MOVLW	0XFF
		    ANDWF	REG1,W
		    BTFSC	STATUS,Z	; ES CERO EL NUMERADOR?
		    GOTO	SALIDA
		    ;	ALGORITMO DE DIVISION: REG1/REG2
		    ;	EXISTEN 2 POSIBILIDADES:
		    ;	1. QUE AUX SE VUELVA NEGATIVO -> CON RESIDUO 
		    ;	2. QUE AUX SE VUELVA CERO -> SIN RESIDUO
DIVI:		    MOVF	REG2,W
		    SUBWF	AUX,F
		    BTFSS	STATUS,C	; ES NEGATIVO? CON RESIDUO
		    GOTO	CON_RES
		    BTFSC	STATUS,Z	; ES CERO? NO RESIDUO
		    GOTO	SIN_RES
		    INCF	RESU2,F
		    GOTO	DIVI
DIV_CERO:	    MOVLW	0XFF
		    MOVWF	RESU2
		    MOVLW	B'10000000'	; DIV ENTRE CERO
		    MOVWF	PORTB
		    GOTO	SALIDA
CON_RES:	    MOVLW	B'10000000'	; SE PRECARGA EL VALOR PARA B7=1
		    MOVWF	PORTB
		    GOTO	SALIDA
SIN_RES:	    INCF	RESU2,F
SALIDA:		    MOVF	RESU2,W
		    MOVWF	PORTC
		    GOTO	FIN
		    
		    END
		    
	
		    
		    
		    
		    
		    
		    
