extends Panel
var 配方容器场景:梅物品格子 = preload("res://界面/插件/配方容器.tscn").instantiate()
@export var 料理名称:String=""
@onready var 食材容器: HBoxContainer = %食材容器
@onready var 食材标题: Label = %食材标题
@onready var 材料: RichTextLabel = $料理排序/材料
@onready var 贴图: TextureRect = $料理排序/顶部信息/贴图
@onready var 属性标签: Label = $料理排序/顶部信息/属性标签
@onready var 制作: Button = $料理排序/按钮容器/制作
@onready var 保存: Button = $料理排序/按钮容器/保存


var 格子节点数组:Array=[]
var 基础美味度:float
var 当前美味度:float=0
var 当前调料加成:float=0.0
var 所需材料数:int=0
var 味道:String=""
var 代币费用:int
var 菜谱:Dictionary
var 卡路里:int
##材料是否满足
var 材料判断:bool=true
func _ready() -> void:
	加载食材()
	加载解锁()
	制作.pressed.connect(制作料理)
@onready var 解锁按钮: Button = $未解锁/解锁标签/解锁按钮
@onready var 解锁标签: Label = $未解锁/解锁标签
@onready var 未解锁: Panel = $未解锁
func 加载解锁():
	if 计划.手工.数据烹饪菜谱(料理名称,"等级")==-1:
		解锁按钮.pressed.connect(解锁判断)
		未解锁.visible=true
		解锁标签.text="你需要消耗%d个\r烹饪代币解锁"%代币费用
	else :
		未解锁.visible=false
func 解锁判断():
	if 计划.检查背包物品数量("烹饪代币")>=代币费用:
		计划.语法糖消耗物品("烹饪代币",代币费用)
		计划.语法糖通知("配方已解锁")
		计划.手工.获得菜谱(料理名称)
		未解锁.visible=false
	else :
		计划.语法糖通知("配方代币不足")
var 配置字典={"可修改数量":false,"编号":1,"限制类型":["食材"],"空置标签":"","默认值":5,"修改返回对象": self}
func 加载食材():
	计划.清除子节点(食材容器,食材标题)
	var 属性=计划.表格.获取属性(料理名称,null)
	if 属性 is Dictionary:
		基础美味度=属性.get("美味度",50)
		代币费用=属性.get("代币",100)
		菜谱=属性.get("菜谱",{})
		卡路里=属性.get("卡路里",0)
		贴图.texture=计划.表格.道具贴图(料理名称)
		#print("打印数据",基础美味度,"/",代币费用,菜谱)
		var 材料数组:Array=[]
		所需材料数=0
		var 编号=0
		for 内容 in 菜谱:
			var 材料格子:梅物品格子=配方容器场景.duplicate()
			配置字典["编号"]=编号
			if 内容=="味道":
				味道=菜谱[内容]
				配置字典["空置标签"]="调味品"
				配置字典["默认值"]=1
				配置字典["限制类型"]=["调料"]
				材料数组.append("口味:"+str(菜谱[内容]))
			else :
				配置字典["默认值"]=int(菜谱[内容])
				配置字典["空置标签"]=内容
				配置字典["限制类型"]=["食材"]
				所需材料数+=int(菜谱[内容])
				材料数组.append(内容+"*%.0f"%菜谱[内容])
			材料格子.从字典初始化(配置字典)
			材料格子.custom_minimum_size=Vector2(100,100)
			食材容器.add_child(材料格子)
			格子节点数组.append(材料格子)
			编号+=1
			更新标签()
		材料.text="需要:\r"+",".join(材料数组)
	else :
		print("错误,食物%s加载失败"%料理名称,属性)
func 更新标签():
	计算美味度()
	材料判断=true
	for 节点 in 格子节点数组:
		if 节点 is 梅物品格子:
			if 节点.空置标签=="调味品":
				if not 节点.道具名称==null and  not 节点.物品数量判断():
					材料判断=false
			elif not 节点.物品数量判断():
				材料判断=false
		else :材料判断=false
	制作.text="材料不足"if not 材料判断 else "制作"
	保存.text="不够美味"if 当前美味度<基础美味度 else "保存"
	var 固定属性格式="+%d卡路里\n美味度%.0f(%.1f)\n解锁需要%.0f"
	var 存档美味度:float=计划.手工.数据烹饪菜谱(料理名称,"美味度")
	属性标签.text=固定属性格式%[卡路里,存档美味度,当前美味度,基础美味度]
func 计算美味度():
	var 调料倍率=10.25
	var 美味度合计=0
	当前调料加成=0.0
	for 节点 in 格子节点数组:
		#print("物品",节点.道具名称)
		if 节点 is 梅物品格子 and not 节点.道具名称==null:
			var 属性字典=计划.表格.获取属性(节点.道具名称)
			if 节点.空置标签=="调味品":
				if 属性字典 is Dictionary and "口味" in 属性字典:
					if 属性字典["口味"]==味道:
						调料倍率=0.35
					美味度合计+=5*所需材料数
					当前调料加成+=计划.表格.蓝图数据(节点.道具名称,"阶级")*0.01
			else :
				if 属性字典 is Dictionary and "美味度" in 属性字典:
					var 美味度=float(属性字典["美味度"])*节点.当前值*2.5
					if 节点.特殊标签=="":
						美味度合计+=美味度*1.0
					else :
						美味度合计+=美味度*计划.手工.烹饪工序查询(节点.特殊标签,"倍率")
	当前美味度= (基础美味度*调料倍率)+美味度合计*(1.0/所需材料数)
func 返回处理方法(节点:梅物品格子):
	var 食材属性=计划.表格.获取属性(节点.道具名称,null)
	if 食材属性 is Dictionary and 节点.空置标签=="调味品":
		更新标签()
	elif 食材属性 is Dictionary and 食材属性.has("食材") and 食材属性["食材"]==菜谱.keys()[节点.编号]:
		更新标签()
	else :
		计划.语法糖通知("不能放入这个%s物品"%节点.道具名称,"料理提示")
		解除物品(节点)
		更新标签()
func 解除物品(配方容器):
	配方容器.道具名称=null
	配方容器.特殊标签=""
	配方容器.更新文本()
var 快速反应场景
var QTE:Panel = preload("res://界面/手工系统/烹饪/qte.tscn").instantiate()
func 制作料理():
	if 快速反应场景:
		快速反应结算(快速反应场景.得分)
		快速反应场景.queue_free()
	else :
		更新标签()
		if 材料判断:
			快速反应场景=QTE.duplicate()
			%"画布".add_child(快速反应场景)
func 快速反应结算(得分):
	if 材料判断:
		for 节点 in 格子节点数组:
			if 节点 is 梅物品格子 and not 节点.道具名称==null:
				删除逻辑(节点)
	var 新美味度=当前美味度*(1+0.1*得分)
	计划.手工.数据烹饪菜谱(料理名称,"美味度",新美味度)
	计划.获得物品语法糖(料理名称,1)
	计划.更新_UI.emit()
	计划.语法糖通知("制作成功%s"%料理名称,"料理制作")
	更新标签()
func 删除逻辑(节点:梅物品格子):
	if 节点.特殊标签=="":
		计划.语法糖消耗物品(节点.道具名称,节点.当前值)
	else :
		计划.手工.烹饪预制(节点.道具名称,节点.特殊标签,-节点.当前值)
