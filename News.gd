extends Control

@onready var showingNews = self.visible


func _ready():
	Global.set("newsRef", self)


func _input(event):
	if Input.is_action_pressed("close_news") and showingNews:
		visible = false

func _process(delta):
	pass


func _on_visibility_changed():
	showingNews = self.visible
