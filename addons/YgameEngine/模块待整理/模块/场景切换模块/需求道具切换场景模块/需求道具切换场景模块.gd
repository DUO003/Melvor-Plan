extends Area2D
@export var 和谁碰撞的名称="人物身体"
@export var _切换的场景:PackedScene;
@export var 需求道具ID:int=1;
@export var 需求道具数量:int=1;
var 进来了=false
var 已获得=false

func _on_area_entered(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=true
func _on_area_exited(area: Area2D) -> void:
	if area.name==和谁碰撞的名称:
		进来了=false
func _input(event: InputEvent) -> void:
	if 进来了==true:
		if 已获得==true:
			if event.is_pressed():
				if ("keycode" in event)==true:
					if event.keycode==4194322:
						if (_切换的场景 == null): return;
						var 场景节点 = get_tree()
						场景节点.change_scene_to_packed(_切换的场景);	
	if 进来了==true:
		if 已获得==false:
			if event.is_pressed():
				if ("keycode" in event)==true:
					if event.keycode==4194322:
						if 背包类.减少物品(需求道具ID,需求道具数量):
							OS.alert("机关已开启")
							已获得=true
						else:
							OS.alert("未拥有道具钥匙")
					#if 背包类
