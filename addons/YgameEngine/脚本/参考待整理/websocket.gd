extends Node
signal 接收数据 #接收到信息的触发信号
var 服务器 = WebSocketPeer.new()
#var 内部ip="ws://127.0.0.1:8383" #如果外面不填就是引用这里
var 内部ip="ws://117.68.122.154:8383"

func 连接服务端(_ip=内部ip,等待信号秒数=1.0):
	服务器.connect_to_url(_ip)#连接
	set_process(true) #启动监听
	await get_tree().create_timer(等待信号秒数).timeout
	return 服务器.get_ready_state()


func _ready() -> void:
	set_process(false)#先禁用
	
func _process(_delta):
	服务器.poll()
	var state = 服务器.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while 服务器.get_available_packet_count():
			
			接收数据.emit(JSON.parse_string(服务器.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# 继续轮询才能正确关闭。
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var _code = 服务器.get_close_code()
		var _reason = 服务器.get_close_reason()
		#print("WebSocket 已关闭，代码：%d，原因 %s。服务器状态?：%s" % [code, reason, code != -1])
		接收数据.emit({ "类型": "服务器连接状态", "状态": "断开连接", "文本": "服务器已和你的连接中断" })
		set_process(false) # 停止处理。
