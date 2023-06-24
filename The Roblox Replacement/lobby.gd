# Typical lobby implementation; imagine this being in /root/lobby.

extends Node

# Connect all functions
var which_level

func _ready():
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

@rpc func register_player(info):
	# Get the id of the RPC sender.
	var id = multiplayer.get_remote_sender_id()
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here

@rpc func pre_configure_game():
	get_tree().paused = true
	var selfPeerID = multiplayer.get_unique_id()

	# Load world
	var world = load(which_level).instantiate()
	get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://player.tscn").instantiate()
	my_player.set_name(str(selfPeerID))
	my_player.set_multiplayer_authority(selfPeerID) # Will be explained later
	get_node("/root/world/players").add_child(my_player)

	# Load other players
	for p in player_info:
		var player = preload("res://player.tscn").instantiate()
		player.set_name(str(p))
		player.set_multiplayer_authority(p) # Will be explained later
		get_node("/root/world/players").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")

var players_done = []

@rpc func done_preconfiguring():
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(multiplayer.is_server())
	assert(who in player_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == player_info.size():
		rpc("post_configure_game")

@rpc func post_configure_game():
	# Only the server is allowed to tell a client to unpause
	if 1 == multiplayer.get_remote_sender_id():
		get_tree().paused = false
		# Game starts now!
