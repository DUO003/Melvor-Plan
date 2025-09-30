extends EquipmentData
class_name 物品装备


@export_group("装备属性")
## 装备阶级 每1级对应5级游历系统等级,最高20.
@export var 阶级: int = 1
@export var 附魔: Dictionary[String, int] = {}

@export_group("职业属性")
## "分类"或"职业">"类型"
##"分类"可选项["武器","护甲","饰品"]决定物品检索
@export var 分类: String = "武器"
##"类型"装备的具体对应装备槽,部分固定属性由"职业"与"类型"决定
@export var 类型: String = "长剑"
##"职业"可选项["战士","法师","射手"]部分固定属性由"职业"与"类型"决定
@export var 职业: String = "战士"
