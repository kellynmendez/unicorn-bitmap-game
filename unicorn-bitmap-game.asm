# Unicorn Bitmap Interactive Game
# @author Kellyn Mendez
# Draws a unicorn that can be controlled by the user. The unicorn can move up and down, walk forward and backward,
# and can also be made to barf rainbows (and stop barfing rainbows)

# Instructions:
# 	Set the pixel size to 4 x 4
#	Set the display to 512 x 512
#	Set the base address to 0x10008000 ($gp)
#	Connect to MIPS then run
#	Move the unicorn up or down with the keys w and s respectively
#	Make the unicorn walk forward and backward with the keys d and a respectively
#	Make the unicorn barf rainbows and stop barfing rainbows with the keys k and l respectively
#	Use the space key to end the program

# Dimensions of the screen
.eqv	WIDTH	128
.eqv	HEIGHT	128

# Colors
.eqv	MAGENTA		0X00FF00FF
.eqv	RED		0X00FF0000
.eqv	MAROON		0X00B84040
.eqv	LIGHT_ORANGE	0X00FFE58D
.eqv	YELLOW		0X00FFFF00
.eqv	MUSTARD		0X00EDC326
.eqv	MINT		0X008EFF8D
.eqv	GREEN		0X0000FF00
.eqv	OLIVE		0X00359D44
.eqv	CYAN		0X0000FFFF
.eqv	SKY_BLUE	0X0000ABFF
.eqv	BLUE		0X000000FF
.eqv	LIGHT_PURPLE	0x00C45FFE
.eqv	PURPLE		0X00A100FF
.eqv	DARK_PURPLE	0X006D00AC
.eqv	WHITE		0X00FFFFFF

.data
# Color arrays
reds:		.word		MAGENTA, RED, MAROON			# Array of red colors
yellows:	.word		LIGHT_ORANGE, YELLOW, MUSTARD		# Array of orange/yellow colors
greens:		.word		MINT, GREEN, OLIVE			# Array of green colors
blues:		.word		CYAN, SKY_BLUE, BLUE			# Array of blue colors
purples:	.word		LIGHT_PURPLE, PURPLE, DARK_PURPLE	# Array of purple colors

.text
main:		# Setting x and y values and necessary variables

		addi	$t0, $zero, WIDTH
		addi	$t0, $t0 -60		# Moving coordinate to best starting place for body
		srl	$t0, $t0, 1
		move	$a0, $t0		# x = $a0
		addi	$t0, $zero, HEIGHT
		addi	$t0, $t0 -10		# Moving coordinate to best starting place for body
		srl	$t0, $t0, 1
		move	$a1, $t0		# y = $a1
		addi	$a2, $zero, WHITE	# Setting color to draw unicorn in white
		
		move	$s0, $a0		# Storing current coordinates in $s0 and $s1
		move	$s1, $a1		#   These are updated throughout the program as the unicorn moves
		move	$s2, $zero		# Flag to indicate mouth should be closed = $s2
		
loop:		addi	$a2, $zero, WHITE	# Setting color parameter and flag
		move	$a3, $s2
		jal	draw_unicorn
		move	$s4, $v0		# Saving coordinates of mouth in $s4 (x) and $s5 (y)
		move	$s5, $v1		#   These are also updated throughout the program as the unicorn moves
					
		addi	$a0, $s0, 47		# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		jal	draw_legs		# Drawing the legs
		move	$a0, $s0		# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		
		beq	$s2, $zero, get_input	# If mouth is closed, skip drawing rainbow
		move	$a0, $s4		# Setting $a0 and $a1 to mouth coordinates
		move	$a1, $s5
		jal	draw_rainbow		# Drawing the rainbow
		move	$a0, $s0		# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		
get_input:	# Checking for input
		
		lw	$t0, 0xffff0000
		beq 	$t0, 0, loop		# If no input is given, keep looping
		
		# Checking given input
		
		lw	$s3, 0xffff0004
		beq	$s3, 32, exit		# If the input was a space, then end the program
		beq	$s3, 119, up		# If input was w, then move unicorn up
		beq	$s3, 115, down		# If input was s, then move unicorn down
		beq	$s3, 97, left		# If input was a, then move unicorn left
		beq	$s3, 100, right		# If input was d, then move unicorn right
		beq	$s3, 107, vomit		# If input was k, then make unicorn barf rainbows
		beq	$s3, 108, stop_vomit	# If input was l, then make unicorn stop barfing rainbows
		j	loop			# Do nothing if invalid input
		
		# Processing the input if valid
		
up:		# Moving unicorn up by blacking out original unicorn and redrawing
		
		li	$a2, 0	
		move	$a3, $s2	
		jal	draw_unicorn	# Redraw unicorn as black
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	draw_legs	# Drawing the legs as black
		move	$a0, $s0	# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		addi	$a1, $a1, -1	# Moving y coordinate up one
		move	$s1, $a1	# Updating current y coordinate
		
		# Checking if mouth is open; if open, black out rainbow
		
		beq	$s2, $zero, cm_up	# If flag = 0, then mouth is closed (do not have to black out rainbow)
		move	$a0, $s4		# Setting mouth coordinates as parameter
		move	$a1, $s5
		jal	erase_rainbow		# Erasing the rainbow
		move	$a0, $s0		# Resetting to current coordinates to draw unicorn
		move	$a1, $s1
		
cm_up:		# Redrawing unicorn

		addi	$a2, $zero, WHITE	# Passing parameters
		move	$a3, $s2
		jal	draw_unicorn	# Redrawing unicorn with colors
		move	$s4, $v0	# Saving mouth coordinates
		move	$s5, $v1	
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		jal	draw_legs	# Blacking out the legs
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		j	loop		# Moving to next input
		
down:		# Moving unicorn down by blacking out original unicorn and redrawing

		li	$a2, 0	
		move	$a3, $s2	
		jal	draw_unicorn	# Redraw unicorn as black
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	draw_legs	# Drawing the legs
		move	$a0, $s0	# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		addi	$a1, $a1, 1	# Moving y coordinate down one
		move	$s1, $a1	# Updating current y coordinate
		
		# Checking if mouth is open; if open, black out rainbow
		
		beq	$s2, $zero, cm_down	# If flag = 0, then mouth is closed (do not have to black out rainbow)
		move	$a0, $s4		# Setting mouth coordinates as parameter
		move	$a1, $s5
		jal	erase_rainbow		# Erasing rainbow
		move	$a0, $s0		# Resetting to current coordinates to draw unicorn
		move	$a1, $s1
		
cm_down:	# Redrawing unicorn
		
		addi	$a2, $zero, WHITE
		move	$a3, $s2
		jal	draw_unicorn	# Redrawing unicorn with colors
		move	$s4, $v0	# Saving mouth coordinates
		move	$s5, $v1
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		jal	draw_legs	# Blacking out the legs
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		j	loop		# Moving to next input

left:		# Moving unicorn to the left by blacking out original unicorn and redrawing

		li	$a2, 0	
		move	$a3, $s2	
		jal	draw_unicorn	# Redraw unicorn as black
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	draw_legs	# Blacking out the legs
		move	$a0, $s0	# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		addi	$a0, $a0, -1	# Moving x coordinate left one
		move	$s0, $a0	# Updating current x coordinate
		
		# Checking if mouth is open; if open, black out rainbow
		
		beq	$s2, $zero, cm_left	# If flag = 0, then mouth is closed (do not have to black out rainbow)
		move	$a0, $s4		# Setting mouth coordinates as parameter
		move	$a1, $s5
		jal	erase_rainbow		# Erasing rainbow
		move	$a0, $s0		# Resetting to current coordinates to draw unicorn
		move	$a1, $s1
		
cm_left:	# Redrawing unicorn
		
		addi	$a2, $zero, WHITE
		move	$a3, $s2
		jal	draw_unicorn	# Redrawing unicorn with colors
		move	$s4, $v0	# Saving mouth coordinates
		move	$s5, $v1
		
		# Drawing legs backward to give the illusion of unicorn moving its legs back
		
		jal	long_pause
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		jal	move_legs	# Drawing the legs taking a step backward
		jal	long_pause
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	move_legs	# Blacking out backward legs
		
		# Resetting back to normal legs
		
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		addi	$a2, $zero, WHITE
		jal	draw_legs	# Drawing the legs
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		j	loop		# Moving to next input

right:		# Moving unicorn to the right by blacking out original unicorn and redrawing

		li	$a2, 0	
		move	$a3, $s2	
		jal	draw_unicorn	# Redraw unicorn as black
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	draw_legs	# Blacking out the legs
		move	$a0, $s0	# Resetting coordinates to unicorn start coordinates
		move	$a1, $s1
		addi	$a0, $a0, 1	# Moving x coordinate right one
		move	$s0, $a0	# Updating current x coordinate
		
		# Checking if mouth is open; if open, black out rainbow
		
		beq	$s2, $zero, cm_right	# If flag = 0, then mouth is closed (do not have to black out rainbow)
		move	$a0, $s4		# Setting mouth coordinates as parameter
		move	$a1, $s5
		jal	erase_rainbow		# Erasing rainbow
		move	$a0, $s0		# Resetting to current coordinates to draw unicorn
		move	$a1, $s1
		
cm_right:	# Redrawing unicorn
		
		addi	$a2, $zero, WHITE
		move	$a3, $s2
		jal	draw_unicorn	# Redrawing unicorn with colors
		move	$s4, $v0	# Saving mouth coordinates
		move	$s5, $v1
		
		# Drawing legs forward then backward to give the illusion of unicorn moving its legs
		
		jal	long_pause
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		jal	move_legs	# Drawing the legs taking a step forward
		jal	long_pause
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		li	$a2, 0
		jal	move_legs	# Blacking out forward legs
		
		# Resetting back to normal legs
		
		addi	$a0, $s0, 47	# Setting $a0 and $a1 to bottom right of unicorn body
		addi	$a1, $s1, 19
		addi	$a2, $zero, WHITE	
		jal	draw_legs	# Drawing the normal legs
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		j	loop		# Moving to next input

vomit:		# Making unicorn barf rainbows by opening the mouth and drawing the rainbow

		move	$a0, $s4	# Setting parameters
		move	$a1, $s5
		jal	open_mouth	# Opening mouth
		move	$a0, $s4	# Setting parameters
		move	$a1, $s5
		jal	draw_rainbow	# Drawing the rainbow
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		li	$s2, 1		# Setting flag to indicate that the mouth is now open
		j	loop

stop_vomit:	# Making the unicorn stop barfing by closing the mouth and blacking out the rainbow
		
		move	$a0, $s4	# Setting parameters
		move	$a1, $s5
		jal	close_mouth	# Closing mouth
		move	$a0, $s4	# Setting parameters
		move	$a1, $s5
		jal	erase_rainbow	# Erasing the rainbow
		move	$a0, $s0	# Moving current coordinates to $a0 and $a1
		move	$a1, $s1
		move	$s2, $zero	# Setting flag to indicate that the mouth is now closed
		j	loop
		
exit:		li 	$v0, 10
		syscall


######################################################## FUNCTIONS ###########################################################

#---------------------------------------------------- DRAW UNICORN FUNCTION --------------------------------------------------
# Draws the unicorn starting at the coordinate given, which will be the point for the top left corner 
# of the body. Draws the body of the unicorn clockwise starting at the top, and uses the helper functions
# draw neck, draw legs, and draw tail at respective points on the body. Note also that the head is drawn 
# by the draw neck function, and horn is drawn by the draw head function
	# $a0 = starting x coordinate
	# $a1 = starting y coordinate
	# $a2 = color to draw unicorn
	# $a3 = flag for whether or not mouth is currently open (to draw unicorn accordingly)
	# Returns coordinates of the mouth in $v0 (x) and $v1 (y)
		
draw_unicorn:	# Starts with the top line of the body first, then moving clockwise to other sides

		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$ra, 16($sp)	
		sw	$s3, 12($sp)
		sw	$s2, 8($sp)
		sw	$s1, 4($sp)	
		sw	$s0, 0($sp)
		
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 48	# Drawing 48 pixels in a line to start the top of the body

draw_top:	# Draws top line of the body
		
		bge	$s1, $s0, set_right_diag1	# While pixel count < 48
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_top

set_right_diag1: # Resetting counters and adjusting coordinate
		
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s0, $zero, 4		# Drawing 4 pixels for the diagonal line
		move	$s1, $zero
		addi	$s3, $zero, 2		# Draw neck after 2 pixels
		
draw_right_diag1: # Draw a diagonal down and to the right from the pixel at the end of the top line of the body

		bge	$s1, $s0, set_right	# While pixel count < 4
		jal	draw_pixel		# Drawing the pixel
		beq	$s1, $s3, call_dneck	# Call draw neck 2 pixels into drawing right upper diagonal of the body
ret_dneck:	addi	$a0, $a0, 1		# Shifting x coordinate right one
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_right_diag1
		
set_right:	# Resetting counter

		addi	$s0, $zero, 10		# Drawing 10 pixels for the right line of the body
		move	$s1, $zero

draw_right:	# Drawing the right line of the body
		
		bge	$s1, $s0, set_right_diag2	# While pixel count < 10
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_right
		
set_right_diag2: # Resetting counters and adjusting coordinate
		
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		addi	$s0, $zero, 4		# Drawing 4 pixels for the diagonal line
		move	$s1, $zero
		
draw_right_diag2: # Making a diagonal down and to the left from the pixel at the end of the right line of the body

		bge	$s1, $s0, set_bottom	# While pixel count < 4
		jal	draw_pixel		# Drawing the pixel
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_right_diag2

set_bottom:	# Resetting counter
		
		addi	$s0, $zero, 48		# Drawing 48 pixels for the bottom line
		move	$s1, $zero
		
draw_bottom:	# Draws bottom line of the body

		bge	$s1, $s0, set_left_diag1	# While pixel count < 48
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_bottom
		
set_left_diag1: # Resetting counters and adjusting coordinate
		
		addi	$a1, $a1, -1		# Shifting y coordinate up one
		addi	$s0, $zero, 4		# Drawing 4 pixels for the diagonal line
		move	$s1, $zero
		
draw_left_diag1: # Draw a diagonal up and to the left from the pixel at the end of the bottom line of the body

		bge	$s1, $s0, set_left	# While pixel count < 4
		jal	draw_pixel		# Drawing the pixel
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		addi	$a1, $a1, -1		# Shifting y coordinate up one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_left_diag1
		
set_left:	# Resetting counter

		addi	$s0, $zero, 10		# Drawing 10 pixels for the left line of the body
		move	$s1, $zero
		addi	$s3, $zero, 7		# 7 pixels into drawing, draw the tail of the unicorn

draw_left:	# Drawing the left line of the body
		
		bge	$s1, $s0, set_left_diag2	# While pixel count < 10
		jal	draw_pixel			# Drawing the pixel
		beq	$s1, $s3, call_dtail		# Call draw tail 7 pixels into drawing the left side of the unicorn
ret_dtail:	addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_left
		
set_left_diag2: # Resetting counters and adjusting coordinate
		
		addi	$a0, $a0, 1		# Shifting x coordinate right one
		addi	$s0, $zero, 4		# Drawing 4 pixels for the diagonal line
		move	$s1, $zero
		
draw_left_diag2: # Making a diagonal up and to the right from the pixel at the end of the left line of the body

		bge	$s1, $s0, exit_draw_unicorn	# While pixel count < 4
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_left_diag2

exit_draw_unicorn: # Exiting function

		lw	$s0, 0($sp)	# Restoring necessary values
		lw	$s1, 4($sp)	
		lw	$s2, 8($sp)
		lw	$s3, 12($sp)
		lw	$ra, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

# The following are the calls to the functions to draw the other body parts of the unicorn
		
call_dneck:	# Drawing the neck

		jal	draw_neck
		j	ret_dneck		# Returning to place in main code to continue drawing the body

call_dtail:	# Drawing the tail

		jal	draw_tail
		j	ret_dtail		# Returning to place in main code to continue drawing the body



#----------------------------------------------------- DRAW NECK FUNCTION ----------------------------------------------------
# Draws the unicorn's neck, a diagonal line up and right, starting from the coordinate given (the base of the neck)
# Also calls the function to draw the unicorn's head at the end of the neck
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
	# $a3 = flag for whether or not mouth is open or not
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_neck:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 6	# Drawing a total of 6 pixels for the neck 
		
draw_neck_loop:	# Drawing the neck

		bge	$s1, $s0, exit_draw_neck	# While pixel count < 6
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_neck_loop

exit_draw_neck:	# Drawing head (and horn, which is included in the draw head function), then exiting draw neck function
		
		jal 	draw_head	# Call to draw the head
		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra
		
#----------------------------------------------------- DRAW LEGS FUNCTION ----------------------------------------------------
# Draws the unicorn's legs, alternating between drawing the close leg and the far leg
	# $a0 = x coordinate of bottom right of body
	# $a1 = y coordinate of bottom right of body
	# $a2 = color to draw legs in (either white to draw or black to erase)
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_legs:	# Setting start values and pushing necessary values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$a1, 8($sp)
		sw	$a0, 4($sp)
		sw	$ra, 0($sp)
		
		addi	$a0, $a0, -7		# Drawing first leg 7 pixels to the left of the bottom right corner of the body
		jal	draw_far_leg			# First leg is a far leg
		addi	$a0, $a0, -12		# Drawing next leg 12 pixels to the left of previous leg
		jal	draw_close_leg			# Second leg is a close leg
		addi	$a0, $a0, -12		# Drawing next leg 12 pixels to the left of previous leg
		jal	draw_far_leg			# Third leg is a far leg
		addi	$a0, $a0, -12		# Drawing next leg 12 pixels to the left of previous leg
		jal	draw_close_leg			# Fourth leg is a close leg
		
		# Exiting function
		
		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra


#-------------------------------------------------- DRAW CLOSE LEG FUNCTION --------------------------------------------------
# Draws the unicorn's leg that is closer in perspective, which is a vertical line and a small horizontal line, 
# starting from the coordinate given (where leg connects to body)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_close_leg: # Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 14	# Drawing 14 pixels in a vertical line as the leg
		
draw_cleg:	# Drawing the leg

		bge	$s1, $s0, set_cfoot	# While pixel count < 14
		jal	draw_pixel		# Drawing the pixel
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_cleg

set_cfoot: 	# Resetting counter variable and adjusting coordinate
		
		move	$s1, $zero
		addi	$s0, $zero, 4	# Drawing 4 pixels in a horizontal line as the foot
		addi	$a1, $a1, -1	# Adjusting coordinates
		addi	$a0, $a0, 1
		
draw_cfoot:	# Drawing the foot
	
		bge	$s1, $s0, exit_draw_cleg	# While pixel count < 4
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_cfoot

exit_draw_cleg:	# Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#--------------------------------------------------- DRAW FAR LEG FUNCTION ---------------------------------------------------
# Draws the unicorn's leg that is further in perspective, which is a vertical line and a small horizontal line, 
# starting from the coordinate given (where leg connects to body)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_far_leg: # Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 8	# Drawing 8 pixels in a vertical line as the leg
		
draw_fleg:	# Drawing the leg

		bge	$s1, $s0, set_ffoot	# While pixel count < 8
		jal	draw_pixel		# Drawing the pixel
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_fleg
		
set_ffoot: 	# Resetting counter variable and adjusting coordinate
		
		move	$s1, $zero
		addi	$s0, $zero, 3	# Drawing 3 pixels in a horizontal line as the foot
		addi	$a1, $a1, -1	# Adjusting coordinates
		addi	$a0, $a0, 1
		
draw_ffoot:	# Drawing the foot
	
		bge	$s1, $s0, exit_draw_fleg	# While pixel count < 3
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_ffoot

exit_draw_fleg:	# Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#----------------------------------------------------- DRAW HEAD FUNCTION ----------------------------------------------------
# Draws the unicorn's head starting at the coordinate given, also calls the function to draw
# the unicorn's horn at a specific place on the head; draws the eye at the end, after finishing drawing
# the head and the horn
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
	# $a3 = flag for whether mouth is open or not
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn,
# and saves the coordinates of the mouth into the corresponding spots in memory
		
draw_head:	# Starting with the left, bottom diagonal of the head first, then moving clockwise to other sides

		addi	$sp, $sp, -24	# Pushing necessary values
		sw	$a1, 20($sp)
		sw	$a0, 16($sp)
		sw	$s2, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 5	# Drawing 5 pixels in a diagonal line up and to the left first
		
draw_l_diag1_head: # Draw a diagonal up and to the left from the pixel at the end of the bottom line of the head

		bge	$s1, $s0, set_l_head	# While pixel count < 5
		jal	draw_pixel		# Drawing the pixel
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		addi	$a1, $a1, -1		# Shifting y coordinate up one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_l_diag1_head

set_l_head:	# Resetting counter and adjusting coordinate

		addi	$s0, $zero, 9		# Drawing 9 pixels for the left line of the head
		move	$s1, $zero

draw_l_head:	# Drawing the left line of the head
		
		bge	$s1, $s0, set_l_diag2_head	# While pixel count < 9
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_l_head
		
set_l_diag2_head: # Resetting counter and adjusting coordinate
		
		addi	$a0, $a0, 1		# Shifting x coordinate right one
		addi	$s0, $zero, 5		# Drawing 5 pixels for the diagonal line
		move	$s1, $zero
		
draw_l_diag2_head: # Making a diagonal up and to the right from the pixel at the end of the left line of the head

		bge	$s1, $s0, set_top_head		# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_l_diag2_head

set_top_head: # Resetting counters and adjusting coordinate
		
		addi	$s0, $zero, 9		# Drawing 9 pixels for the top line of the head
		move	$s1, $zero
		
draw_top_head:	# Draws top line of the head
		
		bge	$s1, $s0, set_r_diag1_head	# While pixel count < 9
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_top_head

set_r_diag1_head: # Resetting counters and adjusting coordinate
		
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s0, $zero, 5		# Drawing 5 pixels for the diagonal line
		move	$s1, $zero
		addi	$s2, $zero, 1		# 1 pixel into drawing the diagonal, draw the horn
		
draw_r_diag1_head: # Draw a diagonal down and to the right from the pixel at the end of the top line of the head

		bge	$s1, $s0, set_right_head	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		beq	$s1, $s2, call_dhorn		# 1 pixel into drawing the diagonal, draw the horn
ret_dhorn:	addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_r_diag1_head
		
set_right_head:	# Resetting counter

		addi	$s0, $zero, 9		# Drawing 9 pixels for the right line of the head
		move	$s1, $zero

draw_right_head: # Drawing the right line of the body
		
		bge	$s1, $s0, set_r_diag2_head	# While pixel count < 9
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_right_head
		
set_r_diag2_head: # Resetting counters and adjusting coordinate
		
		addi	$s0, $zero, 5		# Drawing 5 pixels for the diagonal line
		move	$s1, $zero
		
		# Saving the coordinates for the start of the mouth
		
		addi	$a1, $a1, -1		# Setting y coordinate back to top of mouth
		move	$v0, $a0		# Saving and returning place where mouth starts
		move	$v1, $a1
		addi	$a1, $a1, 1		# Setting y coordinate back
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		
		# If mouth should be open, draw it open
		
		beq	$a3, $zero, draw_r_diag2_head	# Branching to draw mouth closed if flag = 0
							# 	Fall through if mouth should be open
		move	$a0, $v0			# Resetting coordinates to mouth start
		move	$a1, $v1
		addi	$a0, $a0, -6			# Adjusting coordinates to correct starting point
		addi	$a1, $a1, 6

draw_omouth: # Resetting counter variable and color
		
		move	$s1, $zero		# $s1 = the pixel count
		addi	$s0, $zero, 5		# Drawing out a total of 5 pixels
		addi	$a1, $a1, -1		# Moving y coordinate up one

draw_omouth_left: # Drawing the left line of the mouth
		
		bge	$s1, $s0, set_draw_omouth_top	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_omouth_left

set_draw_omouth_top: # Resetting counter variable
		
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 6	# Drawing out a total of 6 pixels
		
draw_omouth_top: # Drawing the top line of the mouth
		
		bge	$s1, $s0, fin_draw_omouth	# While pixel count < 6
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_omouth_top

fin_draw_omouth: # After finished drawing open mouth, draw rest of head
		
		addi	$a0, $a0, -6			# Setting coordinates to beginning of bottom line
		addi	$a1, $a1, 6
		j	set_bottom_head			# Skipping drawing closed mouth
		
		
draw_r_diag2_head: # Making a diagonal down and to the left from the pixel at the end of the right line of the head

		bge	$s1, $s0, set_bottom_head	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_r_diag2_head

set_bottom_head: # Resetting counter
		
		addi	$s0, $zero 9		# Drawing 9 pixels for the bottom line
		move	$s1, $zero
		
draw_bottom_head: # Draws bottom line of the body

		bge	$s1, $s0, exit_draw_head	# While pixel count < 9
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_bottom_head

exit_draw_head: # Drawing the eye
		
		addi	$a0, $a0, 9		# Adjusting the coordinates
		addi	$a1, $a1, -11
		jal	draw_pixel		# Drawing the eye

		# Restoring values and exiting the function
		
		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$s2, 12($sp)
		lw	$a0, 16($sp)
		lw	$a1, 20($sp)
		addi	$sp, $sp, 24
		jr	$ra

# Drawing the horn

call_dhorn:	jal	draw_horn	# Drawing the horn
		j	ret_dhorn	# Returning to place in main code to continue drawing the body


#----------------------------------------------------- DRAW HORN FUNCTION ----------------------------------------------------
# Draws the unicorn's horn, a diagonal line up and right, starting from the coordinate given (the base of the horn)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_horn:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 7	# Drawing a total of 7 pixels for the horn
		
draw_horn_loop:	# Drawing the horn

		bge	$s1, $s0, exit_draw_horn	# While pixel count < 7
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_horn_loop

exit_draw_horn:	# Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#------------------------------------------------------ DRAW TAIL FUNCTION ---------------------------------------------------
# Draws the unicorn's tail, a diagonal line left and down, starting from the coordinate given (the base of the tail)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_tail: # Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 10	# Making tail a length of 10 pixels
		
		
draw_tail_loop:	# Drawing the neck

		bge	$s1, $s0, exit_tail		# While pixel count < 10
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_tail_loop

exit_tail:	# Exiting function
		
		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#---------------------------------------------------- OPEN MOUTH FUNCTION ----------------------------------------------------
# Drawing the mouth of the unicorn as open
# If the mouth was not open before, blacking out the bottom left of the head then draw the open mouth
# 	(this is based on the flag, $a3)
# The start of the mouth is the pixel at the base of the right line of the head (not part of the diagonal)
	# $a0 = x coordinate of mouth
	# $a1 = y coordinate of mouth
	# $a3 = flag for whether mouth is currently open; 0 = closed, 1 = open

open_mouth:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 5	# Blacking out a total of 5 pixels
		move	$a2, $zero	# Setting color to black
		
		addi	$a0, $a0, -1	# Adjusting coordinate to be the first pixel for the diagonal
		addi	$a1, $a1, 1
		
open_mouth_loop: # Blacking out pixels of closed mouth

		bge	$s1, $s0, set_omouth_left	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	open_mouth_loop

set_omouth_left: # Resetting counter variable and color
		
		move	$s1, $zero		# $s1 = the pixel count
		addi	$a2, $zero, WHITE	# Setting color to draw unicorn in white
		addi	$s0, $zero, 5		# Drawing out a total of 5 pixels
		addi	$a1, $a1, -1		# Moving y coordinate up one

omouth_left:	# Drawing the left line of the mouth
		
		bge	$s1, $s0, set_omouth_top	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	omouth_left

set_omouth_top:	# Resetting counter variable
		
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 6	# Drawing out a total of 6 pixels
		
omouth_top:	# Drawing the top line of the mouth
		
		bge	$s1, $s0, exit_open_mouth	# While pixel count < 6
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	omouth_top

exit_open_mouth: # Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#---------------------------------------------------- CLOSE MOUTH FUNCTION ---------------------------------------------------
# Blacking out the open mouth lines and redrawing the mouth to be closed
	# $a0 = x coordinate of mouth
	# $a1 = y coordinate of mouth

close_mouth:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero		# $s1 = the pixel count
		addi	$s0, $zero, 5		# Drawing a total of 5 pixels
		addi	$a2, $zero, WHITE	# Setting color to white
		
		addi	$a0, $a0, -1	# Adjusting coordinate to be the first pixel for the diagonal
		addi	$a1, $a1, 1
		
close_mouth_loop: # Drawing the pixels of closed mouth

		bge	$s1, $s0, set_cmouth_left	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, -1			# Shifting x coordinate left one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	close_mouth_loop

set_cmouth_left: # Resetting counter variable and color
		
		move	$s1, $zero		# $s1 = the pixel count
		move	$a2, $zero		# Setting color to black
		addi	$s0, $zero, 5		# Blacking out a total of 5 pixels
		addi	$a1, $a1, -1		# Moving y coordinate up one

cmouth_left:	# Blacking out the left line of the mouth
		
		bge	$s1, $s0, set_cmouth_top	# While pixel count < 5
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	cmouth_left

set_cmouth_top:	# Resetting counter variable
		
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 6	# Blacking out a total of 6 pixels
		
cmouth_top:	# Blacking out the top line of the mouth
		
		bge	$s1, $s0, exit_close_mouth	# While pixel count < 6
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	cmouth_top

exit_close_mouth: # Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra
		
#-------------------------------------------------- DRAW RAINBOW LINE FUNCTION -----------------------------------------------
# Draws a line in the rainbow, which color line is based off of parameter
	# $a0 = starting x coordinate
	# $a1 = starting y coordinate 
	# $a2 = base address of color array
	# $a3 = how far right the rainbow should stretch
	
draw_rbw_line:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero		# $s1 = the pixel count
		move	$s0, $a3		# Drawing a total of x (user given) pixels to the right
		move	$a3, $a2		# Moving color array address into $a3 for call to change_color
		lw	$a2, ($a2)		# Setting the first color of the array
		
draw_rbw_top:	# Drawing the line straight down, changing color along the way		
		
		bge	$s1, $s0, set_rbw_down 		# While pixel count < how far right the rainbow should stretch
		jal	change_color			# Changing the color
		move	$a2, $v0			# Storing new color
		jal	draw_pixel			# Drawing the pixel
		jal	pause				# Adding pause
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_rbw_top

set_rbw_down:	# Drawing 2 diagonal pixels
		
		addi 	$a1, $a1, 1		# Shifting y coordinate down one for diagonal pixel
		jal	change_color		# Changing the color
		move	$a2, $v0		# Storing new color
		jal	draw_pixel		# Drawing the pixel
		jal	pause			# Adding pause
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		jal	change_color		# Changing the color
		move	$a2, $v0		# Storing new color
		jal	draw_pixel		# Drawing the pixel
		jal	pause			# Adding pause
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		# Resetting counter and number of pixels to draw
		
		move	$s1, $zero		# $s1 = the pixel count
		addi	$s0, $s0, 43		# Length of rainbow will be 43 pixels
		
draw_rbw_down:	# Drawing the line straight down, changing color along the way		
		
		bge	$s1, $s0, exit_draw_rbw 	# While pixel count < 43
		jal	change_color			# Changing the color
		move	$a2, $v0			# Storing new color
		jal	draw_pixel			# Drawing the pixel
		jal	pause				# Adding pause
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_rbw_down

exit_draw_rbw: # Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra


#----------------------------------------------- REDRAW RAINBOW LINE FUNCTION ------------------------------------------------
# Redraws the line in the rainbow in order to add the animation effect(which color line is based off of parameter)
	# $a0 = starting x coordinate
	# $a1 = starting y coordinate 
	# $a2 = base address of color array
	# $a3 = how far right the rainbow should stretch

redraw_rbw_line:
		# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero		# $s1 = the pixel count
		move	$s0, $a3		# Drawing a total of x (user given) pixels to the right
		move	$a3, $a2		# Moving color array address into $a3 for call to change_color
		addi	$a2, $a2, 4		# Starting the redraw with second color in array
		lw	$a2, ($a2)		# Loading the color

redraw_rbw_top:	# Drawing a horizontal line, changing color along the way		
		
		bge	$s1, $s0, rd_set_rbw_down 	# While pixel count < how far right the rainbow should stretch
		jal	change_color			# Changing the color
		move	$a2, $v0			# Storing new color
		jal	draw_pixel			# Drawing the pixel
		jal	pause				# Adding pause
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	redraw_rbw_top

rd_set_rbw_down: # Drawing 2 diagonal pixels
		
		addi 	$a1, $a1, 1		# Shifting y coordinate down one for diagonal pixel
		jal	change_color		# Changing the color
		move	$a2, $v0		# Storing new color
		jal	draw_pixel		# Drawing the pixel
		jal	pause			# Adding pause
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		jal	change_color		# Changing the color
		move	$a2, $v0		# Storing new color
		jal	draw_pixel		# Drawing the pixel
		jal	pause			# Adding pause
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		# Resetting counter and number of pixels to draw
		
		move	$s1, $zero		# $s1 = the pixel count
		addi	$s0, $s0, 43		# Length of rainbow will be 43 pixels
		
redraw_rbw_down:	# Drawing the line straight down, changing color along the way		
		
		bge	$s1, $s0, exit_redraw_rbw 	# While pixel count < 43
		jal	change_color			# Changing the color
		move	$a2, $v0			# Storing new color
		jal	draw_pixel			# Drawing the pixel
		jal	pause				# Adding pause
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	redraw_rbw_down

exit_redraw_rbw: # Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra


#---------------------------------------------------- DRAW RAINBOW FUNCTION --------------------------------------------------
# Draws the rainbow using the draw rainbow line function
	# $a0 = x coordinate for mouth
	# $a1 = y coordinate for mouth

draw_rainbow:
		addi	$sp, $sp, -20		# Pushing necessary values
		sw	$s1, 16($sp)
		sw	$s0, 12($sp)
		sw	$a1, 8($sp)
		sw	$a0, 4($sp)
		sw	$ra, 0($sp)
		move	$s0, $a0		# Saving mouth coordinates
		move	$s1, $a1
		
		# Drawing line of purple shades
		
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 1		#	line should start
		la	$a2, purples		# Making outer rainbow line purple
		addi	$a3, $zero, 5		# Adjusting size of top of rainbow line
		jal	draw_rbw_line		#	purple line should be 5 pixels long
		
		# Drawing line of blue shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 2		#	line should start
		la	$a2, blues		# Making rainbow line blue
		addi	$a3, $zero, 4		# Adjusting size of top of rainbow line
		jal	draw_rbw_line		#	blue line should be 4 pixels long
		
		# Drawing line of green shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 3		#	line should start
		la	$a2, greens		# Making rainbow line green
		addi	$a3, $zero, 3		# Adjusting size of top of rainbow line
		jal	draw_rbw_line		#	green line should be 3 pixels long
		
		# Drawing line of orange/yellow shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 4		#	line should start
		la	$a2, yellows		# Making rainbow line yellow/orange
		addi	$a3, $zero, 2		# Adjusting size of top of rainbow line
		jal	draw_rbw_line		#	yellow/orange line should be 2 pixels long
		
		# Drawing line of red shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 5		#	line should start
		la	$a2, reds		# Making rainbow line red
		addi	$a3, $zero, 1		# Adjusting size of top of rainbow line
		jal	draw_rbw_line		#	red line should be 1 pixel long
		
		# Redrawing line of purple shades to add animation effect
		
		jal	check_input		# Making sure there is no new input; if there is, then exit
		bne	$v0, $zero, exit_drbw
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1		
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 1		#	line should start
		la	$a2, purples		# Making outer rainbow line purple
		addi	$a3, $zero, 5		# Adjusting size of top of rainbow line
		jal	redraw_rbw_line		#	purple line should be 5 pixels long
		
		# Redrawing line of blue shades to add animation effect
		
		jal	check_input		# Making sure there is no new input; if there is, then exit
		bne	$v0, $zero, exit_drbw
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 2		#	line should start
		la	$a2, blues		# Making rainbow line blue
		addi	$a3, $zero, 4		# Adjusting size of top of rainbow line
		jal	redraw_rbw_line		#	blue line should be 4 pixels long
		
		# Redrawing line of green shades to add animation effect
		
		jal	check_input		# Making sure there is no new input; if there is, then exit
		bne	$v0, $zero, exit_drbw
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 3		#	line should start
		la	$a2, greens		# Making rainbow line green
		addi	$a3, $zero, 3		# Adjusting size of top of rainbow line
		jal	redraw_rbw_line		#	green line should be 3 pixels long
		
		# Redrawing line of orange/yellow shades to add animation effect
		
		jal	check_input		# Making sure there is no new input; if there is, then exit
		bne	$v0, $zero, exit_drbw
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 4		#	line should start
		la	$a2, yellows		# Making rainbow line yellow/orange
		addi	$a3, $zero, 2		# Adjusting size of top of rainbow line
		jal	redraw_rbw_line		#	yellow/orange line should be 2 pixels long
		
		# Redrawing line of red shades to add animation effect
		
		jal	check_input		# Making sure there is no new input; if there is, then exit
		bne	$v0, $zero, exit_drbw
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 5		#	line should start
		la	$a2, reds		# Making rainbow line red
		addi	$a3, $zero, 1		# Adjusting size of top of rainbow line
		jal	redraw_rbw_line		#	red line should be 1 pixel long
		
exit_drbw:	lw	$ra, 0($sp)		# Restoring necessary values
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		lw	$s0, 12($sp)
		lw	$s1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#---------------------------------------------- DRAW BLACK RAINBOW LINE FUNCTION ---------------------------------------------
# Draws a line in the rainbow as black to erase the rainbow
	# $a0 = starting x coordinate
	# $a1 = starting y coordinate
	# $a3 = how far right the rainbow should stretch
	
black_rbw_line:	# Pushing values on stack and setting start values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero		# $s1 = the pixel count
		move	$s0, $a3		# Drawing a total of x (user given) pixels to the right
		li	$a2, 1			# Setting color to black
		
black_rbw_top:	# Drawing the line straight down, changing color along the way		
		
		bge	$s1, $s0, set_brbw_down 	# While pixel count < how far right the rainbow should stretch
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	black_rbw_top

set_brbw_down:	# Drawing 2 diagonal pixels
		
		addi 	$a1, $a1, 1		# Shifting y coordinate down one for diagonal pixel
		jal	draw_pixel		# Drawing the pixel
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		jal	draw_pixel		# Drawing the pixel
		addi	$a0, $a0, 1		# Moving coordinate down and to the right one
		addi	$a1, $a1, 1
		
		# Resetting counter and number of pixels to draw
		
		move	$s1, $zero		# $s1 = the pixel count
		addi	$s0, $s0, 43		# Length of rainbow will be 43 pixels
		
black_rbw_down:	# Drawing the line straight down, changing color along the way		
		
		bge	$s1, $s0, exit_black_rbw_line	# While pixel count < 43
		jal	draw_pixel			# Drawing the pixel
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	black_rbw_down

exit_black_rbw_line: # Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra


#---------------------------------------------------- ERASE RAINBOW FUNCTION -------------------------------------------------
# Erases the rainbow by drawing rainbow completely in black
	# $a0 = x coordinate for mouth
	# $a1 = y coordinate for mouth

erase_rainbow:
		addi	$sp, $sp, -20		# Pushing necessary values
		sw	$s1, 16($sp)
		sw	$s0, 12($sp)
		sw	$a1, 8($sp)
		sw	$a0, 4($sp)
		sw	$ra, 0($sp)
		move	$s0, $a0		# Saving mouth coordinates
		move	$s1, $a1
		
		# Drawing line of purple shades
		
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 1		#	line should start
		addi	$a3, $zero, 5		# Adjusting size of top of rainbow line
		jal	black_rbw_line		#	purple line should be 5 pixels long
		
		# Drawing line of blue shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 2		#	line should start
		addi	$a3, $zero, 4		# Adjusting size of top of rainbow line
		jal	black_rbw_line		#	blue line should be 4 pixels long
		
		# Drawing line of green shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 3		#	line should start
		addi	$a3, $zero, 3		# Adjusting size of top of rainbow line
		jal	black_rbw_line		#	green line should be 3 pixels long
		
		# Drawing line of orange/yellow shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 4		#	line should start
		addi	$a3, $zero, 2		# Adjusting size of top of rainbow line
		jal	black_rbw_line		#	yellow/orange line should be 2 pixels long
		
		# Drawing line of red shades
		
		move	$a0, $s0		# Moving mouth coordinates into $a0 and $a1
		move	$a1, $s1
		addi	$a0, $a0, -5		# Adjusting the coordinate to be where the next rainbow
		addi	$a1, $a1, 5		#	line should start
		addi	$a3, $zero, 1		# Adjusting size of top of rainbow line
		jal	black_rbw_line		#	red line should be 1 pixel long
		
		lw	$ra, 0($sp)		# Restoring necessary values
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		lw	$s0, 12($sp)
		lw	$s1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#------------------------------------------------- MOVE LEGS FUNCTION ------------------------------------------------
# Draws the unicorn's legs moving to make it look like it is walking
	# $a0 = x coordinate of bottom right of body
	# $a1 = y coordinate of bottom right of body
	# $a2 = color to draw legs in (either white to draw or black to erase)

move_legs:	# Setting start values and pushing necessary values
		
		addi	$sp, $sp, -12		# Pushing necessary values
		sw	$a1, 8($sp)
		sw	$a0, 4($sp)
		sw	$ra, 0($sp)
		
		addi	$a0, $a0, -7		# Drawing first leg 7 pixels to the left
		jal	draw_for_fleg			# First leg is a far leg
		addi	$a0, $a0, -12		# Drawing second leg 12 pixels to the left of the first
		jal	draw_back_cleg			# Second leg is a close leg
		addi	$a0, $a0, -12		# Drawing next leg 12 pixels to the left of previous leg
		jal	draw_for_fleg
		addi	$a0, $a0, -12		# Drawing next leg 12 pixels to the left of previous leg
		jal	draw_back_cleg
		
		# Exiting function
		
		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra

#---------------------------------------------- DRAW FORWARD FAR LEG FUNCTION ------------------------------------------------
# Draws the unicorn's leg that is further in perspective moving forward (legs are diagonal and forward compared to
#   the straught legs)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_for_fleg: # Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 3	# Drawing 6 pixels in a diagonal line down and right as the leg
					#	Count is 3 because the line is drawn as two down then one right
					#	So there are 3 groups of 2 pixels in the leg -> 6 total pixels
		
draw_ffleg_loop: # Drawing the leg

		bge	$s1, $s0, set_for_ffoot	# While group count < 3
		jal	draw_pixel		# Drawing the pixel
		addi	$a1, $a1, 1
		jal	draw_pixel
		addi	$a0, $a0, 1		# Shifting x coordinate right one
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_ffleg_loop

set_for_ffoot: 	# Resetting counter variable and adjusting coordinate
		
		move	$s1, $zero
		addi	$s0, $zero, 3	# Drawing 3 pixels in a diagonal line up and right as the foot
		addi	$a0, $a0, -1
		
draw_fffoot_loop: # Drawing the foot
	
		bge	$s1, $s0, exit_for_fleg		# While pixel count < 3
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, -1			# Shifting y coordinate up one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_fffoot_loop

exit_for_fleg:	# Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

#---------------------------------------------- DRAW BACKWARD CLOSE LEG FUNCTION ----------------------------------------------
# Draws the unicorn's leg that is closer in perspective moving backward (legs are diagonal and backward compared to
#   the straight legs)
	# $a0 = starting x value
	# $a1 = starting y value
	# $a2 = color
# This function also resets $a0 and $a1 to the original coordinates once it is done so the unicorn can keep being drawn

draw_back_cleg: # Pushing values on stack and setting start values
		
		addi	$sp, $sp, -20	# Pushing necessary values
		sw	$a1, 16($sp)
		sw	$a0, 12($sp)
		sw	$s1, 8($sp)
		sw	$s0, 4($sp)	
		sw	$ra, 0($sp)	
		move	$s1, $zero	# $s1 = the pixel count
		addi	$s0, $zero, 5	# Drawing 10 pixels in a diagonal line down and right as the leg
					#	Count is 10 because the line is drawn as two down then one right
					#	So there are 5 groups of 2 pixels in the leg -> 10 total pixels
		
draw_bcleg_loop: # Drawing the leg

		bge	$s1, $s0, set_back_cfoot # While group count < 5
		jal	draw_pixel		 # Drawing the pixel
		addi	$a1, $a1, 1
		jal	draw_pixel
		addi	$a0, $a0, -1		# Shifting x coordinate left one
		addi	$a1, $a1, 1		# Shifting y coordinate down one
		addi	$s1, $s1, 1		# Incrementing the pixel count by one
		j	draw_bcleg_loop

set_back_cfoot: # Resetting counter variable and adjusting coordinate
		
		move	$s1, $zero
		addi	$s0, $zero, 4	# Drawing 4 pixels in a diagonal line up and right as the foot
		addi	$a0, $a0, -1
		
draw_bcfoot_loop: # Drawing the foot
	
		bge	$s1, $s0, exit_back_cleg	# While pixel count < 4
		jal	draw_pixel			# Drawing the pixel
		addi	$a0, $a0, 1			# Shifting x coordinate right one
		addi	$a1, $a1, 1			# Shifting y coordinate down one
		addi	$s1, $s1, 1			# Incrementing the pixel count by one
		j	draw_bcfoot_loop

exit_back_cleg:	# Exiting function

		lw	$ra, 0($sp)	# Restoring necessary values
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$a0, 12($sp)
		lw	$a1, 16($sp)
		addi	$sp, $sp, 20
		jr	$ra

		
#---------------------------------------------------- DRAW PIXEL FUNCTION ----------------------------------------------------
# Draws a pixel in at the coordinate specified
	# $a0 = x
	# $a1 = y
	# $a2 = color

draw_pixel:	# $t1 = base address + 4 * (x + y * width)
		
		mul	$t1, $a1, WIDTH		# y * width
		add	$t1, $t1, $a0		# + x
		mul	$t1, $t1, 4		# (x + y * width) * 4 = the offset
		add	$t1, $t1, $gp		# adding it to the base address
		sw	$a2, ($t1)		# storing the color at the location
		jr	$ra

#--------------------------------------------------- CHANGE COLOR FUNCTION ---------------------------------------------------
# Changes the color to the next color in the array colors
	# $a2 = current color
	# $a3 = address of color array
	# Returns new color in $v0
	
change_color:	# Looping through array to find the current color

		move	$t0, $a3
		lw	$t3, 8($a3)		# Storing last color of array in $t3
		
color_loop:	lw	$t1, ($t0)
		beq	$a2, $t1, found_color	# If the color has been found
		addi	$t0, $t0, 4		# Else, check next color
		j	color_loop


found_color:	# Changing the current color to the next color

		beq	$t1, $t3, last_color	# If it's the last color in the array, branch
		addi	$t2, $t0, 4		
		lw	$v0, ($t2)		# Otherwise, the next array element is the next color
		j	exit_color

last_color:	move	$t2, $a3
		lw	$v0, ($t2)		# Making the next color the first color in the array

exit_color:	jr	$ra


#----------------------------------------------- CHECK FOR INPUT FUNCTION ----------------------------------------------------
# Checks if any input has been given
	# $v0 = flag for if there is input, 1 if there is and 0 if not

check_input:	# Checking for input
		
		lw	$t0, 0xffff0000
		beq 	$t0, $zero, set_zero		# If no input is given, set flag to zero
		li	$v0, 1				# Otherwise, set flag to one
		j	exit_cinput

set_zero:	move	$v0, $zero

exit_cinput:	jr	$ra



#---------------------------------------------------- PAUSE FUNCTION ---------------------------------------------------------
# Adds a pause, for between drawings of rainbow pixels to make the animation effect on the rainbow easier to see

pause:
	addi	$sp, $sp, -4	# Pushing necessary values	
	sw	$a0, ($sp)
	
	li	$v0, 32		# Syscall to pause
	li	$a0, 3
	syscall
	
	lw	$a0, ($sp)	# Restoring necessary values
	addi	$sp, $sp, 4

	jr	$ra

#---------------------------------------------------- LONG PAUSE FUNCTION ---------------------------------------------------------
# Adds a long pause, for between drawings of legs to make the walking effect easier to see

long_pause:
	addi	$sp, $sp, -4	# Pushing necessary values	
	sw	$a0, ($sp)
	
	li	$v0, 32		# Syscall to pause
	li	$a0, 100
	syscall
	
	lw	$a0, ($sp)	# Restoring necessary values
	addi	$sp, $sp, 4

	jr	$ra
