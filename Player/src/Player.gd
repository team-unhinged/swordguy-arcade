extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal jump()
signal move(dir)
signal hit(dmg) 
signal fall()
signal idle()
signal die()

export(int) var moveSpeed
export(int) var jumpHeight # a measure how powerful the jump should be

var health = 3
var facingRight = true 
var dir

# Track player states in an enum below
enum {
	JUMPING,
	MOVE_LEFT,
	MOVE_RIGHT,
	FALLING,
	IDLE,
	DEAD
}

var currState

func _handle_state():
	# check the current state and trigger the appropriate signal
	match self.currState:
		JUMPING:
			self.emit_signal("jump")
		MOVE_LEFT:
			self.emit_signal("move", -1)
		MOVE_RIGHT:
			self.emit_signal("move", 1)			
		FALLING:
			self.emit_signal("fall")
		IDLE:
			self.emit_signal("idle")
		DEAD:
			self.emit_signal("dead")
	
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.connect( "jump", self, "_on_Player_jump" )
	self.connect( "move", self, "_on_Player_move" )
	self.connect( "hit",  self, "_on_Player_hit"  )
	self.connect( "fall", self, "_on_Player_fall" )
	self.connect( "idle", self, "_on_Player_idle" )
	self.connect( "dead", self, "_on_Player_dead" )

	# $"Sprite/AnimationPlayer".play("idle")

func _input(event):
	print(event)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func _on_Player_jump():
	pass

func _on_Player_move( dir ):
	pass

func _on_Player_hit( dmg ):
	pass

func _on_Player_fall():
	pass

func _on_Player_idle():
	pass

func _on_Player_die():
	pass