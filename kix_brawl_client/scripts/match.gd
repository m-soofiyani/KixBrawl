extends Node3D

var Player_State : Dictionary
var local_predicted_pos : Vector3
var last_server_calculated_state : Dictionary
var server_states_buffer : Array
var input_direction : Vector2
var speed := 2

var render_time : int
var RenderIntervalFromNow := 100
var time_offset_from_server : int

var last_pos_applied_render_time : int
###############################
var EnetClient : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:

	$Inputs/MoveJoyStick.moving.connect(on_input)
	get_tree().paused = true
	set_physics_process(false)
	
	var err = EnetClient.create_client("91.239.214.89" , Peers.PORT)
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
	if !last_server_calculated_state.is_empty():

		if _server_calculated_state[$Players.get_children()[0].name.to_int()]["T"] > last_server_calculated_state[$Players.get_children()[0].name.to_int()]["T"]:
			last_server_calculated_state = _server_calculated_state
			server_states_buffer.append(last_server_calculated_state)
			if server_states_buffer.size() > 1:
				if server_states_buffer[0][$Players.get_children()[0].name.to_int()]["T"] < render_time:
					server_states_buffer.remove_at(0)
	
	else:
		last_server_calculated_state = _server_calculated_state
	
	


func _physics_process(delta: float) -> void:
	render_time = GetRenderTime(RenderIntervalFromNow)
	DefinePlayerState()
	print("render time : " , render_time)
	print("server_buffer : "  ,server_states_buffer.size())
	#if local_predicted_pos != server_calculated_state.P:
		#local_predicted_pos.lerp(server_calculated_state.P , .01)
		#
	for id in last_server_calculated_state.keys():

		for player in $Players.get_children():
			
			if id == player.name.to_int():
				if !server_states_buffer.is_empty():
					var server_calculated_pos = Vector3(server_states_buffer[0][id]["P"].x , .5 , server_states_buffer[0][id]["P"].y)
					var duration = (server_states_buffer[0][id]["T"] - last_pos_applied_render_time) / 1000
					create_tween().tween_property(player , "position" ,server_calculated_pos, duration)
					last_pos_applied_render_time = server_states_buffer[0][id]["T"]
					#player.position.lerp(server_calculated_pos , .1)
					

	
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
		
	

func GetRenderTime(renderInterval) -> int:
	var now = Time.get_ticks_msec()
	if time_offset_from_server != 0:
		now = Time.get_ticks_msec() - time_offset_from_server
	return now - renderInterval

@rpc("authority")
func send_time_msec_from_server(time_msec):
	var now = Time.get_ticks_msec()
	if now > time_msec:
		time_offset_from_server = now - time_msec
	else:
		time_offset_from_server = time_msec - now
