extends StaticBody2D

##################################################
const CIRCLE_SCENE: PackedScene = preload("res://scenes/circle/circle.tscn")
# 원형 오브젝트 씬 미리 불러오기

var path_node: Path2D
var polygon_node: Polygon2D
var collision_polygon_node: CollisionPolygon2D
var line_mode: Line2D
# 각 노드 선언

##################################################
func _ready() -> void:
	path_node = $Path2D
	polygon_node = $Polygon2D
	collision_polygon_node = $CollisionPolygon2D
	line_mode = $Line2D
	# 각 노드 설정
	
	var points: PackedVector2Array = path_node.curve.get_baked_points()
	# path_node의 포인트들을 가져옴
	
	polygon_node.polygon = points
	collision_polygon_node.polygon = points
	line_mode.points = points
	# 가져온 포인트들을 각 노드에 설정하여 지형 생성

##################################################
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left_mouse"):
	# 마우스 왼쪽 버튼을 눌렀을 때
		var circle_instance: Polygon2D = CIRCLE_SCENE.instantiate()
		circle_instance.global_position = get_global_mouse_position()
		add_child(circle_instance)
		# 마우스 클릭 지점에 원형 인스턴스 생성 및 추가
		
		var world_circle_polygon: PackedVector2Array = []
		for point in circle_instance.polygon:
			world_circle_polygon.append(point + circle_instance.global_position)
		'''
		원형 오브젝트의 데이터를 가져와서 월드 좌표로 변환
		각 포인트들은 로컬 좌표로 저자되어 있음. 그렇기에 원형 오브젝트의
		글로벌 좌표 + 각 포인트의 로컬 좌표를 더해줘야 각 포인트의 월드 좌표가 됨
		'''
		
		var clip_polygon: Array[PackedVector2Array] = \
			Geometry2D.exclude_polygons(polygon_node.polygon, world_circle_polygon)
		'''
		Geometry2D.exclude_polygons() 함수는 첫 번째 다각형에서 두 번째 다각형의
		영역을 제거한 새로운 다각형 리스트를 반환하는 함수
		'''
		
		if clip_polygon.size() > 0:
		# 새로운 다각형 리스트가 존재한다면(다각형이 겹쳐졌다면)
			polygon_node.polygon = clip_polygon[0]
			collision_polygon_node.polygon = clip_polygon[0]
			line_mode.points = clip_polygon[0]
			# 각 지형에 설정
		
		circle_instance.queue_free()
		# 원형 인스턴스 제거
