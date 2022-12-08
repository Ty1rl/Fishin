extends RigidBody

export var speed = 4

var hooked = false
var in_water = false
var target
var direction = Vector3.ZERO

var rng = RandomNumberGenerator.new()

onready var meshs = $Meshs
onready var body = $Meshs/Body
onready var tail = $Meshs/Tail

onready var in_mat = preload("res://Scenes/Fish/fish_in_water.material")
onready var out_mat = preload("res://Scenes/Fish/fish_out_water.material")

const FLOAT_EPSILON = 0.01
static func compare_floats(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon

func _ready():
	meshs.set_as_toplevel(true)

func _physics_process(delta):
	if hooked:
		global_transform.origin = target.global_transform.origin
	elif in_water and target != null:
		direction = target.translation - translation
		direction = target.translation - translation
		direction = direction.normalized()
		add_central_force(direction * speed)
	
	if in_water:
		body.set_surface_material(0,in_mat)
		tail.set_surface_material(0,in_mat)
	else:
		body.set_surface_material(0,out_mat)
		tail.set_surface_material(0,out_mat)
	
	meshs.translation = translation
	if global_transform.origin != global_transform.origin + direction:
		meshs.look_at(global_transform.origin + direction,Vector3.UP)

func _on_SwimTimer_timeout():
	if in_water and target == null and !hooked:
		rng.randomize()
		$SwimTimer.wait_time = rng.randi_range(1,3)
		direction = Vector3(rng.randi_range(-1,1),0,rng.randi_range(-1,1))
		direction = direction.normalized()
		apply_central_impulse(direction * speed)
	
	if in_water and hooked:
		$SplashParticles.emitting = true
		$SplashPlayer.set_pitch_scale(rng.randf_range(0.33,1))
		$SplashPlayer.play()
	else:
		$SplashParticles.emitting = false


func _on_Area_body_entered(body):
	if body.is_in_group("Hook"):
		target = body


func _on_Area_body_exited(body):
	if body.is_in_group("Hook"):
		target = null
