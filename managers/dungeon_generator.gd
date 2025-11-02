extends Node
class_name DungeonGenerator

# Configuration
@export var min_rooms: int = 10
@export var max_rooms: int = 15
@export var grid_size: int = 7  # 7x7 grid of possible rooms

# The dungeon layout
var rooms: Dictionary = {}  # Vector2i -> RoomData
var current_room_pos: Vector2i = Vector2i.ZERO

# Directions
const DIRECTIONS = {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0)
}

# Opposite directions for connecting rooms
const OPPOSITE_DIR = {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east"
}

func generate_dungeon() -> Dictionary:
	rooms.clear()
	
	# Step 1: Generate layout
	_generate_room_layout()
	
	# Step 2: Assign special room types
	_assign_room_types()
	
	# Step 3: Validate (optional but recommended)
	_validate_dungeon()
	
	return rooms

func _generate_room_layout():
	# Start at center
	var center = Vector2i(grid_size / 2, grid_size / 2)
	var start_room = RoomData.new(center, "start")
	rooms[center] = start_room
	
	# Random walk algorithm
	var current_pos = center
	var target_rooms = randi_range(min_rooms, max_rooms)
	
	while rooms.size() < target_rooms:
		# Pick a random direction
		var direction_name = DIRECTIONS.keys()[randi() % 4]
		var direction_vec = DIRECTIONS[direction_name]
		var next_pos = current_pos + direction_vec
		
		# Check if valid position
		if not _is_valid_position(next_pos):
			continue
		
		# Place room with probability
		if next_pos not in rooms and randf() > 0.3:
			var new_room = RoomData.new(next_pos, "normal")
			rooms[next_pos] = new_room
			
			# Connect the rooms
			_connect_rooms(current_pos, next_pos, direction_name)
		
		# Move to next position (even if we didn't place a room)
		if next_pos in rooms:
			current_pos = next_pos
		else:
			# Sometimes backtrack to create branches
			if randf() > 0.7 and rooms.size() > 1:
				current_pos = rooms.keys()[randi() % rooms.size()]

func _is_valid_position(pos: Vector2i) -> bool:
	# Check bounds
	if pos.x < 0 or pos.x >= grid_size:
		return false
	if pos.y < 0 or pos.y >= grid_size:
		return false
	return true

func _connect_rooms(from_pos: Vector2i, to_pos: Vector2i, direction: String):
	# Set connections in both rooms
	rooms[from_pos].connections[direction] = true
	rooms[to_pos].connections[OPPOSITE_DIR[direction]] = true

func _assign_room_types():
	if rooms.is_empty():
		return
	
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	
	# BFS to find traversal distances
	var distances = _calculate_traversal_distances(start_pos)
	
	# Find farthest room by traversal
	var farthest_room = start_pos
	var max_distance = 0
	
	for pos in distances.keys():
		if distances[pos] > max_distance:
			max_distance = distances[pos]
			farthest_room = pos
	
	# Assign boss room
	if farthest_room != start_pos:
		rooms[farthest_room].room_type = "boss"
	
	# Assign treasure rooms (dead ends, but not too close to start)
	var treasure_count = 0
	var max_treasures = 2
	
	for pos in rooms.keys():
		if treasure_count >= max_treasures:
			break
		
		# Skip start and boss rooms
		if rooms[pos].room_type != "normal":
			continue
		
		# Must be at least 3 steps from start
		if distances[pos] < 3:
			continue
		
		# Check if it's a dead end (only 1 connection)
		var connection_count = 0
		for connected in rooms[pos].connections.values():
			if connected:
				connection_count += 1
		
		if connection_count == 1 and randf() > 0.5:
			rooms[pos].room_type = "treasure"
			treasure_count += 1

# NEW FUNCTION: Calculate actual traversal distances
func _calculate_traversal_distances(start_pos: Vector2i) -> Dictionary:
	var distances = {}
	var queue = [start_pos]
	distances[start_pos] = 0
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_distance = distances[current]
		
		# Check all connected neighbors
		for dir_name in DIRECTIONS.keys():
			if rooms[current].connections[dir_name]:
				var neighbor = current + DIRECTIONS[dir_name]
				
				# If we haven't visited this room yet
				if neighbor not in distances:
					distances[neighbor] = current_distance + 1
					queue.append(neighbor)
	
	return distances

func _validate_dungeon() -> bool:
	# Check that all rooms are reachable from start
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	var visited = {}
	var queue = [start_pos]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if current in visited:
			continue
		visited[current] = true
		
		# Add connected neighbors to queue
		for dir_name in DIRECTIONS.keys():
			if rooms[current].connections[dir_name]:
				var neighbor = current + DIRECTIONS[dir_name]
				if neighbor in rooms and neighbor not in visited:
					queue.append(neighbor)
	
	# All rooms should be visited
	var is_valid = visited.size() == rooms.size()
	
	if not is_valid:
		push_warning("Dungeon validation failed! %d/%d rooms reachable" % [visited.size(), rooms.size()])
	
	return is_valid

# Debug visualization
func print_dungeon_layout():
	print("\n=== DUNGEON LAYOUT ===")
	
	# Calculate distances for display
	var start_pos = Vector2i(grid_size / 2, grid_size / 2)
	var distances = _calculate_traversal_distances(start_pos)
	
	for y in range(grid_size):
		var room_row = ""
		var connection_row = ""
		
		for x in range(grid_size):
			var pos = Vector2i(x, y)
			
			if pos in rooms:
				# Room cell - always 3 characters wide
				var room_char = ""
				match rooms[pos].room_type:
					"start": 
						room_char = " S "
					"boss": 
						room_char = " B "
					"treasure": 
						room_char = " T "
					_: 
						# Pad single digit with space
						var dist = distances.get(pos, 0)
						if dist < 10:
							room_char = " %d " % dist
						else:
							room_char = "%2d " % dist  # For 10+
				
				room_row += "[%s]" % room_char
				
				# Check for east connection
				if rooms[pos].connections["east"]:
					room_row += "─"
				else:
					room_row += " "
				
				# Check for south connection (for next row)
				if rooms[pos].connections["south"]:
					connection_row += "  │  "
				else:
					connection_row += "     "
			else:
				# Empty cell - 5 characters total to match [X] + space
				room_row += "  ·  "
				connection_row += "     "
		
		print(room_row)
		
		# Print connection row if not last row
		if y < grid_size - 1:
			print(connection_row)
	
	print("\nTotal rooms: %d" % rooms.size())
	
	# Print detailed connection info
	print("\n=== ROOM DETAILS ===")
	for pos in rooms.keys():
		var room = rooms[pos]
		var connected_dirs = []
		for dir in ["north", "south", "east", "west"]:
			if room.connections[dir]:
				connected_dirs.append(dir)
		var dist = distances.get(pos, 0)
		print("(%d,%d) [%s] distance:%d → %s" % [pos.x, pos.y, room.room_type, dist, ", ".join(connected_dirs)])
