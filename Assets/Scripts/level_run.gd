extends Node

@export var base_speed: float = 150.0
@export var speed_increase: float = 5.0   # +5 px/sec toutes les 5 sec
@export var max_speed: float = 600.0
@onready var tilemap1: TileMapLayer = $TileMap1
@onready var tilemap2: TileMapLayer = $TileMap2
@onready var player: CharacterBody2D = $Player

var speed: float
var time_elapsed: float = 0.0
var map_width: float

func _ready():
	speed = base_speed
	var rect = tilemap1.get_used_rect()
	map_width = rect.size.x * tilemap1.tile_set.tile_size.x

	tilemap2.position.x = tilemap1.position.x + map_width
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	hud.update_coins_display()

func _process(delta):
	time_elapsed += delta
	speed = min(base_speed + speed_increase * time_elapsed, max_speed)
	
	# Scroll du terrain
	tilemap1.position.x -= speed * delta
	tilemap2.position.x -= speed * delta
	
	# Recyclage des tilemaps
	if tilemap1.position.x <= -map_width:
		tilemap1.position.x = tilemap2.position.x + map_width
	elif tilemap2.position.x <= -map_width:
		tilemap2.position.x = tilemap1.position.x + map_width
