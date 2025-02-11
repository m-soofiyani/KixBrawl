extends Control

var wsclient : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var wsclient_id : int
const SERVER_IP := "127.0.0.1"
const PORT := 8080
var last_packet

var EnetClient : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var choosen_name : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#visual_start()
	var err = wsclient.create_client("ws://"+ SERVER_IP+":"+str(PORT))
	if err != OK:
		print("Failed to connect : " + err)
		
	else :
		print("connected to server succsessfully! ")
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wsclient.poll()
	var state = wsclient.get_connection_status()
	if state == WebSocketMultiplayerPeer.CONNECTION_CONNECTED:
		if wsclient.get_available_packet_count() > 0:
			last_packet = JSON.parse_string(wsclient.get_packet().get_string_from_utf8())
			
			if last_packet.type == Message.Message.GREET:
				wsclient_id = int(last_packet.id)
			
			if last_packet.type == Message.Message.SEARCHOPPONENT:
				$Back/Matchmaking/VBoxContainer/Label.text = last_packet.message
				
			if last_packet.type == Message.Message.MATCHINFO:
				
				Start_Match(last_packet.port)
				


#func visual_start():
	#$Panel/AnimationPlayer.play("menuanim")


func _on_login_guest_button_up() -> void:
	if !$Back/UserInfo/HBoxContainer/GuestPanel/BoxContainer/Username/lineedit.text.is_empty():
		$Back/UserInfo.hide()
		$Back/Matchmaking.show()
		choosen_name = $Back/UserInfo/HBoxContainer/GuestPanel/BoxContainer/Username/lineedit.text
		
		if wsclient.get_connection_status() == WebSocketMultiplayerPeer.CONNECTION_CONNECTED:
			var err = wsclient.put_packet(JSON.stringify({
				"type" : Message.Message.GUESTLOGIN,
				"name" : choosen_name,
				"id" : wsclient_id
			}).to_utf8_buffer())


func _on_search_match_button_up() -> void:
	if wsclient.get_connection_status() == WebSocketMultiplayerPeer.CONNECTION_CONNECTED:
		var err = wsclient.put_packet(JSON.stringify({
			"type" : Message.Message.JOINMATCH,
			"name" : choosen_name,
			"id" : wsclient_id
		}).to_utf8_buffer())


func Start_Match(port):
	
	var err = EnetClient.create_client(SERVER_IP , port)
	if err != OK:
		print(err)
	else:
		print("connected to server")
	multiplayer.multiplayer_peer = EnetClient
	Peers.EnetPeer = EnetClient
	get_tree().change_scene_to_packed(preload("res://scenes/match.tscn"))


func on_connected_to_server():
	print("connected to enet server!")

func on_connection_failed():
	print("connection failed")
