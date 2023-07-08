extends Node2D

var player_scn = preload("res://Scenes/Player.tscn")
var box_scn = preload("res://Scenes/Box.tscn")
var wall_scn = preload("res://Scenes/Wall.tscn")
var sensor_scn = preload("res://Scenes/Sensor.tscn")

enum Tile { NONE = 0, PLAYER = 1, BOX = 2, WALL = 3, SENSOR = 4}
enum Action { UP, RIGHT, DOWN, LEFT, WAIT }

var tile_to_scn := { Tile.PLAYER: player_scn, Tile.BOX: box_scn, 
					Tile.WALL: wall_scn, Tile.SENSOR: sensor_scn }

var layer1 := [[0, 0, 0, 0, 0],
			   [0, 0, 0, 0, 4],
			   [0, 3, 3, 3, 3],
			   [0, 0, 0, 0, 0],
			   [0, 0, 0, 0, 0]] 
var layer2 := [[0, 0, 0, 0, 0],
			   [0, 1, 0, 2, 0],
			   [0, 0, 0, 0, 0],
			   [0, 0, 0, 0, 0],
			   [0, 0, 0, 0, 0]]
var level_w: int = len(layer1[0])
var level_h: int = len(layer1)
var player_loc: Vector2
var tile_size: int = 64
var grid_start := Vector2(0, 0)

func _ready():
	var found = false 
	for i in range(level_h):
		for j in range(level_w):
			if layer2[i][j] == Tile.PLAYER:
				player_loc = Vector2(j, i)
				found = true
				break
		if found:
			break
	print(player_loc)

func _input(event):
	if event.is_action_pressed("Up"):
		next_state(Action.UP)
	if event.is_action_pressed("Right"):
		next_state(Action.RIGHT)
	if event.is_action_pressed("Down"):
		next_state(Action.DOWN)
	if event.is_action_pressed("Left"):
		next_state(Action.LEFT)
	if event.is_action_pressed("Wait"):
		next_state(Action.WAIT)

func next_state(action: Action):
	if action == Action.WAIT:
		pass
	var move_vec = Vector2(0, 0)
	if action == Action.UP:
		move_vec = Vector2(0, -1)
	if action == Action.RIGHT:
		move_vec = Vector2(1, 0)	
	if action == Action.DOWN:
		move_vec = Vector2(0, 1)
	if action == Action.LEFT:
		move_vec = Vector2(-1, 0)
	var new_loc = player_loc + move_vec
	print(new_loc)
	# if out of bounds
	if new_loc.x < 0 or new_loc.x >= level_w or \
			new_loc.y < 0 or new_loc.y >= level_h:
			pass
	# if moving into wall
	if layer1[new_loc.y][new_loc.x] == Tile.WALL:
		pass
	# if moving into empty
	if layer1[new_loc.y][new_loc.x] == Tile.NONE:
		layer2[player_loc.y][player_loc.x] = Tile.NONE
		player_loc = new_loc
		layer2[player_loc.y][player_loc.x] = Tile.PLAYER
	draw_state()
	

func draw_state():
	for child in $GridTile.get_children():
		child.queue_free()
	for i in range(level_h):
		for j in range(level_w):
			if layer1[i][j] != Tile.NONE:
				var tile_scene = tile_to_scn[layer1[i][j]].instantiate()
				tile_scene.position = grid_start + tile_size * Vector2(j, i)
				$GridTile.add_child(tile_scene)
			if layer2[i][j] != Tile.NONE:
				var tile_scene = tile_to_scn[layer2[i][j]].instantiate()
				tile_scene.position = grid_start + tile_size * Vector2(j, i)
				$GridTile.add_child(tile_scene)
