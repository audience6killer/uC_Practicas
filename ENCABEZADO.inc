;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		
;			        ENCABEZADO 
;    
;   Este sera el encabezado que contendra las configuraciones por defecto
;   durante el curso
;    
;   uC : pic16f887
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
		    PROCESSOR	16F887
		    __CONFIG	0X2007,0X23E4
		    __CONFIG	0X2008,0X3FFF
;   TODO: DESCRIPCION DE LOS REGISTROS DE CONNFIGURACION
		    
		    INCLUDE	<p16f887.inc>
		    ORG		0X0000
		    CLRF	PORTA
		    CLRF	PORTB
		    CLRF	PORTC
		    CLRF	PORTD
		    CLRF	PORTE
		    BSF		STATUS,RP0
		    BSF		STATUS,RP1
		    CLRF	ANSEL
		    CLRF	ANSELH
		    BCF		STATUS,RP1	; BANCO 1
