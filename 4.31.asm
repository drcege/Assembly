DATA SEGMENT
    CR EQU 0DH
    LF EQU 0AH
    MAX EQU 200
    
    ;�����Ϣ
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
    
    ;������
    bufName  DB MAX, 0, MAX DUP (0)
    bufClass DB MAX, 0, MAX DUP (0)
    bufID    DB MAX, 0, MAX DUP (0)
    bufScore DB MAX, 0, MAX DUP (0)
    TEMP     DB 5 DUP(0), '$'
    BUFFER   EQU OFFSET TEMP+5
    
    ;��������
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
    MOV DS, AX            ;��ʼ��
    ;����������
    
    ;�����
    PRINT_STR MACRO VAR
        PUSH AX
        PUSH DX
        MOV DX, VAR
        MOV AH, 09H
        INT 21H
        POP DX
        POP AX
    ENDM
    
    ;��ʾ��Ϣ����ȡ����
    LEA BX, msgTips             ;�����ʾ��Ϣ
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    LEA BX, msgName
    PRINT_STR BX
    LEA DX, bufName             ;��ȡ��������
    MOV AH, 0AH
    INT 21H

    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgClass
    PRINT_STR BX
    LEA DX, bufClass            ;��ȡ���а༶
    MOV AH, 0AH
    INT 21H
    
    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgID
    PRINT_STR BX
    LEA DX, bufID               ;��ȡ����ID
    MOV AH, 0AH
    INT 21H
    
    LEA BX, msgCRLF 
    PRINT_STR BX
    LEA BX, msgScore
    PRINT_STR BX
    LEA DX, bufScore           ;��ȡ���гɼ�
    MOV AH, 0AH
    INT 21H
    
    ;��������
    MOV SI, 02H                ;���������ݴӵ�������ʼ
    ;�Ƚϳɼ���ʮλ
CMP9:
    INC cnt                    ;����ѧ������
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
    ;ͳ�Ʋ������ۼӺ�
    XOR AX, AX
    CMP bufScore[SI], 'A'       ;�ж��Ƿ�Ϊ'A'
    JNE NOTA
    MOV AL, 10                  ;��'A', ת��Ϊ10
    JMP CALC
NOTA:
    MOV AL, bufScore[SI]
    SUB AL, '0'                 ;����'A', д�������ַ���Ӧֵ
CALC:
    ;����ɼ���ʮ����ֵ
    MOV BL, 10
    MUL BL                      ;AX <- AL x BL, ʮλֵ��10
    MOV BL, bufScore[SI+1]
    SUB BL, '0'  ;ת����λֵ
    XOR BH, BH
    ADD AX, BX                  ;AX�Ѿ��洢�ɼ�����������
    MOV BL, 10
    MUL BL                      ;AX <- AL x 10
    MOV BL, bufScore[SI+3]
    SUB BL, '0'  ;С��λֵ
    XOR BH, BH
    ADD AX, BX
    ADD averSum, AX             ;��ʱ�ɼ�Ϊ��λ����С���ѳ�10
    
    ;ѭ�������
    ADD SI, 4                   ;ÿ���ɼ�����Ϊ�ģ�����Ϊ�ո�λ��
    CMP bufScore[SI], CR        ;�ж��Ƿ�Ϊ�س�����
    JE OVER                     ;�س�����
    INC SI                      ;�����һ��ȡ�¸��ɼ�
    JMP CMP9
OVER:
    ;����ͳ�ƽ���
    MOV bufName[SI], '$'
    MOV bufClass[SI], '$'
    MOV bufID[SI], '$'
    MOV bufScore[SI], '$'
    ;����ƽ��ֵ
    MOV AX, averSum
    XOR DX, DX
    XOR CX, CX
    MOV CL, cnt
    DIV CX                 ;AX <- DX:AX / cnt ��
                           ;DX <- DX:AX / cnt ����
    MOV CL, 10
    DIV CL                 ;AL <- AX / 10 ��
                           ;AH <- AX / 10 ����
    MOV averFloat, AH      ;��һ����AX����10������AH��С������
    XOR AH, AH             ;��ո�λ������
    MOV averSum, AX        ;��λ���̼�ƽ���ɼ�����������
    
    ;���ɼ���С����
    CALL SORT
    
    ;�����ʾ
    LEA BX, msgCRLF
    PRINT_STR BX
    PRINT_STR BX
    PRINT_STR BX
    LEA BX, msgResult            ;�����ʾ
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    XOR AX, AX
    LEA BX, msgTotal
    PRINT_STR BX
    MOV AL, cnt
    CALL DECOUT                  ;����Ŀ
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
    CALL DECOUT                  ;ƽ���ɼ���������
    MOV AH, 2
    MOV DL, '.'
    INT 21H                      ;С����
    XOR AX, AX
    MOV AL, averFloat
    CALL DECOUT                  ;ƽ���ɼ�С������
    LEA BX, msgCRLF
    PRINT_STR BX
    
    CALL SORT
    LEA BX, msgCRLF
    PRINT_STR BX
    LEA BX, msgSorted            ;������ʾ
    PRINT_STR BX
    
    MOV BX, OFFSET bufName[2]    ;���������
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufClass[2]   ;�����༶
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufID[2]      ;�����ID
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    MOV BX, OFFSET bufScore[2]   ;��������
    PRINT_STR BX
    LEA BX, msgCRLF
    PRINT_STR BX
    
    ;���ز���ϵͳ
    MOV AX, 4C00H
    INT 21H
;
; DECOUT: ��ʮ������ʽ���һ���޷��������֣�
; ��ڣ�(AX),��Ҫ���������
; ���ڣ���
; �洢��Ԫ����Ҫʹ��TEMP����Ļ�����
DECOUT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, BUFFER           ;ָ�򻺳���β��
OUTLOOP:
    MOV DX, 0
    MOV CX, 10
    DIV CX                   ;AX <- ��, DX <- ����, DX:AX/10
    ADD DL, '0'              ;��0-9ת��Ϊ�ַ�
    DEC BX
    MOV BYTE PTR [BX], DL    ;��DL�е��ַ����浽������
    OR AX, AX
    JNZ OUTLOOP              ;(AX)=0 �����
OUTLOOPFIN:
    MOV DX, BX
    PRINT_STR DX             ;���ת������
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DECOUT ENDP
;
; SORT�����ɼ��ɴ�Сð������
; ��ڣ�cnt, bufName, bufClass, bufID, bufScore
; ���ڣ���
SORT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    XOR CX, CX
    MOV CL, cnt
    DEC CX                    ;���ѭ������ΪԪ�ظ�����һ
LOOP_OUT:
    MOV DI, CX                ;����ѭ���������ⱻ�ڲ��ƻ�
                              ;�ڲ�ѭ�������������ͬ,�����ʼ��
    MOV BX, 02H               ;�ڲ�ѭ����ʼ״̬���ӵ������ַ���ʼ
LOOP_IN:
    MOV AL, bufScore[BX]
    CMP AL, bufScore[BX+5]    ;�Ƚ�ʮλ
    JA CONTI                  ;���ں�һ����,����ѭ��
    JB XCH                    ;С�ں�һ����������
    MOV AL, bufScore[BX+1]
    CMP AL, bufScore[BX+1+5]  ;�Ƚϸ�λ
    JA CONTI
    JB XCH
    MOV AL, bufScore[BX+3]
    CMP AL, bufScore[BX+3+5]  ;�Ƚ�С��λ
    JAE CONTI                 ;���ڵ��ں�һ��������ѭ��
XCH:                          ;������ǰԪ�غͺ�һ��
    MOV DX, CX                ;����ѭ����ǰ����
    MOV CX, 4                 ;�������黺��������
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
    ADD SI, MAX+2             ;����һ���������ĳ��ȣ�ָ���¸�����
    LOOP LOOP4
    MOV CX, DX                ;�ָ��ڲ�ѭ������
CONTI:
    ADD BX, 05H               ;��һ��Ԫ�ص��±�
    LOOP LOOP_IN
    MOV CX, DI                ;�ָ����ѭ������
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
