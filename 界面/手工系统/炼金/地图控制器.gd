extends Control
@onready var 地图背景: 梅噪声地图 = $地图背景
@onready var 地图节点: 梅噪声地图 = $地图节点
func _process(时间):
	地图背景.噪声偏移X+=时间*10
	地图背景.生成噪声地图数据()
	地图背景.绘制地图()
