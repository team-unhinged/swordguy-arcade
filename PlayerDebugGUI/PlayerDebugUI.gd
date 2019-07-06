extends Control

var player
var stateValueLabel: Label
var velocityValueLabel: Label
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"Player"
	stateValueLabel = $"PlayerDebugUI/GUI/HBoxContainer/StateInfo/StateValue"
	velocityValueLabel = $"PlayerDebugUI/GUI/HBoxContainer/VelocityInfo/VelocityValue"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var state = player.currState
	var state: int = 5
	#var velocity: Vector2 = player.velocity
	var velocity: Vector2 = Vector2(1,2)
	stateValueLabel.text = "%x" % state
	velocityValueLabel.text = "<%d, %d>" % [velocity.x, velocity.y]

