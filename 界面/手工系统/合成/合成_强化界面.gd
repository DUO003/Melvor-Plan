extends 基类梅窗口
@onready var 主菜单: Button = %主菜单
@onready var 配方容器: 梅物品格子 = %配方容器
@onready var 符文容器: 梅物品格子 = %符文容器
@onready var 装备栏: 梅物品格子 = %装备栏
@onready var 装备分解: 梅物品格子 = %装备分解
@onready var 创造数量: SpinBox = %创造数量
@onready var 鉴定: Button = %鉴定
@onready var 创造: Button = %创造
@onready var 分解: Button = %分解
@onready var 鉴定价格: Label = %鉴定价格
@onready var 物品背包: VBoxContainer = %物品背包
@onready var 选项卡: TabContainer = $内容节点/内容/选项卡
@onready var 装备信息: Label = %装备信息
@onready var 材料信息: RichTextLabel = %材料信息
func  _ready() -> void:
	super._ready()#注册
	主菜单.pressed.connect(func():计划.切换场景("合成界面"))
	配方容器.修改返回对象=self
	配方容器.初始更新()
	符文容器.修改返回对象=self
	符文容器.初始更新()
	装备栏.修改返回对象=self
	装备栏.初始更新()
	装备分解.修改返回对象=self
	装备分解.初始更新()
	鉴定.pressed.connect(鉴定判断)
	创造.pressed.connect(创造判断)
	升级.pressed.connect(升级判断)
	分解.pressed.connect(分解判断)
	更新鉴定费用()
	选项卡.current_tab=0
	选项卡.tab_changed.connect(选项卡事件)
	选项卡事件()
	更新装备信息()
	计划.更新_UI.connect(装备升级检查)
func 选项卡事件(_参数=0):
	if not 物品背包:
		print("错误")
		return
	var 当前标签名 = 选项卡.get_tab_title(选项卡.current_tab)
	var 数组:Array[String]
	var 标题:String
	if 当前标签名=="物品鉴定":
		数组=["装备","宝石"]
		标题="待鉴定物品"
	elif 当前标签名=="创造宝石":
		数组=["符文","宝石"]
		标题="符文"
	else :
		物品背包.visible=false
		return
	物品背包.visible=true
	物品背包.切换背包(数组,标题)
func 返回处理方法(节点):
	if 节点 == 配方容器:
		更新鉴定费用()
	if 节点 == 装备栏:
		更新装备信息()
	if 节点 == 装备分解:
		if not 装备分解.上次放入的物品 is 物品装备:
			清空装备分解()
func 清空装备分解():
	装备分解.上次放入的物品=null
	装备分解.道具名称=null
	装备分解.更新文本()
func 分解判断():
	if 装备分解.上次放入的物品:
		if 装备分解.上次放入的物品 is 物品装备:
			GBIS.inventory_service.remove_item_by_data("装备",装备分解.上次放入的物品)
			清空装备分解()
func 更新装备信息():
	if 装备栏.上次放入的物品 is 物品装备:
		var 装备:物品装备=装备栏.上次放入的物品
		装备信息.text=装备.返回简介("强化栏")
		材料文本(装备)
	else :
		装备信息.text="需要放入装备"
		%"材料滚动区".visible=false
@onready var 复选框示例: CheckBox = %复选框示例
@onready var 材料选择: VBoxContainer = %材料选择
@onready var 升级: Button = %升级
var 材料节点字典:Dictionary[CheckBox,Dictionary]
var 选项状态:Dictionary[String,bool]
func 材料文本(装备:物品装备):
	var 材料字典=材料需求(装备)
	%"材料滚动区".visible=true
	计划.清除子节点(材料选择,材料信息)
	材料节点字典={}
	if not 材料字典:
		return
	for 材料名称 in 材料字典:
		var 图片=计划.表格.道具贴图(材料名称)
		var 克隆节点:CheckBox=复选框示例.duplicate()
		var 字典=材料字典[材料名称]
		克隆节点.icon=图片
		克隆节点.visible=true
		if not 字典.可选:
			克隆节点.disabled=true
			克隆节点.button_pressed=true
		else :
			克隆节点.button_pressed=选项状态.get(材料名称,false)
		克隆节点.pressed.connect(装备升级检查)
		材料选择.add_child(克隆节点)
		材料节点字典[克隆节点]=材料字典[材料名称]
	装备升级检查()
func 装备升级检查(通知:bool=false):
	if 装备栏.上次放入的物品 is 物品装备:
		var 装备:物品装备=装备栏.上次放入的物品
		var 材料字典=材料需求(装备)
		var 不足:bool=false
		var 可选:int=0
		if not 材料字典:
			材料信息.text="已满级"
			if 通知:计划.语法糖通知("装备已满级","装备提示")
			return false
		for 克隆节点 in 材料节点字典:
			var 字典:Dictionary=材料节点字典[克隆节点]
			var 材料名称=字典.材料
			var 背包数量=计划.检查背包物品数量(材料名称)
			克隆节点.text="%s:%d/%d"%[材料名称,背包数量,字典.数量]
			if 克隆节点.disabled:
				if 背包数量<字典.数量:
					不足=true
			elif 克隆节点.button_pressed:
				if 背包数量<字典.数量:
					不足=true
				可选+=1
				选项状态[材料名称]=true
			else :选项状态[材料名称]=false
		var 装备职业=装备.职业
		if 装备职业=="":
			if 通知 and not 可选==3:计划.语法糖通知("需要选择3种材料","装备提示")
			if not 不足 and 可选==3:
				材料信息.text="条件满足"
				return true
			else :
				材料信息.text="%s任选%d/3个材料"%[("材料不足\r"if 不足 else ""),可选]
		else :
			if 通知 and not 可选==1:计划.语法糖通知("需要额外选择1种材料","装备提示")
			if not 不足 and 可选==1:
				材料信息.text="条件满足"
				return true
			else :
				材料信息.text="%s固定材料+%d/1个材料"%[("材料不足\r"if 不足 else ""),可选]
	return false
func 装备升级材料扣除():
	if 装备栏.上次放入的物品 is 物品装备:
		for 克隆节点 in 材料节点字典:
			if 克隆节点.button_pressed:
				var 字典:Dictionary=材料节点字典[克隆节点]
				计划.语法糖消耗物品(字典.材料,字典.数量)
func 升级判断():
	if 装备栏.上次放入的物品 is 物品装备:
		var 装备:物品装备=装备栏.上次放入的物品
		if 装备升级检查():
			装备升级材料扣除()
			装备.装备升级(装备.等级+1)
			更新装备信息()
			计划.语法糖通知("升级成功","升级")
		else :
			计划.语法糖通知("升级条件不满足","升级")
func 材料需求(装备:物品装备)->Dictionary:
	var 装备等级=装备.等级
	var 装备阶级=装备.阶级
	var 材料字典={}
	if 装备等级<装备阶级*5:
		var 基础材料=计划.获取配方("基础素材",1,1)
		var 装备职业=装备.职业
		for 材料名称 in 基础材料:
			var 数量=0
			var 可选=true
			if 装备职业=="":
				数量=min(3+装备等级,int(25+装备等级/3.0))
			elif 计划.表格.蓝图数据(材料名称,"职业")==装备职业:
				数量=4+装备等级*2
				可选=false
			else :
				数量=min(20,5+装备等级)
			if 数量>=1:
				材料字典[材料名称]={"数量":数量,"可选":可选,"材料":材料名称}
	return 材料字典
func 鉴定判断():
	if 配方容器.道具名称==null:
		计划.语法糖通知("需要未鉴定装备类物品或者宝石","鉴定")
		return
	var 道具名称=配方容器.道具名称
	var 背包数量=计划.检查背包物品数量(道具名称)
	if 背包数量>=1:
		if 计划.语法糖金币消费(更新鉴定费用(),"鉴定消费"):
			计划.语法糖消耗物品(道具名称,1)
			var 阶级=计划.表格.蓝图数据(道具名称,"阶级")
			计划.手工.数据灵感("精通",阶级*20)
			计划.语法糖通知("灵感精通+%d"%(阶级*20),"灵感")
			if 鉴定概率(道具名称)>=randf():
				if 计划.表格.蓝图标签检查(道具名称,"装备"):
					计划.获得物品语法糖(道具名称,1,"装备物品")
					计划.语法糖通知("装备鉴定成功","鉴定")
				elif 计划.表格.蓝图标签检查(道具名称,"宝石"):
					计划.获得物品语法糖(道具名称,1,"物品宝石")
					计划.语法糖通知("宝石鉴定成功","鉴定")
				else :
					计划.获得物品语法糖(道具名称,1)
					计划.语法糖通知("代码错误,该物品无法鉴定","鉴定")
			else :
				计划.语法糖通知("鉴定失败,物品报废","鉴定")
		else :计划.语法糖通知("金币不足","鉴定")
	else :
		计划.语法糖通知("物品不足","鉴定")
func 创造判断():
	var 数量:int=int(创造数量.value)
	if 符文容器.道具名称==null:
		计划.语法糖通知("需要放入正确的符文","鉴定")
		return
	var 道具名称=符文容器.道具名称
	var 背包数量=计划.检查背包物品数量(道具名称)
	if 背包数量>=5*数量:
		var 对应道具={
	"火符文": "火宝石",
	"水符文": "水宝石",
	"冰符文": "冰宝石",
	"草符文": "草宝石",
	"雷符文": "雷宝石",
	"土符文": "土宝石",
	"风符文": "风宝石"}
		if 对应道具.has(道具名称):
			计划.语法糖消耗物品(道具名称,5*数量)
			计划.获得物品语法糖(对应道具[道具名称],数量)
		else :
			计划.语法糖通知("物品类型错误,需要放入元素符文.","鉴定")
	else :
		计划.语法糖通知("物品不足","鉴定")
func 更新鉴定费用()->int:
	if 配方容器.道具名称==null:
		鉴定价格.text="消耗金币鉴定物品"
		return 0
	var 道具名称=配方容器.道具名称
	var 价格:int=计划.表格.蓝图数据(道具名称,"价值")*5
	var 阶级=计划.表格.蓝图数据(道具名称,"阶级")
	鉴定价格.text="鉴定价格%d金币\r成功率%.1f%%\r鉴定获取灵感精通+%d"%[价格,鉴定概率(道具名称)*100,阶级*20]
	return 价格
func 鉴定概率(道具名称):
	var 成功率=0.5*0.9**(计划.表格.蓝图数据(道具名称,"阶级")-1)
	return 成功率
