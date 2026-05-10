// Draw a single pixel in the center of the 32x32 screen

// Clear screen buffer
LDI r15 clear_screen_buffer
STR r15 r0

// Set pixel X to 16
LDI r15 pixel_x
LDI r1 16
STR r15 r1

// Set pixel Y to 16
LDI r15 pixel_y
LDI r2 16
STR r15 r2

// Draw the pixel
LDI r15 draw_pixel
STR r15 r0

// Push screen buffer to display
LDI r15 buffer_screen
STR r15 r0

HLT
