extends Button

@export var _切换的场景:PackedScene;

func _ready():
	pressed.connect(func ():
		if (_切换的场景 == null): return;
		var 场景节点 = get_tree()
		场景节点.change_scene_to_packed(_切换的场景);
	
		)
	pass # Replace with function body.


