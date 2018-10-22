 ; Program to find (n)th term in fibonacci series
 ; 0 1	1	2	3	5	8	13	21...
 ; Program finds out (n)th fibonacci term, where n is stored in r7 (considering 0 as first term in series)
 ; r2 will store output value 		  
 ; r7 stores the value of (n+1)
 ; r4 = f(n-1)+f(n-2)
	 AREA appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #0    ;f(0) = 0
	          MOV r1 , #1    ; f(1) = 1
              MOV r7 , #7	 ; value of n + 1
              SUB r2 , r7,#1 ; R2 = n	 
              CMP r2 , #1
              IT LS 
              BLS STOP				  
			  SUB r3 , r2 ,#1      ; LOOP COUNT R3
LOOP              ADD r4 , r1 , r0  ;R4 to hold  value of f(n-1)+ f(n-2) 
                  MOV r0 ,r1
                  MOV r1 ,r4
                  MOV r2 , r4
                  SUB r3 ,#1 ; decreament number of terms  
				  CMP r3 ,#0 
                  BNE LOOP	;loop if number of terms is nonzero				  
STOP		      B STOP  ; stop program
        endfunc
      end

