; (0,0) --------- x -------->
;	|				B
;	|
;	y	A
;	|
;	|
;	v
; On horizontal line, y is same So, we pushed y cordinate first and then x cordinates(which are changing)
; On vertical line, x is same So, we pushed x cordinate first and then y cordinates(which are changing)
; (x,y) is input from user which is stored in registers R0 and R1 respectively
; We took 40 pixels to plot a line. So, horizontal and vertical lines will be of length 40 pixels each. 


	 PRESERVE8
     THUMB
     AREA     appcode, CODE, READONLY
     EXPORT __main
	 ENTRY 
__main  FUNCTION
					;MOV R10,#1				;CROSSWIRE MASK
					MOV R6,#0				;COUNTER FOR LOOP
					MOV R0,#100				;x
					MOV R1,#110				;y
					MOV R2,#40				;NUMBER OF PIXELS FOR CROSSWIRE
					SUB R7,R0,#20			;POINT A
					LDR R3, =0X20000000    ; R7 = array address
					
					MOV R5,R1			; Y PUSHED FIRST(Y IS FIXED FOR HORIZONTAL LINE)
					MOV R4, #0        ; R8 = array index position to store R0 into
					STR R5, [R3, R4]  ; store R0 into array[R8]
					
LOOP_HORIZONTAL		ADD R4,R4,#1		; INCREMENTING INDEX
					MOV R5,R7			; (INDEX) OF X CORDINATE
					STR R5, [R3, R4]  ; store R0 into array[R8]		
					ADD R7,R7,#1
					ADD R6,R6,#1 		;LOOP COUNTER
					CMP R6,R2			; IF COUNTER < 40, JUMP
					BLT LOOP_HORIZONTAL
					ADD R4,R4,#1
					SUB R7,R1,#20			;POINT B
					MOV R5,R0			; X PUSHED FIRST(X IS FIXED FOR VERTICAL LINE)
					STR R5, [R3, R4]  ; store X into array[R8]
					MOV R6,#0				;COUNTER FOR LOOP
LOOP_VERTICAL		ADD R4,R4,#1		; INCREMENTING INDEX
					MOV R5,R7			; (INDEX) OF Y CORDINATE
					STR R5, [R3, R4]  ; store R0 into array[R8]		
					ADD R7,R7,#1
					ADD R6,R6,#1 		;LOOP COUNTER
					CMP R6,R2			; IF COUNTER < 40, JUMP
					BLT LOOP_VERTICAL

; For checking encryption module, we considered thet the pixels generated from above code is input data to encryption module
					LDR R6, =0X20000070    ; R7 = array address
ENCRYPTION			MOV R10,#0			;counting number of array elements accessed
					LDR R0, [R3, R10]  ; LOAD DATA FROM ARRAY (PIXEL DATA)
					MOV R1,#77				;initialization vector -> KEY
LOOP				EOR R1,R0,R1 			; NEW KEY
					STR R1, [R6, R10]  
					ADD R10,R10,#1
					LDR R0, [R3, R10]  ; LOAD DATA FROM ARRAY (PIXEL DATA)
					CMP R10, R4			; IF COUNTER < R4, JUMP
					BLT LOOP
					
					MOV R10,#0			;counting number of array elements accessed
					MOV R11,#0
					LDR R7, =0X200000E0    ; R7 = array address
HAMMING 			LDR R1, [R6, R10]  ; LOAD DATA FROM ARRAY (PIXEL DATA)

					; Begin by expanding the 8-bit value to 12-bits, inserting
					; zeros in the positions for the four check bits (bit 0, bit 1, bit 3
					; and bit 7).
					
					AND	R2, R1, #0x1		; Clear all bits apart from d0
					MOV	R0, R2, LSL #2		; Align data bit d0
					
					AND	R2, R1, #0xE		; Clear all bits apart from d1, d2, & d3
					ORR	R0, R0, R2, LSL #3	; Align data bits d1, d2 & d3 and combine with d0
					
					AND	R2, R1, #0xF0		; Clear all bits apart from d3-d7
					ORR	R0, R0, R2, LSL #4	; Align data bits d4-d7 and combine with d0-d3
					
					; We now have a 12-bit value in R0 with empty (0) check bits in
					; the correct positions
					

					; Generate check bit c0
					
					EOR	R2, R0, R0, LSR #2	; Generate c0 parity bit using parity tree
					EOR	R2, R2, R2, LSR #4	; ... second iteration ...
					EOR	R2, R2, R2, LSR #8	; ... final iteration
					
					AND	R2, R2, #0x1		; Clear all but check bit c0
					ORR	R0, R0, R2		; Combine check bit c0 with result
					
					; Generate check bit c1
					
					EOR	R2, R0, R0, LSR #1	; Generate c1 parity bit using parity tree
					EOR	R2, R2, R2, LSR #4	; ... second iteration ...
					EOR	R2, R2, R2, LSR #8	; ... final iteration
					
					AND	R2, R2, #0x2		; Clear all but check bit c1
					ORR	R0, R0, R2		; Combine check bit c1 with result
					
					; Generate check bit c2
					
					EOR	R2, R0, R0, LSR #1	; Generate c2 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	; ... second iteration ...
					EOR	R2, R2, R2, LSR #8	; ... final iteration
					
					AND	R2, R2, #0x8		; Clear all but check bit c2
					ORR	R0, R0, R2		; Combine check bit c2 with result	
					
					; Generate check bit c3
					
					EOR	R2, R0, R0, LSR #1	; Generate c3 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	; ... second iteration ...
					EOR	R2, R2, R2, LSR #4	; ... final iteration
					
					AND	R2, R2, #0x80		; Clear all but check bit c3
					ORR	R0, R0, R2		; Combine check bit c3 with result
					ADD R11, R11,#2
					ADD R10, #1
					STR R0,[R7,R11]
					CMP R10,R4
					BLT HAMMING
					

stop    B stop 
	ENDFUNC 
	END