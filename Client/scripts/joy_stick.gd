extends Node2D

@export var joy_direction : Vector2
@export var ismoving : bool
@export var LeftOrRight :type
var targeting : bool
enum type {
	left,
	right
}
signal fire(direction)
signal target
signal moving(direction)

func _ready() -> void:
	targeting = false

func _input(event):
	
	#if event is InputEventScreenTouch and event.is_pressed():
	if event is InputEventScreenDrag:
		if LeftOrRight == type.left:
			if event.position.x < DisplayServer.window_get_size(0).x/2:
				var origin = $Joyframe.position
				
				var distance = origin.distance_to((event.position - self.position))
				distance = clampf(distance , 0 ,120)
				$Joyframe/Joy.position = (event.position - self.position).normalized() * distance
				
				joy_direction = ($Joyframe/Joy.position - origin).normalized()
				moving.emit(joy_direction)
				ismoving = true
				
				
				
		if LeftOrRight == type.right:
			if event.position.x > DisplayServer.window_get_size(0).x/2:
				if !targeting:
					targeting = true
					target.emit()
				var origin = $Joyframe.position
					
				var distance = origin.distance_to((event.position - self.position))
				distance = clampf(distance , 0 ,120)
				$Joyframe/Joy.position = (event.position - self.position).normalized() * distance
					
				joy_direction = ($Joyframe/Joy.position - origin).normalized()
				ismoving = true
	
	elif event is InputEventScreenTouch and event.is_released():
		
		if target:
			targeting = false
		$Joyframe/Joy.position = Vector2.ZERO
		if joy_direction != Vector2.ZERO:
			fire.emit(joy_direction)
		joy_direction = Vector2.ZERO
		moving.emit(joy_direction)
		ismoving = false
		

func disable_process():
	set_process_input(false)
