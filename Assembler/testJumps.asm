.ORG 0
IN R6
ADD R1,R1
DEC R7
RTI
IN R5

.ORG 20
IN R2 ;20
LDM R0,0 ;21
LDM R3,2A ;23
LDM R7,F ;25
LDM R1,-2 ;27
LDM R5,2F ;29
STD R0,R1 ;2A
INC R1 ;2B
DEC R7 ;2C
JZ R5 ;2D
JMP R3 ;2E
ADD R2,R2 ;2F