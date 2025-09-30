extends Control
@export var 本地监听端口:int=9999
@export var 网络IP:String="127.0.0.1"
@export var 端口号:int=9999

var peer:ENetMultiplayerPeer; #后面串联到multiplayer.multiplayer_peer了
#主动接受的信号
signal 启动服务器;#无需参数
signal 连接服务器;#无需参数
#通知的信号
signal 客户端登入;#无回调
signal 客户端退出;#回调参数 1.ID
signal 服务器断开;#回调参数 1.ID
signal 创建与连接成功通知;#无回调
func _ready() -> void:
	启动服务器.connect(
		func ()->void:
			peer = ENetMultiplayerPeer.new()
			peer.create_server(本地监听端口)
			#返回连接状态
			#该 MultiplayerPeer 已断开连接。
			if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
				OS.alert("启动服务器失败")
				return
			elif peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
				print("启动服务器成功")
				emit_signal("创建与连接成功通知")
			#关联到MultiplayerAPI实例
			multiplayer.multiplayer_peer = peer
			#$"登入界面".visible=true;
			multiplayer.multiplayer_peer.peer_connected.connect(func(id):
				emit_signal("客户端登入",id)
				)
			multiplayer.multiplayer_peer.peer_disconnected.connect(func(id):
				emit_signal("客户端退出",id)
				)
			)
	连接服务器.connect(
		func ()->void:
			#链接
			#连接服务器
			# Start as client
			#创建一个客户端提
			peer = ENetMultiplayerPeer.new()
			peer.create_client(网络IP, 端口号)
			print(peer.get_connection_status())
			if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
				#该 MultiplayerPeer 已断开连接。
				OS.alert("不能连接到多人服务器")
				return
			
			if peer.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTING:
				print("连接成功??",网络IP,端口号)
				emit_signal("创建与连接成功通知")
			#串联
			multiplayer.multiplayer_peer = peer
			
			multiplayer.multiplayer_peer.peer_connected.connect(func(id):
				emit_signal("客户端登入",id)
				)
			multiplayer.multiplayer_peer.peer_disconnected.connect(func(id):
				emit_signal("客户端退出",id)
				)
			multiplayer.server_disconnected.connect(func():
				emit_signal("服务器断开")
				)
			)
