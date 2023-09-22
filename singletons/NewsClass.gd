class_name NewsClass


var title: String
var image: String
var text: String
var filename: String
var richText: String

var keywords: Array[String]

func _init(titleInput: String, imageInput: String, textInput: String, richTextInput: String, filenameInput: String, keywordsInput: Array[String] = []):
	title = titleInput
	image = imageInput
	text = textInput
	richText = richTextInput
	filename = filenameInput
	if keywordsInput.size() > 0:
		keywords = keywordsInput
	else:
		keywords = _get_keywords()

func _get_keywords():
	return ['jacaré', 'parque', 'estadual']
