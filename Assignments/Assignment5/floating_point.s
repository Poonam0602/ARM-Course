; Implementation of logic gates using neural network
; ERaisedToX 
; Sigmoid : (1/(1+ERaisedToX))
; GetX : Calculate value of X based on weightages

	 area     appcode, CODE, READONLY
	 IMPORT printMsg             
	 export __main	
	 ENTRY 
__main  function		 
		;for LOGIC_NOT following are the valid combination of input as can be seen in python code
		;X0->1, X1->0, X2->0
		;X0->1, X1->1, X2->0
		VLDR.F32 S29,=1 ;X0
		VLDR.F32 S30,=1	;X1
		VLDR.F32 S31,=0	;X2
		ADR.W  R6, BranchTable_Byte
		MOV R7,#0 ; to select one option in switch case (gates)
		;0->LOGIC_AND
		;1->LOGIC_OR
		;2->LOGIC_NOT
		;3->LOGIC_NAND
		;4->LOGIC_NOR
		;5->LOGIC_XOR
		;6->LOGIC_XNOR
		TBB   [R6, R7] ; switch case equivalent in Arm cortex M4
		;S0 = W0,S1 = W1, S2 = W2, S3 = (Bias)
;S0 stores final value of e raised to power x
LOGIC_AND	VLDR.F32 S0,=-0.1
			VLDR.F32 S1,=0.2
			VLDR.F32 S2,=0.2
			VLDR.F32 S3,=-0.2
			B GetX
LOGIC_OR	VLDR.F32 S0,=-0.1
			VLDR.F32 S1,=0.7
			VLDR.F32 S2,=0.7
			VLDR.F32 S3,=-0.1
			B GetX
LOGIC_NOT	VLDR.F32 S0,=0.5
			VLDR.F32 S1,=-0.7
			VLDR.F32 S2,=0
			VLDR.F32 S3,=0.1
			B GetX
LOGIC_NAND	VLDR.F32 S0,=0.6
			VLDR.F32 S1,=-0.8
			VLDR.F32 S2,=-0.8
			VLDR.F32 S3,=0.3
			B GetX
LOGIC_NOR	VLDR.F32 S0,=0.5
			VLDR.F32 S1,=-0.7
			VLDR.F32 S2,=-0.7
			VLDR.F32 S3,=0.1
			B GetX
LOGIC_XOR	VLDR.F32 S0,=-5
			VLDR.F32 S1,=20
			VLDR.F32 S2,=10
			VLDR.F32 S3,=1
			B GetX
LOGIC_XNOR	VLDR.F32 S0,=-5
			VLDR.F32 S1,=20
			VLDR.F32 S2,=10
			VLDR.F32 S3,=1
			B GetX
;S28 will store the final X0*W0 + X1*W1 + X2*W2 + Bias
GetX				VMLA.F32 S28, S0, S29
					VMLA.F32 S28, S1, S30
					VMLA.F32 S28, S2, S31
					VADD.F32 S28, S28, S3
					B ERaisedToX
;offset calculation for switch case
BranchTable_Byte	DCB    0
					DCB    ((LOGIC_OR-LOGIC_AND)/2)
					DCB    ((LOGIC_NOT-LOGIC_AND)/2)
					DCB    ((LOGIC_NAND-LOGIC_AND)/2)
					DCB    ((LOGIC_NOR-LOGIC_AND)/2)
					DCB    ((LOGIC_XOR-LOGIC_AND)/2)
					DCB    ((LOGIC_XNOR-LOGIC_AND)/2)

ERaisedToX		MOV R0,#10				;Holding the Number of Terms in Series 'n' 
				MOV R1,#1				;Counting Variable 'i' 
				VMOV.F32 S0,#1			;Holding the sum of series elements 's' 
				VMOV.F32 S1,#1			;Temp Variable to hold the intermediate series elements 't' 
				VMOV.F32 S2,#10			;Holding 'x' Value 
LOOP1			CMP R1,R0		;Compare 'i' and 'n'  
				BLE LOOP				;if i < n goto LOOP 
				B Sigmoid					;else goto stop 
LOOP			VMUL.F32 S1,S1,S2; t = t*x 
				VMOV.F32 S5,R1			;Moving the bit stream in R1('i') to S5(floating point register) 
				VCVT.F32.U32 S5, S5		;Converting the bitstream into unsigned fp Number 32 bit 
				VDIV.F32 S1,S1,S5		;Divide t by 'i' and store it back in 't' 		
				VADD.F32 S0,S0,S1		;Finally add 's' to 't' and store it in 's' 
				ADD R1,R1,#1			;Increment the counter variable 'i' 
				B LOOP1					;Again goto comparision 
			
Sigmoid			VDIV.F32 S2, S3, S2 ; 1/e^x
				VADD.F32 S2, S3, S2 ; 1 + 1/e^x
				VDIV.F32 S2, S3, S2 ; 1/(1 + 1/e^x)
				B OUTPUT
			
OUTPUT			VLDR.F32 S15 ,=0.5
				VCMP.F32 S2, S15 ; compare the output of sigmoid routine with S15
				VMRS.F32 APSR_nzcv,FPSCR ; Transfer floating-point flags to the APSR flags
				ITE HI
				MOVHI R0,#1; if S2 > S15
				MOVLS R0,#0; if S2 < S15
				BL printMsg	 ; Refer to ARM Procedure calling standards.
		
fullstop    B  fullstop ; stop program	   
     endfunc
     end