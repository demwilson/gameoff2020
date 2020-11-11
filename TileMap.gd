extends TileMap

var overworld

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2
var level_num = 0
var level_size
var player_start_position

var topLeftAnchorPoints = []
var RoomCellSize = Vector2(9,9)
var nextTileCellQueue = []
var possibleStartPoints = []

var Room_0000 = preload("res://Room_0000.tscn")
var Corridor_1111 = preload("res://Corridor_1111.tscn")

var CellMidpoints = {
	"Top" : Vector2.ZERO,
	"Bottom": Vector2.ZERO,
	"Left": Vector2.ZERO,
	"Right": Vector2.ZERO
}

var MapCornerPoints = {
	"TopLeft": Vector2.ZERO,
	"TopRight": Vector2.ZERO,
	"BottomLeft": Vector2.ZERO,
	"BottomRight": Vector2.ZERO	
}

const LEVEL_SIZES = [
	Vector2(54, 36),
	Vector2(72, 54)
]

enum Tile {
	BRCorner,	# 0
	Door,	# 1
	Floor,	# 2
	VWall,	# 3
	HWall,	# 4
	TLCorner,	# 5
	TRCorner, #6
	TWall, #7
	BLCorner, #8
	Ladder
}

func _ready():
	overworld = get_parent()
	randomize()
	build_level()

func _on_Player_collided(collision):
	if collision.collider is TileMap:
		var playerTilePos
		if collision.normal.x == 1:
			var remainderX = int(overworld.player.position.x) % int(tile_size.x)
			var newX = overworld.player.position.x + tile_size.x - remainderX
			playerTilePos = self.world_to_map(Vector2(newX, overworld.player.position.y))
		elif collision.normal.y == 1:
			var remainderY = int(overworld.player.position.y) % int(tile_size.y)
			var newY = overworld.player.position.y + tile_size.y - remainderY
			playerTilePos = self.world_to_map(Vector2(overworld.player.position.x, newY))
		else:
			playerTilePos = self.world_to_map(overworld.player.position)


		playerTilePos -= collision.normal
		var tile = collision.collider.get_cellv(playerTilePos)
		if tile == Tile.Door:
			set_tile(playerTilePos.x, playerTilePos.y, Tile.Floor)
		elif tile == Tile.Ladder:
			level_num += 1
			overworld.score += 20
			if level_num < LEVEL_SIZES.size():
				build_level()
				overworld.place_player()
			else:
				overworld.score += 1000
				overworld.win_event()
	
func build_level():
	self.clear()
	
	level_size = LEVEL_SIZES[level_num]
	#populate possible starting points
	generate_possible_start_points()
	#populate all top left corner vectors of the 9x9 cells	
	generate_Anchor_Points()
	#populate door/opening midpoints
	generate_midpoints_for_doors_openings()
	#populate map corners array
	generate_Map_Corner_Points()
	
	#Max number of rooms based on RoomCellSizes and level size
	var numberOfCells = (level_size.x / RoomCellSize.x) * (level_size.y / RoomCellSize.y)
	var startingSpot = possibleStartPoints[randi() % possibleStartPoints.size()]
	var firstSpot = true
	var needsCorridor = false
		
	for i in range(numberOfCells):
#		yield(get_tree().create_timer(0.5), 'timeout')
		var currentSpot
		if firstSpot:
			currentSpot = startingSpot
			firstSpot = false
		else:
			currentSpot = nextTileCellQueue.pop_front()
		
		#add the room
		add_room(currentSpot, needsCorridor)

		if needsCorridor:
			#close blocked off sections
			#TODO: number of exits is based on corridor scene will need to get that value somewhere
			var numberOfExits = 4
			place_walls(currentSpot, numberOfExits)	
		else:
			#place doors
			place_doors(currentSpot)
		
		#mark position as palced
		needsCorridor = !needsCorridor
		if nextTileCellQueue.size() == 0:
			break;
	
	# Place Player
	place_player_start(startingSpot)
	
	# Place end ladder
	place_exit(startingSpot)
	
func place_player_start(startingSpot):
	var start_room = startingSpot
	var player_x = start_room.x + 4 - randi() % 2
	var player_y = start_room.y + 4 - randi() % 2
	player_start_position = Vector2(player_x, player_y) * tile_size
	
func place_exit(startingSpot):
	var end_room
	var cellIndex
	var ladderPlaced = false	
	
	while !ladderPlaced: 
		if startingSpot == MapCornerPoints.TopLeft:
			#set ladder bottomRight
			end_room = MapCornerPoints.BottomRight
			cellIndex = self.get_cell(end_room.x + 4, end_room.y + 4)
			if cellIndex != -1:
				ladderPlaced = true
		elif startingSpot == MapCornerPoints.TopRight:
			#set ladder bottomLeft
			end_room = MapCornerPoints.BottomLeft
			cellIndex = self.get_cell(end_room.x + 4, end_room.y + 4)
			if cellIndex != -1:
				ladderPlaced = true
		elif startingSpot == MapCornerPoints.BottomRight:
			#set ladder topLeft
			end_room = MapCornerPoints.TopLeft
			cellIndex = self.get_cell(end_room.x + 4, end_room.y + 4)
			if cellIndex != -1:
				ladderPlaced = true
		else:
			#set ladder topRight
			end_room = MapCornerPoints.TopRight
			cellIndex = self.get_cell(end_room.x + 4, end_room.y + 4)
			if cellIndex != -1:
				ladderPlaced = true
			
	var ladder_x = end_room.x + 4 - randi() % 2
	var ladder_y = end_room.y + 4 - randi() % 2
	set_tile(ladder_x, ladder_y, Tile.Ladder)

func generate_Anchor_Points():
	var roomSizeX = RoomCellSize.x
	var roomSizeY = RoomCellSize.y
	var points = []
	for x in range(level_size.x / RoomCellSize.x):
		for y in range(level_size.y / RoomCellSize.y):
			topLeftAnchorPoints.append(Vector2(x * roomSizeX, y * roomSizeY))

func generate_Map_Corner_Points():
	#top left corner
	MapCornerPoints.TopLeft = Vector2(0,0)
	#top right corner
	MapCornerPoints.TopRight = Vector2(level_size.x - RoomCellSize.x,0)
	#bottom left corner
	MapCornerPoints.BottomLeft = Vector2(0,level_size.y - RoomCellSize.y)
	#bottom right corner
	MapCornerPoints.BottomRight = Vector2(level_size.x - RoomCellSize.x,level_size.y - RoomCellSize.y)

func add_room(topLefPosition, isCorridor):
	#map the room to the tile map
	var scene
	var roomsTileMap
	var usedCells
	
	#map the scene to the tilemap
	if isCorridor:
		scene = Corridor_1111.instance()
		roomsTileMap = scene.get_node("TileMap")
		usedCells = roomsTileMap.get_used_cells()
		for usedCell in usedCells:
			var cellindex = roomsTileMap.get_cell(usedCell.x, usedCell.y)
			if cellindex == Tile.BRCorner:
				if usedCell.x == 2 && usedCell.y == 6:
					#rotate tile 270 degree to right
					set_tile(topLefPosition.x + usedCell.x, topLefPosition.y + usedCell.y, cellindex, false, true, true)
				elif usedCell.x == 6 && usedCell.y == 6:
					#rotate tile 180 degree to the right
					set_tile(topLefPosition.x + usedCell.x, topLefPosition.y + usedCell.y, cellindex, true, true, false)
				else:
					set_tile(topLefPosition.x + usedCell.x, topLefPosition.y + usedCell.y, cellindex)
			else:
				set_tile(topLefPosition.x + usedCell.x, topLefPosition.y + usedCell.y, cellindex)
	else:
		scene = Room_0000.instance()
		roomsTileMap = scene.get_node("TileMap")
		usedCells = roomsTileMap.get_used_cells()
		for usedCell in usedCells:
			var cellindex = roomsTileMap.get_cell(usedCell.x, usedCell.y)
			set_tile(topLefPosition.x + usedCell.x, topLefPosition.y + usedCell.y, cellindex)
	scene.free()
	#remove possible anchor points
	topLeftAnchorPoints.remove(topLeftAnchorPoints.find(topLefPosition))

func place_doors(anchorSpotPosition):
	var doorsToAdd = []
	var canPlaceTop = true
	var canPlaceLeft = true
	var canPlaceRight = true
	var canPlaceBottom = true
	var currentBottomMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y)
	var currentRightMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y)
	var currentTopMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y)
	var currentLeftMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y)
	var canPlaceObj = { 
		"canPlace": false,
		"forced": false,
		"tileToPlace": Tile.Door,
		"direction": "Bottom"
	}
	var forcedDoorsToPlace = []
	if anchorSpotPosition == MapCornerPoints.TopLeft:
		canPlaceTop = false
		canPlaceLeft = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
		
	elif anchorSpotPosition == MapCornerPoints.TopRight:
		canPlaceTop = false
		canPlaceRight = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	elif anchorSpotPosition == MapCornerPoints.BottomLeft:
		canPlaceLeft = false
		canPlaceBottom = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
	elif anchorSpotPosition == MapCornerPoints.BottomRight:
		canPlaceRight = false
		canPlaceBottom = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (level_size.x - RoomCellSize.x):
		canPlaceTop = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (level_size.y - RoomCellSize.y):
		canPlaceLeft = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
	elif anchorSpotPosition.y == (level_size.y - RoomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (level_size.x - RoomCellSize.x):
		canPlaceBottom = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	elif anchorSpotPosition.x == (level_size.x - RoomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (level_size.y - RoomCellSize.y):
		canPlaceRight = false
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	else:
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentBottomMidPoint, "Bottom", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Bottom")
			else:
				forcedDoorsToPlace.append("Bottom")
		else:
			canPlaceBottom = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentRightMidPoint, "Right", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Right")
			else:
				forcedDoorsToPlace.append("Right")
		else:
			canPlaceRight = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentLeftMidPoint, "Left", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Left")
			else:
				forcedDoorsToPlace.append("Left")
		else:
			canPlaceLeft = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
		canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentTopMidPoint, "Top", canPlaceObj)
		if canPlaceObj.canPlace:
			if !canPlaceObj.forced:
				doorsToAdd.append("Top")
			else:
				forcedDoorsToPlace.append("Top")
		else:
			canPlaceTop = false
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
	
	#of the possible spots check if they can actually be placed there
	var numberOfDoorsToAdd = 0
	if doorsToAdd.size() > 0:
		numberOfDoorsToAdd = 1 + randi() % doorsToAdd.size()
	#finally paint the doors lucky enough to pass filtering
	var pointsToAdd = []
	for doorToAdd in numberOfDoorsToAdd:
		var doorDirection = doorsToAdd[randi() % numberOfDoorsToAdd]
		if doorDirection == "Bottom":
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y + RoomCellSize.y))

		if doorDirection == "Top":
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y - RoomCellSize.y))

		if doorDirection == "Right":
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x + RoomCellSize.x, anchorSpotPosition.y))

		if doorDirection == "Left":
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x - RoomCellSize.x, anchorSpotPosition.y))
	
	for forcedDoorToPlace in forcedDoorsToPlace:
		if forcedDoorToPlace == "Bottom":
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y + RoomCellSize.y))

		if forcedDoorToPlace == "Top":
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y - RoomCellSize.y))

		if forcedDoorToPlace == "Right":
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x + RoomCellSize.x, anchorSpotPosition.y))

		if forcedDoorToPlace == "Left":
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.Door)
			pointsToAdd.append(Vector2(anchorSpotPosition.x - RoomCellSize.x, anchorSpotPosition.y))
	
	
	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func place_walls(anchorSpotPosition, numberOfExits):
	var pointsToAdd = []
	var canPlaceTop = true
	var canPlaceLeft = true
	var canPlaceRight = true
	var canPlaceBottom = true
		
	if anchorSpotPosition == MapCornerPoints.TopLeft:
		canPlaceTop = false
		canPlaceLeft = false
	elif anchorSpotPosition == MapCornerPoints.TopRight:
		canPlaceTop = false
		canPlaceRight = false
	elif anchorSpotPosition == MapCornerPoints.BottomLeft:
		canPlaceLeft = false
		canPlaceBottom = false
	elif anchorSpotPosition == MapCornerPoints.BottomRight:
		canPlaceRight = false
		canPlaceBottom = false
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (level_size.x - RoomCellSize.x):
		canPlaceTop = false
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (level_size.y - RoomCellSize.y):
		canPlaceLeft = false
	elif anchorSpotPosition.y == (level_size.y - RoomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (level_size.x - RoomCellSize.x):
		canPlaceBottom = false
	elif anchorSpotPosition.x == (level_size.x - RoomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (level_size.y - RoomCellSize.y):
		canPlaceRight = false
	
	var canPlaceObj = true
	var nextPoint
	var currentAnchorMidPoint
	if !canPlaceTop:
		set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)
	else:
		#top is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y - RoomCellSize.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Top")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TWall)

	if !canPlaceBottom:
		set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)
	else:
		#bottom is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y + RoomCellSize.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Bottom")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HWall)

	if !canPlaceLeft:
		set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)
	else:
		#left is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x - RoomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Left")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VWall)

	if !canPlaceRight:
		set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)
	else:
		#right is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x + RoomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Right")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VWall)

	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func can_place_door_with_neighbor_cell_midpoint(currentMidpoint, direction, canPlaceObj):
	var cellIndex

	match direction:
		"Top":
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y - 1)
		"Bottom":
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y + 1)
		"Left":
			cellIndex = self.get_cell(currentMidpoint.x - 1, currentMidpoint.y)
		"Right":
			cellIndex = self.get_cell(currentMidpoint.x + 1, currentMidpoint.y)
	
	if cellIndex == -1:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = false
		canPlaceObj.tileToPlace = Tile.Door
	elif cellIndex == Tile.Door:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = true
		canPlaceObj.tileToPlace = Tile.Floor
	elif cellIndex == Tile.Floor:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = true
		canPlaceObj.tileToPlace = Tile.Door		
	else:
		canPlaceObj.canPlace = false
		canPlaceObj.forced = false
		canPlaceObj.tileToPlace = Tile.Door
	return canPlaceObj

func can_place_with_neighbor_cell_midpoint(currentMidpoint, direction):
	var cellIndex

	match direction:
		"Top":
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y - 1)
		"Bottom":
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y + 1)
		"Left":
			cellIndex = self.get_cell(currentMidpoint.x - 1, currentMidpoint.y)
		"Right":
			cellIndex = self.get_cell(currentMidpoint.x + 1, currentMidpoint.y)
	
	if cellIndex == -1:
		return true
	elif cellIndex == Tile.Door || cellIndex == Tile.Floor:
		return true
	else:
		return false

func generate_possible_start_points():
	#top left corner
	possibleStartPoints.append(Vector2(0,0))
	#top right corner
	possibleStartPoints.append(Vector2(level_size.x - RoomCellSize.x,0))
	#bottom left corner
	possibleStartPoints.append(Vector2(0,level_size.y - RoomCellSize.y))
	#bottom right corner
	possibleStartPoints.append(Vector2(level_size.x - RoomCellSize.x,level_size.y - RoomCellSize.y))

func generate_midpoints_for_doors_openings():
	#top midpoint
	CellMidpoints.Top = Vector2((RoomCellSize.x - 1) / 2, 0)
	#bottom midpoint
	CellMidpoints.Bottom = Vector2((RoomCellSize.x - 1) / 2, (RoomCellSize.y - 1))
	#left midpoint
	CellMidpoints.Left = Vector2(0, (RoomCellSize.y - 1) / 2)
	#right midpoint
	CellMidpoints.Right = Vector2((RoomCellSize.x - 1), (RoomCellSize.y - 1) / 2)

func set_tile(x, y, type, flipx = false, flipy = false, transpose = false):
	self.set_cell(x, y, type, flipx, flipy, transpose)
