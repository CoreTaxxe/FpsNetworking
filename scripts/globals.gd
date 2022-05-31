extends Node

var DEFAULT_IP = "94.114.206.172"
var DEFAULT_PORT = 5555

var lobby_wait_time = 1
var game_wait_time = 1

var settings_scene_path = "res://scenes/settings/settings.tscn"
var create_join_game_path = "res://scenes/create_join_game/create_join_game.tscn"
var lobby_scene_path = "res://scenes/lobby/lobby.tscn"
var menu_scene_path = "res://scenes/menu/menu.tscn"
var main_game_scene = "res://scenes/main/main.tscn"

var mouse_sensitivity = 0.5
var mouse_sensitivity_modifier = 10.0

var main_music_volume = 0

var network_tick_rate = 60
