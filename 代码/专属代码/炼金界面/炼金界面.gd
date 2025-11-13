extends Control


func _ready() -> void:
	%"背包栏".folded=true
	背包折叠(true)
	%"背包栏".folding_changed.connect(func(折叠): 背包折叠(折叠))
	GBIS.connect("鼠标物品",func():
		%"背包栏".folded=true
		背包折叠(%"背包栏".folded))
	
	

func 背包折叠(折叠):
	if 折叠:
		%"背包栏".title="<背包"
		%"背包栏".size=Vector2(180,60)
		%"背包栏".position=Vector2(1520,100)
	else :
		%"背包栏".title="背包>"
		%"背包栏".size=Vector2(730,900)
		%"背包栏".position=Vector2(965,100)
