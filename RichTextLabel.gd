extends RichTextLabel


var textParts: Array[String] = []
var markers: Dictionary = {}
var charTrack: int = 0
var selectedText: String
var menu = get_menu()
var menuButtons = {
	MENU_MAX+1: {'label': 'Sinalizar como falso', 'id': MENU_MAX+1},
	MENU_MAX+2: {'label': 'Anexar evidência', 'id': MENU_MAX+2},
	MENU_MAX+3: {'label': 'Remover marcação', 'id': MENU_MAX+3},
}
var currentHovered = null
const bbFakeColor = 'red'
const bbResolvedColor = 'green'

# Called when the node enters the scene tree for the first time.
func _ready():
	_build_menu([MENU_MAX+1])
	menu.id_pressed.connect(_on_item_pressed)
	

func _translate_plain_to_bbcode_position(position: int):
	var bbtext = text
	var counter = 0
	var rawCounter = 0
	var continueCount = true
	for letter in bbtext:
		if letter == '[' and continueCount:
			continueCount = false
		rawCounter += 1
		if continueCount:
			counter += 1
		if letter == ']' and !continueCount:
			continueCount = true
		if position == counter:
			break;
	return rawCounter

func make_close_tag(tag: String):
		if '=' in tag:
			return tag.split('=')[0].replace('[', '[/') + ']'
		else:
			return tag.replace('[', '[/')

func _insert_into_bbcode(from: int, to: int, openTag: String, closeTag: String):
	var bbtext = text
	var counter = 0
	var rawCounter = 0
	var continueCount = true
	
	var startPosition = 0
	var endPosition = 0
	var beforeRawString = ''
	var afterRawString = ''
	var acumString = ''
	var startInsertion = false

	var localTagStack = []
	var currentTag = ''
	var lastLetter = ''
	for letter in bbtext:
		if startInsertion:
			if letter == '[' and lastLetter != ']':
				acumString += closeTag
			if letter != '[' and lastLetter == ']':
				acumString += openTag
			acumString += letter
			
			if letter == '[':
				currentTag += letter
			if letter == ']' and currentTag != '':
				localTagStack.append(currentTag+letter)
				currentTag = ''
				
		lastLetter = letter
		
		if letter == '[' and continueCount:
			continueCount = false
			
		rawCounter += 1
		if continueCount:
			counter += 1
			
		if letter == ']' and !continueCount:
			continueCount = true
				
		if from == counter:
			startInsertion = true
			startPosition = rawCounter
			acumString += openTag
			beforeRawString = bbtext.substr(0, _translate_plain_to_bbcode_position(from))
		if to == counter:
			acumString += closeTag
			afterRawString = bbtext.substr(_translate_plain_to_bbcode_position(to), -1)
			break;
	return beforeRawString + acumString + afterRawString

func _on_item_pressed(id):

	if id == MENU_MAX + 1:
		markers[get_selection_from()] = {
			'start': get_selection_from(),
			'end': get_selection_to()+1,
			'resolved': false,
			'text':  get_selected_text(),
			'bbtext': '[url=%s][bgcolor=%s]'%[get_selection_from(), bbFakeColor] + get_selected_text() + '[/bgcolor][/url]',
		}
	if id == MENU_MAX + 2:
		markers[currentHovered] = {
			'start': markers[currentHovered].start,
			'end': markers[currentHovered].end,
			'resolved': true,
			'text':  markers[currentHovered].text,
			'bbtext': '[url=%s][bgcolor=%s]'%[markers[currentHovered].start, bbResolvedColor] + markers[currentHovered].text + '[/bgcolor][/url]',
		}
	if id == MENU_MAX + 3:
		print(markers)
		print('removing %s'%currentHovered)
		markers.erase(currentHovered)
		print(markers)


	var newText
	if id == MENU_MAX + 1:
		newText = _insert_into_bbcode(get_selection_from(), get_selection_to(), '[url=%s][bgcolor=%s]'%[get_selection_from(), bbFakeColor], '[/bgcolor][/url]')
	if id == MENU_MAX + 2:
		newText = _insert_into_bbcode(get_selection_from(), get_selection_to(), '[url=%s][bgcolor=%s]'%[markers[currentHovered].start, bbResolvedColor], '[/bgcolor][/url]')

	text = newText

func _build_text_from_markers():
	charTrack = 0
	var parsedText = get_parsed_text()
	var keys = markers.keys()
	keys.sort()
	clear()
	keys.map(func(key):	
		var t = markers[key]
		if charTrack != t.start:	
			append_text(parsedText.substr(charTrack, t.start - charTrack))
		append_text(t.bbtext)
		textParts.append(t.bbtext)
		charTrack = t.end
	)
	append_text(parsedText.substr(charTrack, -1))


func _on_meta_hover_started(meta):
	_build_menu([MENU_MAX+2, MENU_MAX+3])
	currentHovered = int(meta)
	

func _on_meta_clicked(meta):
	pass


func _on_meta_hover_ended(meta):
	_build_menu([MENU_MAX+1])
	currentHovered = null


func _build_menu(ids: Array):
	menu.clear()
	ids.map(func(id): menu.add_item(menuButtons[id].label, menuButtons[id].id))
	
