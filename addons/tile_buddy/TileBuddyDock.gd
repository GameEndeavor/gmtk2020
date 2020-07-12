tool
extends PanelContainer

signal debug()

const CORNERS = [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]
const BITMASK_TILESET : TileSet = preload("res://addons/tile_buddy/bitmask_tileset.tres")
const OUTPUT_TILES : Vector2 = Vector2(12, 4)

onready var option_button = $VBoxContainer/HSplitContainer/OptionButton

signal file_updated(path)

var bind_ref = []

func _ready():
	_init_bind_ref()

# Triggered when the user presses the button to generate textures
# Iterates through all added textures, generating an auto-tile for each
func _on_GenerateButton_pressed():
	for i in option_button.get_item_count():
		var file_path = option_button.get_item_text(i)
		generate_auto_tile(file_path)

# Creates the base texture that will be used for the output image
func _generate_texture(tile_size : Vector2) -> Image:
	var image = Image.new()
	# Create texture to accommodate enough tiles (12 x 4)
	image.create(OUTPUT_TILES.x * tile_size.x, OUTPUT_TILES.y * tile_size.y, false, Image.FORMAT_RGBA8)
	# Make completely transmparent
	image.fill(Color(1.0, 1.0, 1.0, 0.0))
	return image

# Starting method to generate the entire auto-tile
func generate_auto_tile(input_file_path : String):
	# Append `_autotile` to the end of the input texture file path
	var output_file_path = input_file_path.get_basename() + "_autotile.png"
	var texture = load(input_file_path)
	var input_image = texture.get_data()
	var tile_size = texture.get_size() / Vector2(5, 3)
	var output_image = _generate_texture(tile_size)
	# Iterate for the number of output tiles to generate
	for y in OUTPUT_TILES.y:
		for x in OUTPUT_TILES.x:
			_generate_tile(Vector2(x, y), input_image, output_image, tile_size)
	output_image.save_png(output_file_path)
	emit_signal("file_updated", output_file_path)

# Where the magic happens. This takes an (x, y) cordinate, get the needed textures from the
# input_image, and uses that to generate the tile needed for the output_image
func _generate_tile(coord : Vector2, input_image : Image, output_image : Image, tile_size : Vector2):
	# Each tile is subdivided into 4 sections
	for i in 4:
		# Get the bitmask, so we know what textures to get
		var bitmask = BITMASK_TILESET.autotile_get_bitmask(0, coord)
		if bitmask == 0:
			continue
		var x_mask = bind_ref[1][CORNERS[i].y * 2]
		var y_mask = bind_ref[CORNERS[i].x * 2][1]
		var index_offset = Vector2()
		index_offset.x = 0 if i % 2 == 0 else 1
		index_offset.y = 0 if i < 2 else 1
		var corner_offset = (index_offset * (tile_size / 2.0))

		# Find the texture position to use for this subtile
		# TODO: Note which conditions handle which tiles and how logic works
		var src_rect = Rect2(Vector2.ZERO, tile_size / 2.0)
		if bitmask & bind_ref[CORNERS[i].x * 2][CORNERS[i].y * 2]:
			src_rect.position = Vector2.ONE * tile_size + corner_offset
		else:
			if !(bitmask & x_mask) && !(bitmask & y_mask):
				src_rect.position = Vector2.ZERO * tile_size + (index_offset * (tile_size * 2)) + corner_offset
			elif !(bitmask & x_mask) && bitmask & y_mask:
				src_rect.position = Vector2.RIGHT * tile_size + (index_offset * Vector2.DOWN * (tile_size * 2)) + corner_offset
			elif bitmask & x_mask && !(bitmask & y_mask):
				src_rect.position = Vector2.DOWN * tile_size + (index_offset * Vector2.RIGHT * (tile_size * 2)) + corner_offset
			else:
				src_rect.position = Vector2(4, 1) * tile_size - corner_offset
		# Apply the sub-tile texture to the output image
		output_image.blit_rect(input_image, src_rect, coord * tile_size + corner_offset)

# TODO: Test!
# Creates an array of bitmasks that represent the 3x3 bitmask of a tile
func _init_bind_ref():
	bind_ref.resize(3)
	for x in 3:
		bind_ref[x] = []
		bind_ref[x].resize(3)
		for y in 3:
			bind_ref[x][y] = 1 << x + y * 3
