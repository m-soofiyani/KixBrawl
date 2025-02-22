extends RigidBody2D

var grappble : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
		#
	#for player in $"../../Players".get_children():
		#if self.linear_velocity.length() < .5 and position.distance_to(player.position) < .8:
			#linear_velocity = (player.position - position) * 10
		#
		#else:
			#return
func shoot(dir : Vector2):
	apply_impulse(dir)
