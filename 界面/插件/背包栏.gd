extends FoldableContainer
@export var 白名单=[]
func _ready() -> void:
	背包折叠(true)
	folding_changed.connect(背包折叠)
	GBIS.鼠标物品.connect(背包折叠)
func 背包折叠(折叠:=true):
	folded=折叠
	if 折叠:
		title="<背包"
		size=Vector2(180,60)
		position=Vector2(1520,100)
	else :
		title="背包>"
		size=Vector2(1000,900)
		position=Vector2(675,100)
