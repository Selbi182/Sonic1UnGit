; ---------------------------------------------------------------------------
; Sprite mappings - explosion from when	a boss is destroyed
; ---------------------------------------------------------------------------
Map_ExplodeBomb_internal:
		dc.w byte_8ED0-Map_ExplodeBomb
		dc.w byte_8F16-Map_ExplodeBomb
		dc.w byte_8F1C-Map_ExplodeBomb
		dc.w byte_8EE2-Map_ExplodeBomb
		dc.w byte_8EF7-Map_ExplodeBomb
byte_8F16:	dc.b 1
		dc.b $F0, $F, 0, $40, $F0
byte_8F1C:	dc.b 1
		dc.b $F0, $F, 0, $50, $F0
		even