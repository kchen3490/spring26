// =============================================
// DVD Bouncing Logo — BatPU-2 Assembly
// A 3x3 square bounces around the 32x32 screen,
// reversing direction when it hits an edge.
// =============================================

// --- Register allocation ---
// r0  = zero (hardwired)
// r1  = X position (top-left corner of square)
// r2  = Y position (top-left corner of square)
// r3  = X velocity (+1 or -1, stored as 1 or 255)
// r4  = Y velocity (+1 or -1, stored as 1 or 255)
// r5  = scratch / loop counter for drawing
// r6  = scratch / current draw X
// r7  = scratch / current draw Y
// r8  = boundary constant (29 = 32 - 3, max position)
// r9  = square size for inner loop (3)
// r10 = pixel_x port
// r11 = pixel_y port
// r12 = draw_pixel port
// r13 = buffer_screen port
// r14 = clear_screen_buffer port
// r15 = scratch

// --- Setup: load constants and ports ---
LDI r1 5              // starting X
LDI r2 10             // starting Y
LDI r3 1              // dx = +1
LDI r4 1              // dy = +1
LDI r8 29             // max position (32 - 3)
LDI r9 3              // square size

LDI r10 pixel_x
LDI r11 pixel_y
LDI r12 draw_pixel
LDI r13 buffer_screen
LDI r14 clear_screen_buffer

// ========== MAIN LOOP ==========
.main_loop

// --- Clear the screen buffer ---
STR r14 r0

// --- Draw 3x3 square ---
// outer loop: row offset r7 = 0, 1, 2
LDI r7 0

.draw_row
    // compute draw Y = r2 + r7
    ADD r2 r7 r15
    STR r11 r15          // set pixel_y

    // inner loop: col offset r6 = 0, 1, 2
    LDI r6 0

    .draw_col
        // compute draw X = r1 + r6
        ADD r1 r6 r15
        STR r10 r15      // set pixel_x
        STR r12 r0       // draw pixel

        INC r6
        CMP r6 r9
        BRH lt .draw_col

    INC r7
    CMP r7 r9
    BRH lt .draw_row

// --- Push buffer to screen ---
STR r13 r0

// --- Update X position ---
ADD r1 r3 r1

// --- Check X boundaries ---
// if X >= 29, bounce (set dx = -1 i.e. 255)
// if X == 0, bounce (set dx = +1 i.e. 1)

CMP r1 r8
BRH eq .bounce_x_high
LDI r15 0
CMP r1 r15
BRH eq .bounce_x_low
JMP .done_x

.bounce_x_high
    LDI r3 -1
    JMP .done_x

.bounce_x_low
    LDI r3 1

.done_x

// --- Update Y position ---
ADD r2 r4 r2

// --- Check Y boundaries ---
CMP r2 r8
BRH eq .bounce_y_high
LDI r15 0
CMP r2 r15
BRH eq .bounce_y_low
JMP .done_y

.bounce_y_high
    LDI r4 -1
    JMP .done_y

.bounce_y_low
    LDI r4 1

.done_y

// --- Loop forever ---
JMP .main_loop
