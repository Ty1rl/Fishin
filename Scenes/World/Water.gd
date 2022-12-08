extends MeshInstance

var rng = RandomNumberGenerator.new()

func _on_WaterArea_body_entered(body):
	$WaterPlayer.set_pitch_scale(rng.randf_range(0.33,1))
	$WaterPlayer.playing = true
	if body.is_in_group("Fish"):
		body.in_water = true


func _on_WaterArea_body_exited(body):
	if body.is_in_group("Fish"):
		body.in_water = false
