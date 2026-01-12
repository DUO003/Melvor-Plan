extends Node
class_name 梅声音
# 播放鼠标点击音效的封装方法
var 点击鼠标音效 = preload("res://素材/音效/点击鼠标音效.mp3")
func 播放鼠标点击音效():
	if 计划.配置文件.has("音量") and 计划.配置文件["音量"] == 0:
		return
	var 音频播放器 = AudioStreamPlayer.new()
	if 点击鼠标音效:
		音频播放器.stream = 点击鼠标音效
		add_child(音频播放器)
		音频播放器.finished.connect(音频播放器.queue_free)
		音频播放器.play()
