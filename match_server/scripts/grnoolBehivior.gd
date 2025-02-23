extends RigidBody2D

var grappble : bool
const max_boundry_x : float = 8
const max_boundry_y : float = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
		
	#Bound_Limit()
	pass

func shoot(dir : Vector2):
	apply_impulse(dir)


func Bound_Limit():
	position.x = clampf(position.x , -max_boundry_x , max_boundry_x)
	position.y = clampf(position.y , -max_boundry_y , max_boundry_y)
