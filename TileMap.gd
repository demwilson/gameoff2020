extends TileMap

#Variables
var overworld
var tileSize = get_cell_size()
var levelNum = 0
var levelSize
var playerStartPosition
var topLeftAnchorPoints = []
var roomCellSize = Vector2(9,9)
var nextTileCellQueue = []
var possibleStartPoints = []
var isGeneratingNewLevel = false

#Resources
var Room_0000 = preload("res://Room_0000.tscn")
var Corridor_1111 = preload("res://Corridor_1111.tscn")

#Objects
var CellMidpoints = {
	"Top": Vector2.ZERO,
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

var DirectionValue = {
	"Bottom": "Bottom",
	"Top": "Top",
	"Left": "Left",
	"Right": "Right"
}

const LEVEL_SIZES = [
	Vector2(54, 36),
	Vector2(72, 54)
]

enum Tile {
	BOTTOM_RIGHT_CORNER,	# 0
	DOOR,	# 1
	FLOOR,	# 2
	VERTICAL_WALL,	# 3
	HORIZONTAL_WALL,	# 4
	TOP_LEFT_CORNER,	# 5
	TOP_RIGHT_CORNER, #6
	TOP_WALL, #7
	BOTTOM_LEFT_CORNER, #8
	LADDER
}

func _ready():
	overworld = get_parent()
	randomize()
	build_level()

func _on_Player_collided(collision):
	if isGeneratingNewLevel:
		return

	if collision.collider is TileMap:
		var playerTilePos
		if collision.normal.x == 1:
			var remainderX = int(overworld.player.position.x) % int(tileSize.x)
			var newX = overworld.player.position.x + tileSize.x - remainderX
			playerTilePos = self.world_to_map(Vector2(newX, overworld.player.position.y))
		elif collision.normal.y == 1:
			var remainderY = int(overworld.player.position.y) % int(tileSize.y)
			var newY = overworld.player.position.y + tileSize.y - remainderY
			playerTilePos = self.world_to_map(Vector2(overworld.player.position.x, newY))
		else:
			playerTilePos = self.world_to_map(overworld.player.position)


		playerTilePos -= collision.normal
		var tile = collision.collider.get_cellv(playerTilePos)
		if tile == Tile.DOOR:
			set_tile(playerTilePos.x, playerTilePos.y, Tile.FLOOR)
		elif tile == Tile.LADDER:
			levelNum += 1
			overworld.score += 20
			if levelNum < LEVEL_SIZES.size():
				isGeneratingNewLevel = true
				print("PlayerPos Prior to new level: " + str(overworld.player.position))
				print("Player Start Post prior:" + str(playerStartPosition))
				build_level()
				overworld.place_player()
				print("PlayerPos post to new level: " + str(overworld.player.position))
				print("Player Start Position post:" + str(playerStartPosition))
			else:
				overworld.score += 1000
				overworld.win_event()
	
func build_level():
	self.clear()
	randomize()
	levelSize = LEVEL_SIZES[levelNum]
	#populate possible starting points
	generate_possible_start_points()
	#populate all top left corner vectors of the 9x9 cells	
	generate_Anchor_Points()
	#populate door/opening midpoints
	generate_midpoints_for_doors_openings()
	#populate map corners array
	generate_Map_Corner_Points()
	
	#Max number of rooms based on roomCellSizes and level size
	var numberOfCells = (levelSize.x / roomCellSize.x) * (levelSize.y / roomCellSize.y)
	var startingSpot = possibleStartPoints[randi() % possibleStartPoints.size()]
	var firstSpot = true
	var needsCorridor = false
	var numberOfCellsPlaced = 0
		
	while numberOfCellsPlaced <= numberOfCells:
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
			place_walls(currentSpot)	
		else:
			#place doors
			place_doors(currentSpot)
		
		numberOfCellsPlaced += 1
		#mark position as palced
		needsCorridor = !needsCorridor
		if nextTileCellQueue.size() == 0:
			break;
	
	# Place Player
	place_player_start(startingSpot)
	
	# Place end ladder
	place_exit(startingSpot)
	
func place_player_start(startingSpot):
	var startRoom = startingSpot
	var roomOffset = 4
	var offsetVariance = 2
	var playerX = startRoom.x + roomOffset - randi() % offsetVariance
	var playerY = startRoom.y + roomOffset - randi() % offsetVariance
	playerStartPosition = Vector2(playerX, playerY) * tileSize
	
func place_exit(startingSpot):
	var endRoom
	var exitOffset = 4
	var offsetVariance = 2
	var cellIndex
	var ladderPlaced = false	
	
	while !ladderPlaced: 
		if startingSpot == MapCornerPoints.TopLeft:
			#set ladder bottomRight
			endRoom = MapCornerPoints.BottomRight
			cellIndex = self.get_cell(endRoom.x + exitOffset, endRoom.y + exitOffset)
			if cellIndex != -1:
				ladderPlaced = true
		elif startingSpot == MapCornerPoints.TopRight:
			#set ladder bottomLeft
			endRoom = MapCornerPoints.BottomLeft
			cellIndex = self.get_cell(endRoom.x + exitOffset, endRoom.y + exitOffset)
			if cellIndex != -1:
				ladderPlaced = true
		elif startingSpot == MapCornerPoints.BottomRight:
			#set ladder topLeft
			endRoom = MapCornerPoints.TopLeft
			cellIndex = self.get_cell(endRoom.x + exitOffset, endRoom.y + exitOffset)
			if cellIndex != -1:
				ladderPlaced = true
		else:
			#set ladder topRight
			endRoom = MapCornerPoints.TopRight
			cellIndex = self.get_cell(endRoom.x + exitOffset, endRoom.y + exitOffset)
			if cellIndex != -1:
				ladderPlaced = true
			
	var exitX = endRoom.x + exitOffset - randi() % offsetVariance
	var exitY = endRoom.y + exitOffset - randi() % offsetVariance
	set_tile(exitX, exitY, Tile.LADDER)

func generate_Anchor_Points():
	var roomSizeX = roomCellSize.x
	var roomSizeY = roomCellSize.y
	for x in range(levelSize.x / roomCellSize.x):
		for y in range(levelSize.y / roomCellSize.y):
			topLeftAnchorPoints.append(Vector2(x * roomSizeX, y * roomSizeY))

func generate_Map_Corner_Points():
	#top left corner
	MapCornerPoints.TopLeft = Vector2(0,0)
	#top right corner
	MapCornerPoints.TopRight = Vector2(levelSize.x - roomCellSize.x,0)
	#bottom left corner
	MapCornerPoints.BottomLeft = Vector2(0,levelSize.y - roomCellSize.y)
	#bottom right corner
	MapCornerPoints.BottomRight = Vector2(levelSize.x - roomCellSize.x,levelSize.y - roomCellSize.y)

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
			if cellindex == Tile.BOTTOM_RIGHT_CORNER:
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
	if topLeftAnchorPoints.find(topLefPosition) != -1:
		topLeftAnchorPoints.remove(topLeftAnchorPoints.find(topLefPosition))

func place_doors(anchorSpotPosition):
	var currentBottomMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Bottom)
	var currentRightMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Right)
	var currentTopMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Top)
	var currentLeftMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Left)

	var forcedDoorsToPlace = []
	var doorsToAdd = []
	
	if anchorSpotPosition == MapCornerPoints.TopLeft:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
	elif anchorSpotPosition == MapCornerPoints.TopRight:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
	elif anchorSpotPosition == MapCornerPoints.BottomLeft:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
	elif anchorSpotPosition == MapCornerPoints.BottomRight:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - roomCellSize.x):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - roomCellSize.y):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
	elif anchorSpotPosition.y == (levelSize.y - roomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - roomCellSize.x):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
	elif anchorSpotPosition.x == (levelSize.x - roomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - roomCellSize.y):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
	else:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, DirectionValue.Top)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, DirectionValue.Left)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, DirectionValue.Bottom)
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, DirectionValue.Right)
	
	#of the possible spots check if they can actually be placed there
	var numberOfDoorsToAdd = 0
	if doorsToAdd.size() > 0:
		numberOfDoorsToAdd = 1 + randi() % doorsToAdd.size()
	#finally paint the doors lucky enough to pass filtering
	var pointsToAdd = []
	for doorToAdd in numberOfDoorsToAdd:
		var doorDirection = doorsToAdd[randi() % numberOfDoorsToAdd]
		
		if doorDirection == DirectionValue.Bottom:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentBottomMidPoint, anchorSpotPosition)

		if doorDirection == DirectionValue.Top:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentTopMidPoint, anchorSpotPosition)

		if doorDirection == DirectionValue.Right:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentRightMidPoint, anchorSpotPosition)

		if doorDirection == DirectionValue.Left:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentLeftMidPoint, anchorSpotPosition)
	
	for forcedDoorToPlace in forcedDoorsToPlace:
		if forcedDoorToPlace == DirectionValue.Bottom:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentBottomMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == DirectionValue.Top:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentTopMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == DirectionValue.Right:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentRightMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == DirectionValue.Left:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentLeftMidPoint, anchorSpotPosition)
	
	
	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func add_door_and_get_point_to_add(direction, pointsToAdd, currentDirectionMidPoint, anchorSpotPosition):
	set_tile(currentDirectionMidPoint.x, currentDirectionMidPoint.y, Tile.DOOR)
	match direction:
		DirectionValue.Bottom:
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y + roomCellSize.y))
		DirectionValue.Top:
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y - roomCellSize.y))
		DirectionValue.Right:
			pointsToAdd.append(Vector2(anchorSpotPosition.x + roomCellSize.x, anchorSpotPosition.y))
		DirectionValue.Left:
			pointsToAdd.append(Vector2(anchorSpotPosition.x - roomCellSize.x, anchorSpotPosition.y))
	return pointsToAdd

func place_walls(anchorSpotPosition):
	var pointsToAdd = []
	var currentBottomMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Bottom)
	var currentRightMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Right)
	var currentTopMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Top)
	var currentLeftMidPoint = get_current_midpoint(anchorSpotPosition, CellMidpoints.Left)
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
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - roomCellSize.x):
		canPlaceTop = false
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - roomCellSize.y):
		canPlaceLeft = false
	elif anchorSpotPosition.y == (levelSize.y - roomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - roomCellSize.x):
		canPlaceBottom = false
	elif anchorSpotPosition.x == (levelSize.x - roomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - roomCellSize.y):
		canPlaceRight = false
	
	var canPlaceObj = true
	var nextPoint
	if !canPlaceTop:
		set_tile(currentTopMidPoint.x, currentTopMidPoint.y, Tile.TOP_WALL)
	else:
		#top is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y - roomCellSize.y)
		pointsToAdd.append(nextPoint)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentTopMidPoint, DirectionValue.Top)
		if canPlaceObj:
			set_tile(currentTopMidPoint.x, currentTopMidPoint.y, Tile.FLOOR)
		else:
			set_tile(currentTopMidPoint.x, currentTopMidPoint.y, Tile.TOP_WALL)

	if !canPlaceBottom:
		set_tile(currentBottomMidPoint.x, currentBottomMidPoint.y, Tile.HORIZONTAL_WALL)
	else:
		#bottom is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y + roomCellSize.y)
		pointsToAdd.append(nextPoint)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentBottomMidPoint, DirectionValue.Bottom)
		if canPlaceObj:
			set_tile(currentBottomMidPoint.x, currentBottomMidPoint.y, Tile.FLOOR)
		else:
			set_tile(currentBottomMidPoint.x, currentBottomMidPoint.y, Tile.HORIZONTAL_WALL)

	if !canPlaceLeft:
		set_tile(currentLeftMidPoint.x, currentLeftMidPoint.y, Tile.VERTICAL_WALL)
	else:
		#left is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x - roomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentLeftMidPoint, DirectionValue.Left)
		if canPlaceObj:
			set_tile(currentLeftMidPoint.x, currentLeftMidPoint.y, Tile.FLOOR)
		else:
			set_tile(currentLeftMidPoint.x, currentLeftMidPoint.y, Tile.VERTICAL_WALL)

	if !canPlaceRight:
		set_tile(currentRightMidPoint.x, currentRightMidPoint.y, Tile.VERTICAL_WALL)
	else:
		#right is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x + roomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentRightMidPoint, DirectionValue.Right)
		if canPlaceObj:
			set_tile(currentRightMidPoint.x, currentRightMidPoint.y, Tile.FLOOR)
		else:
			set_tile(currentRightMidPoint.x, currentRightMidPoint.y, Tile.VERTICAL_WALL)

	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func can_place_door_with_neighbor_cell_midpoint(currentMidpoint, direction, canPlaceObj):
	var cellIndex

	match direction:
		DirectionValue.Top:
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y - 1)
		DirectionValue.Bottom:
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y + 1)
		DirectionValue.Left:
			cellIndex = self.get_cell(currentMidpoint.x - 1, currentMidpoint.y)
		DirectionValue.Right:
			cellIndex = self.get_cell(currentMidpoint.x + 1, currentMidpoint.y)
	
	if cellIndex == -1:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = false
		canPlaceObj.tileToPlace = Tile.DOOR
	elif cellIndex == Tile.DOOR:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = true
		canPlaceObj.tileToPlace = Tile.FLOOR
	elif cellIndex == Tile.FLOOR:
		canPlaceObj.canPlace = true
		canPlaceObj.forced = true
		canPlaceObj.tileToPlace = Tile.DOOR		
	else:
		canPlaceObj.canPlace = false
		canPlaceObj.forced = false
		canPlaceObj.tileToPlace = Tile.DOOR
	return canPlaceObj

func can_place_with_neighbor_cell_midpoint(currentMidpoint, direction):
	var cellIndex

	match direction:
		DirectionValue.Top:
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y - 1)
		DirectionValue.Bottom:
			cellIndex = self.get_cell(currentMidpoint.x, currentMidpoint.y + 1)
		DirectionValue.Left:
			cellIndex = self.get_cell(currentMidpoint.x - 1, currentMidpoint.y)
		DirectionValue.Right:
			cellIndex = self.get_cell(currentMidpoint.x + 1, currentMidpoint.y)
	
	if cellIndex == -1:
		return true
	elif cellIndex == Tile.DOOR || cellIndex == Tile.FLOOR:
		return true
	else:
		return false

func get_current_midpoint(anchorSpotPosition, MidpointDirection):
	return Vector2(anchorSpotPosition.x + MidpointDirection.x, anchorSpotPosition.y + MidpointDirection.y)

func generate_possible_start_points():
	#top left corner
	possibleStartPoints.append(Vector2(0,0))
	#top right corner
	possibleStartPoints.append(Vector2(levelSize.x - roomCellSize.x,0))
	#bottom left corner
	possibleStartPoints.append(Vector2(0,levelSize.y - roomCellSize.y))
	#bottom right corner
	possibleStartPoints.append(Vector2(levelSize.x - roomCellSize.x,levelSize.y - roomCellSize.y))

func generate_midpoints_for_doors_openings():
	#top midpoint
	CellMidpoints.Top = Vector2((roomCellSize.x - 1) / 2, 0)
	#bottom midpoint
	CellMidpoints.Bottom = Vector2((roomCellSize.x - 1) / 2, (roomCellSize.y - 1))
	#left midpoint
	CellMidpoints.Left = Vector2(0, (roomCellSize.y - 1) / 2)
	#right midpoint
	CellMidpoints.Right = Vector2((roomCellSize.x - 1), (roomCellSize.y - 1) / 2)

func set_tile(x, y, type, flipx = false, flipy = false, transpose = false):
	self.set_cell(x, y, type, flipx, flipy, transpose)
	
func get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentDirectionMidPoint, workingDirection):
	var directionWallNeeded = {
		"Bottom": Tile.HORIZONTAL_WALL,
		"Top": Tile.TOP_WALL,
		"Right": Tile.VERTICAL_WALL,
		"Left": Tile.VERTICAL_WALL
	}
	
	var canPlaceObj = { 
		"canPlace": false,
		"forced": false,
		"tileToPlace": Tile.DOOR,
		"direction": DirectionValue.Bottom
	}
	canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentDirectionMidPoint, workingDirection, canPlaceObj)
	if canPlaceObj.canPlace:
		if !canPlaceObj.forced:
			doorsToAdd.append(workingDirection)
		else:
			forcedDoorsToPlace.append(workingDirection)
	else:
		#since door can't be placed paint the tile with a wall
		set_tile(currentDirectionMidPoint.x, currentDirectionMidPoint.y, directionWallNeeded[workingDirection])
	
	return [doorsToAdd, forcedDoorsToPlace]
