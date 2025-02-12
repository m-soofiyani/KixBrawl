extends Node2D

var enetserver_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int
var SPEED := 2
var message : String

var Players_id : Array



var Players_States_Collection : Dictionary
var Calculated_Player_States : Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args = OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
			break
	
	enetserver_peer.create_server(port)
	multiplayer.set_multiplayer_peer(enetserver_peer)
	print("Match Server Starts on port : " + str(port))
	
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)


func _physics_process(delta: float) -> void:


	for id in Players_id:
		if Players_States_Collection.has(id):
			if Calculated_Player_States.has(id):
				Calculated_Player_States[id]["T"] = Time.get_ticks_msec()
				Calculated_Player_States[id]["P"] += Players_States_Collection[id]["V"]
				print(Players_States_Collection[id]["V"])

				#print(Calculated_Player_States[id]["P"])
	#
	#print("client:" , Players_States_Collection)
	print("server:" , Calculated_Player_States)
	#print(pos1)
	#print(pos2)

	
func on_peer_connected(id:int):
	message = "New Peer connected with id : " + str(id)
	Players_id.append(id)
	
	
	print(message)
	for _id in Players_id:
		welcome.rpc_id(_id , "Welcome you added to Players IDS of this match!")
	
func on_peer_disconnected(id : int):
	message = "Peer Diconnected with id : " + str(id)
	Players_id.erase(id)
	print(message)

@rpc("authority")
func welcome(message):
	pass


#@rpc("any_peer" , "unreliable")
#func send_input_from_client(input_vel):
	#client_input_vel = input_vel
	

@rpc("any_peer" , "unreliable")
func send_player_state_from_client(player_state):
	#print(player_state)
	var player_id = multiplayer.get_remote_sender_id()
	if Calculated_Player_States.has(player_id):
		return
		
	else:
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		Calculated_Player_States[player_id] = {"T" : Time.get_ticks_msec() , "P" : Vector2.ZERO}
		#
	#
	if Players_States_Collection.has(player_id):
		if Players_States_Collection[player_id]["T"] < player_state["T"]:
			Players_States_Collection[player_id] = player_state
		
	else:
		Players_States_Collection[player_id] = player_state

@rpc("authority" , "unreliable")
func update_client_state(updated_pos):
	pass
