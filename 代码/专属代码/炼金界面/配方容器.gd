extends Control
class_name 梅物品格子
##启用后玩家可以把符合限制物品拖动到格子内进行替换,替换成功执行回调方法
@export var 可修改物品:bool=true
##启用后格子内有物品时玩家可以使用滑块修改物品数量,修改后执行回调方法
@export var 可修改数量:bool=true
##如果需要修改数量需要传入一个限制范围,至少有差值大于1才会显示滑块(支持自动排列小的数字到前面)
@export var 物品数量限制:Vector2i=Vector2i(1,64)
##如果需要区分回调方法是那个格子执行的,可以预先分配一个编号.
@export var 编号:int=1
##覆盖类型限制逻辑,优先级更高,如果为空执行限制类型逻辑,否则只允许白名单的物品放入格子
@export var 物品白名单:Array=[]
##如果物品白名单为空,且限制类型也为空则,可以放入任意物品,限制类型后只能放入类型与限制一致的物品.
@export var 限制类型:Array=[]
##限制类型筛选后,可以对也有额外属性的食材进行筛选.满足其中之一即可
@export var 限制属性类型:Dictionary={}
##如果格子内是空的会显示的文本
@export var 空置标签:String="空格子"
##如果放入的物品不符合条件会发送给玩家的提示
@export var 标签警告:String="内容物品错误"
##支持无标签物品和烹饪玩法的物品在背包内物品不足是变为灰色
@export var 物品不足提示:bool=true
##物品被替换或初始化后自动设置一个数量的值
@export var 默认值:int=1
var 当前值=默认值
var 道具名称=null
var 特殊标签=""
var 修改返回对象=null#通过代码传入
@onready var 输入: HSlider = $输入
@onready var 数量: Label = $数量

var 初始化=false
func _ready() -> void:
	if 初始化:
		初始更新()
		计划.更新_UI.connect(更新文本)
##初始化方法,一步到胃初始化节点
func 从字典初始化(自定义配置: Dictionary = {}) -> void:
	可修改物品 = 自定义配置.get("可修改物品", true)
	可修改数量 = 自定义配置.get("可修改数量", true)
	if 可修改数量:
		物品数量限制 = 自定义配置.get("物品数量限制", Vector2i(1, 64))
	编号 = 自定义配置.get("编号", 1)
	物品白名单 = 自定义配置.get("物品白名单", [])
	限制类型 = 自定义配置.get("限制类型", [])
	限制属性类型 = 自定义配置.get("限制属性类型", {})
	空置标签 = 自定义配置.get("空置标签", "空格子")
	标签警告 = 自定义配置.get("标签警告", "内容物品错误")
	物品不足提示 = 自定义配置.get("物品不足提示",true)
	默认值 = 自定义配置.get("默认值", 1)
	if 自定义配置.get("禁止初始更新", false):
		初始化=false
		return
	当前值=默认值
	道具名称=自定义配置.get("道具名称", null)
	特殊标签=自定义配置.get("特殊标签", "")
	修改返回对象=自定义配置.get("修改返回对象", null)
	初始化=true
	
func 初始更新():
	if 可修改物品:
		gui_input.connect(鼠标信号处理)
	当前值=默认值
	输入.value=当前值
	if 可修改数量:
		if 物品数量限制.x>物品数量限制.y:
			物品数量限制=Vector2i(物品数量限制.y,物品数量限制.x)
		输入.visible=true
		输入.min_value=物品数量限制.x
		输入.max_value=物品数量限制.y
		输入.value_changed.connect(func(值):
			if 当前值!=int(值):
				当前值=int(值)
				if not 修改返回对象==null:
					修改返回对象.返回处理方法(self)
				更新文本())
	else :
		输入.visible=false
	更新文本()
func 更新文本():
	if 道具名称==null:
		数量.text=空置标签
		$"图片".texture=null
		$"图片".size=size
		数量.position.y=(size.y-数量.size.y)*0.5
		$"标签".visible=false
		输入.visible=false
	else :
		if 可修改数量 and 物品数量限制.x>=1:
			输入.visible=true
		else :输入.visible=false
		if 当前值>1:
			数量.text=str(当前值)
			$"图片".size=Vector2(size.x,size.y-数量.size.y+10)
		else :
			数量.text=""
			$"图片".size=size
		数量.position.y=size.y-数量.size.y
		$"图片".texture=计划.表格.道具贴图(道具名称)
		if 物品不足提示 and not 物品数量判断():
			$"图片".self_modulate=Color(0.245, 0.245, 0.245, 1.0)
		else :
			$"图片".self_modulate=Color(1.0, 1.0, 1.0, 1.0)
		if 特殊标签=="":
			$"标签".visible=false
		else :
			$"标签".add_theme_font_size_override("font_size", (size.y/5))
			$"标签".text=特殊标签
			$"标签".visible=true
##判断当前数量是否小于等于背包中数量
func 物品数量判断()->bool:
	if 道具名称==null:return false
	var 物品数量=0
	if 特殊标签=="":
		物品数量=计划.检查背包物品数量(道具名称)
	elif 计划.表格.蓝图标签检查(道具名称,"食材"):物品数量=计划.手工.烹饪预制(道具名称,特殊标签)
	return 物品数量>=当前值
func 鼠标信号处理(鼠标信号):
	#print(鼠标信号)
	if 鼠标信号 is InputEventMouseButton and not 鼠标信号.pressed:
		if GBIS.has_moving_item():
			var 正在移动的物品=GBIS.moving_item_service.moving_item
			#print("正在移动的物品",正在移动的物品)
			var 缓存道具名=正在移动的物品.item_name
			if 物品白名单.size()>=1:
				if 物品白名单.has(缓存道具名):
					设置物品(正在移动的物品)
				else :计划.语法糖通知(标签警告,"炼金容器")
			else :
				if 计划.表格.蓝图标签检查(缓存道具名,限制类型) or 限制类型.size()==0:
					if 限制属性类型.keys().size()==0:
						设置物品(正在移动的物品)
					else :
						var 物品属性=计划.表格.获取属性(缓存道具名,null)
						if 物品属性 is Dictionary:
							var 完成条件=false
							for 条件 in 限制属性类型:
								if 物品属性.has(条件) and 限制属性类型[条件].has(物品属性[条件]):
									设置物品(正在移动的物品)
									完成条件=true
									break
							if not 完成条件:
								计划.语法糖通知(标签警告,"炼金容器")
				else :计划.语法糖通知("标签"+标签警告,"炼金容器")
			$"输入".value=当前值
			if 正在移动的物品 is 标准物品:
				if 正在移动的物品.特殊标签=="":
					GBIS.鼠标物品.emit(false)
			if not 修改返回对象==null:
				修改返回对象.返回处理方法(self)
			GBIS.moving_item_service.安全清除移动物品()
	elif 鼠标信号 is InputEventMouseButton and 鼠标信号.button_index == MOUSE_BUTTON_RIGHT and 鼠标信号.pressed:
		if not 道具名称==null:
			道具名称=null
			当前值=默认值
			更新文本()
			if not 修改返回对象==null:
				修改返回对象.返回处理方法(self)
func 设置物品(物品:ItemData):
	道具名称=物品.item_name
	当前值=默认值
	if 物品 is 标准物品:
		特殊标签=物品.特殊标签
	更新文本()
