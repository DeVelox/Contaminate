extends Button

@export var uicon: String
@export var uname: String
@export var udesc: String

@onready var bicon: TextureRect = $MarginContainer/VBoxContainer/Icon
@onready var bname: Label = $MarginContainer/VBoxContainer/Name
@onready var bdesc: Label = $MarginContainer/VBoxContainer/Desc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bicon.texture = load(uicon)
	bname.text = uname
	bdesc.text = udesc


func _on_pressed() -> void:
	UpgradeManager.add_upgrade(uname)
