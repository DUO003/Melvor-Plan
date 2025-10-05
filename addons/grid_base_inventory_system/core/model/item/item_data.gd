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
@export var type: String = "ANY"

@export_group("显示设置")
## 物品图标
@export var icon: Texture2D
## 物品占的列数
@export var columns: int = 1
## 物品占的行数
@export var rows: int = 1
## view 上的材质，如果为空，则尝试获取 GBIS.material
@export var material: ShaderMaterial
## 把 shader 需要修改的参数设置在这里
@export var shader_params: Dictionary[String, Variant]

## 获取货品形状
func get_shape() -> Vector2i:
	return Vector2i(columns, rows)

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
	引擎.屏幕.滚动提示("当前类型物品暂时不能直接出售","商店信息")
	return false

## 物品是否能购买（检查资源是否足够等）
func can_buy() -> bool:
	if 初始化.梅存档["金币"]>=self.价值:
	#push_warning("[Override this function] check if the item [%s] can be bought" % item_name)
		return true
	引擎.屏幕.滚动提示("购买失败金币不足","商店信息")
	return false

## 购买后扣除资源
func cost(背包) -> void:
	初始化.梅存档["金币"]-=self.价值
	self.商店剩余数量-=1
	if self.商店剩余数量<=0:
		GBIS.inventory_service.remove_item_by_data(背包, self)
		引擎.屏幕.滚动提示("该商品当前库存已空谢谢惠顾","商店信息补货")
		print("商店剩余数量<=0")
	初始化.emit_signal("更新_UI")#刷新金币数量显示
	初始化.购买物品.emit(self,背包)#刷新商品描述显示 剩余数量
	#push_warning("[Override this function] [%s] cost resource" % item_name)

## 出售后增加资源
func sold() -> void:
	if self is 物品装备:
		初始化.梅存档["金币"]+=100
		引擎.屏幕.滚动提示("出售成功获取金币+100","商店信息")
		初始化.emit_signal("更新_UI")
	#push_warning("[Override this function] [%s] add resource" % item_name)

## 购买并添加到背包
func buy(背包) -> bool:
	if not can_buy():
		return false
	for target_inv in GBIS.inventory_names:
		var 资源 = self.duplicate()
		if 资源 is 标准物品:
			资源.价值=0
			资源.商店剩余数量=0
			引擎.屏幕.滚动提示("购买成功:"+str(资源.item_name),"商店信息")
		if GBIS.inventory_service.add_item(target_inv, 资源):
			cost(背包)
			return true
	return false
