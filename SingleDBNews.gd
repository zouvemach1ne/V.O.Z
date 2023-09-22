extends Panel

var News = NewsClass

@onready var TITLE = $MarginContainer/VBoxContainer/Titulo
@onready var IMAGE = $MarginContainer/VBoxContainer/Imagem
@onready var FILENAME = $MarginContainer/VBoxContainer/Arquivo
var TABCONTAINER
var DATABASE


func startup(news: NewsClass):
	News = news
	TITLE.text = News.title
	IMAGE.texture = (load(News.image))
	FILENAME.text = News.filename
	DATABASE = find_parent("BancoDeDados")
	TABCONTAINER = DATABASE.TABCONTAINER
	

func showNewsItem():
	var resource = load("res://ResourceNews.tscn").instantiate()
	resource.NewsObject = News
	DATABASE.addNewsTab(resource)
	resource.setLabel(News.richText, News)

func _on_gui_input(event):
	if Input.is_action_pressed("left_click"):
		showNewsItem()
