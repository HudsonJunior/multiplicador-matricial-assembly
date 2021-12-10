.section .data
	titulo: 	.asciz 	"\n*** Trabalho 2: Multiplicador Matricial ***\n"
	menu: 	    .asciz 	"\n=========== MENU ===========\n1 - Digitar Matrizes\n2 - Obter Matrizes de Arquivo\n3 - Calculo Produto Matricial\n4 - Gravar Matriz Resultante em Arquivo\n5 - Sair\n"
    pedeMenu:   .asciz  "\nOpção => "
    formato: 	.asciz 	"%d"
	
    opcao: 		.int 	0
    
    A: 		    .space 	4
    B:          .space  4
    C:          .space  4

.section .text
.globl _start
_start:
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
    pushl   $formato
    call    scanf

    addl    $16, %esp

    movl    opcao, %eax

    # faz a chamada de cada operação do menu

    # sair
    cmpl    $5, %eax
    je      _fim

    cmpl    $1, %eax
    je      _leituraTerminal

    cmpl    $2, %eax
    je      _leituraArq

    cmpl    $3, %eax
    je      _multMatrizes

    cmpl    $4, %eax
    je      _gravaResultado

    jmp    _menu

_leituraTerminal:
    jmp     _menu

_leituraArq:
    jmp     _menu

_multMatrizes:
    jmp     _menu

_gravaResultado:
    jmp     _menu


