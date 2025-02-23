extends Node3D

var local_calculated_velocity : Vector3
var current_pos : Vector3
var previous_pos : Vector3
@onready var state_machine = $AnimationTree.get("parameters/playback")
signal position_changed 
var Shooting : bool

func _ready() -> void:
	position_changed.connect(on_position_changed)
	state_machine.travel("Idle")
	$AnimationGame/AnimationPlayer.set_speed_scale(2) 

func look_at_direction(direction : Vector3):
	var up = Vector3(0, 1, 0)
	
	direction = direction.normalized()
	if global_transform.origin + direction == global_transform.origin:
		return
	if direction.cross(up).length() < 0.0001:
		return
		
	look_at(global_transform.origin + direction , up , true)


	
func _process(delta: float) -> void:
	rotation_degrees.x = 0
	rotation_degrees.z = 0
	
	current_pos = position
	if !Shooting:
		state_machine.travel("Idle")
	if current_pos != previous_pos:
		position_changed.emit()
		previous_pos = current_pos


func on_position_changed():
	if !Shooting:
		state_machine.travel("RunFoots")


@rpc("authority")
func shoot(id):
	#print(id , "shoot")
	Shooting = true
	if id == self.name and Shooting:
		state_machine.travel("Shoot")
		#var _tween = create_tween()
		var rand_rot = randf()
		var target_rot = rotation_degrees.y + 360


		#await _tween.tween_property(self , "rotation_degrees:y" , target_rot , .3).finished
		await get_tree().create_timer(1).timeout
		Shooting = false
		
