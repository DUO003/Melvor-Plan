extends Control
class_name 订单卡片
@export_group("外部传入入参数")
@export var 订单字典: Dictionary={}

@export_group("自动识别参数")
@export var 物品名称:String="铁锭"
@export var 物品贴图:Texture2D
@export var 单价:int=100
@export var 订单量:int=20
@export var 时限:int=-1
@export var 额外概率: float=0.20
@export var 额外数量倍率: float=0.5
@export var 额外物品:String="蓝图纸"
@export var 背包数量:int#每次使用前自行更新
@export var 唯一ID:String#销毁订单的凭据
var 订单标记:int=0#作为枚举使用0表示资源订单

@export_group("固定文本")
@export_multiline var 固定文本:String="[font_size=30]金币合计:[/font_size]{金币数量}[img=40x40]res://素材/游戏素材/货币/without background/2.png[/img]
[font_size=30]{额外奖励概率}%概率:[/font_size]{额外奖励数量}[img=40x40]{额外奖励图片}[/img]"
var 固定条件=[["{金币数量}",func():return 订单金币()],
["{额外奖励概率}",func():return clampi(int(额外概率*100),0,100)],
["{额外奖励数量}",func():return 订单额外()],
["{额外奖励图片}",func():return 梅表格.获取表格信息(梅表格.装备蓝图,额外物品,"icon")]]
var 装饰词数组 = ["优质", "完美", "卓越", "精良", "顶级", "上乘","优选", "精品", "优品",
	"臻品", "绝佳", "超凡","顶配", "高端", "精粹", "极速", "快捷", "高效","速达", "迅捷", "神速", "快单", "急单", "捷取",
	"珍稀", "稀有", "限定","专属", "绝版", "孤品", "特选", "稀缺", "罕见","珍品", "福运", "祥瑞", "吉运", "好运", "顺遂",
	"如意", "安康", "喜乐", "锦鲤", "幸运", "福泽", "吉兆"];
var 装饰随机数=randi() % 装饰词数组.size()
var 固定标题="[img=40x40]{图标}[/img]#{标题}"
var 标题=[["res://素材/豆包AI素材/图标/合成图标.png","资源订单"],["res://素材/豆包AI素材/图标/合成图标.png","课题订单"]]

func _ready() -> void:
	订单解析()
	全面更新()
	更新计时器()
	$"放弃".pressed.connect(func():
		销毁卡片订单()
		if 初始化.节点有效性检查("订单界面"):
			初始化.节点["订单界面"].网格容器.mouse_behavior_recursive=MOUSE_BEHAVIOR_DISABLED
			初始化.创建计时器(0.3,func():初始化.节点["订单界面"].网格容器.mouse_behavior_recursive=MOUSE_BEHAVIOR_INHERITED,false))
	$"提交".pressed.connect(func(): 
		背包数量=初始化.检查背包物品数量(物品名称)
		if 背包数量>=订单量:
			初始化.语法糖消耗物品(物品名称,订单量)
			初始化.梅存档["金币"]+=订单金币()
			if 额外概率>=randf():
				初始化.语法糖获得物品(额外物品,订单额外())
			初始化.emit_signal("更新_UI")
			销毁卡片订单())
	if not 时限==-1:
		$"计时器".timeout.connect(func(): 更新计时器())
func 订单金币():
	return 单价*订单量
func 订单额外():
	return ceili(额外数量倍率*订单量)
func 订单解析():
	物品名称=订单字典.get("名称","错误")
	订单量=订单字典.get("订单量",-1)
	唯一ID=订单字典.get("ID","")
	if 物品名称=="错误" or 订单量==-1 or 唯一ID=="":
		print_rich("[color=red]订单有异常数据错误[/color]\r",订单字典)
		销毁卡片订单()#订单有异常数据错误
	时限=订单字典.get("时限",-1)
	var 缓存表格=梅表格.获取表格字典(梅表格.装备蓝图,-1,物品名称)
	#print(缓存表格)
	var 缓存贴图=load(缓存表格.get("icon",""))
	if 缓存贴图:
		物品贴图=缓存贴图
	单价=int(float(缓存表格.get("价值",1.0))*(1+0.01*订单字典.get("幸运值",0)))
	var 类型=缓存表格.get("类型","")
	if 类型=="符文":
		var 精通等级=初始化.梅存档["手工"].get(物品名称,0)
		单价=int(min(20,1.0305 ** 精通等级))*单价
	var 阶级:int=int(缓存表格.get("阶级",0))
	订单标记=订单字典.get("订单标记",订单标记)
	额外概率=min(0.20+0.08*阶级,1)
	额外数量倍率=(0.4+0.1*阶级)if 阶级<10 else (1.4+0.3*(阶级-10))#补偿概率达到百分比后数量
	if 订单标记==1:
		额外物品="黄图纸"
	else :
		额外物品="蓝图纸"
func 全面更新():
	$"名称单价".text=物品名称+"\n单价:"+str(单价)+"$"
	$"装饰文本".text=装饰词数组[装饰随机数]
	$"贴图".texture=物品贴图
	背包数量=初始化.检查背包物品数量(物品名称)
	$"进度条".max_value=订单量
	$"进度条".value=背包数量
	$"进度条/进度".text=str(min(订单量,背包数量))+"/"+str(订单量)
	
	var 缓存标题=固定标题
	缓存标题=缓存标题.replace("{图标}",标题[订单标记][0])
	缓存标题=缓存标题.replace("{标题}",标题[订单标记][1])
	$"订单类型".text=缓存标题
	报酬处理()
func 更新计时器():
	if 时限==-1:
		$"倒计时".visible=false
	else :
		var 当前时间: float=Time.get_unix_time_from_system()
		var 剩余秒数: int=int(时限-当前时间)
		if 剩余秒数>0:
			$"倒计时".visible=true
			$"倒计时".text="剩余："+初始化.格式化时间(剩余秒数,2)
		else :
			销毁卡片订单()
#未完成 销毁卡片订单
func 销毁卡片订单():
	var 订单存档=初始化.梅存档["挂机"].get("订单存档",[])
	print("订单存档",订单存档)
	print("唯一ID",唯一ID)
	订单存档 = 订单存档.filter(func(订单): return 订单.get("ID") != 唯一ID)
	初始化.梅存档["挂机"]["订单存档"]=订单存档
	queue_free()
	初始化.保存存档("订单完成或订单删除")
func 报酬处理():
	var 文本=固定文本
	for 条件 in 固定条件:
		文本=文本.replace(条件[0], str(条件[1].call()))
	$"报酬".text=文本
