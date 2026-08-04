; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if an object has gone off screen:
; - If it hasn't, queue the sprite for display.
; - If it has, try to find the relevant entry in the respawn table to clear
;   the respawn block flag (i.e. remember its state), and delete the object.
; ---------------------------------------------------------------------------

RememberState:
		out_of_range.w	.offscreen			; check if object is off-screen, branch if so
		bra.w	DisplaySprite				; object is on-screen, display sprite
; ---------------------------------------------------------------------------

.offscreen:
		respawn_entry.w	DeleteObject			; get respawn entry for this object; branch to DeleteObject if none exists
		bclr	#7,(a2)					; clear respawn table entry, so object manager can load this object again

	.delete:
		bra.w	DeleteObject				; delete the object
; End of function RememberState