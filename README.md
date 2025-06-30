# FAST-40

FAST-40 is a cartridge ROM program for the Commodore VIC-20 which reconfigures the stock 22x23 text screen to display a denser 40x24 mode. It is written entirely in 6502 assembly language and requires a 3K RAM expansion to run.

No hardware modification is required.

Other (vintage) 40-column programs typically suffer from some combination of sluggish performance, visual glitching, or screen-editor functionality issues. FAST-40 was designed from the ground up to render an artifact-free 40x24 text mode with performance comparable to the hardware-assisted 22x23 display, whilst faithfully reproducing standard screen-editor functionality. In tests, FAST-40 character output rates match or exceed stock speeds.

FAST-40 works under emulation and on real VIC-20 hardware - it can be attached as an auto-start cartridge in VICE (see below) or burned/flashed/loaded into a suitable EPROM or 'soft' cartridge such as the Final Expansion 3.

#### FAST-40 is copyright © 2025 [8-Bit Guru](mailto:the8bitguru@gmail.com).

Creation of modified or derivative works using, in whole or in part, any sourcecode, assets, or binary package originating from this project is subject to the following:

* **Free for non-commercial use** (you must clearly include a credit link to this project within your project).

* **Commercial use is expressly forbidden** except by explicit consent from the copyright holder.

* The FAST-40 project is hosted on [GitHub](https://github.com/EightBitGuru/FAST-40).

#### Who is 8-Bit Guru?

8-Bit Guru (also: Eight-Bit Guru, 8BitGuru, 8BG) is the *nom de guerre* of Mark Johnson. I'm a professional coder from the UK who has been telling computers what to do since 1981. My day job is all about C# and Azure, whilst my hobby projects mostly involve writing 6502 assembly language for the VIC-20 (my first computer, back in '81).

## How to build and run FAST-40

### Suggested Toolchain

* **Editor**  
My personal choice is [Visual Studio Code](https://code.visualstudio.com/), but any editor you're comfortable with will suffice.
I also use a 3rd-party VSCode extension called [Kick Assembler 8-Bit Retro Studio 0.23.3](https://gitlab.com/retro-coder/commodore/kick-assembler-vscode-ext) which provides a bunch of useful functionality including syntax highlighting and automated invocation of KickAssembler and VICE without needing to switch out to a command prompt.

* **Assembler**  
The sourcecode syntax targets [KickAssembler 5.25](https://theweb.dk/KickAssembler/Main.html#frontpage). No other build tool is required.  
Note that KickAssembler is written in Java and requires a Java runtime to operate. My preference is [AdoptJDK](https://adoptopenjdk.net/releases.html).

* **Emulator**  
The code builds a binary cartridge image which can be used with ***xvic***, the VIC-20 emulator shipped with [VICE](https://vice-emu.sourceforge.io/).

### Build / Run

The sourcecode produces a standard BLK5 ($A000-$BFFF) 8K cartridge ROM binary image.

Execute KickAssembler in your working copy directory to build the image:
 
    java -jar [Your_KickAssembler_Path]\KickAss.jar main.asm -o fast40.bin -binfile

To use the image with ***xvic***:

    [Your_VICE_Path]\bin\xvic.exe -memory 1 -cartA fast40.bin

* The cartridge auto-starts via the standard Commodore **A0CBM** signature-detection mechanism.

* Both PAL and NTSC video standards are supported.

* The JiffyDOS v6.01 Kernal ROM is supported, if present.

* FAST-40 expects to run on a real or emulated VIC-20 fitted with an NMOS 6502, and makes use of several undocumented opcodes. It will not operate correctly on later variants such as the CMOS 65C02 which disable or replace these opcodes.

### Memory Requirements

FAST-40 uses all of the 4K unexpanded RAM area for video display reconfiguration and requires a minimum of 3K expansion RAM in BLK0 (of which just under 1K is reserved and the remaining 2.1K left free for BASIC).

If 8K (or 16K/24K) expansion RAM is also present in BLK1/2/3 then FAST-40 will make all 8K blocks available for BASIC and the 'lost' 2.1K in BLK0 available for machine-code programs.

### New RESET Command

FAST-40 provides a new BASIC command to easily reset the system and switch between memory configurations without having to swap cartridges. **Note that memory is cleared during a system reset.**

    RESET [0|3|8]   Switch to specified video/memory configuration
    
        RESET		Switch to 40x24 3K/8K+ mode
        RESET 0		Switch to 22x23 unexpanded mode
        RESET 3		Switch to 22x23 3K mode
        RESET 8		Switch to 22x23 8K+ mode (if RAM is present in BLK1/2/3)

### SHIFT/RUNSTOP Behaviour

On a stock VIC-20 the SHIFT/RUNSTOP key combination causes the commands `LOAD` and `RUN` to be injected into the keyboard buffer to initiate an automatic start of the next program found on tape. Modern users prefer to use disk devices (or modern pseudo-disk devices such as SD cards) for storage instead of tape, and will often make use of the JiffyDOS Kernal ROM which disables tape operations in order to provide extended disk functionality.

FAST-40 detects the presence of JiffyDOS and alters the SHIFT/RUNSTOP commands to favour disk users as follows:
* If JiffyDOS is _not_ present, the sequence `LOAD"$",8` and `LIST` is executed to read and display the directory of the disk
* If JiffyDOS _is_ present then its `@$` command is the preferred method to view the disk directory; therefore the sequence `LOAD"*",8` and `RUN` is executed to auto-start the first program on the disk

### System Reconfiguration

FAST-40 makes changes to numerous memory areas, VIC registers, and system vectors in order to configure and manage the 40x24 display mode.

Memory areas:

    $0003-$0004     Not normally used by BASIC/KERNAL.     [only used if BRK debugging is enabled on build]
    $00D9-$00F1     Normally used as the BASIC screen editor line-link table.
    $02B4-$02FF     Not normally used by BASIC/KERNAL.
    $0C40-$0FFF     Top of 3K RAM expansion (BLK0).
    $1000-$1FFF     Normally used as the unexpanded screen and RAM area.
    $9400-$95FF     Normally used as colour memory when RAM is in BLK1/2/3.

VIC registers:

    $9000           Screen x-position
    $9001           Screen y-position
    $9002           Screen memory address and columns
    $9003           Screen rows and character height
    $9005           Screen memory address and character generator address

System vectors:

    $028F/$0290     SHIFT/CTRL/C= key decode
    $0308/$0309     BASIC decode
    $0314/$0315     IRQ interrupt
    $0316/$0317     BRK interrupt                          [only used if BRK debugging is enabled on build]
    $0324/$0325     Character input
    $0326/$0327     Character output

These vectors may be modified by other programs wishing to provide additional functionality alongside FAST-40. Such programs should preserve the vector chain by first capturing the target address of whichever vector(s) they need before replacing them with their own, and finalise their processing by passing control to those captured addresses.

### Programming Caveats

The VIC-20 has no memory protection hardware and therefore FAST-40 cannot 'lock' the various memory areas, vectors, and VIC registers it uses. The following cautions apply for other programs wishing to operate in the 40x24 mode:

* Programs should not read/write video or colour memory directly, but instead use the PRINT statement (in BASIC) or call the CHROUT vector at $FFD2 (in machine-code). Both are configured to route their output through to the custom display logic within FAST-40, and thereby allow it to manage screen output.

* Common programming techniques such as switching character-case by altering the value at address 36869 ($9005), adjusting cursor blink phase, frequency, or position by altering the relevant zero-page values at $CC/$CD/$CF/$D3/$D6, or otherwise directly interacting with screen editor functionality via zero-page or other addresses is discouraged. Such interactions are unlikely to yield the expected result or (more likely) will disrupt FAST-40 operation.

* All PRINTable control characters are supported, including those for cursor positioning, colour selection, reverse-mode, etc. The VIC-20 keyboard does not emit characters for the SHIFT/C= key combination which performs the toggle between upper-case and lower-case character sets, but these non-printing characters do exist - generated with CHR$(14) and CHR$(142) - and are supported by FAST-40.

* Limitations in the VIC design mean there is no way to preserve the usual 1:1 relationship between individual text-mode characters and their respective colour attribute when in 40x24 mode. All text colours are supported but they operate on 2x2 blocks of characters; in other words, the colour resolution is half that of the text resolution and colour layout should therefore be planned accordingly to avoid attribute clash.

### Accidental Breakage

In the event that a program inadvertantly 'breaks' FAST-40 by overwriting something it depends upon to generate the 40x24 mode, recovery can be achieved in the following ways:

* Writes to the text buffer, display bitmap, colour memory, and screen-editor management areas will be repaired whenever the screen is cleared with SHIFT/CLRHOME or PRINT CHR$(147).

* Writes to the VIC registers, system vectors, and/or other runtime memory structures can almost always be repaired via a RUNSTOP/RESTORE 'soft' reset.

* Writes to the display character matrix and any other critical areas will require a system reset to trigger a repair. A system reset can be achieved by power-cycling the machine, hitting a hardware reset button if one is fitted, or by using the new RESET command. **Note that memory is cleared during a system reset.**

## Beta testing, and credit where it's due

The following VIC-20 afficionados at [Denial](https://sleepingelephant.com/ipw-web/bulletin/bb/index.php) actively participated in the beta-test phase. Their time and effort spent testing, sending bug reports, and assisting with crash diagnosis is greatly appreciated.

* tokra
* mathom

### Beta 1 (9th April 2025)
* Initial release for testing.

### Beta 2 (21st April 2025)
* Fixed a bug where entering long BASIC lines would sometimes lose the character in column 40, causing syntax errors (reported by **tokra@denial**)
* Fixed a bug where data fed to the INPUT command included the prompt in the returned value and therefore broke it (reported by **mathom@denial**)
* Fixed a bug where inserting a character into a long line would sometimes erroneously insert a blank line after it
* Fixed a bug where doing a character insert in column 40 erroneously placed the inserted space character into column 39
* Fixed a bug in the screen-scrolling logic where it forgot that text buffer lines were not always contiguous in memory
* Fixed a bug where RUNSTOP/RESTORE didn't reset the default text colour and character-case
* Added a BRK handler to display CPU registers (to help debug a JiffyDOS showstopper crash reported by **mathom@denial**)
* Added an alternate build option to do LOAD"$",8 / LIST on SHIFT/RUNSTOP
* Tweaked the PAL/NTSC startup test to save the result for RUNSTOP/RESTORE and thereby avoid repeated re-tests
* Tweaked the cursor blink phase timings to help cursor visibility during rapid/repeated movement (reported by **mathom@denial**)

### Beta 2A (22nd April 2025)
* Fixed a bug introduced in Beta 2 which totally broke the character insert and delete routines (reported by **tokra@denial**)

### Beta 3 (24th April 2025)
* Fixed a bug where deleting a character from column 1 replaced the character in column 39 on the previous line instead of column 40
* Fixed a bug where deleting a character from column 1 of an unlinked line produced an unwanted side-effect on the previous line
* Fixed a bug where the screen-scroll CTRL-delay code intermittently failed to execute properly (reported by **tokra@denial**)

### Release v1.0 (2nd May 2025)
* Fixed a bug where the startup RAM detection wasn't triggering a clean system reset if BLK1 is empty
* Fixed the JiffyDOS showstopper crash (JiffyDOS rearranges some code in the SHIFT/CTRL/C= keypress logic)
* Added the JiffyDOS banner to the startup message (if present)

### Release v1.1 (xx July 2025)
* Rendering performance increased from 92% to 107% of stock display speed (FAST-40 is now faster at drawing the 40x24 mode than the stock ROM is at drawing 22x23)
* Bitmap refreshes triggered by a case-switch event or INS/DEL keypress events are now up to 30% faster
* FAST-40 now always requires 3K in BLK0 and leaves all 8K blocks completely free for BASIC
* The runtime memory footprint in Page 2 has been reduced
* SHIFT/RUNSTOP keypress behaviour now adapts to JiffyDOS Kernal presence
* Fixed a bug where line continuation markers were not correctly reset after a screen-scroll event
* ##Fixed a bug where case-switch events conflicted with screen-scroll events and triggered a crash
* ##Refactored INS/DEL keypress logic to reduce complexity and eliminate Stack usage

## The Wishlist

The following improvements and enhancements may make it into the project if time, motivation, and memory availability permit:

* Integrate the display matrix setup logic into the RUNSTOP/RESTORE handler for better breakage recovery
* Add a SHIFT-key modifier to the scroll CTRL-delay logic to toggle a full hold until released
* Add a CTRL-key modifier to the cursor control logic to allow jumping to the start/end of physical/logical lines
* Add a bitmap point-plotting routine and an accompanying PLOT command to BASIC
* Add PEEK/POKE intercepts to allow screen/colour memory access akin to the stock 22x23 text mode

Other suggestions and/or pull requests will be reviewed periodically.
