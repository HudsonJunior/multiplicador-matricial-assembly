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
    tamA:       .int    0
    tamB:       .int    0
    tamCBytes:       .int    0
    
    # matrizes
    A: 		    .int 	8
    B:          .int    8
    C:          .int    8

    # leitura das matrizes
    leitura:    .asciz  "\nLeitura do Vetor %c:\n"	
    pedenum: 	.asciz 	"Elemento [%d][%d] => "
    colunas:    .int    0
    i:          .int    -1
    j:          .int    -1
    k:          .int    -1
    num:        .double 0
    soma:       .double -1
    limpaBuf:   .string "%*c"
    
    # impressao das matrizes
    imprime:    .asciz  "\nMatriz %c:\n"
    elemento:   .asciz  "%.2lf "

    # leitura do arquivo
    nomeArquivoEntrada:     .int 0
    pedeNomeArquivoEntrada: .ascii "\nEntre com o nome do arquivo de entrada => " 
    fimPedeArqEntrada:

    SYS_EXIT:               .int 1
    SYS_READ:               .int 3
    SYS_WRITE:              .int 4
    SYS_OPEN:               .int 5
    STD_OUT:                .int 1 
    STD_IN:                 .int 2 
	SYS_CLOSE: 	            .int 6
    NULL:                   .byte 0 
    O_RDONLY:               .int 0x0000 
    S_IRUSR:                .int 0x0100
    O_APPEND:               .int 0x0400
	S_IWUSR: 	            .int 0x0080 # user has write permission
	O_WRONLY:	            .int 0x0001 # somente escrita
    O_CREAT: 	            .int 0x0040
    valorFloat:             .double 0.0
    msgAcabou:              .asciz "\nLeitura realizada com sucesso\n"
    fimMsgAcabou:
    .equ                    tamMsgAcabou, fimMsgAcabou-msgAcabou

    tamSrtArquivoEntrada:   .int 80
    stringLida:             .space 80    # para ler 80 caracteres do arquivo de entrada 
    descritor:              .int 0

    .equ                    tamanhoPedeArqEntrada, fimPedeArqEntrada-pedeNomeArquivoEntrada

    nomeArquivoOut:         .asciz  "out.txt"

    # mensagens de erros
    erroOP:     .asciz  "\nREALIZE A INSERCAO NAS MATRIZES\n"
    erroDim:    .asciz  "\nINCOMPATIBILIDADE DAS DIMENSOES\n"
    erroCalc:    .asciz  "\nREALIZE A MULTIPLICAÇÃO ANTES DE SALVAR NO ARQUIVO\n"

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

    cmpl    $6, %eax
    je      _fim

    cmpl    $1, %eax
    je      _leituraTerminal

    cmpl    $2, %eax
    je      _leituraArq

    # verifica se ja fez a leitura 
    cmpl    $0, mA
    je      _erroOperacao

    cmpl    $0, nB
    je      _erroOperacao

    cmpl    $3, %eax
    je      _multMatrizes

    cmpl    $4, %eax
    je      _gravaResultado

    cmpl    $5, %eax
    je      _imprimeMatrizes

    jmp     _menu

_leituraTerminal:
    # verifica se as matrizes ja foi alocada
    cmpl    $0, mA
    jne     _limpaMatrizesTerminal

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

_limpaMatrizesArq:
    # desalocação dos vetores A e B
    pushl   A
    call    free

    pushl   B
    call    free

    movl    $0, mA
    movl    $0, nA
    movl    $0, nB
    movl    $0, pB
    movl    $0, tamA
    movl    $0, tamB  
    
    jmp     _pedeArqEntrada

_limpaMatrizesTerminal:
    # desalocação dos vetores A e B
    pushl   A
    call    free

    pushl   B
    call    free

    movl    $0, mA
    movl    $0, nA
    movl    $0, nB
    movl    $0, pB
    movl    $0, tamA
    movl    $0, tamB  
    
    jmp     _leituraTerminal

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
    # verifica se as matrizes ja foi alocada
    cmpl    $0, mA
    jne     _limpaMatrizesArq

    jmp     _pedeArqEntrada
    jmp     _menu

_multMatrizes:
    # alocacao da matriz C
    movl    mA, %eax
	movl    pB, %ebx
	mull    %ebx
    movl    $8, %ebx
    mull    %ebx
    movl    %eax, tamCBytes

    pushl   %eax
	call    malloc
    movl    %eax, C

    movl    mA, %ecx
    movl    $0, i

    call    _mm1
    call    _imprimeResultado
    jmp     _menu

_mm1:
    pushl   %ecx

    movl    pB, %ecx
    movl    $0, j

    call    _mm2

    # incremento do i
    movl    i, %eax 
    incl    %eax
    movl    %eax, i
    
    popl    %ecx
    loop    _mm1
    ret

_mm2:
    pushl   %ecx

    movl    nB, %ecx
    movl    $0, k

    # soma = 0
    fldz    
    fstpl   soma

    call    _mm3

    # calculo do offset de C
    movl    i, %eax
    movl    pB, %ebx
    mull    %ebx
    movl    j, %ebx
    addl    %ebx, %eax
    movl    $8, %ebx
    mull    %ebx
    movl    C, %edi
    addl    %eax, %edi

    # insercao em C
    fldl    soma
    fstpl   (%edi)
    addl    $8, %edi

    # incremento do j
    movl    j, %eax 
    incl    %eax
    movl    %eax, j

    popl    %ecx
    loop    _mm2
    ret

_mm3:
    pushl   %ecx

    # calculo do offset de A
    movl    nB, %eax
    movl    i, %ebx
    mull    %ebx
    movl    k, %ebx
    addl    %ebx, %eax
    movl    $8, %ebx
    mull    %ebx
    movl    A, %edi
    addl    %eax, %edi

    # calculo do offset de B
    movl    pB, %eax
    movl    k, %ebx
    mull    %ebx
    movl    j, %ebx
    addl    %ebx, %eax
    movl    $8, %ebx
    mull    %ebx
    movl    B, %esi
    addl    %eax, %esi

    # multiplicacao de ponto flutuante
    fldl    (%edi)  # carrega valor de A na pilha de PF
    fmull   (%esi)  # multiplica  
    faddl   soma    # soma + resultado da mult
    fstpl   soma    # coloca do topo da pilha de PF para a variavel soma

    # incremento de k
    movl    k, %eax 
    incl    %eax
    movl    %eax, k

    popl    %ecx
    loop    _mm3
    ret

_imprimeResultado:
    # imprime matriz C
    pushl   $'C'
    pushl   $imprime
    call    printf
    addl    $8, %esp
    
    movl    C, %edi
    movl    mA, %ecx
    movl    pB, %eax
    movl    %eax, colunas
    call    _imprimeExterno
    ret

_gravaResultado:
    cmpl    $0, tamCBytes
    je      _erroNaoCalculado  
    
    cmpl    $0, nomeArquivoEntrada
    je      _criaArquivoEntrada

    call     _insereArquivoEntrada

    jmp     _menu

_erroNaoCalculado:
    pushl   $erroCalc
    call    printf
    addl    $4, %esp
    jmp     _menu

_criaArquivoEntrada:
    movl 	SYS_OPEN, %eax 		# system call OPEN: retorna o descritor em %eax
	movl 	$nomeArquivoOut, %ebx
	movl 	O_WRONLY, %ecx
	orl 	O_CREAT, %ecx
	movl 	S_IRUSR, %edx
	orl 	S_IWUSR, %edx
	int 	$0x80
    
    movl 	%eax, descritor 			# guarda o descritor
	movl 	SYS_WRITE, %eax
    movl    descritor, %ebx
    
    
    movl    C, %edi
    movl    %edi, %ecx
    movl    tamCBytes, %edx
    int     $0x80

	movl 	SYS_CLOSE, %eax
	int 	$0x80
    jmp     _menu

_insereArquivoEntrada:
    movl 	SYS_OPEN, %eax 		# system call OPEN: retorna o descritor em %eax
	movl 	$nomeArquivoEntrada, %ebx
	movl 	O_WRONLY, %ecx
	orl 	O_APPEND, %ecx
	movl 	S_IRUSR, %edx
	orl 	S_IWUSR, %edx
	int 	$0x80
    
    movl 	%eax, descritor 			# guarda o descritor
	movl 	SYS_WRITE, %eax
    movl    descritor, %ebx
    
    movl    C, %edi
    movl    %edi, %ecx
    movl    tamCBytes, %edx
    int     $0x80

	movl 	SYS_CLOSE, %eax
	int 	$0x80
    ret

_erroOperacao:
    pushl   $erroOP
    call    printf
    addl    $4, %esp
    jmp     _menu

_erroDim:
    pushl   $erroDim
    call    printf
    addl    $4, %esp
    jmp     _menu

_pedeArqEntrada:

    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx
    movl    $pedeNomeArquivoEntrada, %ecx
    movl    $tamanhoPedeArqEntrada, %edx
    int     $0x80

_leNomeArqEntrada:
    movl    SYS_READ, %eax
    movl    STD_IN, %ebx
    movl    $nomeArquivoEntrada, %ecx
    movl    $50, %edx         # le 50 caracteres no maximo
    int     $0x80

_insereFinalString:
    movl    $nomeArquivoEntrada, %edi
    subl    $1, %eax        # para compensar o deslocamento
    addl    %eax, %edi        # avan�a at� o enter
    movl    NULL, %eax
    movl    %eax, (%edi)        # coloca caracter final de string no lugar

_abreArqLeitura:
    movl    SYS_OPEN, %eax         # system call OPEN
    movl    $nomeArquivoEntrada, %ebx
    movl    O_RDONLY, %ecx
    movl    S_IRUSR, %edx
    int     $0x80
    movl    %eax, descritor     # guarda o descritor retornado em %eax

_leTamLinhaMatrizA:
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80 

    pushl   $stringLida
    call    atoi
    movl    %eax, mA    

_leTamColunaMatrizA:
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80  

    pushl   $stringLida
    call    atoi
    movl    %eax, nA    

_calculaDimensaoMatrizA:
    movl    nA, %eax
    movl    mA, %ebx
    mull    %ebx
    movl    %eax, tamA
    movl    $8, %ebx
    mull    %ebx
    pushl   %eax
    call    malloc
    movl    %eax, A

    movl    tamA, %ecx
    movl    A, %edi

_leValoresMatrizA:
    movl    %ecx, tamA
    
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $3, %edx
    int     $0x80

    finit
    subl    $8, %esp
    pushl   $stringLida
    call    atof
    fstl    valorFloat
    fstpl   (%esp)

    fldl    valorFloat
    fstpl   (%edi)
    addl    $8, %edi
    addl    $24, %esp

    movl    tamA, %eax
    movl    tamA, %ecx
    decl    %eax
    movl    %eax, tamA
    
    loop    _leValoresMatrizA

_leTamLinhaMatrizB:
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80 

    pushl   $stringLida
    call    atoi
    movl    %eax, nB

    movl    nA, %eax
    movl    nB, %ebx
    cmpl    %eax, %ebx
    jne     _erroDim

_leTamColunaMatrizB:
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80  

    pushl   $stringLida
    call    atoi
    movl    %eax, pB    

_calculaDimensaoMatrizB:
    movl    nB, %eax
    movl    pB, %ebx
    mull    %ebx
    movl    %eax, tamB
    movl    $8, %ebx
    mull    %ebx
    pushl   %eax
    call    malloc
    movl    %eax, B

    movl    tamB, %ecx
    movl    B, %esi

_leValoresMatrizB:
    movl    %ecx, tamB
    
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $3, %edx
    int     $0x80

    finit
    subl    $8, %esp
    pushl   $stringLida
    call    atof
    fstl    valorFloat
    fstpl   (%esp)

    fldl    valorFloat
    fstpl   (%esi)
    addl    $8, %esi
    addl    $24, %esp

    movl    tamB, %eax
    movl    tamB, %ecx
    decl    %eax
    movl    %eax, tamB
    
    loop    _leValoresMatrizB
    jmp     _acabouArquivo

_acabouArquivo:
    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx         # recupera o descritor
    movl    $msgAcabou, %ecx
    movl    $tamMsgAcabou, %edx
    int     $0x80
    jmp     _menu
# TODO: adicionar free da matriz ao ler do arquivo
