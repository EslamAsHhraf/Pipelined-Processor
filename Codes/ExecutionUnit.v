/*ID/EX Buffer 141 bit*/
/*
1: IOR                                |  0 
1: IOW                                |  1
1: OPS                                |  2
3: ALU_OP                             |  5:3
1: ALU                                |  6
2: FD                                 |  8:7
16: Data1                             |  24:9
16: Data2                             |  40:25
3: WB_Address                         |  43:41
1: MR                                 |  44
1: MW                                 |  45
1: WB                                 |  46
1: JMP                                |  47
1: SP                                 |  48
1: SPOP                               |  49
2: FGS                                |  51:50
32: PC                                |  83:52
1: JWSP                               |  84
3: SRC_Address                        |  87:85
1: IMM                                |  88
1: Stack_PC                           |  89
1: Stack_Flags                        |  90
16: Immediate_Value                   |  106:91
2: Forwarding_Unit_Selectors          |  108:107
16: Data_From_Forwarding_Unit1        |  124:109
16: Data_From_Forwarding_Unit2        |  140:125
*/

/*EX/MEM Buffer 76*/
/*
32: Data                    | 31:0
3: WB_Address_Out           | 34:32         
1: MR_Out                   | 35
1: MW_Out                   | 36
1: WB_Out                   | 37
32: Address                 | 69:38
1: JWSP_Out                 | 70
1: Stack_PC_Out             | 71
1: Stack_Flags_Out          | 72
3: Final_Flags              | 75:73
*/


module ExecutionUnit(
    /*Inputs From Buffer*/
    IOR,IOW,OPS,ALU,MR,MW,WB,JMP, SP,SPOP,JWSP,IMM,Stack_PC,Stack_Flags,
    FD,FGS,
    ALU_OP,WB_Address,SRC_Address,
    Data1,Data2,Immediate_Value,
    PC,

    /*Signals*/
    Forwarding_Unit_Selectors, // 1-bit To be changed in the design

    /*Asynchronous Inputs*/
    Data_From_Forwarding_Unit1,
    Data_From_Forwarding_Unit2,

    /*Flags*/
    /*NF|CF|ZF*/
    Flags,

    /*Flags From Memory*/
    /*NF|CF|ZF*/
    Flags_From_Memory,

    /*Input Port*/
    INPUT_PORT,

    /*Stack Pointer*/
    Stack_Pointer,

    /*Outputs*/
    MR_Out,MW_Out,WB_Out,JWSP_Out,Stack_PC_Out,Stack_Flags_Out,
    WB_Address_Out,
    Data,Address,

    /*Flags Outputs*/
    /*NF|CF|ZF*/
    Final_Flags,

    /*Stack Pointer Out*/
    Stack_Pointer_Out,

    /*For Jumps*/
    Taken_Jump, 

    /* Output Signals */
    /*PC Selectors*/
    To_PC_Selector
);  
    /*Inputs*/
    input IOR,IOW,OPS,ALU,MR,MW,WB,JMP,SP,SPOP,JWSP,IMM,Stack_PC,Stack_Flags;
    input [1:0] FD,FGS,Forwarding_Unit_Selectors;
    input [2:0] ALU_OP,WB_Address,SRC_Address,Flags;
    input [15:0] Data1,Data2,Immediate_Value,Data_From_Forwarding_Unit1,Data_From_Forwarding_Unit2,INPUT_PORT;
    input [31:0] PC, Stack_Pointer;

    /*Outputs*/
    output MR_Out,MW_Out,WB_Out,JWSP_Out,Stack_PC_Out,Stack_Flags_Out, Taken_Jump, To_PC_Selector;
    output [2:0] WB_Address_Out,Final_Flags;
    output [31:0] Data,Address, Stack_Pointer_Out;

    /*Connections*/
    wire Temp_CF,Select_Flags_Or_From_Memory, Jump_On_Which_Flag;
    wire [2:0] Flags_From_Decision,Flags_Out;
    wire [15:0] Operand1,Operand2,Immediate_Or_Register,Data_Or_One,Data_From_ALU,Data_To_Use;
    wire [31:0] SP_From_Adder_Subtractor, Push_Or_Pop_Stack_Pointer;


    /* Level 1 */
    assign Operand1= Forwarding_Unit_Selectors[0]==1'b1?Data_From_Forwarding_Unit1:Data1;

    assign Immediate_Or_Register= IMM==1'b1?Immediate_Value:Data2;

    assign Data_Or_One= Forwarding_Unit_Selectors[1]==1'b1?Data_From_Forwarding_Unit2:Immediate_Or_Register;

    assign Operand2= OPS==1'b1?16'd1:Data_Or_One;


    /* Level 2 */
    assign {Temp_CF,Data_From_ALU} = (ALU_OP==3'd7)? ~Operand1:
        (ALU_OP==3'd0)? Operand1+Operand2:
        (ALU_OP==3'd1)? Operand1-Operand2:
        (ALU_OP==3'd2)? Operand1&Operand2:
        (ALU_OP==3'd3)? Operand1|Operand2:
        (ALU_OP==3'd4)? Operand1<<Operand2:
        (ALU_OP==3'd5)? Operand1>>Operand2:Operand1;


    /*NF|CF|ZF*/
    assign Flags_Out[0]= Data_From_ALU==16'd0; // ZF
    assign Flags_Out[1]= (ALU_OP==3'd0 || ALU_OP==3'd1 || ALU_OP==3'd4) ? Temp_CF : Flags[1]; // CF
    assign Flags_Out[2]= Data_From_ALU[15]==1'b1; // NF


    /* Level 3 */
    assign Data_To_Use=(JMP==1'b1)?Operand1:
        (IOW==1'b1)?Operand1:
        (ALU===1'b1)?Data_From_ALU:
        (IOR===1'b1)?INPUT_PORT:
        (MW===1'b1)?Operand2:Operand2;


    assign Flags_From_Decision=(FD==2'b00)?{Flags[2],0,Flags[0]}:
        (FD==2'b01)?{Flags[2],1,Flags[0]}:
        (FD==2'b10)?Flags:
        (FD==2'b11)?Flags_Out:3'b000;

    
    assign Select_Flags_Or_From_Memory= Stack_Flags & MR;

    assign Final_Flags=Select_Flags_Or_From_Memory==1'b1?Flags_From_Memory:Flags_From_Decision;

    
    /* Level 4 Data*/

    /*NF|CF|ZF*/
    assign Jump_On_Which_Flag = (FGS==2'd0)? Flags[0]:
        (FGS==2'd1)? Flags[2]:
        (FGS==2'd2)? Flags[1]: 1'b1;
    
    assign Taken_Jump = Jump_On_Which_Flag & JMP;


    assign Data =  (Taken_Jump & SP)? PC: {{16{1'b0}},Data_To_Use}; 
    

    /* Level 4 Address*/
    assign SP_From_Adder_Subtractor = SPOP==1'b1? Stack_Pointer+32'd1: Stack_Pointer-32'd1;

    assign Stack_Pointer_Out = SP==1'b1? SP_From_Adder_Subtractor: Stack_Pointer;

    assign Push_Or_Pop_Stack_Pointer = SPOP==1'b1? Stack_Pointer_Out: Stack_Pointer;

    assign Address = (SP==1'b1)? Push_Or_Pop_Stack_Pointer: 
        (MR==1'b1)? {{16{1'b0}}, Operand2}:           //Address = Src in Case of Load
        (MR==1'b0)? {{16{1'b0}}, Operand1};           //Address = Dst Otherwise


    assign To_PC_Selector = (Taken_Jump & !JWSP);

    /*Unchangable*/
    assign  {MR_Out,MW_Out,WB_Out,JWSP_Out,Stack_PC_Out,Stack_Flags_Out}={MR,MW,WB,JWSP,Stack_PC,Stack_Flags};
endmodule