; Program to find largest of three numbers
;	g = a     
;	if b > g  
;		g = b 
;	if c > g  
;		g = c 
		
	 AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #7  ;first number -> a
	          MOV r1 , #60  ;second number -> b
              MOV r2 , #10 ;third number  -> c		  
              MOV r3,r0    ;Consider r0 the largest, r3 -> g(greatest number)
			  CMP r1 , r3
              IT GT        ;if (b > g), g = b
			  MOVGT r3,r1
			  CMP r2,r3
			  IT GT        ;if (c > g), g = c
			  MOVGT r3,r2
STOP		      B STOP  ; stop program
        endfunc
      end
