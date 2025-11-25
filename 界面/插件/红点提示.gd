extends Control
@export var 红点条目: String="默认红点"
var 红点数量=1
func _ready():
	计划.connect("更新红点",Callable(self, "_更新红点"))
	_更新红点()
func _更新红点(指定更新=null):
	if 指定更新==null or 指定更新==红点条目:
		获取红点()
		if 红点数量==0:
			hide()
			return
		else :
			show()
		if 红点数量==1:
			$"红点/数量".text=""
			return
		$"红点/数量".text=str(红点数量)
func 获取红点():
	红点数量=计划.梅红点单例.获取红点状态(红点条目)
