extends TileMap

#Variables
var overworld
var tileSize = get_cell_size()
var tileHalfSize = Vector2(tileSize.x / 2, tileSize.y / 2)
var levelNum = 0
var levelSize
var playerStartPosition
var topLeftAnchorPoints = []
var possibleExitAnchorPoints = []
var roomCellSize = Vector2(9,9)
var nextTileCellQueue = []
var possibleStartPoints = []
var isGeneratingNewLevel = false
var gameOver = false
var chestIsOpen = false
var minExitDistanceInRoomCells = 2

#Resources
var Room_0000 = preload("res://overworld/Room_0000.tscn")
var Corridor_1111 = preload("res://overworld/Corridor_1111.tscn")

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
	"Bottom": "down",
	"Top": "up",
	"Left": "left",
	"Right": "right"
}

const LEVEL_SIZES = [
	Vector2(54, 36),
	Vector2(72, 54)
]

const ROOM_CELL_PROBABILITY_WEIGHTS = [60, 40]

#enums
enum Tile {
	BOTTOM_RIGHT_CORNER, # 0
	DOOR, # 1
	FLOOR, # 2
	VERTICAL_WALL, # 3
	HORIZONTAL_WALL, # 4
	TOP_LEFT_CORNER, # 5
	TOP_RIGHT_CORNER, #6
	TOP_WALL, #7
	BOTTOM_LEFT_CORNER, #8
	LADDER, #9
	CLOSED_CHEST, #10
	OPEN_CHEST, #11
	BOTTOM_LEFT_BEND_DOWN, #12
	BOTTOM_RIGHT_BEND_DOWN, #13
	HALL_FLOOR_ARROWS, #14
	HALL_FLOOR_CROSS, #15
	ROCK, #16
}

enum RoomCellType {
	CORRIDOR,
	ROOM
}

func _ready():
	overworld = get_parent()
	build_level()

func _on_Player_collided(collisionPoint, direction):
	if isGeneratingNewLevel || gameOver || chestIsOpen:
		return
	
	match direction:
		DirectionValue.Top:
			collisionPoint = Vector2(collisionPoint.x, collisionPoint.y - tileHalfSize.y)
		DirectionValue.Bottom:
			collisionPoint = Vector2(collisionPoint.x, collisionPoint.y + tileHalfSize.y)
		DirectionValue.Left:
			collisionPoint = Vector2(collisionPoint.x - tileHalfSize.x, collisionPoint.y)
		DirectionValue.Right:
			collisionPoint = Vector2(collisionPoint.x + tileHalfSize.x, collisionPoint.y)
	
	var mapCollision = world_to_map(collisionPoint)
	var tileIndex = get_cellv(mapCollision)
	var playerPos = overworld.player.position
	if tileIndex == Tile.DOOR:
		set_tile(mapCollision.x, mapCollision.y, Tile.FLOOR)
	elif tileIndex == Tile.CLOSED_CHEST:
		open_treasure_chest(mapCollision)
	elif tileIndex == Tile.LADDER:
		levelNum += 1
		overworld.score += 20
		if levelNum < LEVEL_SIZES.size():
			isGeneratingNewLevel = true
			build_level()
			overworld.place_player()
			overworld.update_floor_level(levelNum)
		else:
			gameOver = true
			overworld.score += 1000
			overworld.win_event()
	
func build_level():
	self.clear()
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
	var startingSpot = possibleStartPoints[Global.random.randi() % possibleStartPoints.size()]
	var firstSpot = true
	var needsCorridor = false
	var numberOfCellsPlaced = 0
		
	while numberOfCellsPlaced <= numberOfCells:
		var chosenRoomCellType = Global.get_random_type_by_weight(ROOM_CELL_PROBABILITY_WEIGHTS)
		
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
			#place chest
			if possibleStartPoints.find(currentSpot) == -1:
				place_treasure_chest(currentSpot)
		
		numberOfCellsPlaced += 1
		
		if chosenRoomCellType == RoomCellType.CORRIDOR:
			needsCorridor = true
		else:
			needsCorridor = false
		
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
	var playerX = startRoom.x + roomOffset - Global.random.randi() % offsetVariance
	var playerY = startRoom.y + roomOffset - Global.random.randi() % offsetVariance
	playerStartPosition = map_to_world(Vector2(playerX, playerY))
	
func place_exit(startingSpot):
	#Remove Player start point from possible points
	possibleExitAnchorPoints.erase(startingSpot)
	var endRoom
	var exitOffset = 4
	var offsetVariance = 2
	var cellIndex
	var ladderPlaced = false
	var loops = 0
	
	while !ladderPlaced:
		loops += 1
		if loops >= 12:
			minExitDistanceInRoomCells -= 1
			loops = 0
		#select a random spot
		var possiblePoint = possibleExitAnchorPoints[Global.random.randi() % possibleExitAnchorPoints.size()]
		
		if abs(startingSpot.x - possiblePoint.x) <= (minExitDistanceInRoomCells * roomCellSize.x):
			continue
		if abs(startingSpot.y - possiblePoint.y) <= (minExitDistanceInRoomCells * roomCellSize.x):
			continue
		#if cellIndex -1 skip everything
		cellIndex = self.get_cell(possiblePoint.x + exitOffset, possiblePoint.y + exitOffset)
		if cellIndex == -1:
			possibleExitAnchorPoints.erase(possiblePoint)
			continue
		else:
			endRoom = possiblePoint
			ladderPlaced = true
		
			
	var exitX = endRoom.x + exitOffset - Global.random.randi() % offsetVariance
	var exitY = endRoom.y + exitOffset - Global.random.randi() % offsetVariance
	set_tile(exitX, exitY, Tile.LADDER)

func generate_Anchor_Points():
	topLeftAnchorPoints = []
	possibleExitAnchorPoints = []
	var roomSizeX = roomCellSize.x
	var roomSizeY = roomCellSize.y
	for x in range(levelSize.x / roomCellSize.x):
		for y in range(levelSize.y / roomCellSize.y):
			topLeftAnchorPoints.append(Vector2(x * roomSizeX, y * roomSizeY))
			possibleExitAnchorPoints.append(Vector2(x * roomSizeX, y * roomSizeY))

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
	var canPlaceObjDoorDirectionPosition = 0
	var canPlaceObjDoorTilePosition = 1
	
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
		numberOfDoorsToAdd = 1 + Global.random.randi() % doorsToAdd.size()
	#finally paint the doors lucky enough to pass filtering
	var pointsToAdd = []
	for doorToAdd in numberOfDoorsToAdd:
		var doorArr = doorsToAdd[Global.random.randi() % numberOfDoorsToAdd]
		var doorTile = doorArr[canPlaceObjDoorTilePosition]
		var doorDirection = doorArr[canPlaceObjDoorDirectionPosition]
		
		if doorDirection == DirectionValue.Bottom:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentBottomMidPoint, anchorSpotPosition, doorTile)

		if doorDirection == DirectionValue.Top:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentTopMidPoint, anchorSpotPosition, doorTile)

		if doorDirection == DirectionValue.Right:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentRightMidPoint, anchorSpotPosition, doorTile)

		if doorDirection == DirectionValue.Left:
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentLeftMidPoint, anchorSpotPosition, doorTile)
	
	for forcedDoorToPlace in forcedDoorsToPlace:
		var forcedDoorTile = forcedDoorToPlace[canPlaceObjDoorTilePosition]
		var forcedDoorDirection = forcedDoorToPlace[canPlaceObjDoorDirectionPosition]
		if forcedDoorDirection == DirectionValue.Bottom:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentBottomMidPoint, anchorSpotPosition, forcedDoorTile)

		if forcedDoorDirection == DirectionValue.Top:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentTopMidPoint, anchorSpotPosition, forcedDoorTile)

		if forcedDoorDirection == DirectionValue.Right:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentRightMidPoint, anchorSpotPosition, forcedDoorTile)

		if forcedDoorDirection == DirectionValue.Left:
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentLeftMidPoint, anchorSpotPosition, forcedDoorTile)
	
	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func add_door_and_get_point_to_add(direction, pointsToAdd, currentDirectionMidPoint, anchorSpotPosition, doorTile):
	set_tile(currentDirectionMidPoint.x, currentDirectionMidPoint.y, doorTile)
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
	possibleStartPoints = []
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
		"down": Tile.HORIZONTAL_WALL,
		"up": Tile.TOP_WALL,
		"right": Tile.VERTICAL_WALL,
		"left": Tile.VERTICAL_WALL
	}
	
	var canPlaceObj = { 
		"canPlace": false,
		"forced": false,
		"tileToPlace": Tile.DOOR
	}
	canPlaceObj = can_place_door_with_neighbor_cell_midpoint(currentDirectionMidPoint, workingDirection, canPlaceObj)
	if canPlaceObj.canPlace:
		if !canPlaceObj.forced:
			doorsToAdd.append([workingDirection, canPlaceObj.tileToPlace])
		else:
			forcedDoorsToPlace.append([workingDirection, canPlaceObj.tileToPlace])
	else:
		#since door can't be placed paint the tile with a wall
		set_tile(currentDirectionMidPoint.x, currentDirectionMidPoint.y, directionWallNeeded[workingDirection])
	
	return [doorsToAdd, forcedDoorsToPlace]

func place_treasure_chest(anchorPosition):
	#generatePossible chest spawnPoints
	var wallAndDoorOffset = 2
	#remove spots where wall are	
	#remove spots where a door could be
	var possibleSpawnPoints = []
	for possibleSpawnPointX in range(roomCellSize.x - wallAndDoorOffset * 2):
		for possibleSpawnPointY in range(roomCellSize.y - wallAndDoorOffset * 2):
			possibleSpawnPoints.append(anchorPosition + Vector2(possibleSpawnPointX + wallAndDoorOffset, possibleSpawnPointY + wallAndDoorOffset))
	#randomly pic a position where the chest should be
	var spawnPoint = possibleSpawnPoints[Global.random.randi() % possibleSpawnPoints.size()]
	#set the tile at the position to closed chest
	set_tile(spawnPoint.x, spawnPoint.y, Tile.CLOSED_CHEST)

func open_treasure_chest(chestPosition):
	#prevent player
	overworld.player.set_can_move(false)
	#prevent collision
	chestIsOpen = true
	#set tile at the position to open chest
	set_tile(chestPosition.x, chestPosition.y, Tile.OPEN_CHEST)	
	#get loot
	overworld.get_loot_for_chest(levelNum)
