extends FoldableContainer
@export var 白名单=[]
@export var 自动打开背包=false
func _ready() -> void:
	背包折叠(true)
	folding_changed.connect(背包折叠)
	if 自动打开背包:
		GBIS.鼠标物品.connect(背包折叠)
	else :
		GBIS.鼠标物品.connect(func(折叠):
			if 折叠:
				背包折叠(true))
func 背包折叠(折叠:=true):
	folded=折叠
	await get_tree().process_frame
	if 折叠:
		title="<背包"
		size=Vector2(180,60)
		position=Vector2(1520,100)
	else :
		title="背包>"
		size=Vector2(1000,900)
		position=Vector2(675,100)
