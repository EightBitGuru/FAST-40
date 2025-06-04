// VIC-20 system memory labels
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace vic20

// Zero Page OS variables
.namespace os_zpvars
{
    .label USRJMP	= $0000         //	Jump for USR
    .label USRVECL	= $0001			//	Vector for USR lo-byte
    .label USRVECH	= $0002			//	Vector for USR hi-byte
//  .label UNUSED	= $0003			//	Not used by BASIC/KERNAL (4 bytes)
    .label SRCHCHAR	= $0007			//	Search character
    .label QUOTFLAG	= $0008			//	Scan-quotes flag
    .label TABSAVE	= $0009			//	TAB column save
    .label LOADMODE	= $000A			//	0=LOAD, 1=VERIFY
    .label INBUFPTR	= $000B			//	Input buffer pointer/# subscript
    .label DIMFLAG	= $000C			//	Default DIM flag
    .label VARTYPE	= $000D			//	Type: FF=string, 00=numeric
    .label NUMTYPE	= $000E			//	Type: 80=integer, 00=floating point
    .label DATAPTR	= $000F			//	DATA scan/LIST quote/memory flag
    .label SUBFLAG	= $0010			//	Subscript/FNx flag
    .label INPTYPE	= $0011			//	0 = INPUT//$40 = GET//$98 = READ
    .label ATNSIGN	= $0012			//	ATN sign/Comparison eval flag
    .label IOPROMPT	= $0013			//	Current I/O prompt flag
    .label INTVAL	= $0014			//	Integer value
    .label STRPTR	= $0016			//	Pointer: temporary string stack
    .label STRVECL	= $0017			//	Current descriptor stack item pointer lo-byte
    .label STRVECH	= $0018			//	Current descriptor stack item pointer hi-byte
    .label STRSTACK	= $0019			//	Stack for temporary strings (3 bytes)
    .label UTILPTR	= $0022			//	Utility pointer area
    .label MULTPROD	= $0026			//	Product area for multiplication
    .label STRTBASL	= $002B			//	Pointer: Start of BASIC lo-byte
    .label STRTBASH	= $002C			//	Pointer: Start of BASIC hi-byte
    .label STRTVARL	= $002D			//	Pointer: Start of Variables lo-byte
    .label STRTVARH	= $002E			//	Pointer: Start of Variables hi-byte
    .label STRTARRL	= $002F			//	Pointer: Start of Arrays lo-byte
    .label STRTARRH	= $0030			//	Pointer: Start of Arrays hi-byte
    .label ENDARRL	= $0031			//	Pointer: End of Arrays lo-byte
    .label ENDARRH	= $0032			//	Pointer: End of Arrays hi-byte
    .label STRTSTRL	= $0033			//	Pointer: String storage (moving down) lo-byte
    .label STRTSTRH	= $0034			//	Pointer: String storage (moving down) hi-byte
    .label UTILSTR	= $0035			//	Utility string pointer
    .label RAMTOPL	= $0037			//	Pointer: Limit of memory lo-byte
    .label RAMTOPH	= $0038			//	Pointer: Limit of memory hi-byte
    .label CURRLINE	= $0039			//	Current Basic line number
    .label PREVLINE	= $003B			//	Previous Basic line number
    .label CONTPTRL	= $003D			//	Pointer: Basic statement for CONT lo-byte
    .label CONTPTRH	= $003E			//	Pointer: Basic statement for CONT hi-byte
    .label DATALINE	= $003F			//	Current DATA line number
    .label DATADDRL	= $0041			//	Current DATA address lo-byte
    .label DATADDRH	= $0042			//	Current DATA address hi-byte
    .label INPVEC	= $0043			//	Input vector
    .label VARNAME	= $0045			//	Current variable name
    .label VARADDR	= $0047			//	Current variable address
    .label FORVAR	= $0049			//	Variable pointer for FOR/NEXT
    .label PTRSAVE	= $004B			//	Y-save; op-save; Basic pointer save
    .label COMPSYM	= $004D			//	Comparison symbol accumulator
    .label MISCWORK	= $004E			//	Misc work area, pointers, etc
    .label GCSTEPSZ	= $0053			//	Garbage collection step size
    .label FUNCVEC	= $0054			//	Jump vector for functions
    .label NUMWORK	= $0057			//	Misc numeric work area
    .label ACC1EXP	= $0061			//	Accum#1: Exponent
    .label ACC1MANT	= $0062			//	Accum#1: Mantissa
    .label ACC1SIGN	= $0066			//	Accum#1: Sign
    .label EVALPTR	= $0067			//	Series evaluation constant pointer
    .label ACC1OVER	= $0068			//	Accum#1 hi-order (overflow)
    .label ACC2EXP	= $0069			//	Accum#2: Exponent, etc.
    .label SIGNCOMP	= $006F			//	Sign comparison, Acc#1 vs #2
    .label ACC1RND	= $0070			//	Accum#1 lo-order (rounding)
    .label CBUFLEN	= $0071			//	Cassette buffer length/Series pointer
    .label CHRGET	= $0073			//	CHRGET subroutine (get BASIC char)
    .label EXECPTRL	= $007A			//	Basic execution pointer (within CHRGET) lo-byte
    .label EXECPTRH	= $007B			//	Basic execution pointer (within CHRGET) hi-byte
    .label RNDSEED	= $008B			//	RND seed value
    .label STWORD	= $0090			//	Status word ST
    .label STOPFLAG	= $0091			//	Keyswitch PIA: STOP and RVS flags
    .label TAPETIME	= $0092			//	Timing constant for tape
    .label LOADMD2	= $0093			//	Load=0, Verify=1
    .label DEFFLAG	= $0094			//	Serial output: deferred char flag
    .label DEFCHAR	= $0095			//	Serial deferred character
    .label CASSEOT	= $0096			//	Tape EOT received
    .label REGSAV	= $0097			//	Register save
    .label FILECNT	= $0098			//	How many open files
    .label DEVIN	= $0099			//	Input device (0=keyboard)
    .label DEVOUT	= $009A			//	Output device (3=screen)
    .label PARITY	= $009B			//	Tape character parity
    .label BYTERCVD	= $009C			//	Byte-received flag
    .label OUTCONT	= $009D			//	Direct=$80/RUN=0 output control
    .label PASS1ERR	= $009E			//	Tape Pass 1 error log/char buffer
    .label PASS2ERR	= $009F			//	Tape Pass 2 error log corrected
    .label JIFFY	= $00A0			//	Jiffy Clock (HML)
    .label EOIFLAG	= $00A3			//	Serial bit count/EOI flag
    .label CYCLECNT	= $00A4			//	Cycle count
    .label COUNTDN	= $00A5			//	Countdown, tape write/bit count
    .label TAPBUFPT	= $00A6			//	Pointer into tape buffer during read/write
    .label READPASS	= $00A7			//	Tape Write ldr count/Read pass/inbit
    .label READERR	= $00A8			//	Tape Write new byte/Read error/inbit
    .label BITERR	= $00A9			//	Write start bit/Read bit err/stbit
    .label TAPESCAN	= $00AA			//	Tape Scan//Cnt//Ld//End/byte assy
    .label CHECKSUM	= $00AB			//	Write lead length/Rd checksum/parity
    .label TBUFFPTR	= $00AC			//	Pointer: tape buffer, scrolling
    .label ENDPROG	= $00AE			//	Tape end addresses/End of program
    .label TIMCONST	= $00B0			//	Tape timing constants
    .label TBUFFSTL	= $00B2			//	Pointer: start of tape buffer lo-byte
    .label TBUFFSTH	= $00B3			//	Pointer: start of tape buffer hi-byte
    .label TAPTIME	= $00B4			//	Tape timer (1 =enable)//	bit cnt
    .label TAPEEOT	= $00B5			//	Tape EOT/RS-232 next bit to send
    .label CHARERR	= $00B6			//	Read character error/outbyte buffer
    .label NAMECNT	= $00B7			//	# characters in file name
    .label CURRLOGF	= $00B8			//	Current logical file
    .label CURRSEC	= $00B9			//	Current secondary address
    .label CURRDEV	= $00BA			//	Current device
    .label FNAMEPTR	= $00BB			//	Pointer: to file name
    .label SHFTWORD	= $00BD			//	Write shift word/Read input char
    .label BLOCKCNT	= $00BE			//	# blocks remaining to Write/Read
    .label SWORDBUF	= $00BF			//	Serial word buffer
    .label MOTOR	= $00C0			//	Tape motor interlock
    .label IOSTARTL	= $00C1			//	I/O start addresses lo-byte
    .label IOSTARTH	= $00C2			//	I/O start addresses hi-byte
    .label SETUPL	= $00C3			//	KERNAL setup pointer lo-byte
    .label SETUPH	= $00C4			//	KERNAL setup pointer hi-byte
    .label KEYPRESS	= $00C5			//	Current key pressed
    .label KEYCOUNT	= $00C6			//	# chars in keyboard buffer
    .label RVSFLAG	= $00C7			//	Screen reverse flag ($00=RVS OFF, $12=RVS ON)
    .label EOLPTR	= $00C8			//	Pointer: End-of-line for input
    .label CRSRIROW	= $00C9			//	Input cursor logical row (0-22)
    .label CRSRICOL	= $00CA			//	Input cursor logical column (0-87)
    .label KEYSCAN	= $00CB			//	Which key: 64 if no key
    .label CRSRMODE	= $00CC			//	cursor enable (0=flash cursor)
    .label CRSRTIME	= $00CD			//	Cursor timing countdown
    .label CRSRCHAR	= $00CE			//	Character under cursor
    .label CRSRBLNK	= $00CF			//	Cursor in blink phase
    .label INPUTSRC	= $00D0			//	Get input from screen/keyboard (0=keyboard, !0=screen)
    .label SCRNLNL	= $00D1			//	Pointer to screen line lo-byte
    .label SCRNLNH	= $00D2			//	Pointer to screen line hi-byte
    .label CRSRLPOS	= $00D3			//	Position of cursor on logical line (0-87)
    .label QUOTMODE	= $00D4			//	Editor quote mode (0=off, !0=on)
    .label LINELEN	= $00D5			//	Current screen line length
    .label CRSRROW	= $00D6			//	Current cursor screen row (0-22)
    .label CHARBYTE	= $00D7			//	Last inkey/checksum/buffer
    .label INSRTCNT	= $00D8			//	Count of INSERTs outstanding
    .label LINELINK	= $00D9			//	Screen line link table
    .label LINELNK2	= $00F1			//	Dummy screen link
    .label ROWMARKR	= $00F2			//	Screen row marker
    .label COLRPTRL	= $00F3			//	Screen color pointer lo-byte
    .label COLRPTRH	= $00F4			//	Screen color pointer hi-byte
    .label KEYPTR	= $00F5			//	Keyboard pointer
    .label RS232RXL	= $00F7			//	RS-232 Rcv pointer lo-byte
    .label RS232RXH	= $00F8			//	RS-232 Rcv pointer hi-byte
    .label RS232TXL	= $00F9			//	RS-232 Tx pointer lo-byte
    .label RS232TXH	= $00FA			//	RS-232 Tx pointer hi-byte
//  .label UNUSED	= $00FB			//	Not used by BASIC/KERNAL (4 bytes)
    .label BASSTORE	= $00FF			//	Basic storage
}


// Page 1 CPU Stack
.namespace cpu
{
    .label STACK	= $0100			//	Processor stack (256 bytes) -and- Floating to ASCII work area (11 bytes) -and- Tape error log (63 bytes)
}


// Pages 2 & 3 OS variables
.namespace os_vars
{
    .label INPBUFF	= $0200			//	BASIC input buffer (89 bytes)
    .label FILETAB	= $0259			//	Logical file table
    .label DEVTAB	= $0263			//	Device # table
    .label SECTAB	= $026D			//	Secondary Address table
    .label KEYBUFF	= $0277			//	Keyboard buffer (10 bytes)
    .label BASICL	= $0281			//	Start-of-BASIC pointer lo-byte
    .label BASICH	= $0282			//	Start-of-BASIC pointer hi-byte
    .label OSMEMTPL	= $0283			//	OS top-of-memory pointer lo-byte
    .label OSMEMTPH	= $0284			//	OS top-of-memory pointer hi-byte
    .label BUSTIME	= $0285			//	Serial bus timeout flag
    .label CURRCOLR	= $0286			//	Current color code
    .label CRSRCOL	= $0287			//	Color under cursor
    .label SCRNMEMP	= $0288			//	Screen memory page
    .label KEYBUFSZ	= $0289			//	Max size of keyboard buffer
    .label REPMODE	= $028A			//	Key repeat (128=repeat all keys)
    .label REPSPEED	= $028B			//	Repeat speed counter
    .label REPDELAY	= $028C			//	Repeat delay counter
    .label SHFTCTRL	= $028D			//	Keyboard Shift/Control flag
    .label LASTSHFT	= $028E			//	Last keyboard shift pattern
    .label DECODEL	= $028F			//	Pointer: SHIFT/CTRL/C= key decode logic lo-byte
    .label DECODEH	= $0290			//	Pointer: SHIFT/CTRL/C= key decode logic hi-byte
    .label SHFTMODE	= $0291			//	Shift mode switch (0 = enabled, 128 = locked)
    .label AUTOSCRL	= $0292			//	Autoscrolldownflag (0=on, !0=off)
    .label RS232CTL	= $0293			//	RS-232 control register
    .label RS232COM	= $0294			//	RS-232 command register
    .label BITTIME	= $0295			//	Nonstandard (Bit time/2-100)
    .label RS232STA	= $0297			//	RS-232 status register
    .label BITS2SND	= $0298			//	Number of bits to send
    .label BAUDRATE	= $0299			//	Baud rate (full) bit time
    .label RS232REC	= $029B			//	RS-232 receive pointer
    .label RS232INP	= $029C			//	RS-232 input pointer
    .label RS232TRA	= $029D			//	RS-232 transmit pointer
    .label RS232OUT	= $029E			//	RS-232 output pointer
    .label TEMPIRQ	= $029F			//	Holds IRQ during tape operations
//  .label UNUSED	= $02A1			//	Not used by BASIC/KERNAL (95 bytes)
    .label ERRMSG	= $0300			//	Error message link
    .label BASWARM	= $0302			//	Basic warm start link
    .label BASCRNCH	= $0304			//	Crunch Basic tokens link
    .label PRNTTOKN	= $0306			//	Print tokens link
    .label NEWCODEL	= $0308			//	Start new BASIC code link vector lo-byte
    .label NEWCODEH	= $0309			//	Start new BASIC code link vector hi-byte
    .label MATHELEM	= $030A			//	Get arithmetic element link
    .label CPUAREG	= $030C			//	Storage for 6502 .A register
    .label CPUXREG	= $030D			//	Storage for 6502 .X register
    .label CPUYREG	= $030E			//	Storage for 6502 .Y register
    .label CPUPREG	= $030F			//	Storage for 6502 .P register
//  .label UNUSED	= $0310			//	Not used by BASIC/KERNAL (4 bytes)
    .label IRQVECL	= $0314			//	Hardware (IRQ) interrupt vector [EABF] lo-byte
    .label IRQVECH	= $0315			//	Hardware (IRQ) interrupt vector [EABF] hi-byte
    .label BRKVECL	= $0316			//	Break interrupt vector [FED2] lo-byte
    .label BRKVECH	= $0317			//	Break interrupt vector [FED2] hi-byte
    .label NMIVECL	= $0318			//	NMI interrupt vector [FEAD] lo-byte
    .label NMIVECH	= $0319			//	NMI interrupt vector [FEAD] hi-byte
    .label OPENVEC	= $031A			//	OPEN vector [F40A]
    .label CLOSEVEC	= $031C			//	CLOSE vector [F34A]
    .label SINPVEC	= $031E			//	Set-input vector [F2C7]
    .label SOUTVEC	= $0320			//	Set-output vector [F309]
    .label RESTVEC	= $0322			//	Restore l/O vector [F3F3]
    .label INPVEC2L	= $0324			//	INPUT vector [F20E] lo-byte
    .label INPVEC2H	= $0325			//	INPUT vector [F20E] hi-byte
    .label OUTVEC2L	= $0326			//	Output vector [F27A] lo-byte
    .label OUTVEC2H	= $0327			//	Output vector [F27A] hi-byte
    .label STOPVEC	= $0328			//	Test-STOP vector [F770]
    .label GETVEC	= $032A			//	GET vector [F1F5]
    .label ABORTIO	= $032C			//	Abort l/O vector [F3EF]
    .label USRVEC2	= $032E			//	User vector (default BRK) [FED2]
    .label LOADRAM	= $0330			//	Link to load RAM [F549]
    .label SAVERAM	= $0332			//	Link to save RAM [F685]
//  .label UNUSED	= $0334			//	Not used by BASIC/KERNAL (8 bytes)
    .label CASSBUFF	= $033C			//	Cassette buffer (192 bytes)
//  .label UNUSED	= $03FC			//	Not used by BASIC/KERNAL (4 bytes)
}


// System RAM
.namespace ram
{
    .label RAMBLK0	= $0400			//	3K expansion block (BLK0)
    .label RAMMAIN	= $1000			//	4K on-board memory
    .label RAMBLK1	= $2000			//	8K expansion block (BLK1)
    .label RAMBLK2	= $4000			//	8K expansion block (BLK2)
    .label RAMBLK3	= $6000			//	8K expansion block (BLK3)
}


// Character glyph ROM
.namespace character_generator
{
    .label UCROM	= $8000			//	Upper case and graphics
    .label REVUCROM	= $8400			//	Reversed upper case and graphics
    .label LCROM	= $8800			//	Upper and lower case
    .label REVLCROM	= $8C00			//	Reversed upper and lower case
}


// VIC 6560/6561 Registers
.namespace vic
{
    .label VCSCRNX	= $9000			//	b7 = interlace  //	b6-0 = screen x-pos
    .label VCSCRNY	= $9001			//	b7-0 = screen y-pos
    .label VCCOLS	= $9002			//	b7 = screen address b9  //	b6-0 = screen cols
    .label VCROWS	= $9003			//	b7 = raster b0  //	b6-1 = screen rows  //	b0 = double-height chars
    .label VCRASTER	= $9004			//	b7-0 = raster b8-1
    .label VCSCRNAD	= $9005			//	b7-4 = screen address b15+b12-10    //	b3-0 = chargen address b15+b12-10
    .label VCPENX	= $9006			//	b7-0 = light pen analog x-position latch
    .label VCPENY	= $9007			//	b7-0 = light pen analog y-position latch
    .label VCJOYX	= $9008			//	b7-0 = joystick digital x-position latch
    .label VCJOYY	= $9009			//	b7-0 = joystick digital y-position latch
    .label VCSOUND1	= $900A			//	b7 = sound on   //	b6-0 = frequency (oscillator 1 - tone)
    .label VCSOUND2	= $900B			//	b7 = sound on   //	b6-0 = frequency (oscillator 2 - tone)
    .label VCSOUND3	= $900C			//	b7 = sound on   //	b6-0 = frequency (oscillator 3 - tone)
    .label VCNOISE	= $900D			//	b7 = sound on   //	b6-0 = frequency (oscillator 4 - noise)
    .label VCVOLUME	= $900E			//	b7-4 = aux colour   //	b3-0 = sound volume
    .label VCSCRNCO	= $900F			//	b7-4 = background colour    //	b3 = reverse mode   //	b2-0 = border colour
}


// VIA #1 6522 Registers
.namespace via1
{
    .label V1PORTBO	= $9110			//	port B output register
    .label V1PORTAO	= $9111			//	port A output register
    .label V1PORTBD	= $9112			//	data direction register B
    .label V1PORTAD	= $9113			//	data direction register A
    .label V1T1LL	= $9114			//	timer #1 low byte latch
    .label V1T1LH	= $9115			//	timer #1 high byte latch
    .label V1T1CL	= $9116			//	timer #1 low byte counter
    .label V1T1CH	= $9117			//	timer #1 high byte counter
    .label V1T2LL	= $9118			//	timer #2 low byte latch
    .label V1T2LH	= $9119			//	timer #2 high byte latch
    .label V1SR		= $911A			//	shift register
    .label V1ACR	= $911B			//	auxiliary control register
    .label V1PCR	= $911C			//	peripheral control register
    .label V1IFR	= $911D			//	interrupt flag register
    .label V1IER	= $911E			//	interrupt enable register
    .label V1PORTAS	= $911F			//	port A (sense cassette switch)
}


// VIA #2 6522 Registers
.namespace via2
{
    .label V2PORTBO	= $9120			//	port B output register
    .label V2PORTAO	= $9121			//	port A output register
    .label V2PORTBD	= $9122			//	data direction register B
    .label V2PORTAD	= $9123			//	data direction register A
    .label V2T1LL	= $9124			//	timer #1 low byte latch
    .label V2T1LH	= $9125			//	timer #1 high byte latch
    .label V2T1CL	= $9126			//	timer #1 low byte counter
    .label V2T1CH	= $9127			//	timer #1 high byte counter
    .label V2T2LL	= $9128			//	timer #2 low byte latch
    .label V2T2LH	= $9129			//	timer #2 high byte latch
    .label V2SR		= $912A			//	shift register
    .label V2ACR	= $912B			//	auxiliary control register
    .label V2PCR	= $912C			//	peripheral control register
    .label V2IFR	= $912D			//	interrupt flag register
    .label V2IER	= $912E			//	interrupt enable register
    .label V2PORTAS	= $912F			//	port A output register
}


// 4-bit colour RAM
.namespace colour_ram
{
    .label COLOUR1	= $9400			//	colour matrix 1
    .label COLOUR2	= $9600			//	colour matrix 2
}


// Unmapped memory addresses
.namespace unmapped
{
    .label UNMAPPED	= $9800			//	2048 bytes unmapped
}


// Expansion RAM Block (BLK5) / Expansion ROM Vectors
.namespace cartridge
{
    .label RAMBLK5	= $A000			//	8K expansion RAM block (BLK5)
    .label EXPCART	= $A000			//	8K expansion ROM cart identifier
    .label CARTCOLD	= $A005			//	expansion ROM cart cold-start vector
    .label CARTWARM	= $A007			//	expansion ROM cart warm-start vector
    .label CARTDATA	= $A009			//	expansion ROM payload
}


// OS BASIC ROM
.namespace basic
{
    .label BASICCLD	= $C000			//	Basic Cold Restart vector
    .label BASICWRM	= $C002			//	Basic Warm Restart vector
    .label CBMBASIC	= $C004			//	DATA 'CBMBASIC' (text)
    .label STMDSP	= $C00C			//	BASIC Command Vectors WORD
    .label FUNDSP	= $C052			//	BASIC Function Vectors WORD
    .label OPTAB	= $C080			//	BASIC Operator Vectors WORD
    .label RESLST	= $C09E			//	BASIC Command Keyword Table DATA
    .label MSCLST	= $C129			//	BASIC Misc. Keyword Table DATA
    .label OPLIST	= $C140			//	BASIC Operator Keyword Table DATA
    .label FUNLST	= $C14D			//	BASIC Function Keyword Table DATA
    .label ERRTAB	= $C19E			//	Error Message Table DATA
    .label ERRPTR	= $C328			//	Error Message Pointers WORD
    .label OKK		= $C364			//	Misc. Messages DATA
    .label UNUSED7	= $C389			//	byte DATA
    .label FNDFOR	= $C38A			//	Find FOR/GOSUB Entry on Stack
    .label BLTU		= $C3B8			//	Open Space in Memory
    .label GETSTK	= $C3FB			//	Check Stack Depth
    .label CHKMEM	= $C408			//	Check Memory Overlap
    .label OMERR	= $C435			//	Output ?OUT OF MEMORY Error
    .label ERROR	= $C437			//	Error Routine
    .label ERRFIN	= $C469			//	Break Entry
    .label READY	= $C474			//	Restart BASIC
    .label MAIN		= $C480			//	Input & Identify BASIC Line
    .label MAIN1	= $C49C			//	Get Line Number & Tokenise Text
    .label INSLIN	= $C4A2			//	Insert BASIC Text
    .label LINKPRG	= $C533			//	Rechain Lines
    .label INLIN	= $C560			//	Input Line Into Buffer
    .label CRUNCH	= $C579			//	Tokenise Input Buffer
    .label FNDLIN	= $C613			//	Search for Line Number
    .label SCRTCH	= $C642			//	Perform [new]
    .label SCRTCH2	= $C644			//	Perform [new] without syntax check
    .label SCRTCH3	= $C647			//	Perform [new] without clearing .A/.Y first
    .label CLEAR	= $C65E			//	Perform [clr]
    .label EXECPTR	= $C68E			//	Reset BASIC execute pointer
    .label LIST		= $C69C			//	Perform [list]
    .label QPLOP	= $C717			//	Handle LIST Character
    .label FOR		= $C742			//	Perform [for]
    .label NEWSTT	= $C7AE			//	BASIC Warm Start
    .label CKEOL	= $C7C4			//	Check End of Program
    .label BASEXVEC	= $C7E1			//	BASIC keyword execution vector
    .label BASICGET	= $C7E4			//	Get BASIC keyword
    .label BASICEX	= $C7ED			//	Execute BASIC keyword
    .label RESTOR	= $C81D			//	Perform [restore]
    .label STOP		= $C82C			//	Perform [stop], [end], break
    .label CONT		= $C857			//	Perform [cont]
    .label RUN		= $C871			//	Perform [run]
    .label GOSUB	= $C883			//	Perform [gosub]
    .label GOTO		= $C8A0			//	Perform [goto]
    .label RETURN	= $C8D2			//	Perform [return]
    .label DATA		= $C8F8			//	Perform [data]
    .label DATAN	= $C906			//	Search for Next Statement / Line
    .label IF	 	= $C928			//	Perform [if]
    .label REM		= $C93B			//	Perform [rem]
    .label ONGOTO	= $C94B			//	Perform [on]
    .label LINGET	= $C96B			//	Fetch linnum From BASIC
    .label LET		= $C9A5			//	Perform [let]
    .label PUTINT	= $C9C4			//	Assign Integer
    .label PTFLPT	= $C9D6			//	Assign Floating Point
    .label PUTSTR	= $C9D9			//	Assign String
    .label PUTTIM	= $C9E3			//	Assign TI$
    .label GETSPT	= $CA2C			//	Add Digit to FAC#1
    .label PRINTN	= $CA80			//	Perform [print#]
    .label CMD		= $CA86			//	Perform [cmd]
    .label STRDON	= $CA9A			//	Print String From Memory
    .label PRINT	= $CAA0			//	Perform [print]
    .label VAROP	= $CAB8			//	Output Variable
    .label CRDO		= $CAD7			//	Output CR/LF
    .label COMPRT	= $CAE8			//	Handle comma, TAB(, SPC(
    .label STROUT	= $CB1E			//	Output String
    .label OUTSPC	= $CB3B			//	Output Format Character
    .label DOAGIN	= $CB4D			//	Handle Bad Data
    .label GET		= $CB7B			//	Perform [get]
    .label INPUTN	= $CBA5			//	Perform [input#]
    .label INPUT	= $CBBF			//	Perform [input]
    .label BUFFUL	= $CBEA			//	Read Input Buffer
    .label QINLIN	= $CBF9			//	Do Input Prompt
    .label READ		= $CC06			//	Perform [read]
    .label RDGET	= $CC35			//	General Purpose Read Routine
    .label EXINT	= $CCFC			//	Input Error Messages DATA
    .label NEXT		= $CD1E			//	Perform [next]
    .label DONEXT	= $CD61			//	Check Valid Loop
    .label FRMNUM	= $CD8A			//	Confirm Result
    .label FRMEVL	= $CD9E			//	Evaluate Expression in Text
    .label EVAL		= $CE83			//	Evaluate Single Term
    .label PIVAL	= $CEA8			//	Constant - pi DATA
    .label QDOT		= $CEAD			//	Continue Expression
    .label PARCHK	= $CEF1			//	Expression in Brackets
    .label CHKRPAR	= $CEF7			//	Scan for ')'
    .label CHKLPAR	= $CEFA			//	Scan for '('
    .label CHKCOMMA	= $CEFD			//	Scan for ','
    .label SYNERR	= $CF08			//	Output ?SYNTAX Error
    .label DOMIN	= $CF0D			//	Set up NOT Function
    .label RSVVAR	= $CF14			//	Identify Reserved Variable
    .label ISVAR	= $CF28			//	Search for Variable
    .label TISASC	= $CF48			//	Convert TI to ASCII String
    .label ISFUN	= $CFA7			//	Identify Function Type
    .label STRFUN	= $CFB1			//	Evaluate String Function
    .label NUMFUN	= $CFD1			//	Evaluate Numeric Function
    .label OROP		= $CFE6			//	Perform [or], [and]
    .label DOREL	= $D016			//	Perform <, =, >
    .label NUMREL	= $D01B			//	Numeric Comparison
    .label STRREL	= $D02E			//	String Comparison
    .label DIM		= $D07E			//	Perform [dim]
    .label PTRGET	= $D08B			//	Identify Variable
    .label ORDVAR	= $D0E7			//	Locate Ordinary Variable
    .label NOTFNS	= $D11D			//	Create New Variable
    .label NOTEVL	= $D128			//	Create Variable
    .label ARYGET	= $D194			//	Allocate Array Pointer Space
    .label N32768	= $D1A5			//	Constant 32768 in Flpt DATA
    .label FACINX	= $D1AA			//	FAC#1 to Integer in (AC/YR)
    .label INTIDX	= $D1B2			//	Evaluate Text for Integer
    .label AYINT	= $D1BF			//	FAC#1 to Positive Integer
    .label ISARY	= $D1D1			//	Get Array Parameters
    .label FNDARY	= $D218			//	Find Array
    .label BSERR	= $D245			//	'?bad subscript error'
    .label ILLEGAL	= $D248			//	'?illegal quantity error'
    .label NOTFDD	= $D261			//	Create Array
    .label INLPN2	= $D30E			//	Locate Element in Array
    .label UMULT	= $D34C			//	Number of Bytes in Subscript
    .label FRE		= $D37D			//	Perform [fre]
    .label GIVAYF	= $D391			//	Convert Integer in (AC/YR) to Flpt
    .label POS		= $D39E			//	Perform [pos]
    .label NODIRECT	= $D3A6			//	Confirm Program Mode (return ?ILLEGAL DIRECT if not)
    .label GETFNM	= $D3E1			//	Check Syntax of FN
    .label FNDOER	= $D3F4			//	Perform [fn]
    .label STRD		= $D465			//	Perform [str$]
    .label STRLIT	= $D487			//	Set Up String
    .label PUTNW1	= $D4D5			//	Save String Descriptor
    .label GETSPA	= $D4F4			//	Allocate Space for String
    .label GARBAG	= $D526			//	Garbage Collection
    .label DVARS	= $D5BD			//	Search for Next String
    .label GRBPAS	= $D606			//	Collect a String
    .label CAT		= $D63D			//	Concatenate Two Strings
    .label MOVINS	= $D67A			//	Store String in High RAM
    .label FRESTR	= $D6A3			//	Perform String Housekeeping
    .label FREFAC	= $D6DB			//	Clean Descriptor Stack
    .label CHRD		= $D6EC			//	Perform [chr$]
    .label LEFTD	= $D700			//	Perform [left$]
    .label RIGHTD	= $D72C			//	Perform [right$]
    .label MIDD		= $D737			//	Perform [mid$]
    .label PREAM	= $D761			//	Pull sTring Parameters
    .label LEN		= $D77C			//	Perform [len]
    .label LEN1		= $D782			//	Exit String Mode
    .label ASC		= $D78B			//	Perform [asc]
    .label GETBYTE	= $D79B			//	Scan and get byte
    .label CHECKNUM	= $D79E			//	Check expression is numeric
    .label VAL		= $D7AD			//	Perform [val]
    .label STRVAL	= $D7B5			//	Convert ASCII String to Flpt
    .label GETNUM	= $D7EB			//	Get parameters for POKE/WAIT
    .label GETADR	= $D7F7			//	Convert FAC#1 to Integer in LINNUM
    .label PEEK		= $D80D			//	Perform [peek]
    .label POKE		= $D824			//	Perform [poke]
    .label WAIT		= $D82D			//	Perform [wait]
    .label FADDH	= $D849			//	Add 0.5 to FAC#1
    .label FSUB		= $D850			//	Perform Subtraction
    .label FADD5	= $D862			//	Normalise Addition
    .label FADD		= $D867			//	Perform Addition
    .label NEGFAC	= $D947			//	2's Complement FAC#1
    .label OVERR	= $D97E			//	Output ?OVERFLOW Error
    .label MULSHF	= $D983			//	Multiply by Zero Byte
    .label FONE		= $D9BC			//	Table of Flpt Constants DATA
    .label LOG		= $D9EA			//	Perform [log]
    .label FMULT	= $DA28			//	Perform Multiply
    .label MULPLY	= $DA59			//	Multiply by a Byte
    .label CONUPK	= $DA8C			//	Load FAC#2 From Memory
    .label MULDIV	= $DAB7			//	Test Both Accumulators
    .label MLDVEX	= $DAD4			//	Overflow / Underflow
    .label MUL10	= $DAE2			//	Multiply FAC#1 by 10
    .label TENC		= $DAF9			//	Constant 10 in Flpt DATA
    .label DIV10	= $DAFE			//	Divide FAC#1 by 10
    .label FDIV		= $DB07			//	Divide FAC#2 by Flpt at (AC/YR)
    .label FDIVT	= $DB0F			//	Divide FAC#2 by FAC#1
    .label MOVFM	= $DBA2			//	Load FAC#1 From Memory
    .label MOV2F	= $DBC7			//	Store FAC#1 in Memory
    .label MOVFA	= $DBFC			//	Copy FAC#2 into FAC#1
    .label MOVAF	= $DC0C			//	Copy FAC#1 into FAC#2
    .label ROUND	= $DC1B			//	Round FAC#1
    .label SIGN		= $DC2B			//	Check Sign of FAC#1
    .label SGN		= $DC39			//	Perform [sgn]
    .label ABS		= $DC58			//	Perform [abs]
    .label FCOMP	= $DC5B			//	Compare FAC#1 With Memory
    .label QINT		= $DC9B			//	Convert FAC#1 to Integer
    .label INT		= $DCCC			//	Perform [int]
    .label FIN		= $DCF3			//	Convert ASCII String to a Number in FAC#1
    .label N0999	= $DDB3			//	String Conversion Constants DATA
    .label INPRT	= $DDC2			//	Output 'IN' and Line Number
    .label PRINTXA	= $DDCD			//	Print XA as unsigned integer
    .label FOUT		= $DDDD			//	Convert FAC#1 to ASCII String
    .label FOUTIM	= $DE68			//	Convert TI to String
    .label FHALF	= $DF11			//	Table of Constants DATA
    .label SQR		= $DF71			//	Perform [sqr]
    .label FPWRT	= $DF7B			//	Perform power ($)
    .label NEGOP	= $DFB4			//	Negate FAC#1
    .label LOGEB2	= $DFBF			//	Table of Constants DATA
    .label EXP		= $DFED			//	Perform [exp]
    .label POLYX	= $E040			//	Series Evaluation
    .label RMULC	= $E08A			//	Constants for RND DATA
    .label RND		= $E094			//	Perform [rnd]
    .label BIOERR	= $E0F6			//	Handle I/O Error in BASIC
    .label BCHOUT	= $E109			//	Output Character
    .label BCHIN	= $E10F			//	Input Character
    .label BCKOUT	= $E115			//	Set Up For Output
    .label BCKIN	= $E11B			//	Set Up For Input
    .label BGETIN	= $E121			//	Get One Character
    .label SYS		= $E127			//	Perform [sys]
    .label SAVET	= $E153			//	Perform [save]
    .label VERFYT	= $E162			//	Perform [verify / load]
    .label OPENT	= $E1BB			//	Perform [open]
    .label CLOSET	= $E1C4			//	Perform [close]
    .label SLPARA	= $E1D1			//	Get Parameters For LOAD/SAVE
    .label COMBYT	= $E1FD			//	Get Next One Byte Parameter
    .label DEFLT	= $E203			//	Check Default Parameters
    .label CMMERR	= $E20B			//	Check For Comma
    .label OCPARA	= $E216			//	Get Parameters For OPEN/CLOSE
    .label COS		= $E261			//	Perform [cos]
    .label SIN		= $E268			//	Perform [sin]
    .label TAN		= $E2B1			//	Perform [tan]
    .label PI2		= $E2DD			//	Table of Trig Constants DATA
    .label ATN		= $E30B			//	Perform [atn]
    .label ATNCON	= $E33B			//	Table of ATN Constants DATA
    .label INIT		= $E378			//	BASIC Cold Start
    .label INIT2    = $E37B         //  BASIC Lukewarm Start (no vector init)
    .label INITTS	= $E381			//	BASIC Tepid Start (no vector/ZP init or messages)
    .label INITAT	= $E387			//	CHRGET For Zero-page
    .label RNDSED	= $E39F			//	RND Seed For zero-page DATA
    .label INITZP	= $E3A4			//	Initialize BASIC zero-page (mostly) RAM
    .label INITMEM	= $E404			//	Check memory, output startup messsages, reset BASIC pointers
    .label INITMEM2 = $E412         //  Second entry point, no memory check or CBM message
    .label BYTEFREE	= $E429			//	Power-Up Message DATA ("BYTES FREE")
    .label BASICV2	= $E437			//	Power-Up Message DATA ("CBM BASIC V2")
    .label BVTRS	= $E44F			//	Table of BASIC Vectors (for 0300) WORD
    .label INITBASV	= $E45B			//	Initialize BASIC Vectors
    .label BASRESET	= $E467			//	BASIC Warm Restart [RUNSTOP-RESTORE]
    .label UNKNOWN4	= $E475			//	Unknown
    .label UNUSED8	= $E47C			//	Unused Bytes For Future Patches EMPTY
}


// OS KERNAL ROM
.namespace kernal
{
    .label SOUTPUT1	= $E4A0			//	Serial Output 1
    .label SOUTPUT2	= $E4A9			//	Serial Output 0
    .label GETSDATA	= $E4B2			//	Get Serial Data And Clock In
    .label GETSALV	= $E4BC			//	Get Secondary Address patch for Serial LOAD/VERIFY
    .label RELLOAD	= $E4C1			//	Relocated Load patch for Serial LOAD/VERIFY
    .label TAPWRITE	= $E4CF			//	Tape Write patch for CLOSE
    .label UNUSED9	= $E4DA			//	Unused EMPTY
    .label IOBASE	= $E500			//	Return I/O Base Address
    .label SCRNORG	= $E505			//	Return Screen Organization
    .label PLOT		= $E50A			//	Read / Set Cursor X/Y Position
    .label INITSCRN	= $E518			//	Initialize screen display
    .label CLRSCRN	= $E55F			//	Clear Screen
    .label CSRHOME	= $E581			//	Home Cursor
    .label SETSCRP	= $E587			//	Set Screen Pointers
    .label SETIODFU	= $E5B5			//	Set I/O Defaults (Unused Entry)
    .label SETIODEF	= $E5BB			//	Set I/O Defaults
    .label INITVIC	= $E5C3			//	Initialise VIC
    .label GETCHAR	= $E5CF			//	Get Character From Keyboard Buffer
    .label INKEY	= $E5E5			//	Input From Keyboard
    .label INSCKEY	= $E64F			//	Input From Screen or Keyboard
    .label FLIPQUOT	= $E6B8			//	Toggle quote-mode flag
    .label SETSPRNT	= $E6C5			//	Set Up Screen Print
    .label INSCHAR	= $E6C7			//	Insert uppercase/graphic character
    .label INSRCHAR	= $E6CB			//	Insert reversed uppercase/graphic character
    .label RESREGS	= $E6DC			//	Restore registers and set quote flag
    .label ADVCRSR	= $E6EA			//	Advance Cursor
    .label RETCRSR	= $E719			//	Retreat Cursor
    .label BACKLINE	= $E72D			//	Back on to Previous Line
    .label SCRNOUT	= $E742			//	Output to Screen
    .label UCHAROUT	= $E756			//	Unshifted character output
    .label SCHAROUT	= $E800			//	Shifted character output
    .label GONXTLN	= $E8C3			//	Go to Next Line
    .label OUTPUTCR	= $E8D8			//	Output <CR>
    .label CHKLNDEC	= $E8E8			//	Check Line Decrement
    .label CHKLNINC	= $E8FA			//	Check Line Increment
    .label SETCOLCD	= $E912			//	Convert Colour Code to Screen Code
    .label COLRTAB	= $E921			//	Colour Code Table DATA
    .label UNUSED10	= $E929			//	Unused - redundant code conversion table?
    .label SCROLL	= $E975			//	Scroll Screen
    .label MAKESPC	= $E9EE			//	Open A Space On The Screen
    .label MOVELINE	= $EA56			//	Move A Screen Line
    .label SYNCCOLR	= $EA6E			//	Syncronise Colour Transfer
    .label STARTLN	= $EA7E			//	Set Start of Line
    .label CLRLINE	= $EA8D			//	Clear Screen Line
    .label PRTSCRN	= $EAA1			//	Print To Screen
    .label SAVECHAR	= $EAAA			//	Save character and colour to screen @ cursor
    .label SYNCPTR	= $EAB2			//	Syncronise Colour Pointer
    .label IRQ	    = $EABF			//	Main IRQ Entry Point
    .label IRQTAPE	= $EAEF			//	Main IRQ Tape Entry Point
    .label IRQEXIT	= $EB15			//	IRQ Exit
    .label SCNKEY	= $EB1E			//	Scan Keyboard
    .label SCNKEY2	= $EB74			//	Keyboard scan logic (check for key repeat)
    .label STOPKEY	= $EBD6			//	Enable VIA for RUN/STOP key
    .label DECODE	= $EBDC			//	SHIFT/CTRL/C= key decode logic
    .label DECODE2J	= $EBF8			//	JiffyDOS ROM entry after SHIFT/C= logic
    .label DECODE2	= $EC0F			//	Stock ROM entry after SHIFT/C= logic
    .label KEYTAB1	= $EC46			//	Pointers to Keyboard decoding tables WORD
    .label KEYTAB2	= $EC5E			//	Keyboard Decoding Table - Unshifted DATA
    .label KEYTAB3	= $EC9F			//	Keyboard Decoding Table - Shifted DATA
    .label KEYTAB4	= $ECE0			//	Keyboard Decoding Table - Commodore DATA
    .label GRAPHTXT	= $ED21			//	Graphics/Text Control
    .label KEYTAB5	= $ED69			//	Keyboard Decoding Table DATA
    .label KEYTAB6	= $EDA3			//	Keyboard Decoding Table - Control DATA
    .label VICTAB	= $EDE4			//	Video Chip Set Up Table DATA
    .label SHIFTTAB	= $EDF4			//	Shift-Run Equivalent DATA
    .label SCRNTAB	= $EDFD			//	Low Byte Screen Line Addresses DATA
    .label TALK		= $EE14			//	Send TALK Command on Serial Bus
    .label LISTN	= $EE17			//	Send LISTEN Command on Serial Bus
    .label SENDSER	= $EE49			//	Send Data On Serial Bus
    .label FLGERR80	= $EEB4			//	Flag Error #80 - device not present
    .label FLGERR03	= $EEB7			//	Flag Error #03 - write timeout
    .label SECOND	= $EEC0			//	Send LISTEN Secondary Address
    .label CLRATN	= $EEC5			//	Clear ATN
    .label TKSA		= $EECE			//	Send TALK Secondary Address
    .label WAITCLK	= $EED3			//	Wait For Clock
    .label CIOUT	= $EEE4			//	Send Serial Deferred
    .label UNTLK	= $EEF6			//	Send UNTALK on Serial Bus
    .label UNLSN	= $EF04			//	Send UNLISTEN on Serial Bus
    .label ACPTR	= $EF19			//	Receive From Serial Bus
    .label CLKON	= $EF84			//	Serial Clock On
    .label CLKOFF	= $EF8D			//	Serial Clock Off
    .label WAIT1MS	= $EF96			//	Delay 1 ms
    .label RS232SND	= $EFA3			//	RS-232 Send
    .label RS232SNB	= $EFEE			//	Send New RS-232 Byte
    .label NODSR	= $F016			//	'No DSR' Error
    .label NOCTS	= $F019			//	'No CTS' Error
    .label TIMEROFF	= $F021			//	Disable Timer
    .label BITCNT	= $F027			//	Compute Bit Count
    .label RS232RCV	= $F036			//	RS-232 Receive
    .label RS232STR	= $F05B			//	Set Up To Receive
    .label PROCBYTE	= $F068			//	Process RS-232 Byte
    .label RS232SUB	= $F0BC			//	Submit to RS-232
    .label RS232BUF	= $F0ED			//	Send to RS-232 Buffer
    .label RS232IN	= $F116			//	Input From RS-232
    .label RS232GET	= $F14F			//	Get From RS-232
    .label SBIDLE	= $F160			//	Serial Bus Idle
    .label IOMSGTAB	= $F174			//	Table of Kernal I/O Messages DATA
    .label PRNTMSGD	= $F1E2			//	Print Message if Direct
    .label PRNTMSG	= $F1E6			//	Print Message
    .label GETIN	= $F1F5			//	Get a byte
    .label CHRIN	= $F20E			//	Input a byte
    .label CHRIN2	= $F22A			//	Input from device other than keyboard or screen
    .label GETTSR	= $F250			//	Get From Tape / Serial / RS-232
    .label CHROUT	= $F27A			//	Output One Character
    .label CHROUT2	= $F285			//	Output to device other than screen
    .label CHKIN	= $F2C7			//	Set Input Device
    .label CHKOUT	= $F309			//	Set Output Devic
    .label CLOSE	= $F34A			//	Close File
    .label FINDFILE	= $F3CF			//	Find File
    .label SETFILE	= $F3DF			//	Set File values
    .label CLALL	= $F3EF			//	Abort All Files
    .label CLRCHN	= $F3F3			//	Restore Default I/O
    .label OPEN		= $F40A			//	Open File
    .label SENDSA	= $F495			//	Send Secondary Address
    .label RS232OPN	= $F4C7			//	Open RS-232
    .label LOAD		= $F542			//	Load RAM From Device
    .label LOAD2	= $F549			//	-load-
    .label LOADSB	= $F55C			//	Load File From Serial Bus
    .label LOADTAP	= $F5CA			//	Load File From Tape
    .label PRNTSRCH	= $F647			//	Print SEARCHING
    .label PRNTNAME	= $F659			//	Print Filename
    .label PRNTACTN	= $F66A			//	Print LOADING / VERIFYING
    .label SAVE		= $F675			//	Save RAM To Device
    .label SAVE2	= $F685			//	-save-
    .label SAVESB	= $F692			//	Save to Serial Bus
    .label SAVETAP	= $F6F1			//	Save to Tape
    .label PRNTSAVE	= $F728			//	Print SAVING
    .label UDTIM	= $F734			//	Increment Real-Time Clock
    .label RDTIM	= $F760			//	Read Real-Time Clock
    .label SETTIM	= $F767			//	Set Real-Time Clock
    .label CHKSTOP	= $F770			//	Check STOP Key
    .label IOERR1	= $F77E			//	Too many files'
    .label IOERR2	= $F781			//	File open'
    .label IOERR3	= $F784			//	File not open'
    .label IOERR4	= $F787			//	File not found'
    .label IOERR5	= $F78A			//	Device not present'
    .label IOERR6	= $F78D			//	Not input file'
    .label IOERR7	= $F790			//	Not output file'
    .label IOERR8	= $F793			//	Missing filename'
    .label IOERR9	= $F796			//	Illegal device number'
    .label FATAPHDR	= $F7AF			//	Find Any Tape Header
    .label WTAPHDR	= $F7E7			//	Write Tape Header
    .label GETBUFAD	= $F84D			//	Get Buffer Address
    .label SETBUFPT	= $F854			//	Set Buffer Start / End Pointers
    .label FSTAPHDR	= $F867			//	Find Specific Tape Header
    .label BUMPTPTR	= $F88A			//	Bump Tape Pointer
    .label PRNTPLAY	= $F894			//	Print PRESS PLAY ON TAPE
    .label CHKTSTAT	= $F8AB			//	Check Tape Status
    .label PRNTRECD	= $F8B7			//	Print PRESS RECORD...
    .label INITTR	= $F8C0			//	Initiate Tape Read
    .label INITTW	= $F8E3			//	Initiate Tape Write
    .label COMNTAPE	= $F8F4			//	Common Tape Code
    .label CHKTSTOP	= $F94B			//	Check Tape Stop
    .label SETRTIMG	= $F95D			//	Set Read Timing
    .label READBITS	= $F98E			//	Read Tape Bits
    .label STORTCHR	= $FAAD			//	Store Tape Characters
    .label RESTPTR	= $FBD2			//	Reset Tape Pointer
    .label NEWCHAR	= $FBDB			//	New Character Setup
    .label SENDTONE	= $FBEA			//	Send Tone to Tape
    .label WRTDATA	= $FC06			//	Write Data to Tape
    .label WRTAPLDR	= $FC95			//	Write Tape Leader
    .label RESETIRQ	= $FCCF			//	Restore Normal IRQ
    .label SETIRQ	= $FCF6			//	Set IRQ Vector
    .label KILLMOTR	= $FD08			//	Kill Tape Motor
    .label CHKRWPTR	= $FD11			//	Check Read / Write Pointer
    .label BMPRWPTR	= $FD1B			//	Bump Read / Write Pointer
    .label RESET	= $FD22			//	Power-Up RESET entry
    .label RESET2	= $FD2F			//	Power-Up RESET after cartridge check
    .label RESET3	= $FD32			//	Power-Up RESET after RAM test
    .label CHKA0CBM	= $FD3F			//	Check For A-ROM
    .label A0CBM	= $FD4D			//	ROM Mask 'a0CBM' DATA
    .label RESKVEC	= $FD52			//	Restore Kernal Vectors (at 0314)
    .label VECTOR	= $FD57			//	Change Vectors For User
    .label RESETVEC	= $FD6D			//	Kernal Reset Vectors WORD
    .label RAMTAS	= $FD8D			//	Initialise System Constants
    .label TAPEIRQ	= $FDF1			//	IRQ Vectors For Tape I/O WORD
    .label INITIO	= $FDF9			//	Initialise I/O
    .label ENTIMER	= $FE39			//	Enable Timer
    .label SETNAM	= $FE49			//	Set Filename
    .label SETLFS	= $FE50			//	Set Logical File Parameters
    .label READSS	= $FE57			//	Get I/O Status Word
    .label SETMSG	= $FE66			//	Control OS Messages
    .label SETTMO	= $FE6F			//	Set IEEE Timeout
    .label MEMTOP	= $FE73			//	Set / Read Top of Memory
    .label MEMBOT	= $FE82			//	Set / Read Bottom of Memory
    .label NMIJUMP  = $FEA9			//	Commodore NMI vector jump
    .label NMI	    = $FEAD			//	Commodore NMI handler
    .label NMINOA0	= $FEC7			//	Commodore NMI handler (when no ROM at $A000)
    .label WRMSTART	= $FED2			//	Start Basic [BRK]
    .label INTEXIT	= $FF56			//	Interrupt exit
    .label RS232TAB	= $FF5B			//	Timing Table DATA
    .label CBMIRQ	= $FF72			//	Commodore IRQ/BRK handler
    .label JMPTAB1	= $FF8A			//	$fd52 restor Restore Vectors
    .label JMPTAB2	= $FF8D			//	$fd57 vector Change Vectors For User
    .label JMPTAB3	= $FF90			//	$fe66 setmsg Control OS Messages
    .label JMPTAB4	= $FF93			//	$eec0 secnd Send SA After Listen
    .label JMPTAB5	= $FF96			//	$eece tksa Send SA After Talk
    .label JMPTAB6	= $FF99			//	$fe73 memtop Set/Read System RAM Top
    .label JMPTAB7	= $FF9C			//	$fe82 membot Set/Read System RAM Bottom
    .label JMPTAB8	= $FF9F			//	$eb1e scnkey Scan Keyboard
    .label JMPTAB9	= $FFA2			//	$fe6f settmo Set Timeout In IEEE
    .label JMPTAB10	= $FFA5			//	$ef19 acptr Handshake Serial Byte In
    .label JMPTAB11	= $FFA8			//	$eee4 ciout Handshake Serial Byte Out
    .label JMPTAB12	= $FFAB			//	$eef6 untalk Command Serial Bus UNTALK
    .label JMPTAB13	= $FFAE			//	$ef04 unlsn Command Serial Bus UNLISTEN
    .label JMPTAB14	= $FFB1			//	$ee17 listn Command Serial Bus LISTEN
    .label JMPTAB15	= $FFB4			//	$ee14 talk Command Serial Bus TALK
    .label JMPTAB16	= $FFB7			//	$fe57 readss Read I/O Status Word
    .label JMPTAB17	= $FFBA			//	$fe50 setlfs Set Logical File Parameters
    .label JMPTAB18	= $FFBD			//	$fe49 setnam Set Filename
    .label JMPTAB19	= $FFC0			//	($031a) (iopen) Open Vector [F40A]
    .label JMPTAB20	= $FFC3			//	($031c) (iclose) Close Vector [F34A]
    .label JMPTAB21	= $FFC6			//	($031e) (ichkin) Set Input [F2C7]
    .label JMPTAB22	= $FFC9			//	($0320) (ichkout) Set Output [F309]
    .label JMPTAB23	= $FFCC			//	($0322) (iclrch) Restore I/O Vector [F353]
    .label JMPTAB24	= $FFCF			//	($0324) (ichrin) Input Vector, chrin [F20E]
    .label JMPTAB25	= $FFD2			//	($0326) (ichrout) Output Vector, chrout [F27A]
    .label JMPTAB26	= $FFD5			//	$f542 load Load RAM From Device
    .label JMPTAB27	= $FFD8			//	$f675 save Save RAM To Device
    .label JMPTAB28	= $FFDB			//	$f767 settim Set Real-Time Clock
    .label JMPTAB29	= $FFDE			//	$f760 rdtim Read Real-Time Clock
    .label JMPTAB30	= $FFE1			//	($0328) (istop) Test-Stop Vector [F770]
    .label JMPTAB31	= $FFE4			//	($032a) (igetin) Get From Keyboad [F1F5]
    .label JMPTAB32	= $FFE7			//	($032c) (iclall) Close All Channels And Files [F3EF]
    .label JMPUDTIM	= $FFEA			//	$f734 udtim Increment Real-Time Clock
    .label JMPTAB34	= $FFED			//	$e505 screen Return Screen Organization
    .label JMPTAB35	= $FFF0			//	$e50a plot Read / Set Cursor X/Y Position
    .label JMPTAB36	= $FFF3			//	$e500 iobase Return I/O Base Address
    .label JMPTAB37	= $FFF6			//	Unused
    .label CPUNMI	= $FFFA			//	CPU non-maskable interrupt vector [FEA9]
    .label CPURES	= $FFFC			//	CPU cold-start reset vector [FD22]
    .label CPUIRQ	= $FFFE			//	CPU interrupt request vector [FF72]
}
