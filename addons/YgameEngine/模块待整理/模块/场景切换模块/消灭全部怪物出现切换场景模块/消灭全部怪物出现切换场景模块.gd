extends Area2D
@export var 和谁碰撞的名称="人物身体"
@export var _切换的场景:PackedScene;
var 进来了=false
var 清空怪物=false
func _ready() -> void:
	hide()#隐藏
func _on_area_entered(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=true
func _on_area_exited(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=false
func _input(event: InputEvent) -> void:
	if 进来了==true:
		if 清空怪物==true:
			if event.is_pressed():
				if ("keycode" in event)==true:
					if event.keycode==4194322:
						if (_切换的场景 == null): return;
						var 场景节点 = get_tree()
						场景节点.change_scene_to_packed(_切换的场景);	

func 计时器触发() -> void:
	if 地图类.取玩家当前所在地图的怪物数量()==0:
		清空怪物=true
		show()#显示
	pass # Replace with function body.
