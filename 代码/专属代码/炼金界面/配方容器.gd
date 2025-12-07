extends Control
var 当前值=10
var 道具名称=null
@export var 催化剂:bool=false
@export var 可修改:bool=false
@export var 编号:int=1
var 修改返回对象=null
func 初始更新():
	$"输入".visible=可修改
	if 可修改:
		gui_input.connect(鼠标信号处理)
		$"输入".value=当前值
		if 催化剂:
			$"输入".visible=false
		else :
			$"输入".value_changed.connect(func(值):
				if 当前值!=int(值):
					当前值=int(值)
					if not 修改返回对象==null:
						修改返回对象.返回处理方法()
					更新文本())
	更新文本()
func 更新文本():
	if 道具名称==null:
		if 催化剂:
			$"数量".text="催化剂"
		else :
			$"数量".text="材料"+str(编号)
		$"图片".texture=null
		$"图片".size=Vector2(150,150)
		$"数量".position=Vector2(0,52)
		$"输入".visible=false
	else :
		if 可修改 and not 催化剂:
			$"输入".visible=true
		if 当前值>1:
			$"数量".text=str(当前值)
			$"图片".size=Vector2(150,110)
		else :
			$"数量".text=""
			$"图片".size=Vector2(150,150)
		$"数量".position=Vector2(0,100)
		$"图片".texture=计划.表格.道具贴图(str(道具名称))
func 鼠标信号处理(鼠标信号):
	if 鼠标信号 is InputEventMouseButton and not 鼠标信号.pressed:
		if GBIS.has_moving_item():
			var 正在移动的物品=GBIS.moving_item_service.moving_item
			print("正在移动的物品",正在移动的物品)
			var 缓存道具名=GBIS.moving_item_service.moving_item.item_name
			if 催化剂: 
				var 标签=计划.表格.缓存蓝图标签[缓存道具名]
				if 标签=="催化" or 标签=="特殊催化":
					道具名称=缓存道具名
					$"图片".texture=GBIS.moving_item_service.moving_item.icon
					当前值=1
					更新文本()
				else :
					计划.语法糖通知("材料类型不匹配","炼金容器")
			elif 计划.表格.缓存蓝图标签[缓存道具名]=="炼金":
					道具名称=缓存道具名
					$"图片".texture=GBIS.moving_item_service.moving_item.icon
					当前值=10
					更新文本()
			else :
				计划.语法糖通知("材料类型不匹配","炼金容器")
			#print(道具名称,当前值)
			$"输入".value=当前值
			if not 修改返回对象==null:
				if 计划.节点有效性检查("炼金窗口"):
					计划.节点["炼金窗口"].背包折叠(false)
				修改返回对象.返回处理方法()
			GBIS.moving_item_service.安全清除移动物品()
	elif 鼠标信号 is InputEventMouseButton and 鼠标信号.button_index == MOUSE_BUTTON_RIGHT and 鼠标信号.pressed:
		if not 道具名称==null:
			道具名称=null
			当前值=0
			更新文本()
			if not 修改返回对象==null:
				修改返回对象.返回处理方法()
