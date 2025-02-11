extends Node2D

var enetserver_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int
var message : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args = OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
			break
	
	enetserver_peer.create_server(port)
	multiplayer.multiplayer_peer = enetserver_peer
	print("Match Server Starts on port : " + str(port))


	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)



func on_peer_connected(id:int):
	message = "New Peer connected with id : " + str(id)
	print(message)
	for _id in multiplayer.get_peers():
		welcome.rpc_id(_id)
	
func on_peer_disconnected(id : int):
	message = "Peer Diconnected with id : " + str(id)
	print(message)

@rpc("authority")
func welcome():
	pass


@rpc("any_peer")
func send_message(message):
	print(message)
