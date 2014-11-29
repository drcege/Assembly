DATA SEGMENT
    CR EQU 0DH
    LF EQU 0AH
    MAX EQU 200
    
    ;输出消息
    msgCRLF DB CR, LF, '$'
    msgTips DB 'Tips:', CR, LF, '1.Must 4 chars for each name/class/ID/score (eg. Kate/3005/0001/60.0)', CR, LF, '2.Separate each word by a space, no spaces at the end of the line!', CR, LF, '3.Replace 100.0 by A0.0', CR, LF, '$'
    msgName DB 'Please input the names of all students:', CR, LF, '$'
    msgClass DB 'Please input the classes of all students:', CR, LF, '$'
    msgID DB 'Please input the IDs of all students:', CR, LF, '$'
    msgScore DB 'Please input the scores of all students:', CR, LF, '$'
    
    msgResult  DB 'The results are as follows:', CR, LF, '$'
    msgTotal DB 'The total number of students is: $'
    msg0to6  DB 'The number of students who scored below 60 is: $'
    msg6to7 DB 'The number of students who scored between 60 and 70 is: $'
    msg7to8 DB 'The number of students who scored between 70 and 80 is: $'
    msg8to9 DB 'The number of students who scored between 80 and 90 is: $'
    msg9toA DB 'The number of students who scored above 90 is: $'
    msgAver DB 'The average score of all students is: $'
    msgSorted DB 'Sorted by scores (high to low):', CR, LF, '$'
    
    ;缓冲区
    bufName  DB MAX, 0, MAX DUP (0)
    bufClass DB MAX, 0, MAX DUP (0)
    bufID    DB MAX, 0, MAX DUP (0)
    bufScore DB MAX, 0, MAX DUP (0)
    TEMP     DB 5 DUP(0), '$'
    BUFFER   EQU OFFSET TEMP+5
    
    ;计数变量
    cnt DB 0
    _0To6 DB 0
    _6to7 DB 0
    _7to8 DB 0
    _8to9 DB 0
    _9toA DB 0
    averSum DW 0
    averFloat DB 0
    
DATA ENDS

STACK SEGMENT STACK
    DW 100 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK
START:
    MOV AX, DATA
    MOV DS, AX            ;初始化
    ;以下主程序
    
    ;输出宏
    PRINT_STR MACRO VAR
        PUSH AX
        PUSH DX
        MOV DX, VAR
        MOV AH, 09H
        INT 21H
        POP DX
        POP AX
    ENDM
    
    ;提示消息并读取数据
    LEA BX, msgTips             ;输出提示消息
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msgName
    PRINT_STR BX
    LEA DX, bufName             ;读取所有名字
    MOV AH, 0AH
    INT 21H

    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgClass
    PRINT_STR BX
    LEA DX, bufClass            ;读取所有班级
    MOV AH, 0AH
    INT 21H
    
    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgID
    PRINT_STR BX
    LEA DX, bufID               ;读取所有ID
    MOV AH, 0AH
    INT 21H
    
    LEA BX, msgCRLF 
    PRINT_STR BX
    LEA BX, msgScore
    PRINT_STR BX
    LEA DX, bufScore           ;读取所有成绩
    MOV AH, 0AH
    INT 21H
    
    ;处理数据
    MOV SI, 02H                ;缓冲区数据从第三个开始
    ;比较成绩的十位
CMP9:
    INC cnt                    ;计数学生个数
    CMP bufScore[SI], '9'
    JB CMP8
    INC _9toA
    JMP ACCU
CMP8:
    CMP bufScore[SI], '8'
    JB CMP7
    INC _8to9
    JMP ACCU
CMP7:
    CMP bufScore[SI], '7'
    JB CMP6
    INC _7to8
    JMP ACCU
CMP6:
    CMP bufScore[SI], '6'
    JB CMP0
    INC _6to7
    JMP ACCU
CMP0:
    INC _0To6    
ACCU:
    ;统计并计算累加和
    XOR AX, AX
    CMP bufScore[SI], 'A'       ;判断是否为'A'
    JNE NOTA
    MOV AL, 10                  ;是'A', 转换为10
    JMP CALC
NOTA:
    MOV AL, bufScore[SI]
    SUB AL, '0'                 ;不是'A', 写入数字字符对应值
CALC:
    ;计算成绩的十进制值
    MOV BL, 10
    MUL BL                      ;AX <- AL x BL, 十位值乘10
    MOV BL, bufScore[SI+1]
    SUB BL, '0'  ;转换个位值
    XOR BH, BH
    ADD AX, BX                  ;AX已经存储成绩的整数部分
    MOV BL, 10
    MUL BL                      ;AX <- AL x 10
    MOV BL, bufScore[SI+3]
    SUB BL, '0'  ;小数位值
    XOR BH, BH
    ADD AX, BX
    ADD averSum, AX             ;此时成绩为三位数，小数已乘10
    
    ;循环或结束
    ADD SI, 4                   ;每个成绩长度为四，加四为空格位置
    CMP bufScore[SI], CR        ;判断是否为回车结束
    JE OVER                     ;回车结束
    INC SI                      ;否则加一读取下个成绩
    JMP CMP9
OVER:
    ;数据统计结束
    MOV bufName[SI], '$'
    MOV bufClass[SI], '$'
    MOV bufID[SI], '$'
    MOV bufScore[SI], '$'
    ;计算平均值
    MOV AX, averSum
    XOR DX, DX
    XOR CX, CX
    MOV CL, cnt
    DIV CX                 ;AX <- DX:AX / cnt 商
                           ;DX <- DX:AX / cnt 余数
    MOV CL, 10
    DIV CL                 ;AL <- AX / 10 商
                           ;AH <- AX / 10 余数
    MOV averFloat, AH      ;第一次商AX除以10的余数AH是小数部分
    XOR AH, AH             ;清空高位的余数
    MOV averSum, AX        ;低位的商即平均成绩的整数部分
    
    ;按成绩大小排序
    CALL SORT
    
    ;结果显示
    LEA BX, msgCRLF
    PRINT_STR BX
    PRINT_STR BX
    PRINT_STR BX
    LEA BX, msgResult            ;结果提示
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    XOR AX, AX
    LEA BX, msgTotal
    PRINT_STR BX
    MOV AL, cnt
    CALL DECOUT                  ;总数目
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msg0to6
    PRINT_STR BX
    MOV AL, _0To6
    CALL DECOUT                  ;0-60
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msg6to7
    PRINT_STR BX
    MOV AL, _6to7
    CALL DECOUT                  ;60-70
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msg7to8
    PRINT_STR BX
    MOV AL, _7to8
    CALL DECOUT                  ;70-80
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msg8to9
    PRINT_STR BX
    MOV AL, _8to9
    CALL DECOUT                  ;80-90
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msg9toA
    PRINT_STR BX
    MOV AL, _9toA
    CALL DECOUT                  ;90-100
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msgAver
    PRINT_STR BX
    MOV AX, averSum
    CALL DECOUT                  ;平均成绩整数部分
    MOV AH, 2
    MOV DL, '.'
    INT 21H                      ;小数点
    XOR AX, AX
    MOV AL, averFloat
    CALL DECOUT                  ;平均成绩小数部分
    LEA BX, msgCRLF
    PRINT_STR BX
    
    CALL SORT
    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgSorted            ;排序提示
    PRINT_STR BX
    
    MOV BX, OFFSET bufName[2]    ;排序后名字
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufClass[2]   ;排序后班级
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufID[2]      ;排序后ID
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufScore[2]   ;排序后分数
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    ;返回操作系统
    MOV AX, 4C00H
    INT 21H
;
; DECOUT: 以十进制形式输出一个无符号数（字）
; 入口：(AX),需要输出的正数
; 出口：无
; 存储单元：需要使用TEMP定义的缓冲区
DECOUT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, BUFFER           ;指向缓冲区尾部
OUTLOOP:
    MOV DX, 0
    MOV CX, 10
    DIV CX                   ;AX <- 商, DX <- 余数, DX:AX/10
    ADD DL, '0'              ;将0-9转换为字符
    DEC BX
    MOV BYTE PTR [BX], DL    ;将DL中的字符保存到缓冲区
    OR AX, AX
    JNZ OUTLOOP              ;(AX)=0 则结束
OUTLOOPFIN:
    MOV DX, BX
    PRINT_STR DX             ;输出转换后结果
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DECOUT ENDP
;
; SORT：按成绩由大到小冒泡排序
; 入口：cnt, bufName, bufClass, bufID, bufScore
; 出口：无
SORT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    XOR CX, CX
    MOV CL, cnt
    DEC CX                    ;外层循环次数为元素个数减一
LOOP_OUT:
    MOV DI, CX                ;保存循环次数以免被内层破坏
                              ;内层循环次数与外层相同,无需初始化
    MOV BX, 02H               ;内层循环初始状态，从第三个字符开始
LOOP_IN:
    MOV AL, bufScore[BX]
    CMP AL, bufScore[BX+5]    ;比较十位
    JA CONTI                  ;大于后一个数,继续循环
    JB XCH                    ;小于后一个数，交换
    MOV AL, bufScore[BX+1]
    CMP AL, bufScore[BX+1+5]  ;比较个位
    JA CONTI
    JB XCH
    MOV AL, bufScore[BX+3]
    CMP AL, bufScore[BX+3+5]  ;比较小数位
    JAE CONTI                 ;大于等于后一个，继续循环
XCH:                          ;交换当前元素和后一个
    MOV DX, CX                ;保存循环当前次数
    MOV CX, 4                 ;交换四组缓冲区数据
    MOV SI, 0
LOOP4:
    MOV AH, bufName[BX][SI]
    XCHG AH, bufName[BX+5][SI]
    MOV bufName[BX][SI], AH
    MOV AH, bufName[BX+1][SI]
    XCHG AH, bufName[BX+1+5][SI]
    MOV bufName[BX+1][SI], AH
    MOV AH, bufName[BX+2][SI]
    XCHG AH, bufName[BX+2+5][SI]
    MOV bufName[BX+2][SI], AH
    MOV AH, bufName[BX+3][SI]
    XCHG AH, bufName[BX+3+5][SI]
    MOV bufName[BX+3][SI], AH
    ADD SI, MAX+2             ;加上一个缓冲区的长度，指向下个数组
    LOOP LOOP4
    MOV CX, DX                ;恢复内层循环次数
CONTI:
    ADD BX, 05H               ;下一个元素的下标
    LOOP LOOP_IN
    MOV CX, DI                ;恢复外层循环次数
    LOOP LOOP_OUT
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SORT ENDP

CODE ENDS

END START
