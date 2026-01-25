#@tool
extends TabContainer
var 瓶子 = preload("res://界面/插件/瓶子.tscn")
var 配方容器场景:梅物品格子 = preload("res://界面/插件/配方容器.tscn").instantiate()
var 食材数组:Array=[]
##每个瓶子的容量
var 食材上限=10
##限制瓶子数量
var 食材瓶限制=10
var 瓶子节点数组:Array=[]
var 格子节点数组:Array=[]
@onready var 食材处理容器: HBoxContainer = %食材处理容器
@onready var 资源: Control = %资源
@onready var 预处理食材标题: Label = %预处理食材标题
@onready var 调味点数: HBoxContainer = %调味点数
@onready var 自动制作: HBoxContainer = $自动制作
@onready var 自动制作标题: VBoxContainer = %自动制作标题

func _ready() -> void:
	加载瓶子食材处理区()
	加载调味点数()
	计划.更新_UI.connect(加载瓶子食材处理区)
	计划.更新_UI.connect(加载调味点数)
	计划.更新玩法.connect(加载制作队列)
	计划.手工.检查并更新队列("烹饪")
	加载制作队列()
func 加载制作队列():
	var 队列烹饪=计划.手工.队列烹饪()
	var 配方节点:队列卡片=preload("res://界面/插件/队列卡片.tscn").instantiate()
	var 序号:int=0
	计划.清除子节点(自动制作,自动制作标题)
	for 队列数据:梅烹饪数据 in 队列烹饪:
		print("加载成功",队列数据)
		var 克隆节点:队列卡片=配方节点.duplicate()
		克隆节点.序号=序号
		克隆节点.队列数据=队列数据
		克隆节点.界面更新方法=func(_参数):加载制作队列()
		自动制作.add_child(克隆节点)
		序号+=1
func 领取奖励(烹饪数据:梅烹饪数据):
	if 烹饪数据.领取奖励():
		加载制作队列()

var 配置字典={"可修改物品":false,"可修改数量":false,"编号":0,"道具名称":"","默认值":5,"修改返回对象": self,"物品不足提示":false}
func 加载调味点数():
	var 调料数组:Array=计划.手工.数据调料点数("")
	if 调料数组.size()==格子节点数组.size():
		var 序号=0
		for 格子:梅物品格子 in 格子节点数组:
			格子.道具名称=调料数组[序号]
			格子.当前值=计划.手工.数据调料点数(调料数组[序号])
			格子.更新文本()
			序号+=1
	else :
		计划.清除子节点(调味点数)
		格子节点数组.clear()
		for 调料名 in 调料数组:
			var 格子:梅物品格子=配方容器场景.duplicate()
			配置字典["道具名称"]=调料名
			配置字典["默认值"]=计划.手工.数据调料点数(调料名)
			格子.从字典初始化(配置字典)
			调味点数.add_child(格子)
			格子节点数组.append(格子)
func 加载瓶子食材处理区() -> void:
	if Engine.is_editor_hint():
		食材数组=[{"数量":4,"物品类型":"白伞菇","标签":"切割"}]
	else :
		加载存档()
		计划.清除子节点(食材处理容器,预处理食材标题)#编辑器内时无法访问 计划 全局代码
	瓶子节点数组.clear()
	var 瓶子场景:梅计划_瓶子=瓶子.instantiate()
	var 随机=RandomNumberGenerator.new()
	for 食材 in 食材数组:
		var 瓶子克隆:梅计划_瓶子 = 瓶子场景.duplicate()
		随机.seed= hash(食材["物品类型"])
		瓶子克隆.内容长度=食材上限
		瓶子克隆.迷雾数量=0
		var 颜色:Color=Color(随机.randf(), 随机.randf(), 随机.randf())
		瓶子克隆.内容数组.clear()
		瓶子克隆.内容数组.append({颜色:食材["数量"]})
		var 瓶子缩放节点 = 瓶子克隆.get_node_or_null("瓶子缩放")
		if 瓶子缩放节点 is Control:
			瓶子缩放节点.scale = Vector2(1.2, 1.2)
		if not Engine.is_editor_hint():
			瓶子克隆.mouse_entered.connect(func():更新数据(食材,瓶子克隆))
			瓶子克隆.mouse_exited.connect(func():更新数据())
			瓶子克隆.gui_input.connect(func(按键):
				if 按键 is InputEventMouseButton and 按键.button_index == MOUSE_BUTTON_LEFT and 按键.pressed:
					选择物品(食材))
		食材处理容器.add_child(瓶子克隆)
		瓶子节点数组.append(瓶子克隆)
		瓶子克隆.更新瓶子()
	预处理食材标题.text="瓶子容量%d\r瓶子限制%d\r当前拥有:%d"%[食材上限,食材瓶限制,瓶子节点数组.size()]
func 选择物品(食材:Dictionary={}):
	var 新建物品:标准物品=标准物品.new(1,食材["物品类型"])
	新建物品.特殊标签=食材["标签"]
	新建物品.current_amount=0
	GBIS.moving_item_service.move_item_by_data(新建物品, Vector2i.ZERO, 128)
func 更新数据(食材:Dictionary={},节点=null):
	if 食材 and 节点:
		var 坐标=节点.global_position
		坐标.x+=节点.size.x*0.5
		资源.更新传入新值(食材,食材上限,坐标)
	else :资源.visible=false
func 加载存档():
	食材数组=计划.手工.获取食材数组()
