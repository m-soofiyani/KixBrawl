extends Node2D

var player1_goals : int
var player2_goals : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_player_1_goal_area_entered(area: Area2D) -> void:

	if area.is_in_group("granools"):
		player2_goals += 1

		area.get_parent().GranoolGoaled()
		


func _on_player_2_goal_area_entered(area: Area2D) -> void:
	if area.is_in_group("granools"):
		player1_goals += 1

		area.get_parent().GranoolGoaled()
