extends Node
#接收模板

#class_name 联机类;
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
	match 类型:
		"类型":
			rpc_id(发送者id,"_接收数据",{类型="对话",文本信息="对话中哦"})	
			
#所有端口都可以接收,用于发送一个可靠协议的RPC
@rpc("any_peer","reliable")
func _接收数据(数据包:Dictionary):
	emit_signal("接收数据",数据包)
	#接收数据.emit(c)
	#print("SHUJU:",c)
	pass


##以下是发送例子

"""发送与接收模板
单例.函数.rpc传输

Dialogue.发送可靠协议.rpc_id(1,"NPC对话",{脚本目标=NPC脚本路径})
			var 返回值=await Dialogue.接收数据
			print("返回值:",返回值)
			if 返回值.类型=="对话":
				OS.alert(返回值.文本信息)	
"""
