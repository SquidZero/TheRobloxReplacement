extends Node
class_name multiplayer_manager

var button_pressed = false
var player_name: String
@export var scene = preload("res://test.tscn").instantiate();
# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/Host.pressed.connect(self._on_host_pressed)
	$Control/Join.pressed.connect(self._on_joined_pressed)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if button_pressed:
#		switch_scene(scene)
#		button_pressed = false

#@rpc func switch_scene(next_scene):
#		get_tree().get_root().add_child(next_scene)
#		queue_free()

var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 4242
const ADDRESS = "localhost"

var connected_peer_ids = []

var players = []

func _on_host_pressed():
	button_pressed = true
	$Control/Label.text = "Server"
	$Control.visible = false
#	switch_scene(scene)
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
#	$UniquePeerId.text = str(multiplayer.get_unique_id())

	add_player_character(1)

	multiplayer_peer.peer_connected.connect(
		func (new_peerid):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peerid)
			rpc_id(new_peerid, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peerid)
	)


@rpc func add_newly_connected_player_character(new_peer_id):
	add_player_character(new_peer_id)

func _on_joined_pressed():
	button_pressed = true
	$Control/Label.text = "Client"
	$Control.visible = false
#	switch_scene(scene)
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
#	$UniquePeerId.text = str(multiplayer.get_unique_id())

func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var player_character = preload("res://player.tscn").instantiate()
	players.append(player_character)
	if peer_id != 1:
		player_character.position = Vector3(players[0].position.x, players[0].position.y + 10, players[0].position.z)
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)


@rpc func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids:
		add_player_character(peer_id)

