extends RigidBody2D

var grappble : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if self.linear_velocity.length() < .1:
		grappble = true
	
	else:
		grappble = false
		
	for player in $"../../Players".get_children():
		if position.distance_to(player.position) < 1 and grappble:
			print(player.name + "can grab the ball")
