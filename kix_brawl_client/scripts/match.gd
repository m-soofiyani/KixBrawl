extends Node3D

var Player_State : Dictionary
var local_predicted_pos : Vector3
var server_calculated_state : Dictionary
var input_direction : Vector2
var speed := 2





###############################
var EnetClient : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:

	$Inputs/MoveJoyStick.moving.connect(on_input)
	get_tree().paused = true
	set_physics_process(false)
	
	var err = EnetClient.create_client("127.0.0.1" , Peers.PORT)
	if err != OK:
		print(err)
	else:
		print("connected to server")
	multiplayer.multiplayer_peer = EnetClient
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)


@rpc("authority")
func welcome(message):
	print(message)
	

func on_input(direction) -> void:
	input_direction = direction
	



@rpc("any_peer","unreliable")
func send_player_state_from_client(message):
	pass


@rpc("authority","unreliable")
func update_client_state(_server_calculated_state):
	if !server_calculated_state.is_empty():

		if _server_calculated_state[$Players.get_children()[0].name.to_int()]["T"] > server_calculated_state[$Players.get_children()[0].name.to_int()]["T"]:
			server_calculated_state = _server_calculated_state
	
	else:
		server_calculated_state = _server_calculated_state
	
	print(server_calculated_state)


func _physics_process(delta: float) -> void:
	
	DefinePlayerState()
	
	
	#if local_predicted_pos != server_calculated_state.P:
		#local_predicted_pos.lerp(server_calculated_state.P , .01)
		#
	for id in server_calculated_state.keys():

		for player in $Players.get_children():
			
			if id == player.name.to_int():
				var server_calculated_pos = Vector3(server_calculated_state[id]["P"].x , .5 , server_calculated_state[id]["P"].y)
				player.position = server_calculated_pos

	
func DefinePlayerState():
	Player_State = { "T" :  Time.get_ticks_msec() , "V" : input_direction }
	send_player_state_from_client.rpc_id(1 , Player_State)



func on_connected_to_server():
	print("connected to enet server!")
	get_tree().paused = false
	set_physics_process(true)
	
func on_connection_failed():
	print("connection failed")



@rpc("authority")
func Define_Ids(player_ids):
	for i in range(player_ids.size()):
		$Players.get_children()[i].name = str(player_ids[i])
		
	
