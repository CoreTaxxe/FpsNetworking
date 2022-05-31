extends Weapon

onready var shell_scene = preload("res://scenes/weapons/stg_44/shells/shells.tscn")
onready var projectile_scene = preload("res://scenes/weapons/stg_44/bullets/bullets.tscn")
onready var decal_scene = preload("res://scenes/weapons/stg_44/decals/decal.tscn")

onready var muzzle = get_node("muzzle")
onready var shells = get_node("shells")

func _init():
	ammo = 30
	damage = 15
	fire_rate = 20
	tag = "Stg. 44"
	
func _ready():
	var _tmp = shell_scene.instance()
	add_child(_tmp)
	remove_child(_tmp)
	
	_tmp = projectile_scene.instance()
	add_child(_tmp)
	remove_child(_tmp)
	
	_tmp = decal_scene.instance()
	add_child(_tmp)
	remove_child(_tmp)

	._onready()
	
func add_decal(ray_cast):
	
	var dec = decal_scene.instance()
	#ray_cast.get_collider()
	get_tree().get_root().add_child(dec)
	dec.global_transform.origin = ray_cast.get_collision_point()
	
	var vec = Vector3.DOWN
	
	if ray_cast.get_collision_normal() == Vector3(0,1,0):
		vec = Vector3.RIGHT
		
	if ray_cast.get_collision_normal() == Vector3(0,-1,0):
		vec = Vector3.RIGHT
	
	dec.look_at(
		ray_cast.get_collision_point() + ray_cast.get_collision_normal(),vec
	)


func fire(pos : Vector3):

	var _tmp_bullet = projectile_scene.instance()
	
	_tmp_bullet.scale = Vector3(0.05,0.05,0.05)
	muzzle.add_child(_tmp_bullet)
	_tmp_bullet.global_transform.origin = muzzle.global_transform.origin
	_tmp_bullet.set_target(pos)
	
	var _tmp_shell = shell_scene.instance()
	
	add_child(_tmp_shell)
	
	_tmp_shell.global_transform.origin = shells.global_transform.origin
	_tmp_shell.scale = Vector3(0.05,0.05,0.05)
	_tmp_shell.look_at(pos,Vector3.UP)
	
	.fire(pos)
	
