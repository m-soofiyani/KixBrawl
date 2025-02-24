extends RigidBody2D

var grappble : bool
const max_boundry_x : float = 8
const max_boundry_y : float = 3
var veloctiy_mult := .1
# Called when the node enters the scene tree for the first time.






func shoot(dir : Vector2):
	apply_impulse(dir)


func Bound_Limit():
	if position.x >= max_boundry_x or position.x <= -max_boundry_x:
		linear_velocity.x *= -1
	if position.y >= max_boundry_y or position.y <= -max_boundry_y:
		linear_velocity.y *= -1
	#position.x = clampf(position.x , -max_boundry_x , max_boundry_x)
	#position.y = clampf(position.y , -max_boundry_y , max_boundry_y)

func GranoolGoaled():
	set_collision_mask_value(2 , false)
	linear_velocity *= veloctiy_mult
