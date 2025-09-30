extends Panel
signal 加入文本;
signal 清屏;
# Called when the node enters the scene tree for the first time.
func _ready():
	$"文本".text="[系统]:欢迎进入游戏"
	
	self.加入文本.connect(_加入文本);
	
	
	self.清屏.connect(func ():
		$"文本".text="";
		);
	pass # Replace with function body.

func _加入文本(文本) ->void:
	$"文本".text+="\n"+文本;
	pass
