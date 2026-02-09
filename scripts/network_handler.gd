extends Node

#const IP_ADDRESS: String = "localhost"
#const PORT: int = 24454
const MAX_CLIENTS: int = 3
var peer: ENetMultiplayerPeer

func start_server(port: int) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer

func start_client(ip: String, port: int) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
