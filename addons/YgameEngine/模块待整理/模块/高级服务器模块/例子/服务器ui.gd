
extends Node

var socket = WebSocketPeer.new()

func _ready():
	socket.connect_to_url("wss://127.0.0.1:8383")
	print_debug("qd")

func _process(delta):
	
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			print("数据包：", socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# 继续轮询才能正确关闭。
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket 已关闭，代码：%d，原因 %s。干净得体：%s" % [code, reason, code != -1])
		set_process(false) # 停止处理。
