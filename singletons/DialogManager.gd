extends Node

@onready var text_box_scene = preload("res://TextBox.tscn")

var dialog_lines = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false

func start_dialog(position, lines):
	print('starting dialog')
	if is_dialog_active:
		return
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	is_dialog_active = true
	
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true
	
	
func _unhandled_input(event):
	if event.is_action("advance_dialog") and is_dialog_active and can_advance_line:
		print('here')
		current_line_index += 1
		text_box.queue_free()
		if current_line_index >= dialog_lines.size():
			current_line_index = 0
			is_dialog_active = false
			return
		_show_text_box()
	
