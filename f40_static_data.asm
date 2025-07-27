// FAST-40 ROM data structures
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_static_data

RAMCODE:
.pc = * "RAMCODE"		// 23-byte self-modifying bitmap merge routine (copied to RAM at runtime) [AY]
.pseudopc f40_runtime_memory.MERGROUT						// Assemble for target RAM address
{
			lda $FFFF,y										// [4]		get character glyph data byte
			and f40_runtime_memory.CRSRMASK					// [3]		apply character mask
			sta mergebit+1									// [4]		modify character/bitmap merge byte
			lda (f40_runtime_memory.CRSRBITL),y				// [5]		indirect get bitmap byte
			and #$FF										// [3]		apply screen bitmap mask
mergebit:	ora #$FF										// [2]		merge glyph byte with bitmap byte
			sta (f40_runtime_memory.CRSRBITL),y				// [6]		indirect set bitmap byte
			dey												// [2]		decrement glyph byte counter
			bpl f40_runtime_memory.MERGROUT					// [3/2]	loop for next glyph byte
			jmp f40_character_output.line_continuation		// [3]		jump to line continuation logic
}

CONCODEC:
.pc = * "CONCODEC"		// CHROUT control character codes (sorted in ascending likely-usage-frequency order)
.byte vic20.screencodes.NULL,vic20.screencodes.F1,vic20.screencodes.F2,vic20.screencodes.F3
.byte vic20.screencodes.F4,vic20.screencodes.F5,vic20.screencodes.F6,vic20.screencodes.F7
.byte vic20.screencodes.F8,vic20.screencodes.RUNSTOP,vic20.screencodes.LF,vic20.screencodes.CBMOFF
.byte vic20.screencodes.CBMON,vic20.screencodes.SHIFTCR,vic20.screencodes.CRSRHOME,vic20.screencodes.UCASE
.byte vic20.screencodes.LCASE,vic20.screencodes.RVSOFF,vic20.screencodes.RVSON,vic20.screencodes.RED
.byte vic20.screencodes.WHITE,vic20.screencodes.PURPLE,vic20.screencodes.YELLOW,vic20.screencodes.CYAN
.byte vic20.screencodes.BLACK,vic20.screencodes.GREEN,vic20.screencodes.BLUE,vic20.screencodes.INSERT
.byte vic20.screencodes.CLRSCRN,vic20.screencodes.CRSRDOWN,vic20.screencodes.CRSRLEFT,vic20.screencodes.CRSRRGHT
.byte vic20.screencodes.CRSRUP,vic20.screencodes.DELETE,vic20.screencodes.CR

CONCODEL:
.pc = * "CONCODEL"		// CHROUT control character handler address lo-bytes (all hi-bytes are the same)
.var concode_lo_bytes = List().add(
	<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,
	<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,
	<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.inactive_code,<f40_controlcode_handlers.shift_cbm,
	<f40_controlcode_handlers.shift_cbm,<f40_controlcode_handlers.carriage_return,<f40_controlcode_handlers.cursor_home,<f40_controlcode_handlers.switch_case,
	<f40_controlcode_handlers.switch_case,<f40_controlcode_handlers.rvs_mode,<f40_controlcode_handlers.rvs_mode,<f40_controlcode_handlers.set_colour_byte,
	<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.set_colour_byte,
	<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.set_colour_byte,<f40_controlcode_handlers.insert,
	<f40_controlcode_handlers.clear_screen,<f40_controlcode_handlers.cursor_down,<f40_controlcode_handlers.cursor_left,<f40_controlcode_handlers.cursor_right,
	<f40_controlcode_handlers.cursor_up,<f40_controlcode_handlers.delete,<f40_controlcode_handlers.carriage_return
)
.for(var i=0;i<concode_lo_bytes.size();i++)
{
	.byte concode_lo_bytes.get(i)-1		// Subtract 1 for RTS offset
}

TROWADD:
.pc = * "TROWADD"		// Text row address hi/lo bytes
TROWADDR:
.lohifill 24,f40_runtime_memory.Text_Buffer+(40*i)

CROWOFFS:				// Character row offsets
.pc = * "CROWOFFS"		// Character row offsets (13 bytes)
.byte 0,20,40,60,80,100,120,140,160,180,200,220,240

IDBUFFLO:				// InsDel buffer row start offset address lo-bytes
.pc = * "IDBUFFLO"		// Address lo-bytes (3 bytes)
.byte <f40_runtime_memory.InsDel_Buffer
.byte <f40_runtime_memory.InsDel_Buffer+40
.byte <f40_runtime_memory.InsDel_Buffer+80

SRSLOAD:				// SHIFT+RUNSTOP bytes for LOAD"$*",8 / LIST
.pc = * "SRSLOAD"		// Command text (13 bytes)
.byte 'L','O'+64		// LOAD
.text @"\"$\",8\$0d"	// "$",8 [CR]
.text @"LIST\$0d"		// LIST

SRSRUN:					// SHIFT+RUNSTOP bytes for RUN
.pc = * "SRSRUN"		// Command text (4 bytes)
.text @"RUN "

WEDGECMD:				// BASIC wedge command
.pc = * "WEDGECMD"		// Command text (5 bytes)
.text "RESET"

.fill 14,$aa 			// Spare bytes

IDMSG1:					// FAST-40 startup banner
.pc = * "IDMSG1"		// Startup banner message
.text @"** COMMODORE BASIC V2 **\$0d "
.byte vic20.screencodes.NULL
IDMSG2:
.byte vic20.screencodes.CR
IDMSG3:					// Must be followed by NULL (zero)
.byte vic20.screencodes.RED
.text @"FAST-40 1.1 (C) 2025 8BG\$0d\$0d"

// -------------------------------------------- PAGE ALIGNMENT --------------------------------------------

.align 256
BITADDRL:				// Character -> Screen_Bitmap 8x16 character address lo-bytes
.pc = * "BITADDRL"		// Character -> Screen_Bitmap 8x16 character address lo-byte table
.for(var x=0;x<15;x++)
{
	.for(var y=0;y<256;y+=16)
	{
		.byte y			// 16 * $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0
	}
}

// Primary Screen Matrix is 20x12 chars  ->  240 bytes at $1000-$10EF (double-height chars)
// Primary Colour Matrix is 20x12 chars  ->  240 bytes at $9600-$96EF (double-height chars)
// Primary Screen Screen_Bitmap is 160x192 bits -> 3840 bytes at $1100-$1FFF
VICNTSC:				// 6560 (NTSC) VIC initialisation data
.pc = * "VICNTSC"		// VIC register values
.byte %00000111			// $9000 - b7 = interlace; b6-0 = screen x-pos
.byte %00011001			// $9001 - b7-0 = screen y-pos
.byte %00010100			// $9002 - b7 = screen address b9; b6-0 = screen cols
.byte %00011001			// $9003 - b7 = raster b0; b6-1 = screen rows; b0 = double-height chars
.byte %00000000			// $9004 - b7-0 = raster b1-8
.byte %11001100			// $9005 - b7-4 = screen address b15+b12-10; b3-0 = chargen address b15+b12-10
.byte %00000000			// $9006 - b7-0 = light pen x-pos
.byte %00000000			// $9007 - b7-0 = light pen y-pos
.byte %00000000			// $9008 - b7-0 = paddle x-pos
.byte %00000000			// $9009 - b7-0 = paddle y-pos
.byte %00000000			// $900A - b7-0 = oscillator 1 frequency
.byte %00000000			// $900B - b7-0 = oscillator 2 frequency
.byte %00000000			// $900C - b7-0 = oscillator 3 frequency
.byte %00000000			// $900D - b7-0 = noise frequency
.byte %00000000			// $900E - b7-4 = auxilliary colour; b3-0 = sound volume
.byte %00011011			// $900F - b7-4 = background colour; b3 = inverse / normal; b2-0 = border colour

// -------------------------------------------- PAGE ALIGNMENT --------------------------------------------

.align 256
BITADDRH:				// Character -> Screen_Bitmap 8x16 character address hi-bytes
.pc = * "BITADDRH"		// Character -> Screen_Bitmap 8x16 character address hi-byte table
.for(var x=0;x<15;x++)
{
	.for(var y=0;y<16;y++)
	{
		.byte [>f40_runtime_memory.Screen_Bitmap]+x	// 16 * $00, 16 * $01, ... 16 * $0F [plus Screen_Bitmap start address hi-byte]
	}
}

// Alternate smaller bitmap address lookup tables
// B2TADDRL:				// Character -> Screen_Bitmap 8x16 character address lo-bytes
// .pc = * "B2TADDRL"		// Character -> Screen_Bitmap 8x16 character address lo-byte table
// .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0

// B2TADDRH:
// .pc = * "B2TADDRH"
// .fill 16, >[f40_runtime_memory.Screen_Bitmap+(256*(i-1))]	// $00 - $0F plus Screen_Bitmap start address hi-byte

.fill 16,$aa 			// Spare bytes

// -------------------------------------------- PAGE ALIGNMENT --------------------------------------------

.align 256
MATDATA:				// Character matrix data for 20x12 (40x24) screen
.pc = * "MATDATA"		// Character code bytes (240 bytes)
.byte $10,$1C,$28,$34,$40,$4C,$58,$64,$70,$7C,$88,$94,$A0,$AC,$B8,$C4,$D0,$DC,$E8,$F4
.byte $11,$1D,$29,$35,$41,$4D,$59,$65,$71,$7D,$89,$95,$A1,$AD,$B9,$C5,$D1,$DD,$E9,$F5
.byte $12,$1E,$2A,$36,$42,$4E,$5A,$66,$72,$7E,$8A,$96,$A2,$AE,$BA,$C6,$D2,$DE,$EA,$F6
.byte $13,$1F,$2B,$37,$43,$4F,$5B,$67,$73,$7F,$8B,$97,$A3,$AF,$BB,$C7,$D3,$DF,$EB,$F7
.byte $14,$20,$2C,$38,$44,$50,$5C,$68,$74,$80,$8C,$98,$A4,$B0,$BC,$C8,$D4,$E0,$EC,$F8
.byte $15,$21,$2D,$39,$45,$51,$5D,$69,$75,$81,$8D,$99,$A5,$B1,$BD,$C9,$D5,$E1,$ED,$F9
.byte $16,$22,$2E,$3A,$46,$52,$5E,$6A,$76,$82,$8E,$9A,$A6,$B2,$BE,$CA,$D6,$E2,$EE,$FA
.byte $17,$23,$2F,$3B,$47,$53,$5F,$6B,$77,$83,$8F,$9B,$A7,$B3,$BF,$CB,$D7,$E3,$EF,$FB
.byte $18,$24,$30,$3C,$48,$54,$60,$6C,$78,$84,$90,$9C,$A8,$B4,$C0,$CC,$D8,$E4,$F0,$FC
.byte $19,$25,$31,$3D,$49,$55,$61,$6D,$79,$85,$91,$9D,$A9,$B5,$C1,$CD,$D9,$E5,$F1,$FD
.byte $1A,$26,$32,$3E,$4A,$56,$62,$6E,$7A,$86,$92,$9E,$AA,$B6,$C2,$CE,$DA,$E6,$F2,$FE
.byte $1B,$27,$33,$3F,$4B,$57,$63,$6F,$7B,$87,$93,$9F,$AB,$B7,$C3,$CF,$DB,$E7,$F3,$FF

LINELEN:				// Maximum line length for each line in a continuation group
.pc = * "LINELEN"		// Zero-based logical line lengths (3 bytes)
.byte 39,39,7

LINEADD:				// Line length additions for each line in a continuation group
.pc = * "LINEADD"		// Zero-based line additions (4 bytes)
.byte 0,40,80,120

JIFFYID:				// JiffyDOS identifier
.pc = * "JIFFYID"		// Identifier string (5 bytes)
.text "JIFFY"

BLNKTIME:				// Cursor blink timers
.pc = * "BLNKTIME"		// Cursor phase on/off timer values (2 bytes)
.byte 19,13

VICPAL:					// 6561 (PAL) VIC initialisation data (differences from NTSC values)
.pc = * "VICPAL"		// VIC register values (2 bytes)
.byte %00001110			// $9000 - b7 = interlace; b6-0 = screen x-pos
.byte %00100100			// $9001 - b7-0 = screen y-pos

// -------------------------------------------- PAGE ALIGNMENT --------------------------------------------

.align 256
GLYPHADD:				// Character glyph pixel address data
.pc = * "GLYPHADD"
GLPHADDR:
.lohifill 256,CHARDATA+(8*i)		// Glyph pixel address lo/hi-bytes
// TODO: might be able to optimise this as:
//			the lo-byte pattern is 8 rows of 32 bytes, 00-f8, in 8-byte steps (so a fill formula will probably work)
//  		the hi-byte pattern is 8 rows of 32 bytes, b0-b7 (so we might be able to determine the value in code somehow and eliminate 256 bytes)
