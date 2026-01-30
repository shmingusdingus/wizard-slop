extends Node

const IP_ADDRESS: String = "71.172.8.51"
const PORT: int = 24454
const MAX_CLIENTS: int = 3
var peer: ENetMultiplayerPeer


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
