// VIC-20 system memory labels
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace vic20

// Screen character/control codes
.namespace screencodes
{
    .label NULL     = $00
    .label RUNSTOP  = $03
    .label WHITE    = $05
    .label CBMOFF   = $08
    .label CBMON    = $09
    .label LF       = $0A
    .label CR       = $0D
    .label LCASE    = $0E
    .label CRSRDOWN = $11
    .label RVSON    = $12
    .label CRSRHOME = $13
    .label DELETE   = $14
    .label RED      = $1C
    .label CRSRRGHT = $1D
    .label GREEN    = $1E
    .label BLUE     = $1F
    .label SPACE    = $20
    .label QUOTE    = $22
    .label SHIFTRUN = $83
    .label F1       = $85
    .label F3       = $86
    .label F5       = $87
    .label F7       = $88
    .label F2       = $89
    .label F4       = $8A
    .label F6       = $8B
    .label F8       = $8C
    .label SHIFTCR  = $8D
    .label UCASE    = $8E
    .label BLACK    = $90
    .label CRSRUP   = $91
    .label RVSOFF   = $92
    .label CLRSCRN  = $93
    .label INSERT   = $94
    .label PURPLE   = $9C
    .label CRSRLEFT = $9D
    .label YELLOW   = $9E
    .label CYAN     = $9F
    .label INVSPACE = $A0
    .label PICHAR   = $DE
    .label PITOKEN  = $FF
}


// Interrupt vector
.namespace vectors
{
    .label KVECLOAD	= %1100101100011110
    .label KVECBUFF	= %0000001100111100
}


// IO device identifiers
.namespace devices
{
    .label KEYBOARD = 0
    .label SCREEN   = 3
}
