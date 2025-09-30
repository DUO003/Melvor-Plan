extends Node
#接收模板
#class_name 联机类;

signal 接收数据; #接收数据的信号.
"""
单例 用于信号接收
类 用于全局变量处理
"""
#所有端口都可以接收,用于发送一个可靠协议的RPC
@rpc("any_peer","reliable","call_local")
func 发送可靠协议(类型:String,数据包:Dictionary):
	#修复127.0.0.1的时候 数据返回延迟
	await get_tree().create_timer(0.01).timeout
	#模板
	var 当前id=multiplayer.get_unique_id()
	var 发送者id=multiplayer.get_remote_sender_id()
	#用于接受的可靠协议
	match 类型:
		"登入":
			rpc_id(发送者id,"_接收数据",{类型="登入回调",文本信息="账号数据"})	
			
#所有端口都可以接收,用于发送一个可靠协议的RPC
@rpc("any_peer","reliable","call_local")
func _接收数据(数据包:Dictionary):
	emit_signal("接收数据",数据包)
	pass
