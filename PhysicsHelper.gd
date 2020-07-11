extends Node
class_name PhysicsHelper

static func calculate_velocity_from_height(height, gravity = Globals.gravity):
	return -sqrt(2 * gravity * height)
