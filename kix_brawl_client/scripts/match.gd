extends Node3D

var Player_State : Dictionary
var local_predicted_pos : Vector3
var last_server_calculated_state : Dictionary
var server_states_buffer : Array
var input_direction : Vector2
var speed := 2

var synced_time_ms : int
var RTT :=0 
var RenderIntervalFromNow := 30
var time_offset_from_server : int
var server_ticks_interval : int
var last_pos_applied_render_time : int
###############################
var EnetClient : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:

	$Inputs/MoveJoyStick.moving.connect(on_input)
	get_tree().paused = true
	set_physics_process(false)
	
	var err = EnetClient.create_client(Peers.SERVER_IP , Peers.PORT)
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
	#print(server_states_buffer)
	#print(server_states_buffer)
	if !last_server_calculated_state.is_empty():

		if _server_calculated_state[$Players.get_children()[0].name.to_int()]["T"] > last_server_calculated_state[$Players.get_children()[0].name.to_int()]["T"]:
			last_server_calculated_state = _server_calculated_state
			server_states_buffer.append(last_server_calculated_state)
			# Remove old states (keep 100ms buffer)
			var cutoff = SyncTimeWithServer() - RenderIntervalFromNow
			while server_states_buffer.size() > 0 && server_states_buffer[0][$Players.get_children()[0].name.to_int()]["T"] < cutoff:
				server_states_buffer.remove_at(0)
	
	else:
		last_server_calculated_state = _server_calculated_state

	


func _process(delta: float) -> void:
	#if server_states_buffer.is_empty():
		#return
		#
	synced_time_ms = SyncTimeWithServer()

	DefinePlayerState()
	
	local_predicted_pos += Vector3(input_direction.x, 0, input_direction.y) * speed * delta

	for player in $Players.get_children():
		if player.name.to_int() == multiplayer.get_unique_id():
			local_predicted_pos.y = .5
			player.position = local_predicted_pos
			
	
	for id in last_server_calculated_state.keys():

		for player in $Players.get_children():
			if id == player.name.to_int():
				if server_states_buffer.size() > 2:
					var state_a = server_states_buffer[0]
					var state_b = server_states_buffer[-1]
					server_ticks_interval =  state_b[id]["T"] - state_a[id]["T"]
					#
					#print("server_ticks_interval : " ,server_ticks_interval)
					#print([state_a[id]["T"] , synced_time_ms ,state_b[id]["T"] ])
					if state_a[id]["T"] <= synced_time_ms && state_b[id]["T"] >= synced_time_ms:
						var interpolate_factor = inverse_lerp(state_a[id]["T"] , state_b[id]["T"] , synced_time_ms)
						var interpolated_pos = Vector3(
							lerp(state_a[id]["P"].x , state_b[id]["P"].x , interpolate_factor),
							0.5,
							lerp(state_a[id]["P"].y , state_b[id]["P"].y , interpolate_factor)
						)

						
						player.position = interpolated_pos
	
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
		
	

func SyncTimeWithServer() -> int:
	var result : int
	var now = Time.get_ticks_msec()
	if time_offset_from_server != 0:
		#print(time_offset_from_server)
		now -= time_offset_from_server  # Align client time with server time
		result = now - server_ticks_interval/2
	return result
	
	
@rpc("authority" , "reliable")
func send_time_msec_from_server(time_msec):
	var now = Time.get_ticks_msec()
	#print("server time : " , time_msec)
	#print("synced_time : " , synced_time_ms)
	time_offset_from_server = now - time_msec 
	#print("time_offset_from_server : ", time_offset_from_server)



@rpc("any_peer" , "reliable")
func send_time_milisec_from_client(client_time_milisec):
	pass
	
@rpc("authority" , "reliable")
func get_client_sent_time_milisec(client_sent_time_milisec):
	var now = Time.get_ticks_msec()
	RTT = now - client_sent_time_milisec
	print("RTT : " , RTT)

	
		
func _on_estimate_rtt_timer_timeout() -> void:
	send_time_milisec_from_client.rpc_id(1 , Time.get_ticks_msec())
