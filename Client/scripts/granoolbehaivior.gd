extends MeshInstance3D

var GeranoolVelocity : Vector2
var rand_offset : float
var t:float
var speed := 2
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#randomize()
	#rand_offset = randf()
	#t += rand_offset
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#t += delta * speed
#
	#if GeranoolVelocity.length() > 1:
		#position.y = abs(sin(t)) + .2
