		AREA    |.text|, CODE, READONLY, ALIGN=2
				THUMB
				EXPORT  main
;SW - PJ0 and PJ1			
GPIO_PORTJ_DATA_R	EQU	0x400603FC
GPIO_PORTJ_DIR_R	EQU	0x40060400
GPIO_PORTJ_DEN_R	EQU 0x4006051C
GPIO_PORTJ_PUR_R	EQU 0x40060510
GPIO_PORTJ_AFSEL_R	EQU	0x40060420

;LED - PN0 and PN1
GPIO_PORTN_DATA_R	EQU 0x400643FC
GPIO_PORTN_DIR_R	EQU 0x40064400
GPIO_PORTN_DEN_R	EQU 0x4006451C
GPIO_PORTN_AFSEL_R	EQU	0x40064420
	
SYSCTL_RCGCGPIO_R	EQU 0x400FE608
	
GPIO_Init
	LDR R1, =SYSCTL_RCGCGPIO_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x1100 ; R0 = R0|0x1100 allow to access PN and PJ
    STR R0, [R1]                    ; [R1] = R0
    NOP
	NOP
	NOP
    NOP                             ; allow time to finish activating
    ;direction register 
    LDR R1, =GPIO_PORTJ_DIR_R       ; R1 = &GPIO_PORTJ_DIR_R
    LDR R0, [R1]                    ; R0 = [R1]
	BIC R0, R0, #0x03				; R0 = R0 & NOT(0x03) 
    STR R0, [R1]    

	LDR R1, =GPIO_PORTN_DIR_R       ; R1 = &GPIO_PORTN_DIR_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x03              ; R0 = R0|0x03 
    STR R0, [R1] 
	
    ;regular port function
    LDR R1, =GPIO_PORTJ_AFSEL_R     ; R1 = &GPIO_PORTJ_AFSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x03      
    STR R0, [R1]    

	LDR R1, =GPIO_PORTN_AFSEL_R     ; R1 = &GPIO_PORTN_AFSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x03               
    STR R0, [R1]
	
    ; digital enable
    LDR R1, =GPIO_PORTJ_DEN_R       ; R1 = &GPIO_PORTJ_DEN_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x03               ; R0 = R0|0x03
    STR R0, [R1]  
	
	LDR R1, =GPIO_PORTN_DEN_R       ; R1 = &GPIO_PORTN_DEN_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x03               ; R0 = R0|0x03
    STR R0, [R1]  

	; 5) enable PULL-UP port

	LDR R1, =GPIO_PORTJ_PUR_R		
	LDR R0, [R1]
	ORR	R0,	R0, #0x03
	STR	R0, [R1]
	
    BX  LR

DELAY
	LDR	R2, =800000
Loop	
	SUB R2,#1
	CMP R2,#0
	BNE Loop

	BX	LR	


BLINK							;blink 3 times
	MOV	R3,#3
BLOOP
	LDR R0,=GPIO_PORTN_DATA_R
	LDR R1,[R0]
	ORR R1,#0x03
	STR R1,[R0]
	BL	DELAY
	
	AND	R1,#0x00
	STR R1,[R0]
	BL	DELAY
	
	SUB	R3,#1
	CMP R3,#0
	BNE	BLOOP
	
	B	SWITCH2



main
	BL  GPIO_Init
         
LOOP
	LDR R0, =GPIO_PORTJ_DATA_R 		; Load data from Port J data register
	LDR R1, [R0]					; for sw1
	LDR R2, [R0]					; for sw2
	LDR R0, =GPIO_PORTN_DATA_R		; load LED address
	
SWITCH1								
	AND R1,#0x01					; 
	CMP	R1,#0x00					; check sw1, low is on
	BNE	SWITCH2						; if sw1 off, jump
	AND R2, #0x02					; else, check sw2
	CMP R2, #0x00	
	ITTE NE						;if off, TT, else, E
	MOVNE R1,#0x02
	STRNE R1,[R0]
	BEQ	 BLINK						;
	
	
SWITCH2	
	AND R2, #0x02
	CMP R2, #0x00
	ITT EQ							; if reset=1					
	MOVEQ R1,#0x01
	STREQ R1,[R0]
	B	LOOP
	

		ALIGN
		END