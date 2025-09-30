extends Control

var 名称: String
var 持续时间: float
var 执行动作中 := false

@onready var 进度条: ProgressBar = $进度条
@onready var 动作名文本: Label = $动作名文本
var 返回对象

func 开始动作(动作名, 动作时间,对象):
	返回对象=对象
	持续时间 = 动作时间
	名称 = 动作名
	动作名文本.text = 名称
	进度条.value = 0
	执行动作中 = true
	
func _process(delta: float) -> void:
	if not 执行动作中:
		return
	进度条.value += delta * 100 / 持续时间
	if 进度条.value >= 100:
		进度条.value = 0
		返回对象.处理动作()
