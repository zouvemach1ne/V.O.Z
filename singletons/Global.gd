extends Node

var playerRef
var newsRef
var dbRef

func isNewsOnScreen():
	if newsRef:
		return newsRef.visible
	return false

func isDbOnScreen():
	if dbRef:
		return dbRef.visible
	return false
