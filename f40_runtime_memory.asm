// FAST-40 runtime RAM labels
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_runtime_memory

// Zero-page - 25 bytes replaces LINELINK at $D9-$F1
.label TXTBUFFL         = $00D9		//	Text buffer start address lo-byte
.label TXTBUFFH	        = $00DA		//	Text buffer start address hi-byte
.label MATROWL          = $00DB     //  Character matrix data row address end lo-byte
.label MATROWH          = $00DC     //  Character matrix data row address end hi-byte
.label CRSRBITL	        = $00DD		//	Cursor draw bitmap address lo-byte
.label CRSRBITH	        = $00DE		//	Cursor draw bitmap address hi-byte
.label CRSRMASK	        = $00DF		//	Cursor draw bitmap mask
.label CRSRUDRW         = $00E0		//	Cursor undraw flag (b7 -> 0=no undraw, 1=undraw)
.label CRSRCOLF	        = $00E1		//	Cursor colour flag ($00=read cursor colour, $80=set cursor colour)
.label CASEFLAG         = $00E2		//	Upper/Lower-case flag ($00=upper-case, $08=lower-case)
.label LINECHAR         = $00E3     //  Character for bitmap merge / line insert refresh flag
.label DRAWROWS         = $00E4     //  Bitmap redraw start row
.label DRAWROWE         = $00E5     //  Bitmap redraw end row
.label REGASAVE	        = $00E6		//	A-register save byte
.label REGXSAVE	        = $00E7		//	X-register save byte
.label REGYSAVE	        = $00E8		//	Y-register save byte
.label TEMPAL	        = $00E9		//	Temporary data/address lo-byte
.label TEMPAH	        = $00EA		//	Temporary data/address hi-byte
.label TEMPBL    	    = $00EB		//	Temporary data/address lo-byte
.label TEMPBH	        = $00EC		//	Temporary data/address hi-byte
.label TEMPCL    	    = $00ED		//	Temporary data/address lo-byte
.label TEMPCH	        = $00EE		//	Temporary data/address hi-byte
.label TEMPDL    	    = $00EF		//	Temporary data/address lo-byte
.label TEMPDH	        = $00F0		//	Temporary data/address hi-byte
.label SPAREZP	        = $00F1		//	Spare (5 bytes)

// Page 2 - 95 bytes available at $02A1-$02FF
.label LINECONT	        = $02A1		//	Line-continuation table (24 bytes to $02B8)
.label TXTBUFRL	        = $02B9     //	Text row address lo-bytes (24 bytes to $02D0)
.label TXTBUFRH	        = $02D1		//	Text row address hi-byte addition bytes (24 bytes to $02E8)
.label MERGROUT	        = $02E9		//	Self-modifying bitmap merge routine (22 bytes to $02FE)
.label Memory_Bitmap    = $02FF     //  b7->PAL/NTSC(1=PAL), b6->JiffyDOS(1=JiffyDOS), b5-0->RAM bitmap

// 3K BLK0 - layout is the same if placed at top of BLK1/2/3
.label SPAREP04         = $0400		//	Spare (2112 bytes)
.label Text_Buffer	    = $0C40		//	Text buffer (960 bytes to 0FFF as four 240-byte pages at $0C40/$0D30/$0E20/$0F10)

// Onboard RAM
.label Character_Matrix	= $1000		//	Screen character matrix is 20x12 double-height chars -> 240 bytes to $10EF
.label SPAREP10	        = $10F0		//	Spare (16 bytes)
.label Screen_Bitmap    = $1100		//	Screen bitmap is 160x192 bits -> 20 * 8 * 24 = 3840 bytes to $1FFF
