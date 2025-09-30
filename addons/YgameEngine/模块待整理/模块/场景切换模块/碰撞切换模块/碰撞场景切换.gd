extends Area2D
@export var 和谁碰撞的名称="人物身体"
@export var _切换的场景:PackedScene;

func _on_area_entered(area: Area2D) -> void:
	
	if area.name==和谁碰撞的名称:
		
		print("触发了")
		if (_切换的场景 == null): return;
		var 场景节点 = get_tree()
		场景节点.change_scene_to_packed(_切换的场景);
	pass # Replace with function body.
