[org 0x0100]
 jmp start
 lap1: db ' P:01L:01 '
 lab2: db ' 00m00.0s '
 lab3: db ' 00m00.0s '
 finish : db '      F    I    N    I    S    H      '
 zero : db '000'
 space : db '  '
 dash : db '               '
 fuel : db 'FUEL'
 ign : db 'IGN'
 fire : db 'FIRE'
 rpmm : db 'rpm'
 seconds: dw 0 
 timerflag: dw 0 
 oldkb: dd 0 

 tickcount:	dd	0
 tickcountn: dd	0

rlcount : dw 0
slcount : dw 0
slbcount: dw 1160
mapmovee : dw 640
boolmapmovee : dw 0 
boolmapmoveel : dw 0 
mapmoveecount : dw 0
turn : dw 2
playername : db '00000000000'
playertime : dw 0 

kattam : dw 0 
gameended : dw 0

finaltime : dw 0 
finaltimebool : dw 0


delay:
push bx
push cx
push si
push di

mov cx,50
l111:
	mov bx, 0xFFFF
l2:
	dec bx
	jnz l2
	loop l111

pop di
pop cx
pop si
pop bx
ret

; takes the segment and offset of a string as parameters 
strlen: 
	 push bp 
	 mov bp,sp 
	 push es 
	 push cx 
	 push di 
	 les di, [bp+4] ; point es:di to string 
	 mov cx, 0xffff ; load maximum number in cx 
	 xor al, al ; load a zero in al 
	 repne scasb ; find zero in the string 
	 mov ax, 0xffff ; load maximum number in ax 
	 sub ax, cx ; find change in cx 
	 dec ax ; exclude null from length 
	 pop di 
	 pop cx 
	 pop es 
	 pop bp 
	 ret 4 
; subroutine to print a string 
; takes the x position, y position, attribute, and address of a null 
; terminated string as parameters 
printstr2: 
	 push bp 
	 mov bp, sp 
	 push es 
	 push ax 
	 push cx 
	 push si 
	 push di 
	 push ds ; push segment of string 
	 mov ax, [bp+4] 
	 push ax ; push offset of string 
	 call strlen
	 cmp ax, 0 ; is the string empty 
	 jz exita ; no printing if string is empty
	 mov cx, ax ; save length in cx 
	 mov ax, 0xb800 
	 mov es, ax ; point es to video base 
	 mov al, 80 ; load al with columns per row 
	 mul byte [bp+8] ; multiply with y position 
	 add ax, [bp+10] ; add x position 
	 shl ax, 1 ; turn into byte offset 
	 mov di,ax ; point di to required location 
	 mov si, [bp+4] ; point si to string 
	 mov ah, [bp+6] ; load attribute in ah 
	 cld ; auto increment mode 
nextchara: 
	 lodsb ; load next char in al 
	 stosw ; print char/attribute pair 
	 loop nextchara ; repeat for the whole string 
exita: 
	 pop di 
	 pop si 
	 pop cx 
	 pop ax 
	 pop es 
	 pop bp 
	 ret 8 

printnum:	
		push bp
		mov bp, sp
		push es
		push ax
		push bx
		push cx
		push dx
		push di

		mov ax, 0xb800
		mov es, ax
		mov ax, [bp+4]
		mov bx, 10
		mov cx, 0

nextdigit:	
		mov dx, 0
		div bx
		add dl, 0x30
		push dx
		inc cx
		cmp ax, 0
		jnz nextdigit
		mov di, 458
nextpos:	
		pop dx
		mov dh, 0x07
		mov [es:di], dx
		add di, 2
		mov byte[es:di],'s'
		loop nextpos
;' P:01L:01 '
		mov ah,01100000b
		mov byte[es:296],'P'
		mov byte[es:298],':'
		mov byte[es:300],'0'
		mov byte[es:302],'1'
		mov byte[es:304],'L'
		mov byte[es:306],':'
		mov byte[es:308],'0'
		mov byte[es:310],'1'

		;' 00m00.0s '
		mov byte[es:456],'0'
		mov byte[es:470],'s'
		
		mov byte[es:616],'0'
		mov byte[es:618],'0'
		mov byte[es:620],'m'
		mov byte[es:622],'0'
		mov byte[es:624],'0'
		mov byte[es:626],'.'
		mov byte[es:628],'0'
		mov byte[es:630],'s'		

		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		pop es
		pop bp
		ret 2


timer:		

		push ax
		inc word[cs:tickcountn]
		cmp word[cs:tickcount],1000
	  	jae exitttta

		cmp word [cs:timerflag], 1 ; is the printing flag set 
 		jne skipall ; no, leave the ISR
		inc word [cs:tickcount]
		push di 
		
		call screen
		
		pop di
		cmp word [cs:tickcount],300
		jae skipstands 
	 	call stands
	 	jmp skip2stands
	 	skipstands:
	 		cmp word [cs:tickcount],550
	 		jae skipsun
	 		mov di,362
	 		call sun
	 		jmp skip2stands
	 		skipsun:
	 			cmp word [cs:tickcount],750
				jae skip2sun
				mov di,430
				call sun
				skip2sun:
	 		cmp word [cs:tickcount],950
			jbe skip2stands
			call stands
		skip2stands:
    	cmp word[slcount],10
	 	je skipll
	 	call finishLine
		call startlight
		skipll:
		call criscross
		call steering
		cmp word[cs:tickcount],20
		jbe skiproad
		call roadlines
		skiproad:
		
		;call printlap

skipall: 
	
	push word [cs:tickcountn]
	call printnum
	jmp naikattamkarni



	exitttta:

	
	cmp word[kattam],0
	je kattamqq
	jmp printtt

	

	valuestorekrlay:
	mov word[finaltimebool],1
	mov bx , word [cs:tickcountn]
	mov word[finaltime],bx

	kattamqq:

	cmp word[finaltimebool],0
	je valuestorekrlay

	mov word[kattam],1
	call clrscrblue

	printtt:

		


	naikattamkarni:
	mov al, 0x20 
 	out 0x20, al ; send EOI to PIC 
 	pop ax 
 	iret
	



kbisr: 
	 push ax 
	 push es 
	 mov ax, 0xb800 
 	 mov es, ax 
 	
	 in al, 0x60 ; read char from keyboard port 
	 cmp al, 0x4b ; has the left arrow pressed 
	 je lefttt ; no, try next comparison
	 jmp rrightt

	lefttt:
	 	cmp word [cs:timerflag],1
	 	je aaddaal
	 	jmp noaaddaal

	 	aaddaal:
			add word[cs:tickcountn],150
			jmp pppleft

		noaaddaal:

			  cmp word[cs:tickcount],300
			  jae roadturnt
			 add word[cs:tickcountn],150

			 jmp pppleft
			 	roadturnt :


					 cmp word[cs:tickcount],330
					 jbe mor1t
					 jmp chmor2t


					 chmor2t:
					 cmp word[cs:tickcount],550
					 jae mor2t
					  add word[cs:tickcountn],150
					 jmp pppleft


					 mor2t:
					 	 cmp word[cs:tickcount],570
						 jbe mor1t

						 chmor3t:
							 cmp word[cs:tickcount],750
						 	 jae mor3t
						 	  add word[cs:tickcountn],150
						 	 jmp pppleft

						 	 mor3t:
						 	  	cmp word[cs:tickcount],770
						 	  	jbe mor1t

					 	  	chmor4t:
					 	  		 cmp word[cs:tickcount],950
					 			 jae mor4t
					 			  add word[cs:tickcountn],150
					 			 jmp pppleft

					 			 mor4t:
					 			  cmp word[cs:tickcount],970
					 			  jbe mor1t
					 			  jmp pppleft



					 mor1t:
					 

			 	
		pppleft:
	 	mov word [es:3270], 0000010000010001b
	 	mov word [es:3272], 0000010000010000b
	 	mov word [es:3276], 0000011101011100b
	 	mov word [es:3278], 0000011101011100b
	 	mov word [es:3280], 0000011101011100b
	 	mov word [es:3282], 0000011101011100b
	 	jmp prevc

	rrightt:
	 cmp al, 0x4d ; has the left arrow pressed 
	 je righttt ; no, try next comparison
	 jmp prevc

	 righttt: 
	 	cmp word [cs:timerflag],1
	 	je aaddaar
	 	jmp noaaddaar
	 	aaddaar:
			add word[cs:tickcountn],150
		noaaddaar:
	 	mov word [es:3270], 0000011100101111b
	 	mov word [es:3272], 0000011100101111b
	 	mov word [es:3276], 0000011100101111b
	 	mov word [es:3278], 0000011100101111b
	 	mov word [es:3280], 0000011100101111b
	 	mov word [es:3282], 0000011100101111b
	 	mov word [es:3288], 0000010000010001b
	 	mov word [es:3290], 0000010000010000b
		jmp prevc
	 prevc:
	 cmp al, 0x48 ; has the up arrow pressed 
	 jne nextcmp ; no, try next comparison 
	 cmp word [cs:timerflag], 1; is the flag already set 
	 je exit ; yes, leave the ISR 
	 mov word [cs:timerflag], 1; set flag to start printing 
	 jmp exit ; leave the ISR 
	 nextcmp:  
		 cmp al, 0xd0 ; has the down key released 
	 	 jne nomatch ; no, chain to old ISR 
	  mov word [cs:timerflag], 0; reset flag to stop printing
	  jmp exit ; leave the interrupt routine 
	nomatch:
		pop es 
		pop ax 
	 	jmp far [cs:oldkb] ; call original ISR 
	exit: 
		mov al, 0x20 
	 	out 0x20, al ; send EOI to PIC 
	 	pop es
	 	pop ax 
	 	iret ; return from interrupt
	 
	 
	 	


; subroutine to clear the screen
clrscr: 
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 0 
nextloc:
     mov word [es:di], 0x0720 
	 add di, 2 
	 cmp di, 4000
	 jne nextloc 
	 pop di
	 pop ax
	 pop es
	 ret

clrscrblue: 
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 0 
nextlocaa:
     mov word [es:di], 0111000000000000b
	 add di, 2 
	 cmp di, 3840 
	 jne nextlocaa 

	 	mov byte[es:1150],'L'
		mov byte[es:1152],'E'
		mov byte[es:1154],'A'
		mov byte[es:1156],'D'
		mov byte[es:1158],'E'
		mov byte[es:1160],'R'
		mov byte[es:1162],'B'
		mov byte[es:1164],'O'
		mov byte[es:1166],'A'
		mov byte[es:1168],'R'
		mov byte[es:1170],'D'
	 	mov byte[es:1310],'P'
		mov byte[es:1312],'#'
		mov byte[es:1324],'N'
		mov byte[es:1326],'a'
		mov byte[es:1328],'m'
		mov byte[es:1330],'e'
		mov byte[es:1332],' '
		mov byte[es:1334],' '
		mov byte[es:1336],'T'
		mov byte[es:1338],'i'
		mov byte[es:1340],'m'
		mov byte[es:1342],'e'
		mov byte[es:1470],'1'
		mov byte[es:1472],'.'
		mov byte[es:1484],'S'
		mov byte[es:1486],'a'
		mov byte[es:1488],'i'
		mov byte[es:1490],'m'
		mov byte[es:1492],' '
		mov byte[es:1494],' '
		mov byte[es:1496],' '
		mov byte[es:1498],'2'
		mov byte[es:1500],'0'
		mov byte[es:1502],'0'
		mov byte[es:1504],'0'
		mov byte[es:1506],'s'

		mov byte[es:1630],'2'
		mov byte[es:1632],'.'
		mov byte[es:1644],'A'
		mov byte[es:1646],'z'
		mov byte[es:1648],'e'
		mov byte[es:1650],'e'
		mov byte[es:1652],'m'
		mov byte[es:1654],' '
		mov byte[es:1656],' '
		mov byte[es:1658],'2'
		mov byte[es:1660],'5'
		mov byte[es:1662],'0'
		mov byte[es:1664],'0'
		mov byte[es:1666],'s'

		mov byte[es:1790],'3'
		mov byte[es:1792],'.'
		mov byte[es:1804],'H'
		mov byte[es:1806],'a'
		mov byte[es:1808],'m'
		mov byte[es:1810],'n'
		mov byte[es:1812],'a'
		mov byte[es:1814],' '
		mov byte[es:1816],' '
		mov byte[es:1818],'4'
		mov byte[es:1820],'0'
		mov byte[es:1822],'0'
		mov byte[es:1824],'0'
		mov byte[es:1826],'s'

		mov byte[es:1950],'4'
		mov byte[es:1952],'.'
		mov byte[es:1964],'T'
		mov byte[es:1966],'a'
		mov byte[es:1968],'h'
		mov byte[es:1970],'i'
		mov byte[es:1972],'r'
		mov byte[es:1974],' '
		mov byte[es:1976],' '
		mov byte[es:1978],'5'
		mov byte[es:1980],'0'
		mov byte[es:1982],'0'
		mov byte[es:1984],'0'
		mov byte[es:1986],'s'

		mov byte[es:2110],'5'
		mov byte[es:2112],'.'
		mov byte[es:2124],'A'
		mov byte[es:2126],'h'
		mov byte[es:2128],'a'
		mov byte[es:2130],'a'
		mov byte[es:2132],'d'
		mov byte[es:2134],' '
		mov byte[es:2136],' '
		mov byte[es:2138],'5'
		mov byte[es:2140],'5'
		mov byte[es:2142],'0'
		mov byte[es:2144],'0'

		mov byte[es:2270],'6'
		mov byte[es:2272],'.'
		mov byte[es:2284],'A'
		mov byte[es:2286],'h'
		mov byte[es:2288],'m'
		mov byte[es:2290],'e'
		mov byte[es:2292],'d'
		mov byte[es:2294],' '
		mov byte[es:2296],' '
		mov byte[es:2298],'6'
		mov byte[es:2300],'0'
		mov byte[es:2302],'0'
		mov byte[es:2304],'0'

		mov byte[es:2430],'7'
		mov byte[es:2232],'.'
		mov byte[es:2444],'R'
		mov byte[es:2446],'a'
		mov byte[es:2448],'h'
		mov byte[es:2450],'e'
		mov byte[es:2452],'l'
		mov byte[es:2454],' '
		mov byte[es:2456],' '
		mov byte[es:2458],'7'
		mov byte[es:2460],'0'
		mov byte[es:2462],'0'
		mov byte[es:2464],'0'

		mov byte[es:2590],'8'
		mov byte[es:2592],'.'
		mov byte[es:2604],'A'
		mov byte[es:2606],'y'
		mov byte[es:2608],'s'
		mov byte[es:2610],'h'
		mov byte[es:2612],'a'
		mov byte[es:2614],' '
		mov byte[es:2616],' '
		mov byte[es:2618],'7'
		mov byte[es:2620],'5'
		mov byte[es:2622],'0'
		mov byte[es:2624],'0'

		mov byte[es:2750],'9'
		mov byte[es:2752],'.'
		mov byte[es:2764],'B'
		mov byte[es:2766],'i'
		mov byte[es:2768],'l'
		mov byte[es:2770],'a'
		mov byte[es:2772],'l'
		mov byte[es:2774],' '
		mov byte[es:2776],' '
		mov byte[es:2778],'9'
		mov byte[es:2780],'0'
		mov byte[es:2782],'0'
		mov byte[es:2784],'0'

		mov byte[es:2910],'1'
		mov byte[es:2912],'0'
		mov byte[es:2914],'.'
		mov byte[es:2924],'l'
		mov byte[es:2926],'a'
		mov byte[es:2928],'i'
		mov byte[es:2930],'l'
		mov byte[es:2932],'a'
		mov byte[es:2934],' '
		mov byte[es:2936],' '
		mov byte[es:2938],'9'
		mov byte[es:2940],'5'
		mov byte[es:2942],'0'
		mov byte[es:2944],'0'
		cmp word[finaltime],2000
		jbe a111
		cmp word[finaltime],2500
		jbe a222
		cmp word[finaltime],4000
		jbe a333
		cmp word[finaltime],5000
		jbe a444
		cmp word[finaltime],5500
		jbe a555
		cmp word[finaltime],6000
		jbe a666
		cmp word[finaltime],7000
		jbe a777
		cmp word[finaltime],7500
		jbe a888
		cmp word[finaltime],9000
		jbe a999
		cmp word[finaltime],11000
		jbe a100	
		jmp nohigh

		a111:
	mov di,1470
	jmp winnerdaykholaja
a222:
	mov di,1630
	jmp winnerdaykholaja
a333:
	mov di,1790
	jmp winnerdaykholaja
a444:
	mov di,1950
	jmp winnerdaykholaja
a555:
	mov di,2110
	jmp winnerdaykholaja
a666:
	mov di,2270
	jmp winnerdaykholaja
a777:
	mov di,2430
	jmp winnerdaykholaja
a888:
	mov di,2590
	jmp winnerdaykholaja
a999:
	mov di,2750
	jmp winnerdaykholaja
a100:
	mov di,2910
	jmp winnerdaykholaja

	winnerdaykholaja:
			call winner
			jmp gooooo


nohigh:
	mov byte[es:3070],'N'
	mov byte[es:3072],'o'
	mov byte[es:3074],' '
	mov byte[es:3076],'H'
	mov byte[es:3078],'i'
	mov byte[es:3080],'g'
	mov byte[es:3082],'h'
	mov byte[es:3084],' '
	mov byte[es:3086],'S'
	mov byte[es:3088],'c'
	mov byte[es:3090],'o'
	mov byte[es:3092],'r'
	mov byte[es:3094],'e'
	jmp gooooo


gooooo:
	 pop di
	 pop ax
	 pop es
	 ret


winner:
	 
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax
	 ;mov ah, 00110100b
	 add di,14

	 mov byte[es:di],'N'
	 add di,2
	 mov byte[es:di],'a'
	 add di,2
	 mov byte[es:di],'s'
	 add di,2
	 mov byte[es:di],'e'
	 add di,2
	 mov byte[es:di],'e'
	 add di,2
	 mov byte[es:di],'m'

	 mov ax, word[finaltime]
	mov bx, 10
	mov cx, 0

nextdigittt:	
		mov dx, 0
		div bx
		add dl, 0x30
		push dx
		inc cx
		cmp ax, 0
		jnz nextdigittt
		add di,4
nextposaa:	
		pop dx
		mov dh, 00110100b
		mov [es:di], dx
		add di, 2
		mov byte[es:di],'s'
		loop nextposaa
	 pop di
	 pop ax
	 pop es
	 ret
	 


sun:
	 
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax
     mov cx,5
 	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,152
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	 add di,2
	 mov word [es:di], 0110000000000000b
	
	 
	 pop di
	 pop ax
	 pop es
	 ret


stands:
	 
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di,1010
	 mov word [es:880], 0011011111011110b
	 mov word [es:860], 0011011111011110b
	 mov word [es:900], 0011011111011110b
	ramp :
	 mov word [es:di], 0111000011011100b 
	 add di, 2 
	 cmp di, 1070 
	 jne ramp 
	 mov word [es:di], 0011011111011101b 
	 mov di,1140
	 mov word [es:di], 0011011111011110b 
	 add di, 2 

	 ramp2:
		 mov word [es:di], 0111000011011100b 
		 add di, 2 
		 cmp di, 1250 
		 jne ramp2 
		 mov word [es:di], 0011011111011101b 
	pop di
	 pop ax
	 pop es
	 ret


screen:

	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 0 
sky:																				
     mov word [es:di], 0011000000000000b 
	 add di, 2 
	 cmp di, 1280 
	 jne sky 
	 
	 mov di,1010
	 push di

	 mov di, 160 
	 mov word [es:di],001000011011010b  
	 add di, 2 

map:
	 mov word [es:di],001000011000100b  
	 add di, 2 
	 cmp di, 200 
	 jne map  
	 mov word [es:di],001000010111111b  
	 add di, 2 
	 mov di,320
	 mov word [es:di],001000010110011b  
	 add di, 2 

	 ml1:
	 	mov word [es:di],001000000000000b  
	 	add di, 2 
	 	cmp di, 360 
	 	jne ml1  
	 	mov word [es:di],001000010110011b 
	 	add di, 2 
	 mov di,480
	 mov word [es:di],001000010110011b 
	 add di, 2 

	 ml2:
	 	mov word [es:di],001000000000000b  
	 	add di, 2 
	 	cmp di, 520 
	 	jne ml2  
	 	mov word [es:di],001000010110011b 
	 	add di, 2 
	 mov di,640
	 mov word [es:di],001000011000000b  
	 add di, 2
 
	 ml3:
	 	mov word [es:di],001000011000100b 
	 	add di, 2 
	 	cmp di, 680 
	 	jne ml3  
	 	mov word [es:di],001000011011001b  
	 add di, 2 
	 pop di
	 mov word [es:di], 0011011111011110b 
	 add di, 2 

	 push di

	  cmp word[cs:tickcount],300
     jae uparjaaa

     jmp aaaaa

     uparjaaa:

     cmp word[cs:tickcount],550
     jae leftmapp

     jmp bahirajaaa

     leftmapp:

      cmp word[boolmapmoveel],0
	 je OOOOO
	 jmp PPPPP

	 OOOOO:
	 mov word[boolmapmoveel],1
	 mov word[mapmovee],200

	 PPPPP:
	 cmp word[mapmoveecount],0
	 je jaaaa

	  cmp word[mapmoveecount],1
	 je jaaaa

	 cmp word[mapmoveecount],2
	 je jaaaa

	 cmp word[mapmoveecount],3
	 je jaaaa

	 cmp word[mapmoveecount],4
	 je jaaaa


	 cmp word[mapmoveecount],5
	 je iddraaa

	 iddraaa:

	cmp word[cs:tickcount],750
	jae bahi


	 mov word[mapmoveecount],0
	mov di,word[mapmovee]
	dec word [mapmovee]
	mov word [es:di],0110000000000000b
	mov word [es:di],0110000000000000b


	jaaaa:
		inc word[mapmoveecount]
		mov di,word[mapmovee]
	
	mov word [es:di],0110000000000000b
	mov word [es:di],0110000000000000b

	bahi:

     jmp bahirajaaa

     aaaaa:

	 cmp word[boolmapmovee],0
	 je OOOO
	 jmp PPPP

	 OOOO:
	 mov word[boolmapmovee],1
	 mov word[mapmovee],640

	 PPPP:
	 cmp word[mapmoveecount],0
	 je jaaa

	  cmp word[mapmoveecount],1
	 je jaaa

	 cmp word[mapmoveecount],2
	 je jaaa

	 cmp word[mapmoveecount],3
	 je jaaa

	 cmp word[mapmoveecount],4
	 je jaaa

	 cmp word[mapmoveecount],5
	 je jaaa

	  cmp word[mapmoveecount],6
	 je jaaa

	 cmp word[mapmoveecount],7
	 je iddraa

	 iddraa:
	 mov word[mapmoveecount],0
	mov di,word[mapmovee]
	inc word [mapmovee]
	mov word [es:di],0110000000000000b
	mov word [es:di],0110000000000000b


	jaaa:
		inc word[mapmoveecount]
		mov di,word[mapmovee]
	
	mov word [es:di],0110000000000000b
	mov word [es:di],0110000000000000b






	bahirajaaa:


	 pop di

	 mov di,1280

line :
	 mov word [es:di], 0100011100101010b 
	 add di, 2 
	 mov word [es:di], 0100011100101010b 
	 add di, 2 
	 mov word [es:di], 0100011100101010b 
	 add di, 2 
	 mov word [es:di], 0100011100101010b 
	 add di, 2 
	 mov word [es:di], 0001011100101010b 
	 add di, 2 
	 mov word [es:di], 0001011100101010b 
	 add di, 2 
	 mov word [es:di], 0001011100101010b 
	 add di, 2 
	 mov word [es:di], 0001011100101010b 
	 add di, 2 
	 cmp di, 1440 
	 jne line

ground :

	 mov word [es:di], 0010000010110000b 
	 add di, 2 
	 cmp di, 2400 
	 jne ground 
	 mov di,1500
	 mov ax,40
road :
		
		mov bx,di
		add bx,ax
		;mov word [es:di], 0111000011011100b
		;add di,2
	 	l1:

			 mov word [es:di], 0111000000000000b 
			 add di,2
			 cmp bx,di
			 jne l1 ; if no clear next position
			 add ax,20 
			 sub di,ax
			 add di,170
			 cmp di,2400
			 jbe road


	 pop di
	 pop ax
	 pop es
	 ret

criscross :
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 2400 
	nextlo:

	cmp word[cs:tickcount],10
	jbe fullcri
	cmp word[cs:tickcount],20
	jbe halfcri
	jmp sroad

	fullcri:
     mov word [es:di], 0111000011011100b 
	 add di, 2  
	 mov word [es:di], 0000011111011100b 
	 add di, 2 
	 jmp cmpppppp

	halfcri:
	sline:
		mov word [es:di], 0111000000000000b 
		add di, 2
		cmp di,2560
		jbe sline

     mov word [es:di], 0111000011011100b 
	 add di, 2  
	 mov word [es:di], 0000011111011100b 
	 add di, 2 
	 jmp cmpppppp

	sroad:
	mov word [es:di], 0111000000000000b 
	add di, 2




	cmpppppp:
	 cmp di, 2716
	 jbe nextlo 

	 pop di
	 pop ax
	 pop es
	 ret




startlight :

	 push es
	 push ax
	 push di

	 inc word[slcount]
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 160 
	 mov bx ,160
	; sub word[slbcount],160
	; mov word[slbcount],1160
	 ;sub word[slbcount],160
	 
	nextl:
         mov word [es:di], 0000000000000000b 
		 add di, 160 
		 cmp di,1160
		 jbe nextl 
	 	add bx,2
	 	mov di,bx
	 	cmp bx,174 
	 	jne nextl
	 	
	 cmp word[slcount],2
	 jbe sl1
	 cmp word[slcount],4
	 jbe sl2
	 cmp word[slcount],7
	 jbe sl3
	 jmp ssss

	 sl3:
	 	 
		 mov word [es:962], 0010000000000000b 
		 mov word [es:964], 0010000000000000b 
		 mov word [es:968], 0010000000000000b 
		 mov word [es:970], 0010000000000000b 

	 sl2:
		 mov word [es:642], 0100000000000000b 
		 mov word [es:644], 0100000000000000b 
		 mov word [es:648], 0100000000000000b 
		 mov word [es:650], 0100000000000000b  

	 sl1:
	 	; add word[slbcount],160
		 mov word [es:322], 0100000000000000b 
		 mov word [es:324], 0100000000000000b 
		 mov word [es:328], 0100000000000000b 
		 mov word [es:330], 0100000000000000b 
	ssss:


	 
	 pop di
	 pop ax 
	 pop es
	 ret



roadlines:
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov word [es:3276], 0000000000000000b
	 mov word [es:3278], 0000000000000000b

	 	cmp word [cs:tickcount],50
		 jbe gear1

		 cmp word [cs:tickcount],80
		 jbe gear2

		 cmp word [cs:tickcount],120
		 jbe gear3

		 cmp word [cs:tickcount],200
		 jbe gear4
		 cmp word [cs:tickcount],250
		 jbe gear5
		 cmp word[cs:tickcount],270
	     je gear4
	     cmp word[cs:tickcount],290
	     je gear3
	     cmp word[cs:tickcount],310
	     je gear4
	     cmp word[cs:tickcount],330
	     je gear5
	     jmp skipgearss

			gear1:
		 	mov word [es:3178], 0111011100000000b

		 	jmp eeend

		 	gear2:
		 	mov word [es:3178], 0010011110111010b
		 	mov word [es:3818], 0111011100000000b
		 	
		 	jmp eeend

		 	gear3:
		 	mov word [es:3818], 0010011110111010b
		 	mov word [es:3824], 0010011110111010b
		 	mov word [es:3190], 0010011110111010b

		 	mov word [es:3184], 0111011100000000b
		 	jmp eeend

		 	gear4:
		 	mov word [es:3184], 0010011110111010b
		 	mov word [es:3190], 0010011110111010b

		 	mov word [es:3824], 0111011100000000b
		 	jmp eeend

		 	gear5:
		 	mov word [es:3184], 0010011110111010b
		 	mov word [es:3824], 0010011110111010b

		 	mov word [es:3190], 0111011100000000b
		 	jmp eeend

		 skipgearss:
	     cmp word[cs:tickcount],530
	     je gear4
	     cmp word[cs:tickcount],550
	     je gear3
	     cmp word[cs:tickcount],570
	     je gear4
	     cmp word[cs:tickcount],590
	     je gear5

		 cmp word[cs:tickcount],730
	     je gear4
	     cmp word[cs:tickcount],750
	     je gear3
	     cmp word[cs:tickcount],770
	     je gear4
	     cmp word[cs:tickcount],790
	     je gear5	     

	     cmp word[cs:tickcount],930
	     je gear4
	     cmp word[cs:tickcount],950
	     je gear3
	     cmp word[cs:tickcount],970
	     je gear4
	     cmp word[cs:tickcount],990
	     je gear5

		 jmp gear5


		 	

		eeend:

	 mov di,1518
	 rrr:
	 mov word [es:di], 0000000000000000b
	 add di,2
     mov word [es:di], 0000000000000000b
    

     add di,158
     cmp word[cs:tickcount],300
     jae roadturn
 


     jmp wapis
 	roadturn :

 		 mov word[es:520],0110000000000000b
		 cmp word[cs:tickcount],330
		 jbe mor1
		 mov word [es:520],001000010110011b
		 mov word[es:360],0110000000000000b
		 jmp chmor2


		 chmor2:
		  mov word [es:360],001000010110011b
		 cmp word[cs:tickcount],550
		 jae mor2
		
		 jmp wapis


		 mor2:
		 	 cmp word[cs:tickcount],570
			 jbe mor1

			 chmor3:
				 cmp word[cs:tickcount],750
			 	 jae mor3
			 	 jmp wapis

			 	 mor3:
			 	  	cmp word[cs:tickcount],770
			 	  	jbe mor1

		 	  	chmor4:
		 	  		 cmp word[cs:tickcount],950
		 			 jae mor4
		 			 jmp wapis

		 			 mor4:
		 			  cmp word[cs:tickcount],970
		 			  jbe mor1
		 			  jmp wapis



		 mor1:
		 add di,2

 		
 	 wapis:

     cmp di,2820
     jbe rrr
	 inc word[rlcount]
	 mov di,1340
	 mov cx,word[rlcount]
	 lll:
	 	add di,160
	 loop lll
	 
	 cmp word[rlcount],3
	 je zzz
	 jmp qqq
	 zzz:
	 	mov word[rlcount],0
	 qqq:
	 call roadpatchs



	 
	 endrr:
	 pop di
	 pop ax 
	 pop es
	 ret


roadpatchs:

	mov cx,20
	llll:
	 mov word [es:di], 0111000000000000b
	 add di,2
	 loop llll
 
     add di,120
     add di,160
     mov cx,20
	llll1:
	 mov word [es:di], 0111000000000000b
	 add di,2
	 loop llll1
     
     add di,120
     add di,160
     add di,160
     mov cx,20
     llll2:
	 mov word [es:di], 0111000000000000b
	 add di,2
	 loop llll2
    
 
     ret



     


printstr: 
	 push bp
	 mov bp, sp
	 push es
	 push ax
	 push cx
	 push si
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov al, 80 
	 mul byte [bp+10] 
	 add ax, [bp+12] 
	 shl ax, 1 
	 mov di,ax 
	 mov si, [bp+6] 
	 mov cx, [bp+4] 
	 mov ah, [bp+8] 

nextchar: 
	 mov al, [si] 
	 mov [es:di], ax
	 add di, 2 
	 add si, 1 
	 loop nextchar 
         pop di
	 pop si
	 pop cx
	 pop ax
	 pop es
	 pop bp
	 ret 10


printlap: 
	 push 68 
	 push 2  
	 push 11 
	 push lap1 
	 push 10 
	 call printstr 
	 push 148 
	 push 2  
	 push 11 
	 push lab2 
	 push 10 
	 call printstr 
	 push 228 
	 push 2  
	 push 11 
	 push lab3 
	 push 10 
	 call printstr 
	 ret

finishLine :
	 push 22 
	 push 2 
	 push 01110000b 
	 push finish 
	 push 37
	
	 call printstr
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 204 
	 fline:
	 	mov word[es:di], 0011011111011100b 
	 	add di, 2 
	 	cmp di,278
	 	jne fline
	 	mov di, 524 

	 	fline1:
		 	mov word[es:di], 0111001111011100b 
		 	add di, 2 
		 	cmp di,598
		 	jne fline1
		 	mov di, 364 

	 		pillar:
			 	mov word[es:di], 0111001100000000b
			 	add di, 72 
			 	mov word[es:di], 0111001100000000b 
			 	add di, 88 
			 	cmp di,1500
			 	jbe pillar

	 pop di
	 pop ax 
	 pop es
	 ret

car :
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 3016 
	 mov bx , 3036

	 GearBoxB:
	 	mov word [es:di], 0010000000000000b 
	 	add di, 2 
	 	cmp di,bx
	 	jne GearBoxB
	 	add  di,140
	 	add bx ,160
	 	cmp di,4000
	 	jbe GearBoxB

	 mov di,3178
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,148
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,148
	 mov word [es:di], 0010011110111010b 
	 add di,2
	 mov word [es:di], 0010011111001101b 
	 add di,2
	 mov word [es:di], 0010011111001101b 
	 add di,2
	 mov word [es:di], 0010011111001110b 
	 add di,2
	 mov word [es:di], 0010011111001101b 
	 add di,2
	 mov word [es:di], 0010011111001101b 
	 add di,2
	 mov word [es:di], 0010011110111001b 
	 add di,148
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,148
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 
	 add di,6
	 mov word [es:di], 0010011110111010b 

	 Gearnob:
		 mov di,3178
		 mov word [es:di], 0111011100000000b 

	centre:
		push 30
		push 18
		push 9
		push zero
		push 3
		call printstr
		push 34
		push 18
		push 40
		push dash
		push 14
		call printstr
		push 50
		push 18
		push 40
		push space
		push 2
		call printstr
		push 54
		push 18
		push 40
		push space
		push 2
		call printstr
		push 54
		push 20
		push 40
		push space
		push 2
		call printstr
		push 20
		push 22
		push 40
		push space
		push 2
		call printstr
		push 60
		push 22
		push 90
		push space
		push 2
		call printstr
	fireee:
		push 19
		push 23
		push 01000111b
		push fire
		push 4
		call printstr
	ignn:
		push 60
		push 23
		push 01000111b
		push ign
		push 3
		call printstr
	fuell:
		push 60
		push 24
		push 01000111b
		push fuel
		push 4
		call printstr

	Lmirror:
		push 14
		push 18
		push 00110111b
		push dash
		push 6
		call printstr
		push 14
		push 19
		push 00100111b
		push dash
		push 6
		call printstr
	Rmirror:
		push 60
		push 18
		push 00110111b
		push dash
		push 6
		call printstr
		push 60
		push 19
		push 00100111b
		push dash
		push 6
		call printstr
	
	 pop di
	 pop ax 
	 pop es
	 ret
steering:
	 push es
	 push ax
	 push di
	 mov ax, 0xb800
	 mov es, ax 
	 mov di, 2720 
	 mov bx , 3036

	 strstillmovment:
	 	mov word [es:3280], 0000010000010001b
	 	mov word [es:3282], 0000010000010000b 
	  
	 strrr:

		push 38
		push 21
		push 01000111b
		push rpmm
		push 3
		call printstr
	     mov word [es:3270], 0000011100101111b 
		 mov word [es:3272], 0000011100101111b 
		 mov word [es:3288], 0000011101011100b 
		 mov word [es:3290], 0000011101011100b 

	 	 mov word [es:3266], 0000011100101111b 
		 mov word [es:3268], 0000011100101111b 
		 mov word [es:3292], 0000011101011100b 
		 mov word [es:3294], 0000011101011100b 

	     mov word [es:3422], 0000011100101111b 
		 mov word [es:3424], 0000011100101111b 
		 mov word [es:3456], 0000011101011100b 
		 mov word [es:3458], 0000011101011100b 
	  	 mov word [es:3578], 0000011100101000b 
		 mov word [es:3580], 0000011100101000b 
		 mov word [es:3620], 0000011100101001b 
		 mov word [es:3622], 0000011100101001b 
		 mov word [es:3582], 0000011111111000b 
		 mov word [es:3618], 0000011111111000b 
		 mov word [es:3736], 0000011100101000b 
		 mov word [es:3738], 0000011100101000b 
		 mov word [es:3740], 0000011111111001b 
		 mov word [es:3782], 0000011100101001b 
		 mov word [es:3784], 0000011100101001b 
		 mov word [es:3780], 0000011111111000b 
		 mov word [es:3896], 0000011100101000b 
		 mov word [es:3898], 0000011100101000b 
		 mov word [es:3942], 0000011100101001b 
		 mov word [es:3944], 0000011100101001b 
		 mov di,3900
		 Oo :
		 	mov word [es:di], 0000011111110000b 
		 	add di,2
		 	cmp di,3942
		 	jne Oo
             mov word [es:3922], 0000011100010000b 
	     mov word [es:3920], 0000011100010001b 
	     mov word [es:3760], 0000011111111000b
	     mov word [es:3600], 0000011100011000b
 	 pop di
	 pop ax 
	 pop es
	 ret
start: 
	mov dx,640
	mov word[mapmovee],dx
	 call clrscr 
	; call startlight
	; call roadlines
	; call criscross
	;call screen
	 call car	
	
	  xor ax, ax 
 	 mov es, ax ; point es to IVT base 
	 mov ax, [es:9*4] 
	 mov [oldkb], ax ; save offset of old routine 
	 mov ax, [es:9*4+2] 
	 mov [oldkb+2], ax ; save segment of old routine 
	 cli ; disable interrupts 
	 mov word [es:9*4], kbisr ; store offset at n*4 
	 mov [es:9*4+2], cs ; store segment at n*4+2 
	 mov word [es:8*4], timer ; store offset at n*4 
	 mov [es:8*4+2], cs ; store segment at n*4+ 
	 sti ; enable interrupts 
	 mov dx, start ; end of resident portion 
	 add dx, 15 ; round up to next para 
	 mov cl, 4 
	 shr dx, cl ; number of paras 
	 mov ax, 0x3100 ; terminate and stay resident 
	 int 0x21
;	 jmp chaliyija
;
;	 abtobahiraja:
;
;	 mov ax, 30 
;	 push ax ; push x position 
;	 mov ax, 20 
;	 push ax ; push y position 
;	 mov ax, 0x71 ; blue on white attribute 
;	 push ax ; push attribute 
;	 mov ax, playername 
;	 push ax ; push address of message 
;	 call printstr2 
;	mov ax, 0x4c00 
 ;	int 0x21