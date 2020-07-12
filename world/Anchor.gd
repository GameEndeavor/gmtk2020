extends Node2D
class_name Anchor

enum Types {
	MERRY, PULL
}

export (int, -1, 1, 2) var direction = 1
export (Types) var type = 0
