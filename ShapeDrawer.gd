tool extends Sprite

export (Color) var color = Color.white setget set_color
export var shape : Shape2D setget set_shape

func _ready():
	connect("script_changed", self, "update")

func set_color(value):
	color = value
	update()

func set_shape(value):
	shape = value
	shape.connect("changed", self, "update")
	update()

func _draw():
	if shape == null: return
	
	if shape is CircleShape2D:
		draw_circle(Vector2.ZERO + offset, shape.radius, color)
	elif shape is RectangleShape2D:
		var rect = Rect2(-shape.extents + offset, shape.extents * 2.0)
		draw_rect(rect, color)
	elif shape is CapsuleShape2D:
		var upper_circle_position = Vector2.ZERO + Vector2(0, shape.height * 0.5) + offset
		draw_circle(upper_circle_position, shape.radius, color)
		
		var lower_circle_position = -Vector2(0, shape.height * 0.5) + offset
		draw_circle(lower_circle_position, shape.radius, color)
		
		var rect_position = -Vector2(shape.radius, shape.height * 0.5) + offset
		var rect = Rect2(rect_position, Vector2(shape.radius * 2, shape.height))
		draw_rect(rect, color)
