extends TileMap

var overworld

var tileSize = get_cell_size()
var levelNum = 0
var levelSize
var playerStartPosition

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
	BottomRightCorner,	# 0
	Door,	# 1
	Floor,	# 2
	VerticalWall,	# 3
	HorizontalWall,	# 4
	TopLeftCorner,	# 5
	TopRightCorner, #6
	TopWall, #7
	BottomLeftCorner, #8
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
		if tile == Tile.Door:
			set_tile(playerTilePos.x, playerTilePos.y, Tile.Floor)
		elif tile == Tile.Ladder:
			levelNum += 1
			overworld.score += 20
			if levelNum < LEVEL_SIZES.size():
				build_level()
				overworld.place_player()
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
	
	#Max number of rooms based on RoomCellSizes and level size
	var numberOfCells = (levelSize.x / RoomCellSize.x) * (levelSize.y / RoomCellSize.y)
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
	set_tile(exitX, exitY, Tile.Ladder)

func generate_Anchor_Points():
	var roomSizeX = RoomCellSize.x
	var roomSizeY = RoomCellSize.y
	for x in range(levelSize.x / RoomCellSize.x):
		for y in range(levelSize.y / RoomCellSize.y):
			topLeftAnchorPoints.append(Vector2(x * roomSizeX, y * roomSizeY))

func generate_Map_Corner_Points():
	#top left corner
	MapCornerPoints.TopLeft = Vector2(0,0)
	#top right corner
	MapCornerPoints.TopRight = Vector2(levelSize.x - RoomCellSize.x,0)
	#bottom left corner
	MapCornerPoints.BottomLeft = Vector2(0,levelSize.y - RoomCellSize.y)
	#bottom right corner
	MapCornerPoints.BottomRight = Vector2(levelSize.x - RoomCellSize.x,levelSize.y - RoomCellSize.y)

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
			if cellindex == Tile.BottomRightCorner:
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
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
	elif anchorSpotPosition == MapCornerPoints.TopRight:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
	elif anchorSpotPosition == MapCornerPoints.BottomLeft:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
	elif anchorSpotPosition == MapCornerPoints.BottomRight:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - RoomCellSize.x):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - RoomCellSize.y):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
	elif anchorSpotPosition.y == (levelSize.y - RoomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - RoomCellSize.x):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
	elif anchorSpotPosition.x == (levelSize.x - RoomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - RoomCellSize.y):
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
	else:
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentTopMidPoint, "Top")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentLeftMidPoint, "Left")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentBottomMidPoint, "Bottom")
		get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentRightMidPoint, "Right")
	
	#of the possible spots check if they can actually be placed there
	var numberOfDoorsToAdd = 0
	if doorsToAdd.size() > 0:
		numberOfDoorsToAdd = 1 + randi() % doorsToAdd.size()
	#finally paint the doors lucky enough to pass filtering
	var pointsToAdd = []
	for doorToAdd in numberOfDoorsToAdd:
		var doorDirection = doorsToAdd[randi() % numberOfDoorsToAdd]
		
		if doorDirection == "Bottom":
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentBottomMidPoint, anchorSpotPosition)

		if doorDirection == "Top":
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentTopMidPoint, anchorSpotPosition)

		if doorDirection == "Right":
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentRightMidPoint, anchorSpotPosition)

		if doorDirection == "Left":
			add_door_and_get_point_to_add(doorDirection, pointsToAdd, currentLeftMidPoint, anchorSpotPosition)
	
	for forcedDoorToPlace in forcedDoorsToPlace:
		if forcedDoorToPlace == "Bottom":
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentBottomMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == "Top":
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentTopMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == "Right":
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentRightMidPoint, anchorSpotPosition)

		if forcedDoorToPlace == "Left":
			add_door_and_get_point_to_add(forcedDoorToPlace, pointsToAdd, currentLeftMidPoint, anchorSpotPosition)
	
	
	for point in pointsToAdd:
		if nextTileCellQueue.find(point) == -1 && topLeftAnchorPoints.find(point) != -1:
			nextTileCellQueue.push_front(point)
			topLeftAnchorPoints.remove(topLeftAnchorPoints.find(point))

func add_door_and_get_point_to_add(direction, pointsToAdd, currentDirectionMidPoint, anchorSpotPosition):
	set_tile(currentDirectionMidPoint.x, currentDirectionMidPoint.y, Tile.Door)
	match direction:
		"Bottom":
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y + RoomCellSize.y))
		"Top":
			pointsToAdd.append(Vector2(anchorSpotPosition.x, anchorSpotPosition.y - RoomCellSize.y))
		"Right":
			pointsToAdd.append(Vector2(anchorSpotPosition.x + RoomCellSize.x, anchorSpotPosition.y))
		"Left":
			pointsToAdd.append(Vector2(anchorSpotPosition.x - RoomCellSize.x, anchorSpotPosition.y))
	return pointsToAdd

func place_walls(anchorSpotPosition):
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
	elif anchorSpotPosition.y == 0 && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - RoomCellSize.x):
		canPlaceTop = false
	elif anchorSpotPosition.x == 0 && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - RoomCellSize.y):
		canPlaceLeft = false
	elif anchorSpotPosition.y == (levelSize.y - RoomCellSize.y) && anchorSpotPosition.x > 0 && anchorSpotPosition.x < (levelSize.x - RoomCellSize.x):
		canPlaceBottom = false
	elif anchorSpotPosition.x == (levelSize.x - RoomCellSize.x) && anchorSpotPosition.y > 0 && anchorSpotPosition.y < (levelSize.y - RoomCellSize.y):
		canPlaceRight = false
	
	var canPlaceObj = true
	var nextPoint
	var currentAnchorMidPoint
	if !canPlaceTop:
		set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TopWall)
	else:
		#top is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y - RoomCellSize.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Top")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Top.x, anchorSpotPosition.y + CellMidpoints.Top.y, Tile.TopWall)

	if !canPlaceBottom:
		set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HorizontalWall)
	else:
		#bottom is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x, anchorSpotPosition.y + RoomCellSize.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Bottom")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Bottom.x, anchorSpotPosition.y + CellMidpoints.Bottom.y, Tile.HorizontalWall)

	if !canPlaceLeft:
		set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VerticalWall)
	else:
		#left is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x - RoomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Left")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Left.x, anchorSpotPosition.y + CellMidpoints.Left.y, Tile.VerticalWall)

	if !canPlaceRight:
		set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VerticalWall)
	else:
		#right is a possible direction
		nextPoint = Vector2(anchorSpotPosition.x + RoomCellSize.x, anchorSpotPosition.y)
		pointsToAdd.append(nextPoint)
		currentAnchorMidPoint = Vector2(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y)
		canPlaceObj = can_place_with_neighbor_cell_midpoint(currentAnchorMidPoint, "Right")
		if canPlaceObj:
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.Floor)
		else:
			set_tile(anchorSpotPosition.x + CellMidpoints.Right.x, anchorSpotPosition.y + CellMidpoints.Right.y, Tile.VerticalWall)

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

func get_current_midpoint(anchorSpotPosition, MidpointDirection):
	return Vector2(anchorSpotPosition.x + MidpointDirection.x, anchorSpotPosition.y + MidpointDirection.y)

func generate_possible_start_points():
	#top left corner
	possibleStartPoints.append(Vector2(0,0))
	#top right corner
	possibleStartPoints.append(Vector2(levelSize.x - RoomCellSize.x,0))
	#bottom left corner
	possibleStartPoints.append(Vector2(0,levelSize.y - RoomCellSize.y))
	#bottom right corner
	possibleStartPoints.append(Vector2(levelSize.x - RoomCellSize.x,levelSize.y - RoomCellSize.y))

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
	
func get_required_and_free_doors_to_palce(doorsToAdd, forcedDoorsToPlace, currentDirectionMidPoint, workingDirection):
	var directionWallNeeded = {
		"Bottom": Tile.HorizontalWall,
		"Top": Tile.TopWall,
		"Right": Tile.VerticalWall,
		"Left": Tile.VerticalWall
	}
	
	var canPlaceObj = { 
		"canPlace": false,
		"forced": false,
		"tileToPlace": Tile.Door,
		"direction": "Bottom"
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
