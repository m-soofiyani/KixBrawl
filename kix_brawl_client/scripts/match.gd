extends Node3D

var Player_State : Dictionary
var local_predicted_pos : Vector3
var server_calculated_state : Dictionary
var input_direction : Vector2
var speed := 2




###############################
#var EnetClient : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	get_tree().paused = true
	$Inputs/MoveJoyStick.moving.connect(on_input)
	#set_physics_process(false)
	######################################################
	#var err = EnetClient.create_client("127.0.0.1" , 8082)
	#if err != OK:
		#print(err)
	#else:
		#print("connected to server")
	#multiplayer.multiplayer_peer = EnetClient
	#######################################################

@rpc("authority")
func welcome(message):
	print(message)
	get_tree().paused = false

func on_input(direction) -> void:
	input_direction = direction
	



@rpc("any_peer","unreliable")
func send_player_state_from_client(message):
	pass


@rpc("authority","unreliable")
func update_client_state(_server_calculated_state):
	server_calculated_state = _server_calculated_state


func _physics_process(delta: float) -> void:
	if multiplayer.multiplayer_peer != null:
		DefinePlayerState()
	#local_predicted_pos += Vector3(input_direction.x , 0 ,input_direction.y)  * delta * speed
	
	#if local_predicted_pos != server_calculated_state.P:
		#local_predicted_pos.lerp(server_calculated_state.P , .01)
		#
	#position = Vector3(local_predicted_pos.x , 0 , local_predicted_pos.y)
	


func DefinePlayerState():
	Player_State = { "T" :  Time.get_ticks_msec() , "V" : input_direction }
	send_player_state_from_client.rpc_id(1 , Player_State)
