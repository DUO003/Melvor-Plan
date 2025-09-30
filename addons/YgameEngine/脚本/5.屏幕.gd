##绘制绘制相关
extends Node
class_name 引擎屏幕


	
var 伤害功能;
#注册伤害
func _ready() -> void:
	伤害功能 = load("uid://dhkr78momttr0").new()
	伤害功能.name="伤害功能"
	add_child(伤害功能)
	
## 伤害绘制(Vector2(300,300),123,"命中","正常"，):
## 伤害绘制(Vector2(300,300),[["命中", 20478], ["命中", 20278], ["暴击", 24311], ["暴击", 22333]])
##	引擎.屏幕.伤害绘制(Vector2(300,300),[["命中", 20478], ["命中", 20278], ["暴击", 24311], ["暴击", 22333]])
	#引擎.屏幕.伤害绘制(Vector2(300,600),123,"命中","正常")	
	#引擎.屏幕.伤害绘制(Vector2(300,400),123,"暴击","正常")
	#引擎.屏幕.伤害绘制(Vector2(300,400),123,"命中","受伤")
	#引擎.屏幕.伤害绘制(Vector2(340,400),123,"命中","补血")
	#引擎.屏幕.伤害绘制(Vector2(500,400),123,"暴击","补蓝")
func 伤害绘制(坐标:Vector2,伤害,类型:String="命中",模式:String="正常"):
	#_type类型 暴击,躲避,命中
	#_mode模式 0正常,1受伤,2补血,3补蓝
	if 伤害 is int:
		伤害功能.draw(伤害,类型,模式,坐标)
	if 伤害 is Array:
		伤害功能.drawArr(坐标,伤害)	

##用于震动屏幕。
##[codeblock]
##引擎.窗口.屏幕震动($Camera2D)
##[/codeblock]
func 屏幕震动(相机: Camera2D = null, 震动持续时长: float = 0.1, 震动幅度: float = 2.0, 震动频率: float = 0.02) -> void:
	if 相机==null:return
	# 记录初始偏移量，震动结束后恢复
	var 原始偏移 = 相机.offset
	var 震动当前时长: float = 0.0
	# 使用帧率控制的循环替代原时间累加方式，更稳定
	while 震动当前时长 < 震动持续时长:
		# 生成随机偏移量
		var offset = Vector2(
			randf_range(-震动幅度, 震动幅度),
			randf_range(-震动幅度, 震动幅度)
		)
		# 应用偏移
		相机.offset = 原始偏移 + offset
		# Godot 4中使用await替代yield
		await get_tree().create_timer(震动频率).timeout
		# 累加已消耗时间
		震动当前时长 += 震动频率
	# 震动结束后恢复原始偏移
	相机.offset = 原始偏移

func 滚动提示(文本:String,替换标签="",组件位置:Container=初始化.提示容器):
		# 如果指定了替换标签，则先删除相同标签的已有提示
	if 替换标签 != "":
		# 遍历组件位置的所有子节点
		for 子节点 in 组件位置.get_children():
			# 检查子节点是否有标签属性且与替换标签一致
			if 子节点.标签 == 替换标签:
				子节点.queue_free()
	var 对象=引擎.对象.创建并添加子对象(组件位置,"res://addons/YgameEngine/场景/滚动提示/control.tscn")
	对象.text=文本+" "
	对象.标签=替换标签
	pass
