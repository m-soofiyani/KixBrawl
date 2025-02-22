extends CharacterBody2D


enum SIDE {
	Right,
	Left
}

var current_side : SIDE
const maximum_x := 8.8

func _ready() -> void:
	if position.x > 0:
		current_side = SIDE.Right
		
	elif position.x < 0:
		current_side = SIDE.Left
	
	
func _process(delta: float) -> void:
	if current_side == SIDE.Right:
		position.x = clamp(position.x , 0 , maximum_x)
		
	elif current_side == SIDE.Left:
		position.x = clamp(position.x , -maximum_x , 0)


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("granools"):

		var direction = get_node("Area2D").global_transform.origin -position
		body.shoot(direction * 10)
