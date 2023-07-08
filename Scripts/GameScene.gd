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
			   [0, 0, 3, 3, 3],
			   [0, 0, 0, 0, 0],
			   [0, 0, 0, 0, 4]] 
var layer2 := [[0, 0, 0, 0, 0],
			   [0, 1, 0, 2, 0],
			   [0, 2, 0, 0, 0],
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
	$GridTile.region_rect = Rect2(grid_start, 
				tile_size * Vector2(level_w, level_h))
	$Camera2D.position = grid_start + (tile_size / 2) * Vector2(level_w, level_h)
	draw_state()

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
	draw_state()

func is_blocked(location: Vector2) -> bool:
	if location.x < 0 or location.x >= level_w or \
			location.y < 0 or location.y >= level_h or \
				layer1[location.y][location.x] == Tile.WALL:
		return true
	return false
	

func next_state(action: Action):
	if action == Action.WAIT:
		return
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
	if is_blocked(new_loc):
		return
	# if moving into box
	if layer2[new_loc.y][new_loc.x] == Tile.BOX:
		var new_box_loc = new_loc + move_vec
		if is_blocked(new_box_loc):
			return
		if layer2[new_box_loc.y][new_box_loc.x] == Tile.BOX: # no multipush (yet)
			return
		layer2[player_loc.y][player_loc.x] = Tile.NONE
		player_loc = new_loc
		layer2[player_loc.y][player_loc.x] = Tile.PLAYER
		layer2[new_box_loc.y][new_box_loc.x] = Tile.BOX
	# if moving into empty
	if layer1[new_loc.y][new_loc.x] == Tile.NONE or \
				layer1[new_loc.y][new_loc.x] == Tile.SENSOR:
		layer2[player_loc.y][player_loc.x] = Tile.NONE
		player_loc = new_loc
		layer2[player_loc.y][player_loc.x] = Tile.PLAYER

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
