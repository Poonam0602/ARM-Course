; Implementation of logic gates using neural network
; ERaisedToX 
; Sigmoid : (1/(1+ERaisedToX))
; GetX : Calculate value of X based on weightages

	 	AREA	appcode, CODE, READONLY
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
LOGIC_AND	VLDR.F32 S0,=-0.1
			VLDR.F32 S1,=0.2
			VLDR.F32 S2,=0.2
			VLDR.F32 S3,=-0.2
			B EXP_X_CALCULATION
LOGIC_OR	VLDR.F32 S0,=-0.1
			VLDR.F32 S1,=0.7
			VLDR.F32 S2,=0.7
			VLDR.F32 S3,=-0.1
			B EXP_X_CALCULATION
LOGIC_NOT	VLDR.F32 S0,=0.5
			VLDR.F32 S1,=-0.7
			VLDR.F32 S2,=0
			VLDR.F32 S3,=0.1
			B EXP_X_CALCULATION
LOGIC_NAND	VLDR.F32 S0,=0.6
			VLDR.F32 S1,=-0.8
			VLDR.F32 S2,=-0.8
			VLDR.F32 S3,=0.3
			B EXP_X_CALCULATION
LOGIC_NOR	VLDR.F32 S0,=0.5
			VLDR.F32 S1,=-0.7
			VLDR.F32 S2,=-0.7
			VLDR.F32 S3,=0.1
			B EXP_X_CALCULATION
LOGIC_XOR	VLDR.F32 S0,=-5
			VLDR.F32 S1,=20
			VLDR.F32 S2,=10
			VLDR.F32 S3,=1
			B EXP_X_CALCULATION
LOGIC_XNOR	VLDR.F32 S0,=-5
			VLDR.F32 S1,=20
			VLDR.F32 S2,=10
			VLDR.F32 S3,=1
			B EXP_X_CALCULATION
;S28 will store the final X0*W0 + X1*W1 + X2*W2 + Bias
EXP_X_CALCULATION	VMLA.F32 S28, S0, S29
					VMLA.F32 S28, S1, S30
					VMLA.F32 S28, S2, S31
					VADD.F32 S28, S28, S3
					B EXPROUTINE
;offset calculation for switch case
BranchTable_Byte	DCB    0
					DCB    ((LOGIC_OR-LOGIC_AND)/2)
					DCB    ((LOGIC_NOT-LOGIC_AND)/2)
					DCB    ((LOGIC_NAND-LOGIC_AND)/2)
					DCB    ((LOGIC_NOR-LOGIC_AND)/2)
					DCB    ((LOGIC_XOR-LOGIC_AND)/2)
					DCB    ((LOGIC_XNOR-LOGIC_AND)/2)
;this program performs e^x,the result will be stored in S2
EXPROUTINE	VMOV.F32 S2, #1 ; Sum Variable
			VMOV.F32 S6, #25 ; 'n' variable - sequence size
			;VMOV.F32 S1, #5 ; 'x' varaiable - in e^x
			VMOV.F32 S3, #1 ; constant
loop		VCMP.F32 S6, #0
			VMRS.F32 APSR_nzcv,FPSCR ; Transfer floating-point flags to the APSR flags
			BEQ SIGROUTINE
			VDIV.F32 S4, S2, S6 ; sum/i
			;VMUL.F32 S5, S1, S4 ; x*sum/i
			VMUL.F32 S5, S28, S4 ; x*sum/i
			VADD.F32 S2, S3, S5 ; sum = 1 + (x * (sum/i))
			VSUB.F32 S6, S6, S3
			B loop
SIGROUTINE	VDIV.F32 S2, S3, S2 ; 1/e^x
			VADD.F32 S2, S3, S2 ; 1 + 1/e^x
			VDIV.F32 S2, S3, S2 ; 1/(1 + 1/e^x)
			B OUTPUT
;SIGROUTINE
			;VMOV.F32 S7, S2 ; e^x to S7
			;VADD.F32 S8, S3, S7 ; 1 + e^x to S8
			;VDIV.F32 S9, S7, S8
			;B OUTPUT
; S15 will hold 0.5 for comparison to finalise the logical output for a particular gate
OUTPUT	VLDR.F32 S15 ,=0.5
		VCMP.F32 S2, S15 ; compare the output of sigmoid routine with S15
		VMRS.F32 APSR_nzcv,FPSCR ; Transfer floating-point flags to the APSR flags
		ITE HI
		MOVHI R0,#1; if S2 > S15
		MOVLS R0,#0; if S2 < S15
		BL printMsg	 ; Refer to ARM Procedure calling standards.
stop 	B  stop ; stop program
		endfunc
		end
