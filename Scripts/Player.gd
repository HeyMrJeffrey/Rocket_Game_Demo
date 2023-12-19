extends RigidBody3D

@export_range(750.0,3000.0) var thrust: float = 1000.0
@export var torque_thrust: float = 100.0

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false


func _process(delta: float) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta *thrust)
		if rocket_audio.playing == false:
			rocket_audio.play()
			booster_particles.emitting = true
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))     
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false           
	
func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("crash_sequence!")
	explosion_particles.emitting = true
	explosion_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_file: String) -> void:
	print("complete_level!")
	success_audio.play()
	success_particles.emitting = true
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
