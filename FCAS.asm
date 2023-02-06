; FCAS para la Flashjacks.
;
; Ultima version: 11-09-2021
;
;
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;Constantes del entorno.

; IDE registers:

IDE_BANK	equ	#4104
IDE_DATA	equ	#7C00
IDE_STATUS	equ	#7E07
IDE_CMD		equ	#7E07
IDE_ERROR	equ	#7E01
IDE_FEAT	equ	#7E01
IDE_SECCNT	equ	#7E02
IDE_LBALOW	equ	#7E03
IDE_LBAMID	equ	#7E04
IDE_LBAHIGH	equ	#7E05
IDE_HEAD	equ	#7E06
IDE_DEVCTRL	equ	#7E0E	;Device control register. Reset IDE por bit 2.
FJ_TIMER1	equ	#7E0D	;Temporizador de 100khz(100uSeg.) por registro. Decrece de 1 en 1 hasta llegar a 00h.

FJ_CLUSH_FB	equ	#7E2D	;Byte alto cluster archivo Flashboy.
FJ_CLUSL_FB	equ	#7E2E	;Byte bajo cluster archivo Flashboy
FLAGS_FB	equ	#7E2F	;Flags info Flashboy. (0,0,0,0,0,0,0,AccessRAM). "7..0"
FJ_TAM3_FB	equ	#7E30	;Byte alto3 tamaño archivo Flashboy.
FJ_TAM2_FB	equ	#7E31	;Byte alto2 tamaño archivo Flashboy.
FJ_TAM1_FB	equ	#7E32	;Byte alto1 tamaño archivo Flashboy.
FJ_TAM0_FB	equ	#7E33	;Byte bajo tamaño archivo Flashboy.
FJ_JOY_1	equ	#7E34	;Registro de salida Joy_Status1
FJ_JOY_2	equ	#7E35	;Registro de salida Joy_Status2
FJ_JOY_3	equ	#7E36	;Registro de salida Joy_Status3
FJ_JOY_4	equ	#7E37	;Registro de salida Joy_Status4
CAS_PARAM	equ	#7E40	;Registro parámetros del Cassette.

; Bits in the status register

BSY	equ	7	;Busy
DRDY	equ	6	;Device ready
DF	equ	5	;Device fault
DRQ	equ	3	;Data request
ERR	equ	0	;Error

M_BSY	equ	(1 SHL BSY)
M_DRDY	equ	(1 SHL DRDY)
M_DF	equ	(1 SHL DF)
M_DRQ	equ	(1 SHL DRQ)
M_ERR	equ	(1 SHL ERR)

; Bits in the device control register register

SRST	equ	2	;Software reset
M_SRST	equ	(1 SHL SRST)

; Standard BIOS and work area entries
CLS	equ	000C3h
CHSNS	equ	0009Ch
KILBUF	equ	00156h
VDP	equ	0F3DFh

; Varios
CALSLT  equ     0001Ch
BDOS	equ	00005h
RDSLT	equ	0000Ch
WRSLT	equ	00014h
ENASLT	equ	00024h
FCB	equ	0005ch
DMA	equ	00080h
RSLREG	equ	00138h
SNSMAT	equ	00141h
RAMAD1	equ	0f342h
RAMAD2	equ	0f343h
LOCATE	equ	0f3DCh
CHGET	equ	0009fh
POSIT	equ	000C6h
MNROM	equ	0FCC1h	; Main-ROM Slot number & Secondary slot flags table
DRVINV	equ	0FB22H	; Installed Disk-ROM

;Fin de las constantes del entorno.
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Macros:

;-----------------------------------------------------------------------------
;
; Enable or disable the IDE registers

;Note that bank 7 (the driver code bank) must be kept switched
;Cuidado. Cuando se cambia de IDE ON a OFF y viceversa, el mapper permanece inalterado.
;Cuando está en IDE_OFF, la siguiente vez permite cambiar de mapper.
;Así que no hacer dos IDE_OFF seguidos ya que el segundo IDE_OFF atacará a la página del mapper con valor cero en este caso.


macro	IDE_ON
	ld	a,1
	ld	(IDE_BANK),a
endmacro

macro	IDE_OFF
	ld	a,0
	ld	(IDE_BANK),a
endmacro

;-----------------------------------------------------------------------------
;
; Comprobación de que la unidad y los datos SD están disponibles.
macro ideready

.iderready:	
	ld	a,(IDE_STATUS)
	bit	BSY,a
	jp	nz,.iderready ; Hace una comprobación al inicio y deja paso cuando la FLASHJACKS informa que puede continuar.
	ld	hl, IDE_DATA
endmacro


;-----------------------------------------------------------------------------
;
; Fin de las macros.
;
;------------------------------------------------------------------------------
	

;------------------------------------------------------------------------------
;
; bytes de opciones:
;
;  options:                            options2:
;
;      bit0 -> 1200Bps		           bit0 -> no usado
;      bit1 -> 2400Bps	                   bit1 -> no usado
;      bit2 -> 3000Bps			   bit2 -> no usado
;      bit3 -> 3600Bps		  	   bit3 -> no usado
;      bit4 -> bypass			   bit4 -> no usado
;      bit5 -> Reset limpio                bit5 -> no usado
;      bit6 -> Enable bus interno CAS      bit6 -> no usado
;      bit7 -> no usado	                   bit7 -> no usado
;
;------------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
; Programa principal:

	org	0100h

	jp	inicio

textointro:     
	db	"FCAS para Flashjacks ver 1.00", 13,10
	db	"Sintesis de Cassette para MSX", 13,10,13,10
	db	13,10,"$"

txtCAS:	
	db	"Cargando CAS....",13,10,"$"

txtBypass:	
	db	"Bypass activado en Motor ON.",13,10,"$"

txtEnter:
	db	13,10,"$"



textonot:
	db	"     FCAS para Flashjacks ver 1.00", 13,10
	db	"     Sintesis de Cassette para MSX",13,10
	db	13,10
	db	"Notas del autor:",13,10
	db	13,10	
	db	" FCAS es un sistema sintetizado para" ,13,10
	db	"cargar cintas de MSX en general.",13,10
	db	13,10
	db	"Intenta reproducir fielmente el sistema",13,10
	db	"de cintas original.",13,10
	db	"A su vez, se puede acelerar para ",13,10
	db	"disfrutar al maximo sin esas largas ",13,10
	db	"esperas.",13,10
	db	13,10
	db	"Asi que, todo vuestro. ",13,10
	db	13,10
	db	"                               AQUIJACKS",13,10
	db	#1A,"$"

textoini:
	db	"     FCAS para Flashjacks ver 1.00", 13,10
	db	"     Sintesis de Cassette para MSX",13,10
fintextoini:	db	13,10
	db	"Modo de uso: FCAS casfile.cas [opciones]",13,10
	db	"Opciones:",13,10
	db	"/N -> 1200Bps(Vel.Normal) /T -> 3000Bps",13,10
	db	"/D -> 2400Bps(Vel.Doble)  /F -> 3600Bps",13,10
	db	"/B -> Bypass. Audio-in a MSX/Audio-out",13,10
	db	"/I -> Datos Cassette por bus interno MSX",13,10
	db	"/R -> Reset con Basic MSX limpio sin FJ",13,10
	db	"/H -> Notas del autor",13,10
	db	13,10
	db	"Desactiva la RAM externa o usa el /R",13,10
	db	"para mayor compatibilidad con cintas.",13,10
	db	"En MSX1 y sistemas de 64k es necesario",13,10
	db	"la ampliacion de RAM. Asi que usa el /R.",13,10
	db	#1A,"$"

inicio:
	ld	sp, (#0006)
	ld	a, (DMA)	
	or	a	
	jp	nz, readline	;Si encuentra parámetros continua.

muestratexto:			;Sin parámetros muestra el texto explicativo y sale.
	; Comprueba primero que no hay un bypass indicado. En ese caso, saltaría a la operación de bypass.
	ld	a, (options)	;Si el bypass ha sido seleccionado salta sin abrir archivo..
	and	%10000
	jp	nz, searchslot
	; Hace un clear Screen o CLS.
	xor    a		; Pone a cero el flag Z.
	ld     ix, CLS          ; Petición de la rutina BIOS. En este caso CLS (Clear Screen).
	ld     iy,(MNROM)       ; BIOS slot
        call   CALSLT           ; Llamada al interslot. Es necesario hacerlo así en MSXDOS para llamadas a BIOS.
	; Averigua si es MSX-DOS2.
	XOR	A
	LD	DE,#0402
	CALL	#FFCA
	OR	A
	JP	Z,error11	;Para comprobar si realmente tienes las tablas.

	; Saca el texto de ayuda.
	ld	de, textoini	;Fija el puntero en el texto de ayuda.
	ld	c, 9
	call	BDOS		;Imprime por pantalla el texto.
	rst	0		;Salida al MSXDOS.

notastexto:			; Muestra el texto de notas del autor.
	; Hace un clear Screen o CLS.
	xor    a		; Pone a cero el flag Z.
	ld     ix, CLS          ; Petición de la rutina BIOS. En este caso CLS (Clear Screen).
	ld     iy,(MNROM)       ; BIOS slot
        call   CALSLT           ; Llamada al interslot. Es necesario hacerlo así en MSXDOS para llamadas a BIOS.
	; Averigua si es MSX-DOS2.
	XOR	A
	LD	DE,#0402
	CALL	#FFCA
	OR	A
	JP	Z,error11	;Para comprobar si realmente tienes las tablas.

	; Saca el texto de ayuda.
	ld	de, textonot	;Fija el puntero en el texto de notas.
	ld	c, 9
	call	BDOS		;Imprime por pantalla el texto.
	rst	0		;Salida al MSXDOS.

readline:
	xor	a		
	ld	hl, #0082	;Extrae parametros de la linea de comandos.
	ld	de, filename
	call	saltaspacio	;Salta todos los espacios encontrados.
	jp	c, muestratexto ;Si no hay nombre de archivo ejecuta salir al MSXDOS.
	cp	"/"
	jp	z, leeoptions2  ;Si hay barra y no nombre de archivo ejecuta las opciones .

leefilename:	
	ldi
	ld	a, (hl)
	cp	" "
	jp	z, leeoptions	;Lee las opciones si encuentra la barra espacio.
	jp	c, abre		;Va a operación de abrir archivo si no encuentra opciones. Programa secundario.
	jp	leefilename	;Bucle lectura nombre de archivo.

leeoptions:
	call	saltaspacio	;Salta todos los espacios encontrados.
	ld	a, (hl)
	cp	"/"
	jp	nz, abre	;Si no encuentra una barra abre archivo. Programa secundario.
	inc	hl
	ld	a, (hl)
	cp	" "
	jp	z, muestratexto
	jp	c, muestratexto ;Si es una barra con un espacio muestra el texto de opciones y fin.
	or	#20		;Pasa de si es mayusculas o minusculas.
	ld	b, %1		;Selecciona la marca del bit a guardar.
	cp	"n"		
	jp	z, setoption	;Si es una n guarda el valor en variale options
	ld	b, %10	;Selecciona la marca del bit a guardar.
	cp	"d"		
	jp	z, setoption	;Si es una d guarda el valor en variale options
	ld	b, %100		;Selecciona la marca del bit a guardar.
	cp	"t"		
	jp	z, setoption	;Si es una t guarda el valor en variale options
	ld	b, %1000	;Selecciona la marca del bit a guardar.
	cp	"f"		
	jp	z, setoption	;Si es una f guarda el valor en variale options
	ld	b, %10000	;Selecciona la marca del bit a guardar.
	cp	"b"		
	jp	z, setoption	;Si es una b guarda el valor en variale options
	ld	b, %100000	;Selecciona la marca del bit a guardar.
	cp	"r"		
	jp	z, setoption	;Si es una r guarda el valor en variale options
	ld	b, %1000000	;Selecciona la marca del bit a guardar.
	cp	"i"		
	jp	z, setoption	;Si es una i guarda el valor en variale options
	cp	"h"		
	jp	z, notastexto	;Si es una h saca las notas y el acerca de.

	jp	muestratexto	;Si es cualquier otra opción muestra el texto de opciones y fin.

leeoptions2:
	call	saltaspacio	;Salta todos los espacios encontrados.
	ld	a, (hl)
	cp	"/"
	jp	nz, muestratexto;Si no encuentra una barra muestra el texto de opciones y fin.
	inc	hl
	ld	a, (hl)
	cp	" "
	jp	z, muestratexto
	jp	c, muestratexto ;Si es una barra con un espacio muestra el texto de opciones y fin.
	or	#20		;Pasa de si es mayusculas o minusculas.
	cp	"h"		
	jp	z, notastexto	;Si es una h saca las notas y el acerca de.
	ld	b, %10000	;Selecciona la marca del bit a guardar.
	cp	"b"		
	jp	z, setoption	;Si es una b guarda el valor en variale options
	
	jp	muestratexto	;Si es cualquier otra opción muestra el texto de opciones y fin.

;Fin del programa principal.
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------	
;Subprocesos del programa principal:

;Almacena variable en options.
setoption:			
	ld	a, (options)
	or	b
	ld	(options), a
	inc	hl
	jp	leeoptions	;Vuelve al bucle principal.

;Almacena variable en options2.
setoption2:
	ld	a, (options2)	
	or	b
	ld	(options2), a
	inc	hl
	jp	leeoptions	;Vuelve al programa principal.

;Bucle de lectura nombre archivo .SCC
setback:			
	inc	hl
	ld	a, (hl)
	cp	" "
	jp	nz, muestratexto;Si encuentra un espacio en lugar del nombre archivo va a muestra el texto de opciones y fin.
	call	saltaspacio	;Salta todos los espacios encontrados.
	cp	"/"
	jp	z, muestratexto	;Si encuentra una barra de opciones en lugar del nombre archivo va a muestra el texto de opciones y fin.
	ld	de, backfile	;Carga variable nombre del archivo .SCC
leefile2:	
	ldi
	ld	a, (hl)
	cp	" "
	jp	nz, leefile2	;hace la lectura hasta encontrar barra de espacio.

	ld	a, (options2)
	or	%10000
	ld	(options2), a	;Guarda una marca de Background en options2.

	xor	a
	ld	(de), a		;Pone un cero al final de la variable nombre del archivo .SCC

	jp	leeoptions	;Vuelve al programa principal.

;Fin de los subprocesos del programa principal.
;-----------------------------------------------------------------------------


; Fin del programa principal.
;
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;
; Programa secundario. Fase de apertura del archivo ya con todas la opciones definidas.
; 

abre:	
	; Cargar archivo en FIB
	ld	de, filename	;Obtiene el File Info Block del
	ld	b, 0		;fichero.
	ld	hl, 0
	ld	ix, FIB
	ld	c, #40
	call	BDOS
	or	a
	jp	nz, error2	;Salta si error del archivo no se puede abrir.	

	ld	a, (options)	;Salta si es bypass.
	and	%10000
	jp	nz, searchslot
	
	call	read_128B	;Lee los primeros 512bytes del archivo

; Busca la unidad Flashjacks en el sistema
searchslot:
	ld	a, (FIB+25)	;Averigua la unidad lógica actual.
	ld	b, a		
	ld	d, #FF		
	ld	c, #6A		
	call	BDOS
	
	ld	a, d
	dec	a		;Le resta 1 ya que el cero cuenta.
	ld	(unidad), a	;Guarda el número de unidad lógica de acceso.
		
	ld	hl, #FB21	;Mira el número de unidades conectado en la interfaz de disco 1.	
	cp	(hl)		
	jp	c, tipodisp	;Si coincide selecciona esta unidad y va a tipo de dispositivo.
	sub	a, (hl)
	inc	hl
	inc	hl		;Mira el número de unidades conectado en la interfaz de disco 2.
	cp	(hl)
	jp	c, tipodisp	;Si coincide selecciona esta unidad y va a tipo de dispositivo.
	sub	a, (hl)
	inc	hl
	inc	hl		;Mira el número de unidades conectado en la interfaz de disco 3.
	cp	(hl)
	jp	c, tipodisp	;Si coincide selecciona esta unidad y va a tipo de dispositivo.
	sub	a, (hl)
	inc	hl
	inc	hl		;Mira el número de unidades conectado en la interfaz de disco 4.
tipodisp:
	inc	hl		;Va al slot address disk de la unidad seleccionada.
	ld	(unidad), a	;Guarda el número de unidad lógica de acceso.
	ld	a, (hl)
	ld	(slotide), a	;Guarda en slotide la dirección de esa unidad.

	di
	ld	a,(slotide)	; Última petición a un subslot con FlashROM.
	ld	hl,4000h
	call	ENASLT

;Detección de la Flashjacks

	;ld	a,(slotide)	
	;ld	hl,5FFEh
	;ld	e,019h
	;call	WRSLT
	
	ld	a,019h		; Carga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	
	ld	a,076h
	ld	(5FFFh),a

	ld	a,(4000h)	; Hace una lectura para tirar cualquier intento pasado de petición.
	
	ld	a,0aah
	ld	(4340h),a	; Petición acceso comandos FlashJacks. 
	ld	a,055h
	ld	(43FFh),a	; Autoselect acceso comandos FlashJacks. 
	ld	a,020h
	ld	(4340h),a	; Petición código de verificación de FlashJacks

	ld	b,16
	ld	hl,4100h	; Se ubica en la dirección 4100h (Es donde se encuentra la marca de 4bytes de FlashJacks)
RDID_BCL:
	ld	a,(hl)		; (HL) = Primer byte info FlashJacks
	cp	057h		; El primer byte debe ser 57h.
	jp	z,ID_2
	ld	a,000h		; Descarga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,000h
	ld	(5FFFh),a
	ei			; Activa interrupciones.
	jp	error1		; Salta a error1 sin cierre de fichero(no lo ha abierto) si no es una Flashjacks.

ID_2:	inc	hl
	ld	a,(hl)		; (HL) = Segundo byte info FlashJacks
	cp	071h		; El segundo byte debe ser 71h.
	jp	z,ID_3
	ld	a,000h		; Descarga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,000h
	ld	(5FFFh),a
	ei			; Activa interrupciones.
	jp	error1		; Salta a error1 sin cierre de fichero(no lo ha abierto) si no es una Flashjacks.

ID_3:	inc	hl
	ld	a,(hl)		; (HL) = Tercer byte info FlashJacks
	cp	098h		; El tercer byte debe ser 98h.
	jp	z,ID_4
	ld	a,000h		; Descarga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,000h
	ld	(5FFFh),a
	ei			; Activa interrupciones.
	jp	error1		; Salta a error1 sin cierre de fichero(no lo ha abierto) si no es una Flashjacks.

ID_4:	inc	hl
	ld	a,(hl)		; (HL) = Cuarto byte info FlashJacks
	cp	022h		; El cuarto byte debe ser 22h.

	jp	z,ID_OK		; Salta si da todo OK.
	
	ld	a,000h		; Descarga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,000h
	ld	(5FFFh),a
	ei			; Activa interrupciones.
	jp	error1		; Salta a error1 sin cierre de fichero(no lo ha abierto) si no es una Flashjacks.

ID_OK:	inc	hl
	ld	a,(hl)		; Al incrementar a 104h sale del modo info FlashJacks
	ld	a,000h		; Descarga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,000h
	ld	(5FFFh),a
	ei
	
	; Hace un clear Screen o CLS.
	xor    a		; Pone a cero el flag Z.
	ld     ix, CLS          ; Petición de la rutina BIOS. En este caso CLS (Clear Screen).
	ld     iy,(MNROM)       ; BIOS slot
        call   CALSLT           ; Llamada al interslot. Es necesario hacerlo así en MSXDOS para llamadas a BIOS.	

	ld	de, textointro	;Fija el puntero en el texto de intro.
	ld	c, 9
	call	BDOS
	
	ld	a, (options)	;Salta a la carga de archivo si el bypass no ha sido seleccionado.
	and	%10000
	jp	z, Cont_Carga
	
	di
	IDE_ON
	ideready

	ld	a,050h		;Resetea estados de variables en FJ.
	ld	(IDE_CMD),a
	
	ideready
	
	jp	Baud_param3	;Salta al resto de comandos sin carga de archivo y sin habilitar la carga por archivo y a 3600bps.

Cont_Carga:	
	ld	de, txtCAS	;Fija el puntero en el texto de cargar CAS.
	ld	c, 9
	call	BDOS

	ld	de, txtEnter	;Tecla Enter.
	ld	c, 9
	call	BDOS
		
	di
	IDE_ON
	ideready

	ld	a,050h		;Resetea estados de variables en FJ.
	ld	(IDE_CMD),a

	ideready

	; Cargar CAS en Flashjacks.	
	ld	a, (FIB+19)	;Top Cluster archivo abierto. Alto.
	ld	(FJ_CLUSH_FB),a	;Ingresa la dirección cluster el archivo. Alto. 
	ld	a, (FIB+20)	;Top Cluster archivo abierto. Bajo.
	ld	(FJ_CLUSL_FB),a	;Ingresa la dirección cluster el archivo. Bajo. 
	ld	a, (FIB+21)	;Tamaño archivo abierto. Alto3.
	ld	(FJ_TAM3_FB),a	;Ingresa el tamaño del archivo. Alto3. 
	ld	a, (FIB+22)	;Tamaño archivo abierto. Alto2.
	ld	(FJ_TAM2_FB),a	;Ingresa el tamaño del archivo. Alto2. 
	ld	a, (FIB+23)	;Tamaño archivo abierto. Alto1.
	ld	(FJ_TAM1_FB),a	;Ingresa el tamaño del archivo. Alto1. 
	ld	a, (FIB+24)	;Tamaño archivo abierto. Bajo.
	ld	(FJ_TAM0_FB),a	;Ingresa el tamaño del archivo. Bajo. 

	ld	a,043h		;Carga CAS.
	ld	(IDE_CMD),a

	ideready		; Hasta que no termina la carga no avanza.

	ld	a,060h		;Habilita la carga por archivo del cassette en la Flashjacks.
	ld	(IDE_CMD),a

	ld	a, (options)	;Salta a los 2400Bps si es la opción seleccionada.
	and	%10
	jp	nz, Baud_param1

	ld	a, (options)	;Salta a los 3000Bps si es la opción seleccionada.
	and	%100
	jp	nz, Baud_param2

	ld	a, (options)	;Salta a los 3600Bps si es la opción seleccionada.
	and	%1000
	jp	nz, Baud_param3
	
	ld	a,04h		; Si no es ninguna de las anteriores opciones, salta a Baudios opción en 1200Bps.
	jp	Baud_Cont	; Continua el proceso.

Baud_param1:
	ld	a,05h		; (Bit2:"1"CASENABLE, Bit1y0:"01" Baudios opción en 2400Bps.
	jp	Baud_Cont
Baud_param2:
	ld	a,06h		; (Bit2:"1"CASENABLE, Bit1y0:"10" Baudios opción en 3000Bps.
	jp	Baud_Cont
Baud_param3:
	ld	a,07h		; (Bit2:"1"CASENABLE, Bit1y0:"11" Baudios opción en 3600Bps.
	jp	Baud_Cont

Baud_Cont:
	ld	b,a
	ld	a, (options)	;Compara si selección de activación datos cassette por bus interno.
	and	%1000000
	jp	z, Baud_Cont2	;Salta si no es la opción seleccionada.
	ld	a,b
	or	%1000		;Aplica la máscara de Bit3:ENACASDATA
	jp	Baud_Cont3
Baud_Cont2:	
	ld	a,b
Baud_Cont3:
	ld	(CAS_PARAM),a	; (Bit3:ENACASDATA, Bit2:"1"CASENABLE, Bit1y0:"00" Baudios opción en 1200Bps.
	
	IDE_OFF
	ei
	jp	SalidaDos



	
;---------------------------------------------------------------------------
; Subprograma finalización del programa y salida estable al sistema

SalidaDos:

	di
	;IDE_ON
	;ideready
	
	;ld	a,050h		;Resetea estados de variables en FJ.
	;ld	(IDE_CMD),a

	;di
	;IDE_ON			;Activa la unidad IDE.
	;ideready

	;IDE_OFF
	
	ld	a,(RAMAD1)		;Esto devuelve los mappers del MSX en un estado lógico y estable.
	ld	hl,4000h
	call	ENASLT			;Select Main-RAM at bank 4000h~7FFFh

	ei				; Activa interrupciones.

printexin2:

	ld	a, (options)	;Salta si es bypass de todos los textos.
	and	%10000
	jp	nz, B_Bypass
	
	;Imprime por pantalla el nombre el CAS.
	ld	de, Nombre_CAS	;Imprime por pantalla el nombre CAS.
	ld	c, #09
	call	BDOS
	;Imprime por pantalla el valor del nombre el CAS.
	ld	de, Valor_N_CAS	;Imprime por pantalla el nombre CAS.
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS

	ld	a, (options)	;Salta a los 3600Bps si es la opción seleccionada.
	and	%1000
	jp	nz, B_txt_3600

	ld	a, (options)	;Salta a los 3000Bps si es la opción seleccionada.
	and	%100
	jp	nz, B_txt_3000

	ld	a, (options)	;Salta a los 2400Bps si es la opción seleccionada.
	and	%10
	jp	nz, B_txt_2400

	;Imprime por pantalla velocidad 1200Bps
	ld	de, Vel_1200	;Imprime por pantalla 1200Bps
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS
	jp	B_txt_End

B_txt_2400:
	;Imprime por pantalla velocidad 2400Bps
	ld	de, Vel_2400	;Imprime por pantalla 2400Bps
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS
	jp	B_txt_End

B_txt_3000:
	;Imprime por pantalla velocidad 3000Bps
	ld	de, Vel_3000	;Imprime por pantalla 3000Bps
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS
	jp	B_txt_End

B_txt_3600:
	;Imprime por pantalla velocidad 3600Bps
	ld	de, Vel_3600	;Imprime por pantalla 3600Bps
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS
	
B_txt_End:	
	ld	a, (options)	;Salta no imprimir mensaje datos internos si no es la opción seleccionada.
	and	%1000000
	jp	z, B_txt_End2
	;Imprime por pantalla datos Cassette por bus MSX 
	ld	de, CAS_BUS_INT	;Imprime por pantalla datos Cassette por bus MSX
	ld	c, #09
	call	BDOS
	;Imprime tecla Enter
	ld	de, txtEnter	;Imprime por pantalla el enter.
	ld	c, #09
	call	BDOS

B_txt_End2:
	;Imprime por pantalla el comando a escribir en BASIC.
	ld	hl,buffer_FILE+10	; Carga el valor de patrón de carga (RUN,BLOAD o CLOAD)
	ld	a,(hl)			; Lo vuelca al acumulador.
	cp	0EAh			; Mira si es 0EA (RUN).	
	jp	z,B_RUN			; Salto si es RUN
	cp	0D3h			; Mira si es 0D3 (CLOAD).	
	jp	z,B_CLOAD		; Salto si es CLOAD
	
	ld	de, Usa_BLOAD		;Imprime por pantalla BLOAD.
	ld	c, 9
	call	BDOS
	jp	B_Continue
B_RUN:
	ld	de, Usa_RUN		;Imprime por pantalla RUN.
	ld	c, 9
	call	BDOS
	jp	B_Continue
B_CLOAD:
	ld	de, Usa_CLOAD		;Imprime por pantalla CLOAD.
	ld	c, 9
	call	BDOS
	ld	de, Valor_N_CAS		;Imprime por pantalla Nombre archivo.
	ld	c, 9
	call	BDOS

B_Continue:
	ld	a, (options)		;Si el reset limpio ha sido seleccionado salta a texto reset
	and	%100000
	jp	nz, EReset
	
	ld	de, texin2		;Imprime por pantalla tecla para continuar
	ld	c, 9
	call	BDOS
	jp	ETecla			;Salta a tecla de espera.
EReset:	
	ld	de, texin3		;Imprime por pantalla tecla para reset
	ld	c, 9
	call	BDOS

ETecla:	xor	a			; Pone a cero el flag Z. Rutina espera pulsación de tecla.
	ld	ix, CHSNS		; Petición de la rutina BIOS. En este caso CHSNS (Mirar buffer teclado).
	ld	iy,(MNROM)		; BIOS slot
        call	CALSLT			; Llamada al interslot. Es necesario hacerlo así en MSXDOS para llamadas a BIOS.
	jp	z, ETecla

	ld	a, (options)		;Si el reset limpio ha sido seleccionado salta a rutina de reset de la Flashjacks
	and	%100000
	jp	nz, Reset

	xor	a			; Pone a cero el flag Z.
	ld	ix, KILBUF		; Petición de la rutina BIOS. En este caso KILBUF (Borra el buffer del teclado).
	ld	iy,(MNROM)		; BIOS slot
        call	CALSLT			; Llamada al interslot. Es necesario hacerlo así en MSXDOS para llamadas a BIOS.

	rst	0			;Salida al MSXDOS.

B_Bypass:
	ld	de, txtBypass		;Imprime por pantalla Bypass Seleccionado.
	ld	c, 9
	call	BDOS
	jp	B_Continue

; Textos de la finalización del programa.
texin2:	db	13,10,"Pulsa una tecla para continuar.",13,10,"$"
texin3:	db	13,10,"Pulsa una tecla para reset limpio.",13,10,"$"

; Fin subprograma finalización del programa y salida estable al sistema
;---------------------------------------------------------------------------


;-----------------------------------------------------------------------------	
;Subproceso de quitar todos los slots y poner una ROM muerta para que te lance el BASIC. A posterior reset Flashjacks:

Reset:	di			; Desactiva interrupciones.
	ld	a,(slotide)	; Última petición a un subslot con FlashROM.
	ld	hl,04000h
	call	ENASLT		; Select Flashrom at bank 4000h~7FFFh

	ld	a,019h		; Carga en un posible FMPAC el modo recepción instrucciones EPROM.
	ld	(5FFEh),a
	ld	a,076h
	ld	(5FFFh),a

	ld	a,(4000h)	; Hace una lectura para tirar cualquier intento pasado de petición.

	ld	a,0aah
	ld	(4340h),a	; Petición acceso comandos FlashJacks. 
	ld	a,055h
	ld	(43FFh),a	; Autoselect acceso comandos FlashJacks. 
	ld	a,010h
	ld	(4340h),a	; Petición de carga externo de archivos.
	; Tipo mappers disponibles:
	; 00h y 7Fh  --  Instrucción ignorar carga externa.
	; 7Eh	     --  Carga externa con mapper AUTO (Lo selecciona FlashJacks con su autoanalisis)
	; 7Dh	     --	 Deja la Flashjacks vacia. Sin nada en los slots. 
	; 01h	     --  Carga externa con mapper KONAMI5
	; 02h	     --  Carga externa con mapper ASCII8K
	; 03h	     --  Carga externa con mapper KONAMI4
	; 04h	     --  Carga externa con mapper ASCII16K
	; 05h	     --  Carga externa con mapper SUNRISE IDE
	; 06h	     --  Carga externa con mapper SINFOX
	; 07h	     --  Carga externa con mapper ROM16K
	; 08h	     --  Carga externa con mapper ROM32K
	; 09h	     --  Carga externa con mapper ROM64K
	; 0Ah	     --  Carga externa con mapper RTYPE
	; 0Bh	     --  Carga externa con mapper ZEMINA6480
	; 0Ch	     --  Carga externa con mapper ZEMINA126
	; 0Dh	     --  Carga externa con mapper FMPAC
	;
	; Bit 7 del mapper:
	; 0	     --  Auto Expansor de Slots
	; 1	     --  Forzado Slot primario
	;
	;
	ld	a,7Dh		; Fuerza el vaciado de slots.
	ld	(4341h),a	; Petición de carga si no es 0.		
	ld	a,0ffh
	ld	(4348h),a	; Petición salida Autoselect.


; --- Reset por soft de la Flashjacks sincronizado con el reset del z80.
	

	ld	a,(4000h)	; Hace una lectura para tirar cualquier intento pasado de petición.
	
	ld	a,0aah
	ld	(4340h),a	; Petición acceso comandos FlashJacks. 
	ld	a,055h
	ld	(43FFh),a	; Autoselect acceso comandos FlashJacks. 
	ld	a,030h
	ld	(4340h),a	; Petición código de reset de FlashJacks

	ld	b,16
	ld	hl,4666h	; Al leer en este momento la dirección x666h fuerza el reset por hardware de la flashjacks.
	ld	a,(hl)		; Despues de aquí, el msx tiene exactamente 0,1Segundos hasta que la Flashjacks deje de responder y haga el cambio de hardware.
	;Reset MSX ultrarápido
	rst	030h
	db	0
	dw	0000h
; Fin del Reset por soft de la Flashjacks sincronizado con el reset del z80.


;-----------------------------------------------------------------------------	
;Subproceso de salida del programa con mensaje de error:

txterror:	db	"Error: $"

error:	;Salida normal con mensaje de error.
	push	de		;Guarda el mensaje de error a mostrar.
	
	ei			;Activa interrupciones. Por si acaso se han quedado desactivadas.
	
	ld	a,(RAMAD1)	;Esto devuelve los mappers del MSX en un estado lógico y estable.
	ld	hl,4000h
	call	ENASLT		;Select Main-RAM at bank 4000h~7FFFh

	ld	de, txterror	;Imprime por pantalla la palabrar Error.
	ld	c, #09
	call	BDOS

	pop	de		;Recupera e imprime por pantalla el mensaje del error.
	ld	c, #09
	call	BDOS

	ei			;Activa interrupciones. Por si acaso se han quedado desactivadas.
	rst	0		;Salida al MSXDOS.

error9: ;Salida cerrando archivo con mensaje de error:
	push	de

	ld	c, 10h		;Cierre del archivo.
	ld	de,FCB
	call	BDOS

	ei			;Activa interrupciones. Por si acaso se han quedado desactivadas.
	
	ld	a,(RAMAD1)	;Esto devuelve los mappers del MSX en un estado lógico y estable.
	ld	hl,4000h
	call	ENASLT		;Select Main-RAM at bank 4000h~7FFFh

	ld	c, 9
	ld	de, txterror	;Imprime por pantalla la palabrar Error.
	call	BDOS

	pop	de		;Recupera e imprime por pantalla el mensaje del error.
	ld	c, #09
	call	BDOS

	rst	0		;Salida al MSXDOS.


;Mensajes de error:	
txterror1:	db	"FLASHJACKS no detectada!!",13,10,"$"
error1:
	ld	de, txterror1	;Error de Flashjacks no detectada.
	jp	error

txterror2:	db	"El archivo no se puede abrir!!",13,10,"$"
txterror3:	db	"El archivo no es compatible!!",13,10,"$"
txterror4:	db	"Archivo no encontrado!!",13,10,"$"
error2:
	ld	de, txterror2	;Error del archivo que no se puede abrir.
	jp	error

error2_:
	ld	de, txterror2	;Error del archivo que no se puede abrir cerrando archivo.
	jp	error9

error3:
	ld	de, txterror3	;Error del archivo que no se puede abrir cerrando archivo.
	jp	error

txterror11:	db	"Esto no es MSX-DOS2.Carga los drivers.",13,10,"$"
error11:
	ld	de, txterror11	;Error no es MSX-DOS2
	jp	error

;Fin del subproceso de salida del programa con mensaje de error.
;-----------------------------------------------------------------------------	


;-----------------------------------------------------------------------------
;
; Subrutinas (vienen de un CALL):

;-----------------------------------------------------------------------------
;
; Espera al ideready de la tarjeta SD.
_ideready:
	ideready
	ret

;-----------------------------------------------------------------------------
;
; Saltar espacios de una cadena de carácteres

saltaspacio:			;Salta todos los espacios en la lectura de cadena de carácteres.
	ld	a, (hl)
	cp	" "
	ret	nz		;Si hay otra cosa que no sea espacios fin de la subrutina.
	inc	hl
	jp	saltaspacio	;Bucle saltar espacios.

;-----------------------------------------------------------------------------
;
; Convierte una cadena numérica de decimal a hexadecimal.
; El resultado lo pone en bc y de

dec2hex:
	ld	bc, 0
	ld	de, 0
dec2hex2:
	inc	hl		;lee la cadena numérica en texto.
	ld	a, (hl)
	cp	" "
	ret	z		;Si hay un espacio fin de la lectura. Sale de la subrutina
	ret	c		;Si no hay nada fin de la lectura. Sale de la subrutina.
	sub	#30		;Lo pasa a número de variable.(30 a 39 ASCII).
	cp	10
	jp	nc, dec2hex3	;Si no es un número muestra texto y fin.
	push	af
	call	mulbcdx10	;Multiplica por 10 el número.
	pop	af
	add	a, d
	ld	d, a
	ld	a, c
	adc	a, 0
	ld	c, a
	ld	a, b
	adc	a, 0
	ld	b, a
	jp	dec2hex2	;Va haciendo bucle hasta tener el número en HEX.
dec2hex3:
	pop	hl		;Mata el RET del stack pointer. (Extrae del SP la llamada del CALL y lo pone en HL por ejemplo).
	jp	muestratexto	;Salto incondicional de muestra texto y fin.

;-----------------------------------------------------------------------------
;
; Multiplica un valor BCD x10

mulbcdx10:
	or	a
	rl	d
	rl	c
	rl	b
	ld	ixh, b
	ld	ixl, c
	ld	iyh, d
	or	a
	rl	d
	rl	c
	rl	b
	or	a
	rl	d
	rl	c
	rl	b
	ld	a, d
	add	a, iyh
	ld	d, a
	ld	a, c
	adc	a, ixl
	ld	c, a
	ld	a, b
	adc	a, ixh
	ld	b, a
	ret

;-----------------------------------------------------------------------------
;
; Lee del archivo el primer bloque de 128bytes.

read_128B:	
	ld	a,0		;Lee el número de unidad lógica de acceso.
	ld	(FCB),a		;Guarda la unidad lógica en el FCB.
				
				; Pone espacios en el nombre de archivo dentro del FCB.
	ld	hl,FCB+1	; Transfiere el FCB a hl.
	ld	a,8+3		; Nombre+ext a borrar con espacios.
B_Name2:ld	(hl),020h	; Carga el caracter espacio en la ubicación del puntero de HL.
	inc	hl		; Incrementa el puntero de FCB.
	dec	a		; Decrementa posiciones restantes.
	jp	nz,B_Name2	; Bucle borrado Nombre archivo en FCB.

				; Convierte de formato nombre archivo FIB a FCB
	ld	hl,FIB+1	; Transfiere el nombre del archivo de FIB a FCB.
	ld	de,FCB+1
	ld	bc,8		; 8 carácteres.
B_Name3:	
	ldi			; Avanza de uno en uno.
	jp	c, B_Punto	; Si llega al final considera lo siguiente como un punto.
	ld	a,(hl)		; Si no ha llegado al final lee el contenido siguiente por si es un punto.
	cp	02Eh		; Mira si hay un punto para tratarlo como extensión.	
	jp	z,B_Punto	; Salto por punto.
	xor	a		; Borra a para evitar afectar al carry.
	jp	B_Name3		; Si no, va incrementado posiciones.

B_Punto:
	inc	hl		; Quitamos "."
	ld	de,FCB+1+8	; Nos vamos a la posición de extensión.
	ld	bc,3		
	ldir			; Aquí copia los tres carácteres siguientes.
		
	ld	bc,0024		; Prepare the FCB. Bytes 12 en adelante.
	ld	de,FCB+13
	ld	hl,FCB+12
	ld	(hl),b
	ldir			; Initialize the second half with zero

	ld	c,0fh		; Abrimos el archivo. (Acordarse de cerrarlo)
	ld	de,FCB
	call	BDOS		
	cp	0ffh
	jp	z, error2_	; Si no se deja abrir, mensaje de error y cierre archivo.
	
	ld	c,1ah		; Le dice a la unidad que el buffer_File es donde debe de volcar los datos.
	ld	de,buffer_FILE	; Lo direcciona a esta posición de memoria.
	call	BDOS		; Set disk transfer address 

	ld	c,021h		;Random Read. Lee un bloque de 128bytes(instrucción 21h). 
	ld	de,FCB
	call	BDOS		; Open file
	cp	01h
	jp	z, error2_	; Si no se deja abrir, mensaje de error y cierre archivo.
	
	ld	c, 10h		;Cierre del archivo.
	ld	de,FCB
	call	BDOS

	;Busca al principio la marca CAS.
	ld	hl,buffer_FILE	; Transfiere el buffer_File
	ld	de,Marca_CAS	; Transfiere el Marca_CAS a comparar.
	ld	b,8		; 8 carácteres.
B_Verify:	
	ld	a,(de)		; Si no ha llegado al final lee el contenido siguiente por si es un punto.
	cp	(hl)		; Mira si hay un punto para tratarlo como extensión.	
	jp	nz,B_Error	; Salto por comparación del byte incorrecto.
	inc	hl
	inc	de
	djnz	B_Verify	; Avanza de uno en uno.
	jp	B_Correct	; Si llega al final es que es correcto.

B_Error:
	pop	hl		; Mata el ret.
	jp	error3		; Error archivo no compatible.
B_Correct:

	;Transfiere el nombre del CAS a su variable.
	ld	hl,buffer_FILE+18	; Transfiere el nombre del CAS a su variable.
	ld	de,Valor_N_CAS
	ld	bc,6
	ldir

	ret

;-----------------------------------------------------------------------------
;Variables del entorno.

oldstack:	dw	0
PCMport:	db	0
tamanyoPCM:	dw	0
options:	db	%0
options2:	db	%0
pcmsize:	dw	0
tamanyo:	db	0,0,0,0
tamanyoc:	db	0,0,0,0
unidad:		db	0
slotide:	db	0
cabezas:	db	0
sectores:	db	0
devicetype:	db	0
atapic:		ds	18
start:		db	0,0,0,0
start_:		db	0,0,0,0
final:		db	0,0,0,0
final_:		db	0,0,0,0
frmxint:	db	2
HMMV:		db	0,0,0,0,0,0,212,1,0,0,#C0
HMMC1:		db	64,0,53
pagvram:	db	0
		db	128,0,106,0,0,#F0

HMMC2:		db	0,0,0
pagvram2:	db	0
		db	0,1,212,0,0,#F0

transback:	db	0,0,0,0,0,1,212,0,0,0,#F0
transback2:	db	0,0,0,0,0,0,0,1,0,1,212,0,0,0,#D0

datovideo:	db	0
TempejeY:	db	0
MultiVDP:	db	0
regside1:	db	0
regside2:	db	0
regside3:	db	0
regside4:	db	0
regside1c:	db	0
regside2c:	db	0
regside3c:	db	0
regside4c:	db	0
atapiread:	db	#A8,0,0,0,0,0,0,0,0,0,0,0
modor800:	db	0
Z80B:		db	0
filehandle:	db	0
filehandle2:	db	0
filename:	ds	64
fileram:	ds	20
fileboot:	db	5Ch,"BOY_BIOS.BIN",0 ; el 5Ch es contrabarra para ir a directorio raiz.
backfile:	ds	64
safe38:		ds	5
buffer:		ds	2
FIB:		ds	64
sonido:		dw	0
sonido2:	dw	0
idevice:	dw	0
Bytes_Leidos:	db	0
Textfile:	db	"00000000000",13,10,"$"
Nombre_CAS	db	"Nombre CAS:","$"
Valor_N_CAS	db	"      ",13,10,"$"
Usa_RUN		db	"Usa en BASIC: RUN",34,"CAS:",13,10,"$"
Usa_BLOAD	db	"Usa en BASIC: BLOAD",34,"CAS:",34,",R",13,10,"$"
Usa_CLOAD	db	"Usa en BASIC: CLOAD",34,"$"
Vel_1200	db	"Velocidad de carga 1200bps",13,10,"$"
Vel_2400	db	"Velocidad de carga 2400bps",13,10,"$"
Vel_3000	db	"Velocidad de carga 3000bps",13,10,"$"
Vel_3600	db	"Velocidad de carga 3600bps",13,10,"$"
CAS_BUS_INT	db	"Datos Cassette por bus MSX",13,10,"$"
Marca_CAS	db	1Fh,0A6h,0DEh,0BAh,0CCh,13h,7Dh,74h
File_Name	db	"           ",13,10,"$"
buffer_FILE:

;Fin de las variables del entorno.
;-----------------------------------------------------------------------------

;Fin del programa completo.
;-----------------------------------------------------------------------------
end