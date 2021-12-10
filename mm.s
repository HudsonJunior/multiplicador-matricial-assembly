.section .data
	titulo: 	.asciz 	"\n*** Trabalho 2: Multiplicador Matricial (double float) ***\n"

    # menu
	menu: 	    .asciz 	"\n=========== MENU ===========\n1 - Digitar Matrizes\n2 - Obter Matrizes de Arquivo\n3 - Calculo Produto Matricial\n4 - Gravar Matriz Resultante em Arquivo\n5 - Imprimir Matrizes\n6 - Sair\n"
    pedeMenu:   .asciz  "\nOpção => "
    opcao: 		.int 	0

    int:        .asciz  "%d"
    float: 	    .asciz 	"%lf"
    quebraLin:  .asciz  "\n"

    # matriz Amxn e matriz Bnxp
    pedeMA: 	.asciz 	"\nNúmero de linhas de A => "
    pedeNA:     .asciz  "\nNúmero de colunas de A => "
    pedeNB: 	.asciz 	"\nNúmero de linhas de B => "
    pedePB: 	.asciz 	"\nNúmero de colunas de B => "

    # dimensoes das matrizes
    mA: 		.int 	0
    nA:         .int    0
    nB:         .int    0
	pB: 		.int 	0
    
    # matrizes
    A: 		    .int 	8
    B:          .int    8
    C:          .int    8

    # leitura das matrizes
    leitura:    .asciz  "\nLeitura do Vetor %c:\n"	
    pedenum: 	.asciz 	"Elemento [%d][%d] => "
    linhas:     .int    0  
    colunas:    .int    0
    i:          .int    -1
    j:          .int    -1
    num:        .double  0
    limpaBuf:   .string "%*c"
    
    # impressao das matrizes
    imprime:    .asciz  "\nMatriz %c:\n"
    elemento:   .asciz  "%.2lf "

    # mensagens de erros
    erroOP:     .asciz  "\nREALIZE A INSERCAO NAS MATRIZES\n"
    erroDim:     .asciz  "\nINCOMPATIBILIDADE DAS DIMENSOES\n"

.section .text
.globl _start
_start:
    finit
	call	_abertura
    jmp     _menu

_fim:
	# finaliza a execução do programa
    pushl   $0
	call    exit

_abertura:
    pushl   $titulo
    call    printf
    addl    $4, %esp
    ret

_menu:
    pushl   $menu
    call    printf
    pushl   $pedeMenu
    call    printf
    pushl   $opcao
    pushl   $int
    call    scanf
    addl    $16, %esp

    movl    opcao, %eax
    
    # faz a chamada de cada operação do menu

    # sair
    cmpl    $6, %eax
    je      _fim

    cmpl    $1, %eax
    je      _leituraTerminal

    cmpl    $2, %eax
    je      _leituraArq

    # verifica se ja fez a leitura 
    cmpl    $-1, i
    je      _erroOperacao

    cmpl    $3, %eax
    je      _multMatrizes

    cmpl    $4, %eax
    je      _gravaResultado

    cmpl    $5, %eax
    je      _imprimeMatrizes

    jmp     _menu

_leituraTerminal:
    # pede numero de linhas e colunas de A
    pushl   $pedeMA
    call    printf
    pushl   $mA
    pushl   $int
    call    scanf
    pushl   $pedeNA
    call    printf
    pushl   $nA
    pushl   $int
    call    scanf
    addl    $24, %esp

    # pede numero de linhas e colunas de B
    pushl   $pedeNB
    call    printf
    pushl   $nB
    pushl   $int
    call    scanf
    pushl   $pedePB
    call    printf
    pushl   $pB
    pushl   $int
    call    scanf
    addl    $24, %esp

    # verifica se as dimensoes sao compativeis
    movl    nA, %eax
    movl    nB, %ebx
    cmpl    %eax, %ebx
    jne     _erroDim

    # calculo do num de bytes e alocacao das matrizes A e B
    movl    nA, %eax
	movl    mA, %ebx
	mull    %ebx
    movl    $8, %ebx
    mull    %ebx
    pushl   %eax
	call    malloc
    movl    %eax, A
    movl    nB, %eax
	movl    pB, %ebx
	mull    %ebx
    movl    $8, %ebx
    mull    %ebx
    pushl   %eax
	call    malloc
    movl    %eax, B
    addl    $8, %esp

_insercaoA:
    pushl   $'A'
    pushl   $leitura
    call    printf 
    addl    $8, %esp

    movl    A, %edi

    # ecx = mA e colunas = nA
    movl    mA, %ecx
    movl    nA, %eax
    movl    %eax, colunas

    movl    $0, i
    call    _insercaoExterno

_insercaoB:
    pushl   $'B'
    pushl   $leitura
    call    printf 
    addl    $8, %esp

    movl    B, %edi

    # ecx = nB e colunas = pB
    movl    nB, %ecx
    movl    pB, %eax
    movl    %eax, colunas

    movl    $0, i
    call    _insercaoExterno

    jmp     _menu

_insercaoExterno:
    pushl   %ecx

    # j = 0 e ecx = nro de colunas
    movl    $0, j
    movl    colunas, %ecx

_insercaoInterno:
    pushl   %ecx

    # entrada do elemento novo
    pushl   j
	pushl   i
	pushl   $pedenum
	call    printf
    pushl   $num
	pushl   $float
	call    scanf
    pushl   $limpaBuf
	call    scanf

    # insercao do num no vetor
    fldl    num
    fstpl   (%edi)
    addl    $8, %edi
    addl    $24, %esp

    # incremento do j
    movl    j, %eax 
    incl    %eax
    movl    %eax, j

    popl    %ecx
    loop    _insercaoInterno

    # incremento do i
    movl    i, %eax 
    incl    %eax
    movl    %eax, i

    popl    %ecx
    loop    _insercaoExterno
    ret

_imprimeMatrizes:
    # imprime matriz A
    pushl   $'A'
    pushl   $imprime
    call    printf
    addl    $8, %esp
    
    movl    A, %edi
    movl    mA, %ecx
    movl    nA, %eax
    movl    %eax, colunas
    call    _imprimeExterno

    # imprime matriz B
    pushl   $'B'
    pushl   $imprime
    call    printf
    addl    $8, %esp

    movl    B, %edi
    movl    nB, %ecx
    movl    pB, %eax
    movl    %eax, colunas
    call    _imprimeExterno 

    jmp     _menu

_imprimeExterno:
    pushl   %ecx
    movl    colunas, %ecx

_imprimeElementos:
    fldl    (%edi)
    addl    $8, %edi
    pushl   %ecx
    subl    $8, %esp
    fstpl   (%esp)
    pushl   $elemento
    call    printf
    addl    $12, %esp    

    popl    %ecx
    loop    _imprimeElementos

    # imprime quebra de linha
    pushl   $quebraLin
    call    printf
    addl    $4, %esp

    popl    %ecx
    loop    _imprimeExterno
    ret

_leituraArq:
    jmp     _menu

_multMatrizes:
    jmp     _menu

_gravaResultado:
    jmp     _menu

_erroOperacao:
    pushl   $erroOP
    call    printf
    addl    $4, %esp
    call    _menu

_erroDim:
    pushl   $erroDim
    call    printf
    addl    $4, %esp
    call    _leituraTerminal
