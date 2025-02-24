extends CharacterBody2D


enum SIDE {
	Right,
	Left
}

enum ANIMS {
	IDLE,
	RUN,
	SHOOT
}

var isShooting : bool

var current_side : SIDE
var current_anim : ANIMS

const maximum_x := 8.8
const maximum_y := 2.5

func _ready() -> void:
	if position.x > 0:
		current_side = SIDE.Right
		
	elif position.x < 0:
		current_side = SIDE.Left
	
	
func _process(delta: float) -> void:
	if velocity.length() > 0:
		current_anim = ANIMS.RUN
		
	else:
		current_anim = ANIMS.IDLE
		
		
	if current_side == SIDE.Right:
		position.x = clamp(position.x , 0 , maximum_x)
		
	elif current_side == SIDE.Left:
		position.x = clamp(position.x , -maximum_x , 0)
		
	position.y = clamp(position.y , -maximum_y , maximum_y)


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if isShooting:
		if body.is_in_group("granools"):
			var direction = get_node("Area2D").global_transform.origin -position
			current_anim = ANIMS.SHOOT

			body.apply_impulse(direction * 15)
