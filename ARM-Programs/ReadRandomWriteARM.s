; Name: Logan McIntyre, Walker Arce
; Date: 20181102
; Lab 3.2
; Desc: Read Random Write functionality ported from 8051.

; Define PORT I/O addresses from the datasheet
PORTA_DIR 		EQU 0x41004400 		; DIR register for PORTA bits
PORTA_DIRSET	EQU 0x41004404		
PORTA_DIRCLR	EQU 0x41004408
PORTA_OUT 		EQU 0x41004410 		; OUT register for PORTA bits
PORTA_OUTCLR 	EQU 0x41004414 		; OUTCLR register for PORTA bits
PORTA_OUTSET 	EQU 0x41004418 		; OUTSET register for PORTA bits
PORTA_IN		EQU 0x41004420
PORTA_WRCONFIG	EQU 0x41004428

PORTB_DIR 		EQU 0x41004480 		; DIR register for PORTB bits
PORTB_DIRSET	EQU 0x41004484		
PORTB_DIRCLR	EQU 0x41004488
PORTB_OUT 		EQU 0x41004490 		; OUT register for PORTB bits
PORTB_OUTCLR 	EQU 0x41004494 		; OUTCLR register for PORTB bits
PORTB_OUTSET 	EQU 0x41004498 		; OUTSET register for PORTB bits
PORTB_IN		EQU 0x410044A0
PORTB_WRCONFIG	EQU 0x410044A8
	
; Define useful bits and LCD commands	
RS_BIT			EQU	0x10			; Bit 4
RW_BIT			EQU 0x20			; Bit 5
EN_BIT			EQU 0x40			; Bit 6
CR_CMD			EQU 0x0C0			; Carriage return command
	
;============================DATA AREA=============================
	AREA data, DATA, READONLY
		
DATALINE1		DCB	"McIntyre, Arce",0
DATALINE2		DCB "ECEN - 3320",0
DATALINE3		DCB	"1ST: ",0
DATALINE4		DCB	"2ND: ",0
	
;=============================VECTOR AREA TABLE==================================
	; Instruct assembler to construct new code area
	AREA vectors, CODE, READONLY
	; Assemble this area to use THUMB instruction set
	THUMB
	; Mark beginning of vector table, DCD allocates one word of memory
__Vectors
	DCD 0x20008000 				; top-of-stack
	DCD Reset_Handler 			; reset handler
	EXPORT __Vectors
	EXPORT Reset_Handler
		
;=============================RESET AREA==========================================
	; Instruct assembler to construct new code area for resets
	AREA RESET, CODE, READONLY
	; Assemble this area to use THUMB instruction set
	THUMB
	; Mark beginning of reset handler
Reset_Handler
		;
		; Reset and initialization code goes here
		;
		LDR R0, =START 			; Load R0 with address at label START
		BX R0 					; Branch to value in R0

;=============================MAIN CODE AREA======================================
	; Instruct assembler to construct new code area for main code
	AREA MAIN, CODE, READONLY
	; Assemble this area to use THUMB instruction set
	THUMB
	
START								; Label to indicate start of main code
	;Configure IO Ports
	LDR			R4, =0x00000070			;Bit mask to make PA4, 5, 6 OUTPUT
	LDR			R5, =PORTA_DIR			;Load PORTA DIR reg address
	STR			R4, [R5]				;Store bit mask into direction register
	LDR			R4, =0x000000FF			;Bit mask to make 0-7 OUTPUT and 8-15 INPUT
	LDR			R5, =PORTB_DIR			;Load PORTB DIR reg address
	STR			R4, [R5]				;Store bit mask into direction register
	LDR			R5, =PORTB_WRCONFIG
	LDR			R4, =0x4006FF00
	STR			R4, [R5]				;Write WRCONFIG
	
	;Engage pullups
	LDR			R5, =PORTB_OUTSET
	LDR			R4, =0x0000FF00			;Engage 8-15
	STR			R4, [R5]				;Enable pullups
	
	BL		LCD_INIT	
	LDR		R6, =DATALINE1
	BL		LCD_STRING
	BL		LCD_CR
	LDR		R6, =DATALINE2
	BL		LCD_STRING
	
	LDR		R0, =7500			; 7.5 second delay
	BL		DELAY_ms
	BL		LCD_CLR
	
	;=======Next part of code performs read-random-write===============
LOOP
	BL		READ_IO				; Places state of DIP swtiches onto R3
	BL		RANDOM				; Randomizes R3, stores in R0
	MOVS	R2, R0				; Copies R0 to R2
	MOVS	R3, R2
	BL		RANDOM
	MOVS	R1, R0				; Copies second number to R1
	MOVS	R0, R2				; Copies first number to R0

	LDR		R6, =DATALINE3
	BL		LCD_STRING
	MOV		R5, R0
	BL		WRITE_BYTE
	BL		LCD_CR
	LDR		R6, =DATALINE4
	BL		LCD_STRING
	MOV		R5, R1
	BL		WRITE_BYTE
	
	LDR		R0, =100
	BL		DELAY_ms
	BL		LCD_CLR
	B		LOOP
	

;=============================PROCEDURES=========================================
; Desc: Delay subroutine performs a loop in 1ms for a 1MHz operating frequency
; Inputs: R0, procedure counter

DELAY_ms
	PUSH {R0, R1, LR} 			; Pushes counter and link register to
LD2 								; stack (R0 at lowest mem location)
	LDR R1, =332
LD1
	SUBS R1, R1, #1 			; Decrement R1 (affect flags)
	BNE LD1 					; Branch if Z is 0 (detects 0 on R1)
	SUBS R0, R0, #1 			; Otherwise, decrement R0 (affect flags)
	BNE LD2 					; If not zero, branch
	POP {R0, R1, PC} 			; Once complete, pop previous values
	NOP
	
; Desc: Initializes the LCD
; Inputs: none

LCD_INIT
	PUSH	{R0, R1, R5, LR}	; Push next address in program code to stack
	LDR		R5, =0x30			; Command function set for LCD
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =5
	BL		DELAY_ms
	BL		LCD_CMD				; Send command to LCD (2nd pulse)
	LDR		R0, =1
	BL		DELAY_ms
	BL		LCD_CMD				; Send command to LCD (3rd pulse)
	LDR		R0, =1
	BL		DELAY_ms	
	LDR		R5, =0x3C			; 8-bit interface
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =5
	BL		DELAY_ms
	LDR		R5, =0x08			; Turn display off
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =16
	BL		DELAY_ms
	LDR		R5, =0x01			; Clear LCD
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =16
	BL		DELAY_ms
	LDR		R5, =0x06			; Increment mode, no shifting
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =16
	BL		DELAY_ms
	LDR		R5, =0x0F			; Turn on LCD
	BL		LCD_CMD				; Send command to LCD
	LDR		R0, =16
	BL		DELAY_ms
	POP		{R0, R1, R5, PC}

; Desc : sends a command to the LCD from register R5
; Input : R5, command to be sent

LCD_CMD
	PUSH	{R1, R2, R3, R4, LR}	; Push next address in program code to stack
	LDR		R1, =PORTA_OUTCLR		; Load PORTA output clear register address to R6
	LDR		R3, =PORTA_OUTSET
	LDR		R4, =PORTB_OUT
	STR		R5, [R4]				; Place command from R5 to PORTB
	MOVS	R2, #RS_BIT
	STR		R2, [R1]				; Clear the RS (send command) pin
	MOVS	R2, #RW_BIT
	STR		R2, [R1]				; Clear the RW (write) pin
	MOVS	R2, #EN_BIT
	STR		R2, [R3]				; Set enable pin
	LDR		R0, =16
	BL		DELAY_ms				; Branch to delay
	STR		R2, [R1]				; Clear enable pin
	POP		{R1, R2, R3, R4, PC}
	
; Desc : sends data to the LCD from register R5
; Input : R5, one byte of data

LCD_DATA
	PUSH	{R1, R2, R3, R4, LR}	; Push next address in program code to stack
	LDR		R1, =PORTA_OUTCLR		; Load PORTA output clear register address to R6
	LDR		R3, =PORTA_OUTSET
	LDR		R4, =PORTB_OUT
	STR		R5, [R4]				; Place data from R5 to PORTB
	MOVS	R2, #RW_BIT
	STR		R2, [R1]				; Clear the RW (write) pin
	MOVS	R2, #RS_BIT
	STR		R2, [R3]				; Set the RS (send data) pin
	MOVS	R2, #EN_BIT
	STR		R2, [R3]				; Set enable pin
	LDR		R0, =16
	BL		DELAY_ms				; Branch to delay to latch data
	STR		R2, [R1]				; Clear enable pin
	POP		{R1, R2, R3, R4, PC}

; Desc : clears the LCD
; Inputs : none		

LCD_CLR
	PUSH	{R5, LR}				; Push next address in program code to stack
	LDR		R5, =0x01				; Clear LCD command
	BL		LCD_CMD					; Send command to LCD
	POP		{R5, PC}
	
; Desc : initiates a carriage return on the LCD
; Inputs : none		

LCD_CR
	PUSH	{R5, LR}				; Push next address in program code to stack
	MOVS	R5, #CR_CMD				; Load R5 with carraige return code
	BL		LCD_CMD					; Send code to LCD
	POP		{R5, PC}
	
; Desc: sets PORTB.0..7 as outputs, PORTB.8..15 as inputs, and PORTA.4..6 as outputs
; Inputs: none

HARDWARE_INIT
	;Configure IO Ports
	LDR			R4, =0x00000070			;Bit mask to make PA4, 5, 6 OUTPUT
	LDR			R5, =PORTA_DIR			;Load PORTA DIR reg address
	STR			R4, [R5]				;Store bit mask into direction register
	LDR			R4, =0x000000FF			;Bit mask to make 0-7 OUTPUT and 8-15 INPUT
	LDR			R5, =PORTB_DIR			;Load PORTB DIR reg address
	STR			R4, [R5]				;Store bit mask into direction register
	LDR			R5, =PORTB_WRCONFIG
	LDR			R4, =0x4006FF00
	STR			R4, [R5]				;Write WRCONFIG
	
	;Engage pullups
	LDR			R5, =PORTB_OUTSET
	LDR			R4, =0x0000FF00			;Engage 8-15
	STR			R4, [R5]				;Enable pullups
	BX 			LR
	
; Desc: prints the string pointed to by R1	
; Inputs : R6 should be loaded with data address

LCD_STRING
	PUSH	{R6, R5, LR}
PRINT_DATA1
	LDRB	R5, [R6]			; Load byte of data to R5
	CMP		R5, #0				; Check if end of string reached
	BEQ		END_PRINT
	ADDS	R6, R6, #1			; Point to next byte
	BL		LCD_DATA			; Print contents of R5
	B		PRINT_DATA1
END_PRINT
	POP		{R6, R5, PC}
	NOP

; Desc: reads the second byte on PORTB (connected to DIP switches), sends to R3
; Inputs : none

READ_IO
	LDR			R5, =PORTB_IN			;Setup address to read
	LDR			R4, [R5]				;Read all 32 bits
	LDR			R3, =0x0000FF00			;Setup bit mask
	ANDS		R4, R3					;Clear other bits
	LSRS		R4, #8					;Shift bits to align with bit zero
	MOVS		R3, R4					;Temp load
	BX 			LR
	
; Desc : reads the information on the DIP switches, creates and prints pseudo-random number
; Inputs : R3, number to be randomized
; Output : "Random" number on R0

RANDOM
	PUSH	{R1, R2, R3, R4, LR}
	LSLS	R3, #1
	MOV		R1, R3					; Copy new data to R1
	LDR		R4, =0x40				; mask bit 6
	ANDS	R1, R4
	LSRS	R1, #6					; Move masked bit to 0 position
	MOV		R2, R3					; Copy data to R2
	LDR		R4, =0x80				; mask bit 7
	ANDS	R2, R4
	LSRS	R2, #7
	EORS	R1, R2					; XOR bits 6 and 7, place in R1.0
									; R1 now contains 0b0000000x
	EORS	R3, R1		
	LDR		R1, =0x7F
	ANDS 	R3, R1	
	MOV		R0, R3

	POP		{R1, R2, R3, R4, PC}
	
; Desc : Writes a byte of information (one bit at a time) to the LCD
; Inputs: R5, byte to be written

WRITE_BYTE
	PUSH	{R3, R4, R5, R6, LR}
	LDR		R6, =8					; Use R6 as counter
	MOVS	R4, R5					; Copy R5 to R4
NEXT_ITER
	MOVS	R3, R4					; Copy original data to R3
	LSRS	R3, R6					; Move bit to be tested into Carry Flag
	BCS		WRITE_ONE
	LDR		R5, =0x30				; Load R5 with ASCII 0
	BL		LCD_DATA
	B		CLOSE_LOOP		
WRITE_ONE
	LDR		R5, =0x31				; Load R5 with ASCII 1
	BL		LCD_DATA				; Write 1 to LCD
CLOSE_LOOP
	SUBS	R6, R6, #1				; Decrement counter
	BEQ		END_WRITE
	B		NEXT_ITER				; If counter not zero, move to next iteration
END_WRITE		
	POP		{R3, R4, R5, R6, PC}
	NOP
	
	END ; End of source code
