// FAST-40 runtime RAM labels
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_runtime_memory

// Zero-page - 25 bytes replaces LINELINK at $D9-$F1
.label MATROWL          = $00D9     //  Character matrix data row address end lo-byte
.label MATROWH          = $00DA     //  Character matrix data row address end hi-byte
.label CRSRBITL	        = $00DB		//	Cursor draw bitmap address lo-byte
.label CRSRBITH	        = $00DC		//	Cursor draw bitmap address hi-byte
.label CRSRMASK	        = $00DD		//	Cursor draw bitmap mask
.label CRSRUDRW         = $00DE		//	Cursor undraw flag (b7 -> 0=no undraw, 1=undraw)
.label CRSRCOLF	        = $00DF		//	Cursor colour flag ($00=read cursor colour, $80=set cursor colour)
.label CASEFLAG         = $00E0		//	Upper/Lower-case flag ($00=upper-case, $08=lower-case)
.label LINECHAR         = $00E1     //  Character for bitmap merge / work buffer extent
.label DRAWROWS         = $00E2     //  Bitmap redraw start row
.label DRAWROWE         = $00E3     //  Bitmap redraw end row
.label REGASAVE	        = $00E4		//	A-register save byte
.label REGXSAVE	        = $00E5		//	X-register save byte
.label REGYSAVE	        = $00E6		//	Y-register save byte
.label TEMPAL	        = $00E7		//	Temporary data/address lo-byte
.label TEMPAH	        = $00E8		//	Temporary data/address hi-byte
.label TEMPBL    	    = $00E9		//	Temporary data/address lo-byte
.label TEMPBH	        = $00EA		//	Temporary data/address hi-byte
.label TEMPCL    	    = $00EB		//	Temporary data/address lo-byte
.label TEMPCH	        = $00EC		//	Temporary data/address hi-byte
.label TEMPDL    	    = $00ED		//	Temporary data/address lo-byte
.label TEMPDH	        = $00EE		//	Temporary data/address hi-byte
.label SPAREZP	        = $00EF		//	Spare (3 bytes)

// Page 2 - 95 bytes available at $02A1-$02FF
.label SPAREP02         = $02A1		//	Spare (19 bytes to 02B3)
.label LINCNTUF         = $02B4		//	Line-continuation table underflow bytes (2 bytes to $02B5)
.label LINECONT	        = $02B6		//	Line-continuation table (24 bytes to $02CD)
.label LINCNTOF         = $02CE		//	Line-continuation table overflow byte (1 byte to $02CE)
.label TXTBUFUF         = $02CE		//	Text row key sequence underflow bytes (2 bytes to $02CF)
.label TXTBUFSQ         = $02D0		//	Text row key sequence bytes (24 bytes to $02E7)
.label TXTBUFOF         = $02E8		//	Text row key sequence overflow byte (1 byte to $02E8)
.label MERGROUT	        = $02E9		//	Self-modifying bitmap merge routine (22 bytes to $02FE)
.label Memory_Bitmap    = $02FF     //  b7->PAL/NTSC(1=PAL), b6->JiffyDOS(1=JiffyDOS), b5-0->RAM bitmap

// 3K BLK0
.label Text_Buffer	    = $0BC7		//	Text buffer (960 bytes to 0F86)
.label InsDel_Buffer	= $0F87		//	Insert/Delete buffer (121 bytes to 0FFF)

// Onboard RAM
.label Character_Matrix	= $1000		//	Screen character matrix is 20x12 double-height chars -> 240 bytes to $10EF
.label SPAREP10	        = $10F0		//	Spare (16 bytes)
.label Screen_Bitmap    = $1100		//	Screen bitmap is 160x192 bits -> 20 * 8 * 24 = 3840 bytes to $1FFF
