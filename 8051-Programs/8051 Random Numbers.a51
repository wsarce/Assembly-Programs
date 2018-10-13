ORG		00H					;Begin at address 0

START:		
	MOV SP, #50H		;Initialize stack pointer
	LCALL LCD_init		;Initialize the LCD and ports
	LCALL READ			;Read DIP switches
	LCALL RANDOM		;Generate first random number
	MOV R5, A			;Save first random number
	LCALL RANDOM		;Generate second random number
	MOV R6, A			;Save second random number
	LCALL WRITE			;Write to LCD the values created
HERE:
	LCALL HERE
	
	
READ:
	MOV A, P3			;Get the values on the DIP switches
	RET
	
RANDOM:
	RL A				;Begin algorithm with left shift in A
	MOV R1, A			;Save A value so it's not lost in the following actions
	
	ANL A, #80H			;Get bit 7 from A
	RL A				;Rotate one time
	ANL A, #01H			;Mask the upper bits
	MOV R2, A			;Save bit 7 for next operations
	
	MOV A, R1			;Return original value
	
	ANL A, #40H			;Get bit 6 from A
	RL A				;Rotate two times
	RL A
	ANL A, #01H			;Mask the upper bits 
	MOV R3, A			;Save bit 6
	
	MOV A, R2			;Return bit 7 to A for XOR operation
	
	XRL A, R3			;XOR bit 6 and 7
	MOV R4, A			;Save XOR value
	MOV A, R1			;Return original value for OR operation
	ANL	A, #0FEH		;Clear bit 0
	ORL A, R4			;Replace bit zero
	
	ANL A, #7FH			;Mask the seventh bit
	RET
WRITE:
	MOV DPTR, #DATA1	;Point to first data string
	LCALL LCD_string	;Print first string on first line
	MOV A, R5			;Move first random number to accumulator
	LCALL PBS			;Print first number
	LCALL LCD_cr		;Move to second line
	MOV DPTR, #DATA2	;Point to second data string
	LCALL LCD_string	;Print second string on second line
	MOV A, R6			;Move second random number to accumulator
	LCALL PBS			;Print second random number
	
	RET

PBS:
	MOV R7, #8H			;Load counter 
	NEXT_BIT:
	MOV	R1,	A			;Preserve value of A
	ANL	A,	#80H		;Isolate bit 7
	CJNE A, #80H, SEND_ZERO		;Compare bit 7 if not equal to one, jump
	CJNE A, #00H, SEND_ONE		;Compare bit 7 if equal to one, jump
	RESTORE:
	MOV A, R1			;Return value of A
	RL A				;Shift to next bit
	DJNZ R7, NEXT_BIT	;Decrement counter
	RET
	SEND_ZERO:
	MOV A, #30H			;Load zero into A
	LCALL LCD_data		;Print zero onto LCD
	SJMP	RESTORE
	SEND_ONE:
	MOV A, #31H			;Load one into A
	LCALL LCD_data		;Print one onto LCD
	SJMP	RESTORE
LCD_init:
	;Initialization of ports
	MOV 	A, #0		;Load all zeros for port 1 configuration
	MOV		P1, A		;Configure port 1 as an output
	MOV 	A, #0		;Load all zeros for port 2 configuration
	MOV		P2, A		;Configure port 2 as an output
	MOV		A, #0ABH	;Load all 1s for pport 3 configuration
	MOV		P3,	A		;Configure port 3 as an input
	
	;Initialization of LCD
	MOV		A,#38H	
	LCALL	LCD_cmd		;Function Set Command pulse 1
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set Command pulse 2
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set Command pulse 3
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set (5 x 7, 2 line)
	LCALL	DELAY200MS
	MOV 	A,#08H		;Display off
	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#01H		;clear LCD
  	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#06H		;Increment mode, no shifting
	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#0EH		;Display on, cursor on
  	LCALL	LCD_cmd
	LCALL	DELAY200MS
	RET
	
	LCD_cr: 
	MOV   	A,#CR
    LCALL	LCD_cmd		;Send CR command to LCD
    RET
	
	LCD_string:
    CLR   	A
    MOVC  	A,@A+DPTR	;Pass data table entry to A
	JZ    	EXIT1		;If A is zero, conclude string
    LCALL  	LCD_data		;Send character pointed to by A to LCD
    INC   	DPTR		;Move to next character
    SJMP  	LCD_string
	EXIT1:
	RET
	
	LCD_data:
	MOV		P1,A
	SETB 	P2.0		;Set RS pin (indicating data)
	CLR 	P2.1		;Clear RW pin, indicating writing
	SETB 	P2.2		;Begin enable bit pulse
	LCALL 	DELAY200MS	;Wait momentarily for actions to complete
	CLR		P2.2		;End enable bit pulse
	RET
	
	LCD_cmd:
	MOV		P1, A		;Move the accumulator's command to port 1
	CLR 	P2.0		;Clear RS pin (indicating a command)
	CLR		P2.1		;Clear RW pin (indicating writing)
	SETB 	P2.2		;Begin enable bit pulse
	ACALL 	DELAY200MS	;Wait momentarily for actions to complete
	CLR 	P2.2		;End enable bit pulse
	RET
	
	DELAY200MS:
	PUSH	3
	MOV		R3,	#200
LOOP:
	LCALL	DELAY1MS
	DJNZ	R3,	LOOP
	POP		3
	RET
	
	DELAY1MS:
	PUSH 	3			;Preserve used registers
	PUSH 	4
	MOV 	R3, #10		;External delay loop sentinal value
LOOP2:
	MOV 	R4, #255	;Internal delay loop sentinal value
LOOP1:
	DJNZ 	R4, LOOP1	;Wait until internal loop comcludes
	DJNZ 	R3, LOOP2	;Wait until external loop concludes
	POP 	4			;Replace preserved values
	POP		3
	RET
	
	CR 	EQU		0C0H			;Load Carraige Return command
DATA1: DB 'FIRST: ', 0
DATA2: DB 'SECOND: ', 0

END
