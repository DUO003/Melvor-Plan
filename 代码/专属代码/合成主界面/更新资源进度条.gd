extends ColorRect

# 资源变量
var variable1 = 0  # 分子
var variable2 = 100  # 分母
var 资源 = ""

func _ready():#初始化
	资源 = $"../文本".text
	update_resource_size()
	
	初始化.connect("更新_UI", Callable(self, "_on_更新_UI"))
#func _process(_delta):#每帧执行

func _on_更新_UI():
	update_resource_size()
	
func update_resource_size():
	
	if 资源 == "精华":
		$"数值".text = str(初始化.资源(资源))
	else:
		variable1 = 初始化.资源(资源)
		variable2 = 100

		# 计算比例（防止除以零）
		var ratio = 0.0
		if variable2 > 0:
			ratio = variable1 /  float(variable2)  # 确保在 0-1 范围内
			$"数值".text = str(round(ratio*1000)/10) + "%"
			ratio = min(max(ratio, 0.0), 1.0)  # 确保在 0-1 范围内
		
		# 计算新的大小（使用 size 属性）
		var new_width = 380 * ratio
		var current_height = size.y  # 修改为 size.y

		size = Vector2(new_width, current_height)  # 修改为 size
