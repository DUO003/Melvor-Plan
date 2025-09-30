extends Area2D
@export var 和谁碰撞的名称="人物身体"
@export var _切换的场景:PackedScene;
@export var 切换的坐标点:地图传送点=地图传送点.无
enum 地图传送点{
	无,
	左边传送点,
	右边传送点,
	玩家出生上线点
}
var 进来了=false
func _on_area_entered(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=true
func _on_area_exited(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=false
func _input(event: InputEvent) -> void:
	if 进来了==true:
		if event.is_pressed():
			if ("keycode" in event)==true:
				if event.keycode==4194322:
					if (_切换的场景 == null): return;
					#进行切换
					var 场景节点 = get_tree()
					场景节点.change_scene_to_packed(_切换的场景);	
					#进行实例化后然后销毁
					if 切换的坐标点==地图传送点.无:
						return
					var node = self._切换的场景.instantiate()	
					if 切换的坐标点==地图传送点.左边传送点:
						#Player.取对象引用().position=node.get_node("游戏地形").get_node("左边传送点").position+node.get_node("游戏地形").position
						pass
					if 切换的坐标点==地图传送点.右边传送点:
						#Player.取对象引用().position=node.get_node("游戏地形").get_node("右边传送点").position+node.get_node("游戏地形").position
						pass
					if 切换的坐标点==地图传送点.玩家出生上线点:
						#Player.取对象引用().position=node.get_node("游戏地形").get_node("玩家出生上线点").position+node.get_node("游戏地形").position
						pass
					#销毁无用节点
					node.queue_free()
