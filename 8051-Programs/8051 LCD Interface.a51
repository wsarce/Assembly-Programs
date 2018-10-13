 	ORG		0H
START:		
	MOV 	SP,#50H		;Begin stack at safe location
	ACALL	INIT_PORTS	;Initialize the output ports
	ACALL	DELAY		;Ensure LCD has time to power up
	ACALL 	INIT_LCD	;Initialize the LCD Display
	MOV		DPTR,#TXT	;Point the data pointer to the text string
	ACALL  	PUTSTRING	;Write string to LCD
	MOV		DPTR,#TXT2	;Point the data pointer to the text string
	ACALL  	PUT_CR		;Instruct LCD to carraige return / line feed
	ACALL	PUTSTRING	;Write string to LCD
HERE:	
	SJMP  	HERE

PUT_CR: 
	MOV   	A,#CR
    ACALL	COMNWRT		;Send CR command to LCD
    RET

INIT_PORTS:
	MOV 	A, #0		;Load all zeros for port 1 configuration
	MOV		P1, A		;Configure port 1 as an output
	MOV 	A, #0		;Load all zeros for port 2 configuration
	MOV		P2, A		;Configure port 2 as an output
	RET
	
INIT_LCD:
   	MOV		A,#38H	
	ACALL	COMNWRT		;Function Set Command pulse 1
	ACALL	DELAY
	ACALL	COMNWRT		;Function Set Command pulse 2
	ACALL	DELAY
	ACALL	COMNWRT		;Function Set Command pulse 3
	ACALL	DELAY
	ACALL	COMNWRT		;Function Set (5 x 7, 2 line)
	ACALL	DELAY
	MOV 	A,#08H		;Display off
	ACALL	COMNWRT
	ACALL	DELAY
	MOV		A,#01H		;clear LCD
  	ACALL	COMNWRT
	ACALL	DELAY
	MOV		A,#06H		;Increment mode, no shifting
	ACALL	COMNWRT
	ACALL	DELAY
	MOV		A,#0EH		;Display on, cursor on
  	ACALL	COMNWRT
	ACALL	DELAY
	RET
	
PUTSTRING:
    CLR   	A
    MOVC  	A,@A+DPTR	;Pass data table entry to A
	JZ    	EXIT1		;If A is zero, conclude string
    ACALL  	PUTCHAR		;Send character pointed to by A to LCD
    INC   	DPTR		;Move to next character
    SJMP  	PUTSTRING
EXIT1:
	RET

PUTCHAR:
	MOV		P1,A
	SETB 	P2.0		;Set RS pin (indicating data)
	CLR 	P2.1		;Clear RW pin, indicating writing
	SETB 	P2.2		;Begin enable bit pulse
	ACALL 	DELAY		;Wait momentarily for actions to complete
	CLR		P2.2		;End enable bit pulse
	RET
	
COMNWRT:
	MOV		P1, A		;Move the accumulator's command to port 1
	CLR 	P2.0		;Clear RS pin (indicating a command)
	CLR		P2.1		;Clear RW pin (indicating writing)
	SETB 	P2.2		;Begin enable bit pulse
	ACALL 	DELAY		;Wait momentarily for actions to complete
	CLR 	P2.2		;End enable bit pulse
	RET
	
DATAWRT:
	MOV		P1, A		;Move the accumulator's data to port 1
	SETB 	P2.0		;Set RS pin (indicating data)
	CLR 	P2.1		;Clear RW pin (indicating writing)
	SETB 	P2.2		;Begin enable bit pulse
	ACALL 	DELAY		;Wait momentarily for actions to complete
	CLR 	P2.2		;End enable bit pulse
	RET
	
DELAY:
	PUSH 	3			;Preserve used registers
	PUSH 	4
	MOV 	R3, #33		;External delay loop sentinal value
LOOP2:
	MOV 	R4, #255	;Internal delay loop sentinal value
LOOP1:
	DJNZ 	R4, LOOP1	;Wait until internal loop comcludes
	DJNZ 	R3, LOOP2	;Wait until external loop concludes
	POP 	4			;Replace preserved values
	POP		3
	RET
	
CR 	EQU		0C0H		;Load Carriage Return command
TXT: 		DB    	'2.1 Arce/McIntyre', 0
TXT2:		DB		'SOON TO USE ARM', 0
END
