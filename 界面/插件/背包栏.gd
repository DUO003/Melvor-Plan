extends FoldableContainer
@export var 白名单=[]
@export var 启用背包=[]
@export var 自动打开背包=false
@onready var 选项卡: TabContainer = $选项卡
@onready var 物品栏: ScrollContainer = %物品栏
func _ready() -> void:
	背包折叠(true)
	if 启用背包==[]:
		启用背包=["物品栏"]
	for i in range(选项卡.get_tab_count()):
		var 标题=选项卡.get_tab_title(i)
		#print(标题,启用背包.has(标题),启用背包)
		选项卡.set_tab_disabled(i,not 启用背包.has(标题))
		if 启用背包[0]==标题:
			选项卡.current_tab=i
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
		#size=Vector2(180,60)
		#position=Vector2(1520,100)
	else :
		title="背包 <%s>"%(">,<".join(白名单))
		#size=Vector2(1000,900)
		#position=Vector2(675,100)
