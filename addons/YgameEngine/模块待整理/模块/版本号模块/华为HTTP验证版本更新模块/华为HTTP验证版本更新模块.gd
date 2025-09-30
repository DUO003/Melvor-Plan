extends Node

@export var 华为HTTP云端链接:String;
@export var 是否强制更新:bool;

var _版本号:float; #需要有版本号模块,华为HTTP挂载在版本号模块下面
func _ready() -> void:
	
	_版本号=get_parent()._版本号
	
	if 华为HTTP云端链接=="":return;
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	
	var body = JSON.new().stringify({})
	var error = http_request.request(华为HTTP云端链接, [], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	#json转换
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	#转到json
	var response = json.get_data()

	
	if _版本号<response["云端版本"]:
		OS.alert("有新的版本:%s,\n当前版本:%s" % [response["云端版本"],_版本号])
		
		if 是否强制更新:
			OS.shell_open(response["下载地址"])
			get_tree().quit()
			
	print(response)
