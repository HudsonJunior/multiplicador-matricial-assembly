.section .data
	titulo: 	.asciz 	"\n*** Trabalho 2: Multiplicador Matricial (double float) ***\n"

    # Menu
	menu: 	    .asciz 	"\n=========== MENU ===========\n1 - Digitar Matrizes\n2 - Obter Matrizes de Arquivo\n3 - Calculo Produto Matricial\n4 - Gravar Matriz Resultante em Arquivo\n5 - Imprimir Matrizes\n6 - Sair\n"
    pedeMenu:   .asciz  "\nOpção => "
    opcao: 		.int 	0

    int:        .asciz  "%d"
    float: 	    .asciz 	"%lf"
    quebraLin:  .asciz  "\n"

    # Matriz Amxn e matriz Bnxp
    pedeMA: 	.asciz 	"\nNúmero de linhas de A => "
    pedeNA:     .asciz  "\nNúmero de colunas de A => "
    pedeNB: 	.asciz 	"\nNúmero de linhas de B => "
    pedePB: 	.asciz 	"\nNúmero de colunas de B => "

    # Dimensoes das matrizes
    mA: 		.int 	0
    nA:         .int    0
    nB:         .int    0
	pB: 		.int 	0
    tamA:       .int    0
    tamB:       .int    0
    tamCBytes:       .int    0
    
    # Matrizes
    A: 		    .int 	8
    B:          .int    8
    C:          .int    8

    # Leitura das matrizes
    leitura:    .asciz  "\nLeitura do Vetor %c:\n"	
    pedenum: 	.asciz 	"Elemento [%d][%d] => "
    colunas:    .int    0
    i:          .int    -1
    j:          .int    -1
    k:          .int    -1
    num:        .double 0
    soma:       .double -1
    limpaBuf:   .string "%*c"
    
    # Impressao das matrizes
    imprime:    .asciz  "\nMatriz %c:\n"
    elemento:   .asciz  "%.2lf "

    # Leitura do arquivo
    nomeArquivoEntrada:     .int 0
    pedeNomeArquivoEntrada: .ascii "\nEntre com o nome do arquivo de entrada => " 
    fimPedeArqEntrada:

    # Serviços disponibilizados pelo sistema
    SYS_EXIT:               .int 1
    SYS_READ:               .int 3
    SYS_WRITE:              .int 4
    SYS_OPEN:               .int 5
    STD_OUT:                .int 1 
    STD_IN:                 .int 2 
	SYS_CLOSE: 	            .int 6
    NULL:                   .byte 0 

    # Constantes de configurcão do parametro flag da chamada open().
    O_APPEND:               .int 0x0400
	O_WRONLY:	            .int 0x0001 
    O_CREAT: 	            .int 0x0040
    O_RDONLY:               .int 0x0000

    # Constantes de configuração do parametro mode da chamada open()
    S_IRUSR:                .int 0x0100
	S_IWUSR: 	            .int 0x0080 

    valorFloat:             .double 0.0
    msgAcabou:              .asciz "\nLeitura realizada com sucesso\n"
    fimMsgAcabou:
    msgGravou:              .asciz "\nGravou no arquivo com sucesso\n"
    fimMsgGravou:
    .equ                    tamMsgAcabou, fimMsgAcabou-msgAcabou
    .equ                    tamMsgGravou, fimMsgGravou-msgGravou

    tamSrtArquivoEntrada:   .int 80
    stringLida:             .space 80    # Para ler até 80 caracteres do arquivo de entrada 
    descritor:              .int 0

    .equ                    tamanhoPedeArqEntrada, fimPedeArqEntrada-pedeNomeArquivoEntrada

    nomeArquivoOut:         .asciz  "out.txt"

    # Mensagens de erros
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
	# Finaliza a execução do programa
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
    
    # Faz a chamada de cada operação do menu

    cmpl    $6, %eax
    je      _fim

    cmpl    $1, %eax
    je      _leituraTerminal

    cmpl    $2, %eax
    je      _leituraArq

    # Verifica se ja fez a leitura 
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
    # verifica se as matrizes ja foram alocadas
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

    # insercao do num na matriz
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
    # fim do loop interno

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

    # zera as variaveis de dimensoes das matrizes
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

    # zera as variaveis de dimensoes das matrizes
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
    # imprime um elemento double
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
    # fim do loop interno

    # imprime quebra de linha
    pushl   $quebraLin
    call    printf
    addl    $4, %esp

    popl    %ecx
    loop    _imprimeExterno
    ret

_leituraArq:
    # Verifica se as matrizes ja foram alocadas
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

    # cálculo do produto matricial
    call    _mm1

    # imprime o resultado
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

    # calculo do offset de A, edi -> A[i * linha_B + k]
    movl    nB, %eax
    movl    i, %ebx
    mull    %ebx
    movl    k, %ebx
    addl    %ebx, %eax
    movl    $8, %ebx
    mull    %ebx
    movl    A, %edi
    addl    %eax, %edi

    # calculo do offset de B, esi -> B[k * coluna_B + j]
    movl    pB, %eax
    movl    k, %ebx
    mull    %ebx
    movl    j, %ebx
    addl    %ebx, %eax
    movl    $8, %ebx
    mull    %ebx
    movl    B, %esi
    addl    %eax, %esi

    # multiplicacao de ponto flutuante: soma += (%edi) * (%esi)
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
    # Verifica se a matriz C já foi calculada
    cmpl    $0, tamCBytes
    je      _erroNaoCalculado  
    
    # Verifica se foi informado um nome do arquivo de entrada
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
    # Cria um arquivo caso não tenha sido informado nennhum
    movl 	SYS_OPEN, %eax 		
	movl 	$nomeArquivoOut, %ebx
	movl 	O_WRONLY, %ecx
	orl 	O_CREAT, %ecx
	movl 	S_IRUSR, %edx
	orl 	S_IWUSR, %edx
	int 	$0x80
    
    movl 	%eax, descritor 			
	movl 	SYS_WRITE, %eax
    movl    descritor, %ebx
    
    # Escreve a matriz C nesse arquivo
    movl    C, %edi
    movl    %edi, %ecx
    movl    tamCBytes, %edx
    int     $0x80

	movl 	SYS_CLOSE, %eax
	int 	$0x80

    # Informa que a gravação foi feita com sucesso
    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx     
    movl    $msgGravou, %ecx
    movl    $tamMsgGravou, %edx
    int     $0x80

    jmp     _menu

_insereArquivoEntrada:
    # Abre o arquivo de entrada em modo APPEND
    movl 	SYS_OPEN, %eax 		
	movl 	$nomeArquivoEntrada, %ebx
	movl 	O_WRONLY, %ecx
	orl 	O_APPEND, %ecx
	movl 	S_IRUSR, %edx
	orl 	S_IWUSR, %edx
	int 	$0x80
    
    movl 	%eax, descritor 			
	movl 	SYS_WRITE, %eax
    movl    descritor, %ebx
    
    # Insere a matriz C no final desse arquivo
    movl    C, %edi
    movl    %edi, %ecx
    movl    tamCBytes, %edx
    int     $0x80

	movl 	SYS_CLOSE, %eax
	int 	$0x80

    # Informa que a gravação foi feita com sucesso
    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx         
    movl    $msgGravou, %ecx
    movl    $tamMsgGravou, %edx
    int     $0x80

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
    # Pede o nome do arquivo a ser lido
    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx
    movl    $pedeNomeArquivoEntrada, %ecx
    movl    $tamanhoPedeArqEntrada, %edx
    int     $0x80

_leNomeArqEntrada:
    # Le o nome do arquivo informado
    movl    SYS_READ, %eax
    movl    STD_IN, %ebx
    movl    $nomeArquivoEntrada, %ecx
    movl    $50, %edx
    int     $0x80

_insereFinalString:
    # Colocar caracter final de string no final da string lida
    movl    $nomeArquivoEntrada, %edi
    subl    $1, %eax        # Para compensar o deslocamento
    addl    %eax, %edi        # Avança até o enter
    movl    NULL, %eax
    movl    %eax, (%edi)        # Coloca caracter final de string no lugar

_abreArqLeitura:
    # Abre o arquivo
    movl    SYS_OPEN, %eax
    movl    $nomeArquivoEntrada, %ebx
    # Somente leitura
    movl    O_RDONLY, %ecx
    movl    S_IRUSR, %edx
    int     $0x80
    movl    %eax, descritor     # Guarda o descritor retornado em %eax

_leTamLinhaMatrizA:
    # Faz a leitura do tamanho de linhas da matriz A
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    # Salvar os caracteres lidos na variavel stringLida
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80 

    # Converte o valor lido para inteiro
    pushl   $stringLida
    call    atoi
    movl    %eax, mA    

_leTamColunaMatrizA:
    # Faz a leitura do tamanho de colunas da matriz A
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    # Salvar os caracteres lidos na variavel stringLida
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80  

    # Converte o valor lido para inteiro
    pushl   $stringLida
    call    atoi
    movl    %eax, nA    

_calculaDimensaoMatrizA:
    # Realiza o calculo da dimensão da matriz A
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
    # Loop de inserção de valores na matriz A
    movl    %ecx, tamA
    
    # Recupera o valor dos valores (3 caracteres x.y)
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $3, %edx
    int     $0x80

    # Converte valor lido para float
    finit
    subl    $8, %esp
    pushl   $stringLida
    call    atof
    fstl    valorFloat
    fstpl   (%esp)

    # Inserção na matriz
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
    # Faz a leitura do tamanho de linhas da matriz B
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80 

    # Converte valor para inteiro
    pushl   $stringLida
    call    atoi
    movl    %eax, nB

    movl    nA, %eax
    movl    nB, %ebx
    cmpl    %eax, %ebx

    # Faz validação das dimensões se são compativeis
    jne     _erroDim

_leTamColunaMatrizB:
    # Faz a leitura do tamanho de colunas da matriz B

    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $1, %edx
    int     $0x80  

    # Converte valor para inteiro
    pushl   $stringLida
    call    atoi
    movl    %eax, pB    

_calculaDimensaoMatrizB:
    # Realiza o calculo da dimensão da matriz B
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
    # Loop de inserção de valores na matriz A
    movl    %ecx, tamB
    
    # Recupera o valor dos valores (3 caracteres x.y)
    movl    SYS_READ, %eax
    movl    descritor, %ebx
    movl    $stringLida, %ecx
    movl    $3, %edx
    int     $0x80

    # Converte valor lido para float
    finit
    subl    $8, %esp
    pushl   $stringLida
    call    atof
    fstl    valorFloat
    fstpl   (%esp)

    # Inserção na matriz
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
    # Escreve uma mensagem indicando que arquivo foi lido com sucesso
    movl    SYS_WRITE, %eax
    movl    STD_OUT, %ebx         
    movl    $msgAcabou, %ecx
    movl    $tamMsgAcabou, %edx
    int     $0x80
    jmp     _menu
