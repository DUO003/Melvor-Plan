extends VBoxContainer
@onready var 背包: 梅背包 = %背包
@onready var 标签: Label = $标签
func 切换背包(筛选标签:Array[String],标题:String="标题"):
	背包.筛选标签=筛选标签
	背包.重新生成()
	标签.text=标题
