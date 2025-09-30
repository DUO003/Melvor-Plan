extends Node
#当前模块例子

#主动接受的信号
signal 启动服务器;#无需参数
signal 连接服务器;#无需参数
#通知的信号
signal 客户端登入;#无回调
signal 客户端退出;#回调参数 1.ID
signal 服务器断开;#回调参数 1.ID
signal 创建与连接成功通知;#无回调
