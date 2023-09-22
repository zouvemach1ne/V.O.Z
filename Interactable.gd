extends Node2D

var SPRITE
@onready var COLLISION_SHAPE = $CollisionShape2D
@onready var INTERACTION_SHAPE = $Area2D/InteractionShape
@onready var shader = load("res://Interactable.gdshader")
@onready var materialWithShader
@onready var popup = $PopupMenu
@onready var CLICKABLE_SHAPE = $ClickableArea/ClickableShape
@onready var TOOLTIP_CONTAINER = $PanelContainer
@onready var TOOLTIP = $PanelContainer/MarginContainer/Tooltip

signal clicked
signal entered
signal exited
signal on_use_range
signal selected_use
var player

var selected = false : set = _set_selected
var timer = Timer.new()

@export var kind: String
var useFunction
var lineColor = Color('#ffff2c')
var lineThickness = 2
var isPlayerInUseRange = false

func makeDialog(): 
	DialogManager.start_dialog(Vector2(SPRITE.global_position.x, SPRITE.global_position.y-SPRITE.get_rect().size.y/4), Jimmy.lines)

func revisarNoticia():
	Global.get("newsRef").visible = true

var Jimmy = {'lines':['Seja bem-vindo, Sr. Veríssimo!', 'Já soube da confusão com o ataque dos jacarés no parque estadual?!']}

var objects ={
	'jimmy': {
		'type': 'npc',
		'name': 'Janete',
		'sprite': "res://images/sprites/other_char/moça.png",
		'menuItems': {
					'Conversar': makeDialog
		},
	},
	'desk': {
		'type': 'object',
		'name': 'Minha mesa',
		'sprite': "res://images/sprites/office/desk.png",
		'menuItems': {
					'Revisar Notícia': revisarNoticia,
					'Procurar no banco de dados': func(): Global.get("dbRef").visible = true
		}
	}
}

func popupMenu(buttons: Dictionary):
	var counter = 0
	#popup.position = position
	for key in buttons.keys():
		popup.add_item(key, counter)
		popup.id_pressed.connect(_on_item_pressed)
		counter+=1

func _on_item_pressed(id):
	var menuItems = objects[kind].menuItems
	useFunction = menuItems.values()[id]
	selected_use.emit(menuItems.values()[id])

func setDefaultOutlineShader():
	materialWithShader = ShaderMaterial.new()
	materialWithShader.shader = shader
	materialWithShader.set_shader_parameter('line_color', lineColor)
	materialWithShader.set_shader_parameter('line_thickness', lineThickness)

func addTimer():
	timer.timeout.connect(do_timer)
	add_child(timer)


func _ready():
	setDefaultOutlineShader()
	var object = objects[kind]
	popupMenu(object.menuItems)
	TOOLTIP.text = object.name
	addTimer()
	SPRITE = Sprite2D.new()
	SPRITE.texture = load(object.sprite)
	if object.type == 'npc':
		SPRITE.scale.x = -1
	add_child(SPRITE)
	var spriteSize = SPRITE.texture.get_size()
	var spriteSizeYOffset = spriteSize.y*0.3/2
	
	COLLISION_SHAPE.shape = RectangleShape2D.new()
	COLLISION_SHAPE.shape.size = Vector2(spriteSize.x, spriteSize.y*0.7)
	COLLISION_SHAPE.position.y = spriteSizeYOffset
	INTERACTION_SHAPE.shape = RectangleShape2D.new()
	INTERACTION_SHAPE.shape.size = COLLISION_SHAPE.shape.size * 1.5
	INTERACTION_SHAPE.position.y = (spriteSizeYOffset * 1.5)/2
	CLICKABLE_SHAPE.shape = RectangleShape2D.new()
	CLICKABLE_SHAPE.shape.size = Vector2(spriteSize.x, spriteSize.y)
	
	
func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.get_name() == 'Player':
		isPlayerInUseRange = true
		on_use_range.emit()

func _on_clickable_area_mouse_entered():
	setPlayerReference()
	SPRITE.material = materialWithShader
	entered.emit()
	timer.start(0.5)

func _on_clickable_area_mouse_exited():
	setPlayerReference()
	exited.emit()
	if TOOLTIP_CONTAINER.visible: TOOLTIP_CONTAINER.visible = false
	if !selected:
		SPRITE.material = null
	timer.stop()

func setPlayerReference():
	if !player: 
		player = Global.get("playerRef")
		if player:	
			clicked.connect(player._clicked_on.bind(self))
			entered.connect(player._entered_obj.bind(self))
			exited.connect(player._exited_obj.bind(self))
			on_use_range.connect(player._on_use_range.bind(self))
			selected_use.connect(player._selected_use)

func _on_clickable_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		setPlayerReference()
		clicked.emit()

func _set_selected(value):
	selected = value
	if TOOLTIP_CONTAINER.visible: TOOLTIP_CONTAINER.visible = false
	if selected:
		var mousePosition = get_global_mouse_position()
		if !popup.visible: 
			popup.popup(Rect2(position.x, position.y, popup.size.x, popup.size.y))
		SPRITE.material = materialWithShader
	else:
		SPRITE.material = null
		
func do_timer():
	if !selected: 
		TOOLTIP_CONTAINER.visible = true
	timer.stop()
	
func _on_popup_menu_popup_hide():
	selected = false

func _on_area_2d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.get_name() == 'Player':
		isPlayerInUseRange = false

func getIsPlayerInUseRange():
	if isPlayerInUseRange:
		on_use_range.emit()
	return isPlayerInUseRange
