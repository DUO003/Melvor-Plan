extends Panel
class_name 奖励悬浮面板
var 物品数组: Array=[]:#限制类型为标准物品 或 物品装备
	set(值):
		物品数组=值
		if is_inside_tree():
			更新物品()
func _ready() -> void:
	if not Engine.is_editor_hint():
		初始化.节点["奖励悬浮面板"]=self#注册
	更新物品()
	$"确认".pressed.connect(func():清空界面())
func 语法糖传入数组(物品的数组: Array,奖励标题:String="待确认奖励"):
	%"标题".text=奖励标题
	custom_minimum_size=Vector2(10,0)+%"标题".get_combined_minimum_size()
	物品数组+=物品的数组
func 清空界面():
	物品数组=[]
func 更新物品():#先删除后添加
	var 节点容器:GridContainer=%"范围"
	var 已加载道具: Array[标准物品]=[]
	for 节点 in 节点容器.get_children():
		if not 节点 is 道具卡片类:
			节点容器.remove_child(节点)
			节点.queue_free()
		else :
			var 类型节点:道具卡片类=节点
			if not 类型节点.道具 in 物品数组:
				节点容器.remove_child(节点)
				节点.queue_free()
			else :
				已加载道具+=[类型节点.道具]
	var 节点数量 = 物品数组.size()  # 获取子节点数量
	if 节点数量 >= 1:# 排版逻辑：计算列数并调整位置
		节点容器.size=Vector2(0,0)
		var 实际列数 = clamp(ceil((4 * sqrt(节点数量)) / 3), 3, 15)
		节点容器.columns = int(实际列数)# 转换为整数（GridContainer.columns要求int类型）
	for 物品数据 in 物品数组:
		if not 物品数据 in 已加载道具:
			var 道具卡片场景:道具卡片类 = preload("res://界面/道具卡片.tscn").instantiate()
			道具卡片场景.道具=物品数据
			%"范围".add_child(道具卡片场景)
	节点容器.update_minimum_size()# 更新尺寸
	节点容器.set_size(节点容器.get_combined_minimum_size())
	if 节点数量 >= 50:
		$"滚动区域".size=Vector2(min(1700,节点容器.size.x),550)
	else :
		$"滚动区域".size=节点容器.size
	size = $"滚动区域".size+Vector2(100,105)
	$"滚动区域".position = (size - $"滚动区域".size) / 2
	position=Vector2((1700-size.x)/2,50+(850-size.y)/2)
	visible = 节点数量 >= 1
