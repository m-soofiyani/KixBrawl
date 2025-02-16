extends Control

var wsserver : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
const PORT := 8080

var OnlineUsers= []
var JoinMatchPlayers = []
var last_packet 
var matchserver_path = "./matchserver.x86_64"

var output = []
var searchForOpponent := true
@export var matchNumberThereshold : int
signal createMatch
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wsserver.create_server(PORT)
	
	wsserver.peer_connected.connect(on_peer_connected)
	wsserver.peer_disconnected.connect(on_peer_disconnected)
	
	
	createMatch.connect(on_create_match)

func on_peer_connected(id):
	print("Peer Connected with id : " + str(id))
	
	await get_tree().create_timer(1).timeout
	var err = wsserver.get_peer(id).put_packet(JSON.stringify({"type": Message.Message.GREET, "message" : "Welcome to KixBrawl MasterServer" , "id" : str(id)}).to_utf8_buffer())
	if err != OK:
		print("Unable to send welcome message!")
		
	
	
func on_peer_disconnected(id):
	print("Peer Disonnected with id : " + str(id))
	
	for user in OnlineUsers:
		if user.id == id:
			OnlineUsers.erase(user)
	

func _process(delta: float) -> void:
	wsserver.poll()
	var state = wsserver.get_connection_status()
	if state == WebRTCMultiplayerPeer.CONNECTION_CONNECTED:
		if wsserver.get_available_packet_count() > 0:
			last_packet = JSON.parse_string(wsserver.get_packet().get_string_from_utf8())
			
			
			if last_packet.type == Message.Message.GUESTLOGIN:
				OnlineUsers.append({
					"name" : last_packet.name,
					"id" : last_packet.id
				})
					
			if last_packet.type == Message.Message.JOINMATCH:
				JoinMatchPlayers.append({
					"name" : last_packet.name,
					"id" : last_packet.id
				})
				wsserver.get_peer(last_packet.id).put_packet(JSON.stringify({
					"type" : Message.Message.SEARCHOPPONENT,
					"message" : "Searching for an Opponent!"
				}).to_utf8_buffer())
				
				
				if JoinMatchPlayers.size() == matchNumberThereshold and searchForOpponent:
					createMatch.emit()


func on_create_match():
	searchForOpponent = false
	print("match created between : " + str(JoinMatchPlayers[0].name) +  " and " + str(JoinMatchPlayers[1].name))
	var new_match = GameMatch.new()
	new_match.name = "Match"
	
	$Matches.add_child(new_match, true)
	
	for player in JoinMatchPlayers:
		new_match.matchinfo.append(player)
		
	
	var args = ["--port", str(new_match.selected_port)]
	var pid =OS.create_process(matchserver_path, args , true)
	if pid > 0:
		print("Started game server on port ", new_match.selected_port, " with PID ", pid)
	else:
		print("Failed to start game server")
		
	for player in new_match.matchinfo:
		wsserver.get_peer(player.id).put_packet(JSON.stringify({
			"type" :Message.Message.MATCHINFO,
			"names" : [new_match.matchinfo[0].name,new_match.matchinfo[0].name],
			"port" : new_match.selected_port
		}).to_utf8_buffer())
	JoinMatchPlayers.clear()
	
	searchForOpponent = true
