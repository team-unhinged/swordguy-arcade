extends KinematicBody2D 

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal jump()
signal move(dir)
signal hit(dmg) 
signal fall()
signal idle()
signal dead()

export(int) var moveSpeed = 0
export(int) var jumpHeight = 0 # a measure how powerful the jump should be

var health := 3
var facingRight := true 
var dir: Vector2
const GRAVITY := 200.0
var velocity := Vector2()
var dx := Vector2(0, 0) # x axis velocity; Apply this to the transform
var dy := Vector2(0, 0) # Y-axis velocity; apply this via physics move_and_collide

# Track player states in an enum below
# They are powers of two so that we can use them as bit masks on the
# currState variable and do bitwise operations.
enum StateMasks {
	GROUNDED = 0x1 
	JUMPING = 0x2,
	MOVE_LEFT = 0x4,
	MOVE_RIGHT = 0x8,
	FALLING = 0xf,
	IDLE = 0x20,
	DEAD = 0x40
}
# 0x21 -> 0b0010 0001 -> GROUNDED + IDLE
# 0x23 -> 0b0010 0011 -> GROUNDED + JUMPING + IDLE
# and so on.

# Can't use an enum as a type annotation.
var currState = StateMasks.IDLE # 0010 0000 or 0x20

func _play_anim(anim: String) -> void:
	if $"Sprite/AnimationPlayer".is_playing() && $"Sprite/AnimationPlayer".get_current_animation() == anim:
		pass
	else:
		$"Sprite/AnimationPlayer".play(anim)

func _check_state(stateMask: int) -> bool:
	return (stateMask & (self.currState)) == stateMask

func _set_state(stateMask: int) -> int:
	return self.currState | stateMask

func _unset_state(stateMask: int) -> int:
	return self.currState & (~(stateMask))

func _handle_state() -> void:
	# check the current state and trigger the appropriate signal
	var anim 
	if _check_state(StateMasks.JUMPING):
		self.emit_signal("jump")
	if _check_state(StateMasks.MOVE_LEFT):
		self.emit_signal("move", StateMasks.MOVE_LEFT)
	if _check_state(StateMasks.MOVE_RIGHT):
		self.emit_signal("move", StateMasks.MOVE_RIGHT)			
	if _check_state(StateMasks.FALLING):
		self.emit_signal("fall")
	if _check_state(StateMasks.IDLE):
		self.emit_signal("idle")
	if _check_state(StateMasks.DEAD):
		self.emit_signal("dead")
	
func _ready() -> void:
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.connect( "jump", self, "_on_Player_jump" )
	self.connect( "move", self, "_on_Player_move" )
	self.connect( "hit",  self, "_on_Player_hit"  )
	self.connect( "fall", self, "_on_Player_fall" )
	self.connect( "idle", self, "_on_Player_idle" )
	self.connect( "dead", self, "_on_Player_dead" )

	#$"Sprite/AnimationPlayer".play("idle")
	self.currState = StateMasks.IDLE

func _player_input() -> void:
	if _check_state(~StateMasks.IDLE):
		self.currState = _unset_state(StateMasks.IDLE)

	if Input.is_action_pressed("ui_left") and not _check_state(StateMasks.MOVE_RIGHT):
		# unet right
		#self.currState = _unset_state(StateMasks.MOVE_RIGHT)
		# set the moving left bit with the MOVE_LEFT bit mask
		self.currState = _set_state(StateMasks.MOVE_LEFT) #& ~StateMasks.IDLE)
	elif Input.is_action_just_released("ui_left"):
		# Unset the left movement bit
		self.currState = _unset_state(StateMasks.MOVE_LEFT)
	elif Input.is_action_pressed("ui_right") and not _check_state(StateMasks.MOVE_LEFT):
		#self.currState = _unset_state(StateMasks.MOVE_LEFT)
		self.currState = _set_state(StateMasks.MOVE_RIGHT)
	elif Input.is_action_just_released("ui_right"):
		# Unset the right movement bit
		self.currState = _unset_state(StateMasks.MOVE_RIGHT)
	elif Input.is_action_pressed( "ui_accept" ):
		if _check_state( StateMasks.GROUNDED ):
			self.currState = _set_state( StateMasks.JUMPING )
	elif Input.is_action_just_released( "ui_accept" ):
		self.currState = _unset_state( StateMasks.JUMPING )


func _physics_process(delta: float) -> void:

	# Let's compute the movement in two phases
	# and then combine the results into one "movement" vector.

	# move left or right

	if _check_state(StateMasks.MOVE_LEFT):
		velocity.x = -moveSpeed
	elif _check_state(StateMasks.MOVE_RIGHT):
		velocity.x = moveSpeed
	else:
		velocity.x = 0
	
	if  _check_state(StateMasks.JUMPING):
		move_and_collide( Vector2(0, -300*delta) )

	# jump?
	# if self.jumping:
	# 	# please do the needful thing
	# 	# jomp
	# 	# we pretty much just need to overcome gravity.
	# 	self.velocity.y 
	if is_on_floor():
		self.currState = _set_state( StateMasks.GROUNDED )
	else:
		self.currState = _unset_state( StateMasks.GROUNDED )

	
	# We don't need to multiply velocity by delta because MoveAndSlide already takes delta time into account.
	
	# The second parameter of move_and_slide is the normal pointing up.
	# In the case of a 2d platformer, in Godot upward is negative y, which translates to -1 as a normal.
	move_and_slide(velocity, Vector2(0, -1))
	if not _check_state( StateMasks.GROUNDED ):
		velocity.y += GRAVITY
	else:
		velocity.y += 0
	
	var motion: Vector2 = velocity * delta
	move_and_collide(motion)

func _process(delta: float):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	_player_input()
	_handle_state()
	print("%x" % self.currState)

func _on_Player_jump() -> void:
	pass

func _on_Player_move(dir: int) -> void:
	# flip the sprite.
	if dir == StateMasks.MOVE_LEFT:
		$"Sprite".flip_h = true
	elif dir == StateMasks.MOVE_RIGHT:
		$"Sprite".flip_h = false
	# Need to migrate away from this explicit sort of triggering of animations and do it based on computations around the state.
	_play_anim("run")

func _on_Player_hit(dmg: int) -> void:
	pass

func _on_Player_fall() -> void:
	pass

func _on_Player_idle() -> void:
	_play_anim( "idle" )

func _on_Player_die() -> void:
	pass