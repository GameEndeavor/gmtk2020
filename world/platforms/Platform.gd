extends Node2D

signal screen_exited()
signal screen_entered()

func _ready():
	init_visibility_shape()

func init_visibility_shape():
	var vn2d = VisibilityNotifier2D.new()
	add_child(vn2d)
	var used_rect = get_node("Ground").get_used_rect()
	vn2d.rect = Rect2(used_rect.position, used_rect.size * 16)
	vn2d.name = "vn2d"
	vn2d.connect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")
	vn2d.connect("screen_entered", self, "_on_VisibilityNotifier2D_screen_entered")

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("screen_exited")

func _on_VisibilityNotifier2D_screen_entered():
	emit_signal("screen_entered")
