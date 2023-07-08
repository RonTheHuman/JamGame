extends Control

enum Tile { NONE = 0, PLAYER = 1, BOX = 2, WALL = 3, SENSOR = 4}

var selected_tile = Tile.NONE


func _on_box_button_pressed():
	selected_tile = Tile.BOX


func _on_sensor_button_pressed():
	selected_tile = Tile.SENSOR
