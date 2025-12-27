extends TileMapLayer

@export var has_medium_stars: bool = false
@export var has_big_stars: bool = false

# Size of the background in tiles
@export var background_width: int = 100
@export var background_height: int = 100

# Star density (0.0 = all blank, 1.0 = all stars)
@export_range(0.0, 1.0) var star_density: float = 0.3

const TILE_SOURCE_ID: int = 1

# Star tiles
@onready var star_tiles: Array[Vector2i] = get_star_tiles()


func _ready() -> void:
	generate_background()


func get_star_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	
	for i in range(3):
		for j in range(3):
			tiles.append(Vector2i(i, j))
	
	if not has_medium_stars:
		tiles.erase(Vector2i(2, 1))
		tiles.erase(Vector2i(2, 2))
	
	if not has_big_stars:
		tiles.erase(Vector2i(0, 0))
	
	return tiles


func generate_background() -> void:
	# Clear any existing tiles
	clear()
	
	# Generate random tiles for the background area
	for x: int in range(int(-background_width / 2.0), int(background_width / 2.0)):
		for y: int in range(int(-background_height / 2.0), int(background_height / 2.0)):
			var tile_to_use: Vector2i
			
			# Use density to determine if this tile should be a star or blank
			if randf() < star_density:
				# Pick a random star tile
				tile_to_use = star_tiles[randi() % star_tiles.size()]
				
				# Set the tile at this position
				set_cell(Vector2i(x, y), TILE_SOURCE_ID, tile_to_use)
