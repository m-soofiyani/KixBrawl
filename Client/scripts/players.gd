extends Node3D

var ids = []
@export var  mats: Array[ShaderMaterial]
signal ids_full
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	on_ids_full()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if ids.size() == 2:
		#ids_full.emit()

func on_ids_full():

	for player in get_children():
		player.get_node("AnimationGame/Rig/Skeleton3D/RETOPO_MODIF").material_override = mats[ids.rfind(player.name.to_int())]
 
