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
@onready var 物品处理逻辑: HBoxContainer = %物品处理逻辑
@onready var 配方容器: 梅物品格子 = %配方容器
@onready var 目标容器: 梅物品格子 = %目标容器
@onready var 小商店容器: VBoxContainer = %小商店容器

var 建筑数据:Dictionary[Vector2i,建筑资源]={}
var 节点字典:Dictionary[Vector2i,Control]={}
var 方块道具:物品方块
func _ready() -> void:
	visible=false
	关闭.pressed.connect(func():visible=false)
	确认.pressed.connect(点击逻辑)
	切换.pressed.connect(切换逻辑)
	切换.toggle_mode=true
	配方容器.修改返回对象=self
	目标容器.修改返回对象=self
	配方容器.初始更新()
	目标容器.初始更新()
	计划.过去一秒.connect(更新检查)
	计划.更新_UI.connect(更新检查)
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
	物品处理逻辑.visible=false
	小商店容器.visible=false
	方块简介.text="简介:\r"+方块道具.简介
	方块简介.size_flags_vertical=SIZE_EXPAND_FILL
	if 方块道具.瓦片功能=="解锁窗口":
		var 加载简介=计划.窗口.窗口数据[方块道具.功能参数].简介
		方块简介.text="简介:\r"+ "\r".join(加载简介)
		var 窗口禁用数组 = 计划.梅存档.挂机.窗口禁用
		切换.button_pressed=not 窗口禁用数组.has(方块道具.功能参数)
		切换.text=计划.窗口.窗口数据[方块道具.功能参数].显示名
		切换.visible=true
	elif 方块道具.瓦片功能=="资源容量":
		var 资源升级:=计划.手工.资源升级费用(方块道具.功能参数,false)
		var 资源介绍:String="%s资源箱*%d\r升级费用:%d\r故事点数(完成任务获得)"%[方块道具.功能参数,资源升级.加点,资源升级.费用]
		方块简介.text="简介:\r%s\r%s"%[方块道具.简介,资源介绍]
		进度条.max_value=资源升级.费用
		进度条.value=资源升级.代币
		确认.visible=true
		进度条.visible=true
		确认.text="升级"
	elif 方块道具.瓦片功能=="显示提示":
		文本编辑器.visible=true
		确认.visible=true
		确认.text="确认"
		if 建筑数据.has(方块坐标):
			文本编辑器.text=建筑数据[方块坐标].文本数据
		else :
			文本编辑器.text=""
		var 节点=节点字典.get(方块坐标,null)
		if 节点:
			if 节点 is 提示框场景:
				节点.切换提示状态(true)
	elif 方块道具.瓦片功能=="图书馆":
		if not 计划.任务.检查主线任务完成("新手任务"):
			确认.visible=true
			确认.text="对话任务"
		小商店容器.更新商品信息(方块道具.item_name)
		方块简介.size_flags_vertical=SIZE_FILL
	elif 方块道具.瓦片功能=="点数加工":
		确认.visible=true
		进度条.visible=true
		小商店容器.更新商品信息(方块道具.item_name)
		确认.text="领取点数"
		方块简介.size_flags_vertical=SIZE_FILL
		加载物品逻辑()
		点数工作台简介()
	elif 方块道具.瓦片功能=="点数仓库":
		更新检查()
		
func 更新检查():
	if not (visible and 方块道具):
		return
	if 方块道具.瓦片功能=="点数加工":
		返回处理方法()
		点数工作台简介()
	elif 方块道具.瓦片功能=="点数仓库":
		var 点数文本:Array=[]
		var 点数:梅点数=计划.点数
		for 点数名 in 点数.点数字典:
			点数文本.append("%s点数\r[img=40x40]%s[/img]:%d 点"%[
				点数名,计划.表格.道具贴图(点数名).resource_path,点数.点数字典[点数名]])
		方块简介.text="简介:\r"+方块道具.简介+"\r"+"\r".join(点数文本)
func 返回处理方法(格子:梅物品格子=配方容器):
	if not 建筑数据.has(方块坐标):
		print("错误找不到建筑数据")
		return
	var 建筑:建筑资源=建筑数据[方块坐标]
	if 配方容器==格子:
		var 物品:标准物品=配方容器.上次放入的物品
		物品=建筑.点数加工(物品)
		if 物品:
			配方容器.当前值=物品.数量
			配方容器.道具名称=物品.item_name
		else :
			配方容器.道具名称=null
			配方容器.上次放入的物品=null
		var 产物:标准物品=建筑.产物
		if 产物:
			目标容器.当前值=产物.数量
			目标容器.特殊标签="点数"
			目标容器.道具名称=产物.item_name
		else :
			目标容器.道具名称=null
		配方容器.更新文本()
		目标容器.更新文本()
func 点数工作台简介():
	if not 建筑数据.has(方块坐标):
		print("错误找不到建筑数据")
		return
	var 建筑:建筑资源=建筑数据[方块坐标]
	var 储物空间:Array[标准物品]=建筑.储物空间
	var 产物:标准物品=建筑.产物
	var 点数上限:int=0
	if not 储物空间.is_empty():
		点数上限+=储物空间[0].数量*建筑.产量
	var 点数:梅点数=计划.点数
	if 产物:
		点数上限+=产物.数量
		方块简介.text="%s点数:%d\r效率1:%d耗时:%s"%[
			产物.item_name,点数.查看点数(产物.item_name),建筑.产量,计划.格式化时间(int(建筑.耗时))]
		进度条标签.text="%d/%d"%[产物.数量,点数上限]
		进度条.max_value=max(1,建筑.耗时)
		进度条.value=建筑.耗时计算()
	else :
		方块简介.text="放入物品加工为对应点数"
		进度条标签.text="等待"
		进度条.max_value=1
		进度条.value=0
func 加载物品逻辑():
	物品处理逻辑.visible=true
	var 储物空间:Array[标准物品]=建筑数据[方块坐标].储物空间
	if 储物空间.size()>=1:
		配方容器.上次放入的物品=储物空间[0]
	else :
		配方容器.上次放入的物品=null
	返回处理方法()
func 点击逻辑():
	if 方块道具.瓦片功能=="资源容量":
		建筑升级()
	elif 方块道具.瓦片功能=="显示提示":
		编辑文本()
	elif 方块道具.瓦片功能=="图书馆":
		地图管理器.保存地图数据()
		await get_tree().process_frame
		启动对话("新手任务")
	elif 方块道具.瓦片功能=="点数加工":
		领取点数()
func 切换逻辑():
	if 方块道具.瓦片功能=="解锁窗口":
		窗口切换()
func 编辑文本():
	if 建筑数据.has(方块坐标):
		建筑数据[方块坐标].文本数据=文本编辑器.text
		var 节点=节点字典.get(方块坐标,null)
		if 节点:
			if 节点 is 提示框场景:
				节点.传入新文本(文本编辑器.text)
	else :
		print("错误,找不到建筑数据")
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
func 领取点数():
	if not 建筑数据.has(方块坐标):
		print("错误找不到建筑数据")
		return
	var 产物:标准物品=建筑数据[方块坐标].产物
	if 产物:
		var 物品数组:Array=[计划.获得物品语法糖(产物.item_name,产物.数量,"点数")]
		计划.语法糖奖励显示(物品数组,"获得点数")
		建筑数据[方块坐标].产物=null
		返回处理方法()
		点数工作台简介()
	else :
		计划.语法糖通知("还没有点数可领取","点数工作台")
