; Program to find GCD of two numbers
;while (a != b)
;{
;    if (a > b)
;            a = a – b;
;       else
;            b = b – a;
;}
	 AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #80	  ;value of a	
			  MOV r1 , #45     ;value of b
LOOP	      CMP r0 , r1
              IT EQ 
              BEQ STOP	
              ITE HI			  
			  SUBHI r0 , r0 , r1 ;if (a > b) -> a = a – b			  
			  SUBLS r1 , r1 , r0 ; else -> b = b - a
              B LOOP			  
STOP		      B STOP  ; stop program
        endfunc
      end
