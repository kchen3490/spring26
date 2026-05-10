// =============================================
// Bouncing Stick Figure v3 — BatPU-2 Assembly
// A stick figure with a hollow round head bounces
// around the 32x32 screen. Each wall bounce
// toggles between two poses:
//   Pose A: arms angled up (V), legs splayed out
//   Pose B: arms angled down (inv V), legs straight
//
// NOTE: BatPU-2 screen has Y=0 at BOTTOM, Y=31
// at top. So the figure is laid out with feet at
// low Y offsets and head at high Y offsets.
// =============================================

// --- Register allocation ---
// r0  = zero (hardwired)
// r1  = X position (left edge of bounding box)
// r2  = Y position (bottom edge of bounding box)
// r3  = X velocity (+1 or -1)
// r4  = Y velocity (+1 or -1)
// r5  = pose flag (0 = pose A, 1 = pose B)
// r7  = pixel offset X (for draw_px subroutine)
// r8  = pixel offset Y (for draw_px subroutine)
// r10 = pixel_x port
// r11 = pixel_y port
// r12 = draw_pixel port
// r13 = buffer_screen port
// r14 = clear_screen_buffer port
// r15 = scratch

// --- Constants ---
define BOUND_X 26   // 32 - 6 = max X for 6-wide figure
define BOUND_Y 21   // 32 - 11 = max Y for 11-tall figure

// --- Setup ---
LDI r1 10             // starting X
LDI r2 5              // starting Y (bottom of figure)
LDI r3 1              // dx = +1
LDI r4 1              // dy = +1
LDI r5 0              // start with pose A

LDI r10 pixel_x
LDI r11 pixel_y
LDI r12 draw_pixel
LDI r13 buffer_screen
LDI r14 clear_screen_buffer

// ========== MAIN LOOP ==========
.main_loop

// --- Clear the screen buffer ---
STR r14 r0

// ---- Draw shared parts (head, neck, torso) ----
// Y offsets are flipped: 0 = bottom (feet), 10 = top (head)
//
// Figure layout (offset from bottom-left):
//   Row 10: . X X .   head top    -> (2,10)(3,10)
//   Row  9: X . . X   head sides  -> (1,9)(4,9)
//   Row  8: X . . X   head sides  -> (1,8)(4,8)
//   Row  7: . X X .   head bottom -> (2,7)(3,7)
//   Row  6: . . X X   neck        -> (2,6)(3,6)
//   Row  5: arms (pose-dependent)
//   Row  4: arms (pose-dependent)
//   Row  3: arms/shoulders (pose-dependent)
//   Row  2: . . X X   torso       -> (2,2)(3,2)
//   Row  1: legs (pose-dependent)
//   Row  0: legs (pose-dependent)

// Head (hollow circle)
LDI r7 2
LDI r8 10
CAL .draw_px
LDI r7 3
LDI r8 10
CAL .draw_px
LDI r7 1
LDI r8 9
CAL .draw_px
LDI r7 4
LDI r8 9
CAL .draw_px
LDI r7 1
LDI r8 8
CAL .draw_px
LDI r7 4
LDI r8 8
CAL .draw_px
LDI r7 2
LDI r8 7
CAL .draw_px
LDI r7 3
LDI r8 7
CAL .draw_px

// Neck: (2,6)(3,6)
LDI r7 2
LDI r8 6
CAL .draw_px
LDI r7 3
LDI r8 6
CAL .draw_px

// Torso: (2,2)(3,2)
LDI r7 2
LDI r8 2
CAL .draw_px
LDI r7 3
LDI r8 2
CAL .draw_px

// ---- Draw pose-specific parts (arms + legs) ----
LDI r15 0
CMP r5 r15
BRH ne .draw_pose_b

// ======== POSE A: arms V-up, legs splayed ========
// Arms go from shoulder at row 3 up to tips at row 5
//   (0,5)(1,4)(2,3)(3,3)(4,4)(5,5)

LDI r7 0
LDI r8 5
CAL .draw_px
LDI r7 1
LDI r8 4
CAL .draw_px
LDI r7 2
LDI r8 3
CAL .draw_px
LDI r7 3
LDI r8 3
CAL .draw_px
LDI r7 4
LDI r8 4
CAL .draw_px
LDI r7 5
LDI r8 5
CAL .draw_px

// Legs A: splayed outward
//   (1,1)(4,1)(0,0)(5,0)

LDI r7 1
LDI r8 1
CAL .draw_px
LDI r7 4
LDI r8 1
CAL .draw_px
LDI r7 0
LDI r8 0
CAL .draw_px
LDI r7 5
LDI r8 0
CAL .draw_px

JMP .done_draw

// ======== POSE B: arms V-down, legs straight ========
.draw_pose_b

// Arms go from shoulder at row 5 down to tips at row 3
//   (0,3)(1,4)(2,5)(3,5)(4,4)(5,3)

LDI r7 0
LDI r8 3
CAL .draw_px
LDI r7 1
LDI r8 4
CAL .draw_px
LDI r7 2
LDI r8 5
CAL .draw_px
LDI r7 3
LDI r8 5
CAL .draw_px
LDI r7 4
LDI r8 4
CAL .draw_px
LDI r7 5
LDI r8 3
CAL .draw_px

// Legs B: straight down
//   (1,1)(4,1)(1,0)(4,0)

LDI r7 1
LDI r8 1
CAL .draw_px
LDI r7 4
LDI r8 1
CAL .draw_px
LDI r7 1
LDI r8 0
CAL .draw_px
LDI r7 4
LDI r8 0
CAL .draw_px

.done_draw

// --- Push buffer to screen ---
STR r13 r0

// --- Update X position ---
ADD r1 r3 r1

// --- Check X boundaries ---
LDI r15 BOUND_X
CMP r1 r15
BRH eq .bounce_x_high
LDI r15 0
CMP r1 r15
BRH eq .bounce_x_low
JMP .done_x

.bounce_x_high
    LDI r3 -1
    LDI r15 1
    XOR r5 r15 r5
    JMP .done_x

.bounce_x_low
    LDI r3 1
    LDI r15 1
    XOR r5 r15 r5

.done_x

// --- Update Y position ---
ADD r2 r4 r2

// --- Check Y boundaries ---
LDI r15 BOUND_Y
CMP r2 r15
BRH eq .bounce_y_high
LDI r15 0
CMP r2 r15
BRH eq .bounce_y_low
JMP .done_y

.bounce_y_high
    LDI r4 -1
    LDI r15 1
    XOR r5 r15 r5
    JMP .done_y

.bounce_y_low
    LDI r4 1
    LDI r15 1
    XOR r5 r15 r5

.done_y

// --- Loop forever ---
JMP .main_loop


// ======== SUBROUTINE: draw one pixel ========
// Input: r7 = offset X, r8 = offset Y
// Draws pixel at (r1 + r7, r2 + r8)
.draw_px
    ADD r1 r7 r15
    STR r10 r15
    ADD r2 r8 r15
    STR r11 r15
    STR r12 r0
    RET
