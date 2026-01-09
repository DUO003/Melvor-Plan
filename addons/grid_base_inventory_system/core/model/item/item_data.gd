extends Resource
## 物品数据基类，不要直接继承这个类
class_name ItemData

## 调用后，将调用包含这个 data 的 view 的 queue_redraw()
## 场景：比如，强化装备后，修改了 shader 参数，但是不想重绘整个 Inventory，可以 emit 这个信号
signal sig_refresh

@export_group("通用设置")
## 物品名称，需要唯一
@export var item_name: String = "Item Name"
## 物品类型，值为“ANY”表示所有类型
var type: String = "ANY"

@export_group("显示设置")
## 物品图标
var icon: Texture2D=null
## 物品占的列数
var columns: int = 1
## 物品占的行数
var rows: int = 1
## view 上的材质，如果为空，则尝试获取 GBIS.material
var material: ShaderMaterial
## 把 shader 需要修改的参数设置在这里
var shader_params: Dictionary[String, Variant]
## 加载逻辑0 专门为存档使用[br]
## 加载逻辑1 自动加载数据[br]
## 加载逻辑2 手动加载 不进行init内处理
func _init(加载逻辑=0,物品名称: String="默认名称") -> void:
	if 加载逻辑==0 and 计划.就绪():
		call_deferred("延迟加载")
		return
	elif 加载逻辑==1:
		item_name=物品名称
		if not item_name in 计划.表格.蓝图字典:
			push_warning("错误[%s]:未能读取到表格" % item_name)
		更新属性()
var 延迟计数器=0
func 延迟加载():
	if item_name=="Item Name":
		延迟计数器+=1
		if 延迟计数器>10:
			push_warning("错误超过延迟执行范围")
			return
		call_deferred("延迟加载")
	else :
		更新属性()
##加载数据专用
var 表格数据:=[]
##加载数据专用
var 蓝图表头
##从表格数据加载物品信息(必须先等表格初始化)
func 更新属性()->bool:
## 物品图标
	icon=计划.表格.道具贴图(item_name)
## 正式开始数据加载
	表格数据=计划.表格.蓝图字典.get(item_name,[])
	蓝图表头=计划.表格.蓝图表头
	if 表格数据==[]:
		var 替换字典={"挂件精通代币":"挂机精通代币"}
		if 替换字典.has(item_name):
			item_name=替换字典[item_name]
			表格数据=计划.表格.蓝图字典.get(item_name,[])
			蓝图表头=计划.表格.蓝图表头
	if 表格数据==[]:
		push_warning("错误[%s]:未能读取到表格信息,表格:" % [item_name],计划.表格.蓝图字典.keys())
		#breakpoint
		return false
## 物品占的列数
	columns = int(表格数据[蓝图表头["列"]])
## 物品占的行数
	rows = int(表格数据[蓝图表头["行"]])
	return true
## 获取货品形状
func get_shape() -> Vector2i:
	return Vector2i(columns, rows)
## 物品掉落
func can_drop() -> bool:
	push_warning("[Override this function] check if the item [%s] can drop" % item_name)
	return true

## 丢弃物品时调用，需重写
func drop() -> void:
	push_warning("[Override this function] item [%s] dropped" % item_name)

## 物品是否能出售（是否贵重物品等）
func can_sell() -> bool:
	if self is 物品装备:
		return true
	计划.语法糖通知("当前类型物品暂时不能直接出售","商店信息")
	return false

## 物品是否能购买（检查资源是否足够等）
func can_buy() -> bool:
	if 计划.语法糖金币消费(self.价值,"随身商店"):return true
	计划.语法糖通知("购买失败金币不足","商店信息")
	return false

## 购买后逻辑
func cost(背包) -> void:
	self.商店剩余数量-=1
	if self.商店剩余数量<=0:
		GBIS.inventory_service.remove_item_by_data(背包, self)
		计划.语法糖通知("该商品当前库存已空谢谢惠顾","商店信息补货")
		print("商店剩余数量<=0")
	计划.更新_UI.emit()#刷新金币数量显示
	计划.购买物品.emit(self,背包)#刷新商品描述显示 剩余数量
	#push_warning("[Override this function] [%s] cost resource" % item_name)

## 出售后增加资源
func sold() -> void:
	if self is 物品装备:
		计划.梅存档["金币"]+=100
		计划.语法糖通知("出售成功获取金币+100","商店信息")
		计划.emit_signal("更新_UI")
	#push_warning("[Override this function] [%s] add resource" % item_name)

## 购买并添加到背包
func buy(背包) -> bool:
	if not can_buy():
		return false
	var 资源 = self.duplicate()
	if 资源 is StackableData:
		资源.stack_size=self.stack_size#必须保留,因为这个不是存档变量.
	if 资源 is 标准物品:#可选,这些值仅作为商品生效,删掉可以少一行存档数据
		资源.价值=0
		资源.商店剩余数量=0
	for 背包名称 in GBIS.inventory_names:
		if GBIS.inventory_service.add_item(背包名称, 资源):
			计划.语法糖通知("购买成功:"+str(资源.item_name),"商店信息")
			cost(背包)
			return true
	return false
var 排序缓存:int=0#0是一个不可能值,因为0号位置是表头不存放物品,-1为找不到物品
func 排序值()->int:
	if 排序缓存>=1:
		return 排序缓存
	if 计划.表格.蓝图字典.has(item_name):
		var 蓝图键数组 = 计划.表格.蓝图数组
		排序缓存 = 蓝图键数组.find(item_name)
	else :
		排序缓存 =-1
	return 排序缓存
func 返回简介(背包名):
	var 简介="物品名称:"+item_name
	if GBIS.shop_names.has(背包名):简介+="(商品)"
	return 简介
