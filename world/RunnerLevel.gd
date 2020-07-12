extends Node2D

const PLATFORM_SCENES = [
	preload("res://world/platforms/Platform1.tscn"),
	preload("res://world/platforms/Platform2.tscn"),
	preload("res://world/platforms/Platform3.tscn"),
	preload("res://world/platforms/Platform4.tscn"),
	preload("res://world/platforms/Platform5.tscn"),
	preload("res://world/platforms/Platform6.tscn"),
	preload("res://world/platforms/Platform7.tscn"),
	preload("res://world/platforms/Platform8.tscn"),
]

var platform_pool = []
var active_platforms = []

onready var platforms = $Platforms
var prev_platform = null

func _ready():
	gen_platforms()
	make_spawner_platform()
	call_deferred("make_connections")

func make_connections():
	$Entities/Player.connect("killed", Globals.game, "restart")

func gen_platforms():
	for i in 3:
		for p in PLATFORM_SCENES.size():
			var platform = PLATFORM_SCENES[p].instance()
			platform_pool.append(platform)
			platform.script = preload("res://world/platforms/Platform.gd")

func make_spawner_platform():
	var platform = PLATFORM_SCENES[0].instance()
	platform.script = preload("res://world/platforms/Platform.gd")
	platforms.add_child(platform)
	platform.position.x -= 32
	active_platforms.append(platform)
	platform.connect("screen_exited", self, "retire_platform", [platform])
	platform.connect("screen_entered", self, "spawn_platform")
	
	prev_platform = platform

func spawn_platform():
	var idx = randi() % platform_pool.size()
	var platform = platform_pool[idx]
	var spacing = 4 * 16
	var width = prev_platform.get_node("Ground").get_used_rect().end.x * 16
	var start = prev_platform.global_position.x + width + spacing
	platforms.add_child(platform)
	platform.global_position.x = start
	platform.global_position.y = ((randi() % 3) - 1) * 16
	platform.connect("screen_exited", self, "retire_platform", [platform])
	platform.connect("screen_entered", self, "spawn_platform")
	
	platform_pool.remove(idx)
	active_platforms.append(platform)
	prev_platform = platform

func retire_platform(platform):
	platform.disconnect("screen_exited", self, "retired_platform")
	platform.disconnect("screen_entered", self, "spawn_platform")
	active_platforms.erase(platform)
	platform_pool.append(platform)
	platforms.remove_child(platform)
