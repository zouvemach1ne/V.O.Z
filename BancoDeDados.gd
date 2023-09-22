extends Control

@onready var showingDb = self.visible
@onready var NEWSGRID = $Panel/DatabaseTabContainer/Content/VBoxContainer/NewsGrid
@onready var TABCONTAINER = $Panel/DatabaseTabContainer
var SingleNewsScene = preload("res://SingleDBNews.tscn")

func _ready():
	Global.set("dbRef", self)
	
	
func _search_keyword_on_db(keyword: String):
	for news in NewsDb.get("news"):
		if keyword in news.keywords:
			var singleNews = SingleNewsScene.instantiate()
			NEWSGRID.add_child(singleNews)
			singleNews.startup(news)
		


func _on_visibility_changed():
	showingDb = visible


func addNewsTab(node):
	if TABCONTAINER:
		TABCONTAINER.add_child(node)
		var currentTab = TABCONTAINER.get_tab_count() - 1
		TABCONTAINER.set_tab_title(currentTab, TABCONTAINER.get_tab_control(currentTab).NewsObject.title)
		TABCONTAINER.set_tab_button_icon(currentTab, load("res://images/sprites/news/closetab.png"))
		TABCONTAINER.current_tab = currentTab



func _on_database_tab_container_tab_button_pressed(tab):
	TABCONTAINER.get_child(tab).free()


func _on_close_button_pressed():
	visible = false


func _on_line_edit_text_submitted(new_text):
	_search_keyword_on_db(new_text)
