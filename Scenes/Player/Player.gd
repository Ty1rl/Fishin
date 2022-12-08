extends KinematicBody

enum states{idle,cast}
var state = states.idle

var rng = RandomNumberGenerator.new()

var on_line = []

var sensitivity = 1

var speed = base_speed
const base_speed = 2
const sprint_speed = 4
const jump = 4
const gravity = -20

var direction:Vector3
var velocity_h:Vector3
var velocity_v = Vector3(0,-20,0)
var snap

onready var arm_base = $ArmBase
onready var arm = $ArmBase/SpringArm
onready var camera = $ArmBase/SpringArm/Camera

var step = true
onready var left_foot = $LeftFoot
onready var right_foot = $RightFoot
onready var left_ray = $LeftRay
onready var right_ray = $RightRay
onready var walk_point = $WalkPoint

func _ready():
	camera.set_physics_interpolation_mode(Node.PHYSICS_INTERPOLATION_MODE_OFF)
	arm.set_as_toplevel(true)
	
	walk_point.set_as_toplevel(true)
	left_foot.set_as_toplevel(true)
	right_foot.set_as_toplevel(true)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		arm_base.rotate_y(deg2rad(-event.relative.x) * sensitivity)
		#arm.rotate_x(deg2rad(-event.relative.y) * sensitivity)
		#arm.rotation.x = clamp(arm.rotation.x, deg2rad(-70), deg2rad(0))
	
	if Input.is_action_just_pressed("cast") and state == states.idle:
		$AnimationPlayer.play("Cast")
		state = states.cast
	elif Input.is_action_just_pressed("cast") and state == states.cast:
		$AnimationPlayer.play("Retract")
		state = states.idle
		
	if Input.is_action_just_pressed("unhook"):
		if !on_line.empty():
			for fish in on_line:
				fish.hooked = false
			on_line.clear()

func _physics_process(delta):
	# horizontal
	direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity_h = arm_base.transform.basis.xform(direction.normalized() * speed)
	
		# vertical
	if is_on_floor():
		if direction != Vector3.ZERO and $WalkTimer.is_stopped():
			$WalkTimer.start()
			$Walk.set_pitch_scale(rng.randf_range(0.25,1))
			$Walk.play()
		
		$WalkTimer.set_wait_time(0.2)
		if Input.is_action_pressed("move_sprint"):
			$WalkTimer.set_wait_time(0.11)
			if direction != Vector3.ZERO:
				$WalkParticles.set_emitting(true)
			else:
				$WalkParticles.set_emitting(false)
			speed = sprint_speed
		else:
			$WalkParticles.set_emitting(false)
			speed = base_speed
		
		if Input.is_action_just_pressed("move_jump"):
			snap = Vector3.ZERO
			velocity_v.y = jump
		else:
			snap = -get_floor_normal()
			velocity_v.y = 0
	else:
		snap = Vector3.DOWN
		velocity_v.y += gravity * delta
	
	# rotation
	if direction != Vector3.ZERO:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity_h.x, -velocity_h.z), 8 * delta)
	
	# apply movement
	move_and_slide_with_snap(velocity_h + velocity_v, snap, Vector3.UP, false, 4, 0.785398, true)
	
	if global_transform.origin.distance_to(walk_point.global_transform.origin) > 0.33:
		walk_point.global_transform.origin = global_transform.origin
		if step:
			if left_ray.is_colliding():
				left_foot.global_transform.origin = left_ray.get_collision_point()
			else:
				left_foot.global_transform.origin = left_ray.global_transform.origin
			step = false
		else:
			if right_ray.is_colliding():
				right_foot.global_transform.origin = right_ray.get_collision_point()
			else:
				right_foot.global_transform.origin = right_ray.global_transform.origin
			step = true

func _process(_delta):
	arm.global_transform.origin = arm_base.get_global_transform_interpolated().origin
	arm.rotation.y = arm_base.rotation.y
	arm.rotation.z = 0


func _on_Menu_sensitivity_change(value):
	sensitivity = value


func _on_FishingPole_hooked(fish):
	on_line.append(fish)
