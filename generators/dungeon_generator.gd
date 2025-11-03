extends Node
class_name DungeonGenerator

# Configuration
@export var min_rooms: int = 10
@export var max_rooms: int = 15
@export var grid_size: int = 7
@export var debug_print: bool = true  # Toggle debug output

# The dungeon layout
var rooms: Dictionary = {}  # Vector2i -> RoomData
var next_room_id: int = 1

# Directions
const DIRECTIONS = {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0)
}

const OPPOSITE_DIR = {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east"
}

func generate_dungeon() -> Dictionary:
	rooms.clear()
	next_room_id = 1
	
	_generate_room_layout()
	_assign_room_types()
	_validate_dungeon()
	
	if debug_print:
		print_dungeon_layout()
	
	return rooms

func _generate_room_layout():
	var center = Vector2i(grid_size / 2, grid_size / 2)
	var start_room = RoomData.new(center, "start")
	start_room.room_id = next_room_id
	next_room_id += 1
	
	start_room.layout_type = RoomData.LayoutType.EMPTY
	start_room.floor_type = "grey"
	start_room.furniture_set = "living_room"
	start_room.layout_seed = randi()
	rooms[center] = start_room
	
	var current_pos = center
	var target_rooms = randi_range(min_rooms, max_rooms)
	
	while rooms.size() < target_rooms:
		var direction_name = DIRECTIONS.keys().pick_random()  # Cleaner than [randi() % 4]
		var direction_vec = DIRECTIONS[direction_name]
		var next_pos = current_pos + direction_vec
		
		if not _is_valid_position(next_pos):
			continue
		
		if next_pos not in rooms and randf() > 0.3:
			var new_room = RoomData.new(next_pos, "normal")
			new_room.room_id = next_room_id
			next_room_id += 1
			
			new_room.layout_type = _choose_random_layout()
			new_room.floor_type = ["wood", "tile", "carpet"].pick_random()
			new_room.furniture_set = ["bedroom", "kitchen", "living_room", "bathroom"].pick_random()
			new_room.layout_seed = randi()
			
			rooms[next_pos] = new_room
			_connect_rooms(current_pos, next_pos, direction_name)
		
		if next_pos in rooms:
			current_pos = next_pos
		elif randf() > 0.7 and rooms.size() > 1:
			current_pos = rooms.keys().pick_random()  # Cleaner

func _is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size and pos.y >= 0 and pos.y < grid_size

func _connect_rooms(from_pos: Vector2i, to_pos: Vector2i, direction: String):
	rooms[from_pos].connections[direction] = true
	rooms[to_pos].connections[OPPOSITE_DIR[direction]] = true

func _assign_room_types():
	if rooms.is_empty():
		return
	
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	var distances = _calculate_traversal_distances(start_pos)
	
	# Find and assign boss room
	var farthest_room = start_pos
	var max_distance = 0
	for pos in distances.keys():
		if distances[pos] > max_distance:
			max_distance = distances[pos]
			farthest_room = pos
	
	if farthest_room != start_pos:
		rooms[farthest_room].room_type = "boss"
		rooms[farthest_room].layout_type = [RoomData.LayoutType.PILLARS, RoomData.LayoutType.ARENA].pick_random()
	
	# Assign treasure rooms (dead ends, far from start)
	var treasure_count = 0
	for pos in rooms.keys():
		if treasure_count >= 2:
			break
		
		if rooms[pos].room_type != "normal" or distances[pos] < 3:
			continue
		
		var connection_count = rooms[pos].connections.values().filter(func(x): return x).size()
		
		if connection_count == 1 and randf() > 0.5:
			rooms[pos].room_type = "treasure"
			#rooms[pos].layout_type = what?
			treasure_count += 1

func _calculate_traversal_distances(start_pos: Vector2i) -> Dictionary:
	var distances = {start_pos: 0}
	var queue = [start_pos]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_distance = distances[current]
		
		for dir_name in DIRECTIONS.keys():
			if rooms[current].connections[dir_name]:
				var neighbor = current + DIRECTIONS[dir_name]
				if neighbor not in distances:
					distances[neighbor] = current_distance + 1
					queue.append(neighbor)
	
	return distances

func _validate_dungeon() -> bool:
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	var visited = {}
	var queue = [start_pos]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if current in visited:
			continue
		visited[current] = true
		
		for dir_name in DIRECTIONS.keys():
			if rooms[current].connections[dir_name]:
				var neighbor = current + DIRECTIONS[dir_name]
				if neighbor in rooms and neighbor not in visited:
					queue.append(neighbor)
	
	var is_valid = visited.size() == rooms.size()
	if not is_valid:
		push_warning("Dungeon validation failed! %d/%d rooms reachable" % [visited.size(), rooms.size()])
	
	return is_valid

func print_dungeon_layout():
	print("\n=== DUNGEON LAYOUT ===")
	
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	var distances = _calculate_traversal_distances(start_pos)
	
	for y in range(grid_size):
		var room_row = ""
		var connection_row = ""
		
		for x in range(grid_size):
			var pos = Vector2i(x, y)
			
			if pos in rooms:
				var room_char = ""
				match rooms[pos].room_type:
					"start": room_char = " S "
					"boss": room_char = " B "
					"treasure": room_char = " T "
					_: 
						var room_id = rooms[pos].room_id
						room_char = " %d " % room_id if room_id < 10 else "%2d " % room_id
				
				room_row += "[%s]%s" % [room_char, "─" if rooms[pos].connections["east"] else " "]
				connection_row += "  │  " if rooms[pos].connections["south"] else "     "
			else:
				room_row += "  ·  "
				connection_row += "     "
		
		print(room_row)
		if y < grid_size - 1:
			print(connection_row)
	
	print("\nTotal rooms: %d\n" % rooms.size())
	
func _choose_random_layout() -> RoomData.LayoutType:
	"""Type-safe random layout selection"""
	var layouts = [
		RoomData.LayoutType.SPARSE,
		RoomData.LayoutType.SCATTERED,
		RoomData.LayoutType.CORRIDORS,
		RoomData.LayoutType.ROWS,
		RoomData.LayoutType.COLUMNS,
		RoomData.LayoutType.CROSSES,
		RoomData.LayoutType.QUARTERS,
		RoomData.LayoutType.PILLARS,
		RoomData.LayoutType.ARENA,
		RoomData.LayoutType.GAUNTLET,
		RoomData.LayoutType.CHECKERBOARD,
		RoomData.LayoutType.CLUSTERED
	]
	return layouts.pick_random()
