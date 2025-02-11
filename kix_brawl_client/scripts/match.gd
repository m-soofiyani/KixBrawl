extends Node3D


@rpc("authority")
func welcome():
	print("Welcome to match")


func _on_button_button_up() -> void:
	send_message.rpc_id(1 , "hello")


@rpc("any_peer")
func send_message(message):
	pass
