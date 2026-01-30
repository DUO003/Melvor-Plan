extends Panel
class_name 检查器方块

@export var 方块名称:String=""
@export var 方块坐标:Vector2i=Vector2i(0,0)
@onready var 贴图: TextureRect = $贴图
@onready var 文本: Label = $文本
@onready var 关闭: Button = $关闭
@onready var 文本编辑器: TextEdit = %文本编辑器
@onready var 确认: Button = %确认
@onready var 切换: CheckButton = %切换
@onready var 方块简介: RichTextLabel = %方块简介
@onready var 地图管理器: 大地图管理 = %地图管理器
@onready var 进度条: ProgressBar = %进度条
@onready var 进度条标签: Label = %进度条标签
var 建筑数据:Dictionary={}
var 节点字典:Dictionary[Vector2i,Control]={}
var 方块道具:物品方块
func _ready() -> void:
	visible=false
	关闭.pressed.connect(func():visible=false)
	确认.pressed.connect(点击逻辑)
	切换.pressed.connect(切换逻辑)
	切换.toggle_mode=true
func 加载方块(名称:String=方块名称,坐标:Vector2i=Vector2i(0,0)):
	#print("检查器")
	计划.地图.方块检查器=self
	visible=true
	方块名称=名称
	方块坐标=坐标
	方块道具=物品方块.new(1,方块名称)
	贴图.texture=方块道具.icon
	文本.text="%s\r坐标(%d,%d)"%[方块名称,方块坐标.x,方块坐标.y]
	建筑数据=地图管理器.建筑数据
	节点字典=地图管理器.节点字典
	确认.visible=false
	切换.visible=false
	文本编辑器.visible=false
	进度条.visible=false
	方块简介.text="简介:\r"+方块道具.简介
	if 方块道具.瓦片功能=="解锁窗口":
		var 加载简介=计划.窗口.界面简介.get(方块道具.功能参数,["当前窗口简介丢失"])
		方块简介.text="简介:\r"+ "\r".join(加载简介)
		var 窗口禁用数组 = 计划.梅存档.挂机.窗口禁用
		切换.button_pressed=not 窗口禁用数组.has(方块道具.功能参数)
		切换.text=方块道具.功能参数
		切换.visible=true
	elif 方块道具.瓦片功能=="资源容量":
		var 资源升级:=计划.手工.资源升级费用(方块道具.功能参数,false)
		var 资源介绍:String="%s资源箱*%d\r升级费用:%d\r故事点数(完成任务获得)"%[方块道具.功能参数,资源升级.加点,资源升级.费用]
		方块简介.text="简介:\r%s\r%s"%[方块道具.简介,资源介绍]
		进度条.max_value=资源升级.费用
		进度条.value=资源升级.代币
		确认.visible=true
		进度条.visible=false
		确认.text="升级"
	elif 方块道具.瓦片功能=="显示提示":
		文本编辑器.visible=true
		确认.visible=true
		确认.text="确认"
		文本编辑器.text=建筑数据.get(方块坐标,"")
		var 节点=节点字典.get(方块坐标,null)
		if 节点:
			if 节点 is 提示框场景:
				节点.切换提示状态(true)
	elif 方块道具.瓦片功能=="对话任务":
		确认.visible=true
		确认.text="对话任务"
func 点击逻辑():
	if 方块道具.瓦片功能=="资源容量":
		建筑升级()
	elif 方块道具.瓦片功能=="显示提示":
		编辑文本()
	elif 方块道具.瓦片功能=="对话任务":
		地图管理器.保存地图数据(地图管理器.家具层)
		启动对话(方块道具.功能参数)
func 切换逻辑():
	if 方块道具.瓦片功能=="解锁窗口":
		窗口切换()
func 编辑文本():
	建筑数据[方块坐标]=文本编辑器.text
	var 节点=节点字典.get(方块坐标,null)
	if 节点:
		if 节点 is 提示框场景:
			节点.传入新文本(文本编辑器.text)
func 窗口切换():
	var 窗口禁用数组:Array = 计划.梅存档.挂机.窗口禁用
	var 窗口名:String=方块道具.功能参数
	if 窗口禁用数组.has(窗口名):窗口禁用数组.erase(窗口名)
	else :窗口禁用数组.append(窗口名)
	切换.button_pressed=not 窗口禁用数组.has(窗口名)
	if 计划.节点有效性检查("空节点"):
		计划.节点["空节点"].生成任务栏按钮()
func 建筑升级():
	pass
func 启动对话(对话任务):
	if Dialogic.current_timeline != null:
		return
	var 首次剧情:=not 计划.任务.检查主线任务完成(对话任务)
	if 首次剧情:
		Dialogic.VAR.set("SCJQ", 首次剧情)#首次剧情=真
		Dialogic.start(对话任务)
	else :
		计划.语法糖通知("任务已完成","任务完成")
	
