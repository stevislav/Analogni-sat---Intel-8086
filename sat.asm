
crtaj_horizontalno macro x,	y1,	y2,	boja
			local skok1
;Crtanje linije po X osi od tacke y1 do tacke y2.
			mov ah,	0ch					;crtanje piksela
			mov	bh,	0
			mov	al, boja				
			mov	cx,	y1					;Y koordinata
			mov	dx,	x					;X koordinata
	skok1:	int	10h						;iscrtaj piksel
			inc	cx						;povecaj vrednost Y koordinate
			cmp	cx,	y2					;uporedi da li se stiglo do y2 koordinate
			jle	skok1					;skok ukoliko cx nema vecu vrednost od y2
			endm

crtaj_vertikalno macro y, x1, x2, boja
			local	skok2
;Crtanje linije po Y osi od tacke x1 do tacke x2.
			mov ah,	0ch					;crtanje piksela
			mov	bh,	0
			mov	al,	boja
			mov	cx,	y					;Y koordinata
			mov	dx,	x1					;X koordinata
	skok2:	int 10h						;iscrtaj piksel
			inc	dx						;povecaj vrednost X koordinate
			cmp	dx,	x2					;uporedi da li se stiglo do x2 koordinate
			jle	skok2					;skok ukoliko dx nema vecu vrednost od x2
			endm

			
; ---- Data segment
dseg segment 'DATA'

y_shift 	dw	0						;pomeraj po Y osi
y1 			dw	0						;vrednosti Y ose
y2			dw	0						;
y3			dw	0						;
x_shift		dw	0						;pomeraj po X osi
x1			dw	0						;vrednosti X oset
x2			dw	0						;
x3			dw	0						;
boja_p		db	31						;menja boju cifara
boja_o		db  20
vreme		db '00:00:00$'				;format za vreme 'sati:minuti:sekunde'
datum		db '00000000$'				;format za datum 'dani.meseci.godine'
novi_iv		dw	?, ?					;za postavljanje prekidne rutine 1Ch
stari_iv	dw	?, ?					;za postavljanje prekidne rutine 1Ch
	
dseg ends
; ---- kraj segmenta


; ---- kod segment
cseg	segment	'CODE'
		assume cs:cseg, ds:dseg, ss:sseg

;glavna funkcija
main proc

;postavljanje grafickog okruzenja
			mov	ah,	0			;320x200 piksela
			mov	al,	13h			;256 boja
			int	10h				;

;postavljanje funkcije za prekid 
;postavljanje segment:ofset od izvrsi u novi_iv
			mov	novi_iv, offset izvrsi
			mov	novi_iv+2, seg	izvrsi
			lea	di,	stari_iv			;di pokazuje na bafer starog iv
			lea	si,	novi_iv				;si pokazuje na novi iv
			mov	al,	1ch					;interapt tajmera
			call postavi_prekid			;

;citanje sa tastature za prekid programa
			mov	ah,	0
			int	16h

;vrati stari iv
			lea	di,	novi_iv				;di pokazuje na bafer iv
			lea	si,	stari_iv			;si pokazuje na stari iv
			mov	al,	1ch					;interapt tajmera
			call postavi_prekid			;
;vracanje u dos tekstualno okruzenje
			mov	ah,	0
			mov	al,	3
			int	10h
;izlaz iz programa
            mov ah, 4ch
            int 21h
main endp

konvertovanje proc
;konvertovanje u ASCII karaktere
;al - visa cifra, ah - niza cifra
            xor ah, ah					;postavi ah na 0
            mov dl, 10					;podeli ax sa 10
            div dl						;ah = ostatak, al = rezultat
            or  ax, 3030h				;prebaci u ASCII karaktere
            ret
konvertovanje endp

uzmi_vreme proc
;uzima sistemsko vreme i prebacuje ga u ASCII karaktere
;cuva se na adresama bx
            mov ah, 2ch					;dobija trenutno vreme
            int 21h						;ch - sati, cl - minuti, dh - sekunde
            mov al, ch					;konvertuj u sate
			call konvertovanje			;
            mov [bx], ax				;sacuvaj
            mov al, cl					;konvertuj u minute
            call konvertovanje			;
            mov [bx+3], ax				;sacuvaj
            mov al, dh					;konvertuj u sekunde
            call konvertovanje			;
            mov [bx+6], ax				;sacuvaj
            ret
uzmi_vreme endp

izvrsi proc
			push	ds					;sacuvaj ds na stek
			call stampaj_okvir
;uzmi novo vreme
			lea bx, vreme				;bx pokazuje na bafer za vreme
			call uzmi_vreme				;
;prva cifra sati			
			mov	x_shift, 65
			mov	y_shift, 20
			call boji_crno
			mov	al, '0'
			cmp	[bx], al
			jne	sat1_1
			call stampaj_0
			jmp	sat1_kraj
	sat1_1: inc	al
			cmp	[bx], al
			jne	sat1_2
			call stampaj_1
			jmp	sat1_kraj
	sat1_2:	inc	al
			cmp	[bx], al
			jne	sat1_3
			call stampaj_2
			jmp	sat1_kraj
	sat1_3:	inc	al
			cmp	[bx], al
			jne	sat1_4
			call stampaj_3
			jmp	sat1_kraj
	sat1_4:	inc	al
			cmp	[bx], al
			jne	sat1_5
			call stampaj_4
			jmp	sat1_kraj
	sat1_5:	inc	al
			cmp	[bx], al
			jne	sat1_6
			call stampaj_5
			jmp	sat1_kraj
	sat1_6:	inc	al
			cmp	[bx], al
			jne	sat1_7
			call stampaj_6
			jmp	sat1_kraj
	sat1_7:	inc	al
			cmp	[bx], al
			jne	sat1_8
			call stampaj_7
			jmp	sat1_kraj
	sat1_8:	inc	al
			cmp	[bx], al
			jne	sat1_9
			call stampaj_8
			jmp	sat1_kraj
	sat1_9:	call stampaj_9
	sat1_kraj:
;druga cifra sati
			mov	x_shift, 65
			mov	y_shift, 60
			call boji_crno
			mov	al,	'0'
			cmp	[bx+1],	al
			jne	sat2_1
			call stampaj_0
			jmp	sat2_kraj
	sat2_1:	inc	al
			cmp	[bx+1],	al
			jne	sat2_2
			call stampaj_1
			jmp	sat2_kraj
	sat2_2:	inc	al
			cmp	[bx+1],	al
			jne	sat2_3
			call stampaj_2
			jmp	sat2_kraj
	sat2_3:	inc	al
			cmp	[bx+1],	al
			jne	sat2_4
			call stampaj_3
			jmp	sat2_kraj
	sat2_4:	inc	al
			cmp	[bx+1],	al
			jne	sat2_5
			call stampaj_4
			jmp	sat2_kraj
	sat2_5:	inc	al
			cmp	[bx+1],	al
			jne	sat2_6
			call stampaj_5
			jmp	sat2_kraj
	sat2_6:	inc	al
			cmp	[bx+1],	al
			jne	sat2_7
			call stampaj_6
			jmp	sat2_kraj
	sat2_7:	inc	al
			cmp	[bx+1],	al
			jne	sat2_8
			call stampaj_7
			jmp	sat2_kraj
	sat2_8:	inc	al
			cmp	[bx+1],	al
			jne	sat2_9
			call stampaj_8
			jmp	sat2_kraj
	sat2_9:	call stampaj_9
	sat2_kraj:
;stampaj dvotacku
			mov	x_shift, 65
			mov	y_shift, 95
			call stampaj_tacke
;prva cifra minuta
			mov	x_shift, 65
			mov	y_shift, 120
			call boji_crno
			mov	al,	'0'
			cmp	[bx+3],	al
			jne	min1_1
			call stampaj_0
			jmp	min1_kraj
	min1_1:	inc	al
			cmp	[bx+3],	al
			jne	min1_2
			call stampaj_1
			jmp	min1_kraj
	min1_2:	inc	al
			cmp	[bx+3],	al
			jne	min1_3
			call stampaj_2
			jmp	min1_kraj
	min1_3:	inc	al
			cmp	[bx+3],	al
			jne	min1_4
			call stampaj_3
			jmp	min1_kraj
	min1_4:	inc	al
			cmp	[bx+3],	al
			jne	min1_5
			call stampaj_4
			jmp	min1_kraj
	min1_5:	inc	al
			cmp	[bx+3],	al
			jne	min1_6
			call stampaj_5
			jmp	min1_kraj
	min1_6:	inc	al
			cmp	[bx+3],	al
			jne	min1_7
			call stampaj_6
			jmp	min1_kraj
	min1_7:	inc	al
			cmp	[bx+3],	al
			jne	min1_8
			call stampaj_7
			jmp	min1_kraj
	min1_8:	inc	al
			cmp	[bx+3],	al
			jne	min1_9
			call stampaj_8
			jmp	min1_kraj
	min1_9:	call stampaj_9
	min1_kraj:
;druga cifra minuta
			mov	x_shift, 65
			mov	y_shift, 160
			call boji_crno
			mov	al,	'0'
			cmp	[bx+4],	al
			jne	min2_1
			call stampaj_0
			jmp	min2_kraj
	min2_1:	inc	al
			cmp	[bx+4],	al
			jne	min2_2
			call stampaj_1
			jmp	min2_kraj
	min2_2:	inc	al
			cmp	[bx+4],	al
			jne	min2_3
			call stampaj_2
			jmp	min2_kraj
	min2_3:	inc	al
			cmp	[bx+4],	al
			jne	min2_4
			call stampaj_3
			jmp	min2_kraj
	min2_4:	inc	al
			cmp	[bx+4],	al
			jne	min2_5
			call stampaj_4
			jmp	min2_kraj
	min2_5:	inc	al
			cmp	[bx+4],	al
			jne	min2_6
			call stampaj_5
			jmp	min2_kraj
	min2_6:	inc	al
			cmp	[bx+4],	al
			jne	min2_7
			call stampaj_6
			jmp	min2_kraj
	min2_7:	inc	al
			cmp	[bx+4],	al
			jne	min2_8
			call stampaj_7
			jmp	min2_kraj
	min2_8:	inc	al
			cmp	[bx+4],	al
			jne	min2_9
			call stampaj_8
			jmp	min2_kraj
	min2_9:	call stampaj_9
	min2_kraj:
;stampaj dvotacku
			mov x_shift, 81
			mov y_shift, 225
			call stampaj_tacke_male
;prva cifra sekundi
			mov	x_shift, 90
			mov	y_shift, 240
			call boji_crno_malo
			mov	al,	'0'
			cmp	[bx+6],	al
			jne	sek1_1
			call stampaj_0_malo
			jmp	sek1_kraj
	sek1_1:	inc	al
			cmp	[bx+6],	al
			jne	sek1_2
			call stampaj_1_malo
			jmp	sek1_kraj
	sek1_2:	inc	al
			cmp	[bx+6],	al
			jne	sek1_3
			call stampaj_2_malo
			jmp	sek1_kraj
	sek1_3:	inc	al
			cmp	[bx+6],	al
			jne	sek1_4
			call stampaj_3_malo
			jmp	sek1_kraj
	sek1_4:	inc	al
			cmp	[bx+6],	al
			jne	sek1_5
			call stampaj_4_malo
			jmp	sek1_kraj
	sek1_5:	inc	al
			cmp	[bx+6],	al
			jne	sek1_6
			call stampaj_5_malo
			jmp	sek1_kraj
	sek1_6:	inc	al
			cmp	[bx+6],	al
			jne	sek1_7
			call stampaj_6_malo
			jmp	sek1_kraj
	sek1_7:	inc	al
			cmp	[bx+6],	al
			jne	sek1_8
			call stampaj_7_malo
			jmp	sek1_kraj
	sek1_8:	inc	al
			cmp	[bx+6],	al
			jne	sek1_9
			call stampaj_8_malo
			jmp	sek1_kraj
	sek1_9:	call stampaj_9_malo
	sek1_kraj:
;druga cifra sekundi
			mov	x_shift, 90
			mov	y_shift, 260
			call boji_crno_malo
			mov	al,	'0'
			cmp	[bx+7],	al
			jne	sek2_1
			call stampaj_0_malo
			jmp	sek2_kraj
	sek2_1:	inc	al
			cmp	[bx+7],	al
			jne	sek2_2
			call stampaj_1_malo
			jmp	sek2_kraj
	sek2_2:	inc	al
			cmp	[bx+7],	al
			jne	sek2_3
			call stampaj_2_malo
			jmp	sek2_kraj
	sek2_3:	inc	al
			cmp	[bx+7],	al
			jne	sek2_4
			call stampaj_3_malo
			jmp	sek2_kraj
	sek2_4:	inc	al
			cmp	[bx+7],	al
			jne	sek2_5
			call stampaj_4_malo
			jmp	sek2_kraj
	sek2_5:	inc	al
			cmp	[bx+7],	al
			jne	sek2_6
			call stampaj_5_malo
			jmp	sek2_kraj
	sek2_6:	inc	al
			cmp	[bx+7],	al
			jne	sek2_7
			call stampaj_6_malo
			jmp	sek2_kraj
	sek2_7:	inc	al
			cmp	[bx+7],	al
			jne	sek2_8
			call stampaj_7_malo
			jmp	sek2_kraj
	sek2_8:	inc	al
			cmp	[bx+7],	al
			jne	sek2_9
			call stampaj_8_malo
			jmp	sek2_kraj
	sek2_9:	call stampaj_9_malo
	sek2_kraj:
			pop	ds
			iret
izvrsi endp

postavi_prekid proc
;cuva stari i daje novi iv
;		al = broj prekida
;		di = adresa bafera koji sadrzi stari iv
;		si = adresa bafera koji sadrzi novi iv
;cuvanje interapt vektora
			mov	ah,	35h			;35h daje iv
			int	21h				;
			mov	[di], bx		;cuvanje ofseta
			mov	[di+2],	es		;cuvanje segmenta
;postavljanje novog interapt vektora
			mov	dx,	[si]		;dx prima ofset
			push ds				;cuvaj ds
			mov	ds,	[si+2]		;
			mov	ah,	25h			;25h postavlja vektor prekida
			int	21h				;
			pop	ds				;vrati ds
			ret
postavi_prekid endp


stampaj_0 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_0 endp

stampaj_1 proc

			mov	ax, y_shift
			mov	y1,	20
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_1 endp

stampaj_2 proc

			mov	ax, y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x2, x3, boja_p
			crtaj_vertikalno y2, x1, x2, boja_p
			ret
stampaj_2 endp

stampaj_3 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_3 endp

stampaj_4 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_4 endp

stampaj_5 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x2, x3, boja_p
			ret
stampaj_5 endp

stampaj_6 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x2, x3, boja_p
			ret
stampaj_6 endp

stampaj_7 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_7 endp

stampaj_8 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_8 endp

stampaj_9 proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_9 endp

stampaj_0_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_0_malo endp

stampaj_1_malo proc

			mov	ax, y_shift
			mov	y1,	10
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_1_malo endp

stampaj_2_malo proc

			mov	ax, y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x2, x3, boja_p
			crtaj_vertikalno y2, x1, x2, boja_p
			ret
stampaj_2_malo endp

stampaj_3_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_3_malo endp

stampaj_4_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_4_malo endp

stampaj_5_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x2, x3, boja_p
			ret
stampaj_5_malo endp

stampaj_6_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x2, x3, boja_p
			ret
stampaj_6_malo endp

stampaj_7_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_7_malo endp

stampaj_8_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x3, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_8_malo endp

stampaj_9_malo proc

			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	boja_p
			crtaj_horizontalno x2, y1,	y2,	boja_p
			crtaj_horizontalno x3, y1,	y2,	boja_p
			crtaj_vertikalno y1, x1, x2, boja_p
			crtaj_vertikalno y2, x1, x3, boja_p
			ret
stampaj_9_malo endp

stampaj_tacke proc
			mov	ax,	y_shift
			mov	y1,	8
			add	y1,	ax
			mov	y2,	12
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	16
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax			
			crtaj_horizontalno x1, y1,	y2,	132
			crtaj_horizontalno x2, y1,	y2,	132
			crtaj_vertikalno y1, x1, x2, 132
			crtaj_vertikalno y2, x1, x2, 132

			mov	ax,	y_shift
			mov	y1,	8
			add	y1,	ax
			mov	y2,	12
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	30
			add	x1,	ax
			mov	x2,	34
			add	x2,	ax			
			crtaj_horizontalno x1, y1,	y2,	132
			crtaj_horizontalno x2, y1,	y2,	132
			crtaj_vertikalno y1, x1, x2, 132
			crtaj_vertikalno y2, x1, x2, 132
			ret
stampaj_tacke endp

boji_crno proc
			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	30
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	20
			add	x2,	ax
			mov	x3,	50
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	0
			crtaj_horizontalno x2, y1,	y2,	0
			crtaj_horizontalno x3, y1,	y2,	0
			crtaj_vertikalno y1, x1, x3, 0
			crtaj_vertikalno y2, x1, x3, 0
			ret
boji_crno endp

stampaj_tacke_male proc
			mov	ax,	y_shift
			mov	y1,	6
			add	y1,	ax
			mov	y2,	10
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	14
			add	x1,	ax
			mov	x2,	18
			add	x2,	ax			
			crtaj_horizontalno x1, y1,	y2,	132
			crtaj_horizontalno x2, y1,	y2,	132
			crtaj_vertikalno y1, x1, x2, 132
			crtaj_vertikalno y2, x1, x2, 132

			mov	ax,	y_shift
			mov	y1,	6
			add	y1,	ax
			mov	y2,	10
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	28
			add	x1,	ax
			mov	x2,	32
			add	x2,	ax			
			crtaj_horizontalno x1, y1,	y2,	132
			crtaj_horizontalno x2, y1,	y2,	132
			crtaj_vertikalno y1, x1, x2, 132
			crtaj_vertikalno y2, x1, x2, 132
			ret
stampaj_tacke_male endp

boji_crno_malo proc
			mov	ax,	y_shift
			mov	y1,	0
			add	y1,	ax
			mov	y2,	15
			add	y2,	ax
			mov	ax,	x_shift
			mov	x1,	0
			add	x1,	ax
			mov	x2,	10
			add	x2,	ax
			mov	x3,	25
			add	x3,	ax
			crtaj_horizontalno x1, y1,	y2,	0
			crtaj_horizontalno x2, y1,	y2,	0
			crtaj_horizontalno x3, y1,	y2,	0
			crtaj_vertikalno y1, x1, x3, 0
			crtaj_vertikalno y2, x1, x3, 0
			ret
boji_crno_malo endp

stampaj_okvir proc
			
			mov	y1,	0		
			mov	y2,	320
			mov	x1,	0
			mov	x3,	200
			crtaj_horizontalno x1, y1,	y2,	124
			crtaj_horizontalno 199, 0,	320, 124
			crtaj_vertikalno y1, x1, x3, 124
			crtaj_vertikalno 319, 0, 200, 124
			ret
stampaj_okvir endp
	
cseg 	ends
; ---- kraj segmenta


; ---- stek segment
sseg 	segment	stack 'STACK'
	   dw   64		dup(?)
sseg ends	   
; ---- kraj segmenta

end main