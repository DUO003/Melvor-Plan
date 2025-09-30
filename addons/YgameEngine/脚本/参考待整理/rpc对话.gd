extends Node
class_name 服务端对话类;
#服务器指令 Dialogue
var 玩家对话={};#记录玩家对话的东西
signal 接收数据; #对话的接收文本数据.
@rpc("any_peer","reliable","call_local")
func 对话():
	var 当前id=multiplayer.get_unique_id()
	var 发送者id=multiplayer.get_remote_sender_id()
	pass

@rpc("any_peer","reliable","call_local")
func 发送可靠协议(类型:String,数据包:Dictionary):
	#修复127.0.0.1的时候 数据返回延迟
	await get_tree().create_timer(0.01).timeout
	#模板
	var 当前id=multiplayer.get_unique_id()
	var 发送者id=multiplayer.get_remote_sender_id()
	print("-0理论触发的执行ID:",发送者id,当前id)
	print("%s接收到来自%s的类型[%s]数据包:%s" % [当前id,发送者id,类型,数据包])
	#数据包.脚本目标
	match 类型:
		"NPC对话":
			print("-1理论触发的执行ID:",发送者id,当前id,数据包)
			if 数据包.脚本目标=="-1":
				rpc_id(发送者id,"_接收数据",{类型="对话",文本信息="脚本不存在,请联系GM"})	
			else:
				var gd:GDScript=load("res://服务端脚本/NPC对话/"+数据包.脚本目标+".gd")
				print("-2理论触发的执行ID:",发送者id,当前id)
				if gd==null:
					
					rpc_id(发送者id,"_接收数据",{类型="对话",文本="脚本不存在,请联系GM",格式="OK"})	
				else:
					print("-3理论触发的执行ID:",发送者id,当前id)
					玩家对话[发送者id]=gd.new(数据包.对话账号)	
					var 返回数据=玩家对话[发送者id]._ready()
					rpc_id(发送者id,"_接收数据",{
						类型="对话"
						,文本信息= 返回数据.文本
						,格式=返回数据.格式
						})	
		"确定选项":
			var 返回数据=玩家对话[发送者id].action(1, 1, 数据包.选项)
			rpc_id(发送者id,"_接收数据",{
				类型="对话"
				,文本信息=返回数据.文本
				,格式=返回数据.格式
				})	
			pass
@rpc("any_peer","reliable","call_local")
func _接收数据(数据包:Dictionary):
	print("收到数据表:",数据包)
	#Dialogue.emit_signal("接收数据",数据包)
	self.接收数据.emit(数据包)
	#接收数据.emit(c)
	#print("SHUJU:",c)
	pass
