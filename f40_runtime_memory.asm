// FAST-40 runtime RAM labels
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

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
.label LINECHAR         = $00E1     //  Character for bitmap merge / work buffer cursor position
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
.label SYSPARM	        = $00EF		//	SYS interceptor 4th parameter (1 byte)
.label SPAREZP	        = $00F0		//	Spare (2 bytes)

// 3K BLK0
.label UNUSEDB0         = $0400     //  Unused BLK0 space (1739 bytes to $0ACA)
.label LINCNTUF         = $0ACB		//	Line-continuation table underflow bytes (2 bytes to $0ACC)
.label LINECONT	        = $0ACD		//	Line-continuation table (24 bytes to $0AE4)
.label LINCNTOF         = $0AE5		//	Line-continuation table overflow byte (1 byte to $0AE5)
.label TXTBUFUF         = $0AE5		//	Text row key sequence underflow bytes (2 bytes to $0AE6)
.label TXTBUFSQ         = $0AE7		//	Text row key sequence bytes (24 bytes to $0AFE)
.label TXTBUFOF         = $0AFF		//	Text row key sequence overflow byte (1 byte to $0AFF)
.label SPAREP04         = $0B00     //  Spare BLK0 space (18 bytes to $0B11)
.label MERGBITL         = $0B12		//	Left-character bitmap merge routine (90 bytes to $0B6B)
.label MERGBITR         = $0B6C		//	Right-character bitmap merge routine (90 bytes to $0BC5)
.label Text_Buffer	    = $0BC6		//	Text buffer (960 bytes to $0F85)
.label InsDel_Buffer	= $0F86		//	Insert/Delete buffer (121 bytes to $0FFE)
.label Memory_Bitmap    = $0FFF     //  b7->PAL/NTSC(1=PAL), b6->JiffyDOS(1=JiffyDOS), b5->write-protect(1=OFF), b4-0->RAM bitmap

// Onboard RAM
.label Character_Matrix	= $1000		//	Screen character matrix is 20x12 double-height chars -> 240 bytes to $10EF
.label SPAREP10	        = $10F0		//	Spare (16 bytes)
.label Screen_Bitmap    = $1100		//	Screen bitmap is 160x192 bits -> 20 * 8 * 24 = 3840 bytes to $1FFF
