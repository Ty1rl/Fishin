extends Spatial

signal hooked(fish)

func _ready():
	$Hook.set_as_toplevel(true)


func _on_Hook_body_entered(body):
	if body.is_in_group("Fish"):
		body.hooked = true
		emit_signal("hooked",body)
