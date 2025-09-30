## 场景管理工具类
## 提供场景切换、管理和控制的功能
extends Node
class_name 引擎场景


##用于背景音乐
var 背景音乐播放器:AudioStreamPlayer 
##用于管理背景音乐的音量
var 背景音乐音量:float=1
##用于管理音效的音量
var 音效音量:float=1

func _ready() -> void:
	背景音乐播放器=AudioStreamPlayer.new()
	add_child(背景音乐播放器)
	
## 切换到指定场景
## [br]参数:[br]
##   - 场景地址: 目标场景的路径，如"res://scenes/main.tscn"
##[codeblock]
## 引擎.场景.切换场景("res://scenes/gameplay.tscn")
##[/codeblock]
func 切换场景(场景地址:String) -> void:
	取场景树().change_scene_to_file(场景地址)

func 切换场景2(场景地址:PackedScene) -> void:
	取场景树().change_scene_to_packed(场景地址)
	
## 获取当前运行的场景节点
## [br]返回:[br]
##   - 当前活动场景的根节点
##[codeblock]
## var 当前场景 = 引擎.场景.取当前场景()
## 当前场景.add_child($NewNode)
##[/codeblock]
func 取当前场景() -> Node:
	return 取场景树().current_scene

## 获取主循环的场景树实例
## [br]返回:[br]
##   - 主循环的MainLoop对象
##[codeblock]
## var 场景树 = 引擎.场景.取场景树()
## 场景树.set_pause(true)
##[/codeblock]
func 取场景树() -> MainLoop:
	return Engine.get_main_loop()

## 暂停执行指定时间（协程阻塞）
## [br]参数:[br]
##   - 秒数: 要等待的时间（秒）
##[codeblock]
## await 引擎.场景.等待(2.0)  # 等待2秒后继续执行
## print("等待结束")
##[/codeblock]
func 等待(秒数:float) -> void:
	await 取场景树().create_timer(秒数).timeout

## 销毁当前活动场景
##[codeblock]
## 引擎.场景.销毁当前场景()
##[/codeblock]
func 销毁当前场景() -> void:
	Engine.get_main_loop().current_scene.queue_free()


##音乐

#region 播放音效:通常用于一次性的短音效
##通常用于mav格式一次性的播放，
##[codeblock]
##引擎.场景.播放音效(load("uid://vh28ybcjpqam"))
##引擎.场景.播放音效(load("uid://vh28ybcjpqam"),0.5)
##[/codeblock]
func 播放音效(音效:AudioStream,指定音量:float=-1):
	var _音效:AudioStreamPlayer=AudioStreamPlayer.new()
	_音效.stream=音效
	add_child(_音效)
	_音效.finished.connect(func():
		_音效.queue_free()#播放销毁
	)
	var 实际音量 = 指定音量 if 指定音量 >= 0 else 音效音量
	_音效.volume_db=linear_to_db(实际音量)#分贝设置
	_音效.play()#播放
	
#endregion

## 通常用于MP3格式播放，自动循环
##[codeblock]
##引擎.场景.播放音乐(load("uid://vh28ybcjpqam"))
##[/codeblock]
func 播放音乐(音乐:AudioStreamMP3):
	背景音乐播放器.stream=音乐
	背景音乐播放器.stream.loop=true#设置循环播放
	背景音乐播放器.play()
		

##通常用于播放音乐声音设置,0.5为一半，0是静音
##[codeblock]
##引擎.场景.设置背景声音大小(0.5)
##[/codeblock]
func 设置背景声音大小(音量:float=0.5):
	背景音乐音量=音量
	背景音乐播放器.volume_db=linear_to_db(背景音乐音量)


##通常用于播放音效声音设置,0.5为一半，0是静音
##[codeblock]
##引擎.场景.设置音效声音大小(0.5)
##[/codeblock]
func 设置音效声音大小(音量:float=0.5):
	音效音量=音量
	
