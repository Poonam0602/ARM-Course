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
					MOV R6,#0				;COUNTER FOR LOOP
					MOV R0,#100				;x
					MOV R1,#110				;y
					MOV R2,#40				;NUMBER OF PIXELS FOR CROSSWIRE
					SUB R7,R0,#20			;POINT A
					LDR R3, =0X20000000     ; R7 = array address
					
					MOV R5,R1				; Y PUSHED FIRST(Y IS FIXED FOR HORIZONTAL LINE)
					MOV R4, #0        		; R8 = array index position to store R0 into
					STR R5, [R3, R4] 	    ; store R0 into array[R8]
					
LOOP_HORIZONTAL		ADD R4,R4,#1			; INCREMENTING INDEX
					MOV R5,R7		 		; (INDEX) OF X CORDINATE
					STR R5, [R3, R4]  		; store R0 into array[R8]		
					ADD R7,R7,#1
					ADD R6,R6,#1 			;LOOP COUNTER
					CMP R6,R2				; IF COUNTER < 40, JUMP
					BLT LOOP_HORIZONTAL
					ADD R4,R4,#1
					SUB R7,R1,#20			;POINT B
					MOV R5,R0				; X PUSHED FIRST(X IS FIXED FOR VERTICAL LINE)
					STR R5, [R3, R4]  		; store X into array[R8]
					MOV R6,#0				;COUNTER FOR LOOP
LOOP_VERTICAL		ADD R4,R4,#1			; INCREMENTING INDEX
					MOV R5,R7				; (INDEX) OF Y CORDINATE
					STR R5, [R3, R4]  		; store R0 into array[R8]		
					ADD R7,R7,#1
					ADD R6,R6,#1 			;LOOP COUNTER
					CMP R6,R2				; IF COUNTER < 40, JUMP
					BLT LOOP_VERTICAL
					
					
					
      ;.................................... DATA ENCRYPTION STARTS HERE....................................
	  
	  
	  
	  
; For checking encryption module, we considered thet the pixels generated from above code is input data to encryption module
					
					LDR R6, =0X20000070    	; R6 = array address
ENCRYPTION			MOV R10,#0				;counting number of array elements accessed
					LDR R0, [R3, R10]  		; LOAD DATA FROM ARRAY (PIXEL DATA)
					MOV R1,#77				;initialization vector -> key
LOOP				EOR R1,R0,R1 			; NEW KEY
					STR R1, [R6, R10]  
					ADD R10,R10,#1
					LDR R0, [R3, R10]  		; LOAD DATA FROM ARRAY (PIXEL DATA)
					CMP R10, R4				; IF COUNTER < R4(count), JUMP
					BLT LOOP
					ADD R4,R4,#3
					MOV R10,#0				;counting number of array elements accessed
					MOV R11,#0
					LDR R7, =0X200000E0    	; R7 = array address
HAMMING 			LDR R1, [R6, R10]       ; LOAD DATA FROM ARRAY (PIXEL DATA)

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
					ORR	R0, R0, R2		    ; Combine check bit c0 with result
					
					; Generate check bit c1
					
					EOR	R2, R0, R0, LSR #1	; Generate c1 parity bit using parity tree
					EOR	R2, R2, R2, LSR #4	; ... second iteration ...
					EOR	R2, R2, R2, LSR #8	; ... final iteration
					
					AND	R2, R2, #0x2		; Clear all but check bit c1
					ORR	R0, R0, R2		    ; Combine check bit c1 with result
					
					; Generate check bit c2
					
					EOR	R2, R0, R0, LSR #1	; Generate c2 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	; ... second iteration ...
					EOR	R2, R2, R2, LSR #8	; ... final iteration
					
					AND	R2, R2, #0x8		; Clear all but check bit c2
					ORR	R0, R0, R2		    ; Combine check bit c2 with result	
					
					; Generate check bit c3
					
					EOR	R2, R0, R0, LSR #1	; Generate c3 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	; ... second iteration ...
					EOR	R2, R2, R2, LSR #4	; ... final iteration
					
					AND	R2, R2, #0x80		; Clear all but check bit c3
					ORR	R0, R0, R2		    ; Combine check bit c3 with result
					ADD R11, R11,#2
					ADD R10, #1
					STR R0,[R7,R11]
					CMP R10,R4
					BLT HAMMING
					
	;----------------------------- TRANSMISSION ENDS HERE ----------------------------------------------
	
	
	
	
	;----------------------------- RECEIVER STARTS HERE ------------------------------------------------
					
					
					LDR R4, =0X200001A0   
					MOV R12,#0
					
					ADD R7, R7, #2
RX					LDR	R0, [R7,R12]
					;EOR	R0, R0, #0x100	
					;Clear bits c0, c1, c3, c7
					LDR R3, =0XFFFFFF74
					AND R3, R0, R3
					
					EOR	R2, R3, R3, LSR #2	; Generate c0 parity bit using parity tree
					EOR	R2, R2, R2, LSR #4	; 
					EOR	R2, R2, R2, LSR #8	; 
					
					AND	R2, R2, #0x1		; Clear all but check bit c0
					ORR	R3, R3, R2		    ; Combine check bit c0 with result
					
					; Generate check bit c1
					
					EOR	R2, R3, R3, LSR #1	; Generate c1 parity bit using parity tree
					EOR	R2, R2, R2, LSR #4	;
					EOR	R2, R2, R2, LSR #8	;
					
					AND	R2, R2, #0x2		; Clear all but check bit c1
					ORR	R3, R3, R2			; Combine check bit c1 with result
					
					; Generate check bit c2
					
					EOR	R2, R3, R3, LSR #1	; Generate c2 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	;
					EOR	R2, R2, R2, LSR #8	;
					
					AND	R2, R2, #0x8		; Clear all but check bit c2
					ORR	R3, R3, R2		    ; Combine check bit c2 with result	
					
					; Generate check bit c3
					
					EOR	R2, R3, R3, LSR #1	; Generate c3 parity bit using parity tree
					EOR	R2, R2, R2, LSR #2	;
					EOR	R2, R2, R2, LSR #4	; 
					
					AND	R2, R2, #0x80		; Clear all but check bit c3
					ORR	R3, R3, R2		    ; Combine check bit c3 with result


					
					;Compare the original value (with error) and the recalculated value using exclusive-OR
					EOR R1, R0, R3


					;Isolate the results of the EOR operatation to result in a 4-bit calculation

					;Clearing all bits apart from c7 and shifting bit 4 positions right
					LDR R6, =0X80
					AND R6, R6, R1
					MOV R6, R6, LSR #4
				
					;Clearing all bits apart from c3 and shifting the 3rd bit 1 position right
					LDR R5, =0X8
					AND R5, R5, R1
					MOV R5, R5, LSR #1
					ADD R1, R6, R5
					;Clearing all bits apart from c0 and c1  
					LDR R6, =0X3
					AND R6, R6, R1


					;Adding the 4 registers together 
					;ADD R1, R4, R5
					ADD R1, R1, R6 

					;Subtracting 1 from R1 to determine the bit position of the error
					SUB R1, R1, #1

					;Store tmp register with binary 1. Then moves the 1, 8 bit positions left.  We use '8' because R1 contains 8 bits
					LDR R6, =0X1
					MOV R6, R6, LSL R1

					;Flips the bit in bit 8 of R0
					EOR R0, R0, R6
					;Result =0x00000A6B   
					;Shrinking of 12 bit parity code to 8 bit data code
					MOV R0, R0, LSR#2
					
					AND R8, R0, #1
					AND R9, R0, #28
					
					MOV R9, R9, LSR#1
					ADD R8, R8, R9
					
					AND R10, R0, #960
					MOV R10, R10, LSR#2
					
					ADD R8, R8, R10    		;Adding the three registers so that we get 8 bit data from 12bit corrected data
					STR R8,[R4,0x01]!
					ADD R12,R12,#2
					CMP R12,R11
					BLT RX	
					
					LDR R4, =0X200001A1
					LDR R6, =0X20000215
					MOV R3, #2
					UDIV R12, R12, R3 	    ; TO COMPARE
					SUB R12, R12, #3
DECRYPTION			MOV R10,#0				;counting number of array elements accessed
					LDR R0, [R4, R10]	  	; LOAD DATA FROM ARRAY (PIXEL DATA)
					MOV R1,#77				;initialization vector -> KEY
LOOP1				EOR R2,R0,R1 			; OUTPUT REGISTER -> stored in memory for checking
					STR R2, [R6, R10]  
					ADD R10,R10,#1
					MOV R1, R0
					LDR R0, [R4, R10]       ; LOAD DATA FROM ARRAY (PIXEL DATA)
					CMP R10, R12			; IF COUNTER < R12, JUMP
					BLT LOOP1



stop    B stop 
	ENDFUNC 
	END