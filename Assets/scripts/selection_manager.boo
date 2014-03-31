import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public selectednesses as List
    public owned as Hash
    public dragging  as bool
    public selection_topleft as Vector3
    public selection_botright as Vector3
    public collider_active as bool
    public mouse as mouse_follow
    public waypoint_indicator as GameObject
    public ld as line_drawer
    public ground as GameObject
    public texture as Texture2D

    def constructor():
        selected = []
        selectednesses = []
        dragging = false
        owned = {}
        collider_active = false

    virtual def Start():
        ld = GetComponent[of line_drawer]()
        waypoint_indicator = GameObject("garbage")
        transform.position = Vector3(-100,-100,0)
        mouse = FindObjectOfType(mouse_follow)
        ground = GameObject.Find("Ground")
        texture = ground.renderer.material.mainTexture cast Texture2D

    def Update():
        update_fog_of_war()
        dragging_selection_update()
        mouse_click_update()
        keyboard_update()

    def world_space_to_texture_space(position as Vector3):
        bounds = ground.renderer.bounds
        texture_space_x = ((position.x - bounds.min.x) / (bounds.max.x - bounds.min.x)) * texture.width
        texture_space_y = ((position.y - bounds.min.y) / (bounds.max.y - bounds.min.y)) * texture.height
        return ((texture_space_x cast int), (texture_space_y cast int))

    def apply_connector_visibility(connector as grunt_movement, pixels as (Color)):
        location = connector.transform.position
        texture_location = world_space_to_texture_space(location)
        for i in range(texture.height):
            for j in range(texture.width):
                index = i * texture.width + j
                pixels[index].a = Mathf.Min(pixels[index].a, 1 - 1.0 / ((i-(texture_location[1]))**2 + (j-(texture_location[0]))**2 + 1) ** 0.4)

    def update_fog_of_war():
        pixels = texture.GetPixels()
        texture_space_origin = Vector3(texture.width / 2.0,
                                       texture.height / 2.0,
                                       0)
        for i in range(len(pixels)):
            pixels[i].r = 0
            pixels[i].g = 0
            pixels[i].b = 0
            pixels[i].a = 1
        for connector as grunt_movement in connector_objs:
            apply_connector_visibility(connector, pixels)
        texture.SetPixels(pixels)
        texture.Apply()

    # Check for mass selection
    def dragging_selection_update():
        if Input.GetMouseButtonDown(0):
            dragging = true
            selection_topleft = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            selection_topleft.z = 0

        if Input.GetMouseButton(0):
            selection_botright = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            selection_botright.z = 0

            # fuck this for now
            if 0:
                p1 = Vector3(selection_topleft.x, 
                             selection_botright.y, 
                             0)
                p3 = Vector3(selection_botright.x, 
                             selection_topleft.y, 
                             0)

                ld.draw_line(gameObject.GetComponent[of MeshFilter](), 
                             [selection_topleft, p1, selection_botright, p3],
                             5, 
                             true)
            

        elif dragging:
            transform.position \
                = (selection_topleft + selection_botright)/2
            (collider2D cast BoxCollider2D).size \
                = selection_botright - selection_topleft
            # backwards because coords positive is up and right, 
            # but intuition for dragging is down and right
            (collider2D cast BoxCollider2D).size.y *= -1 

            dragging = false

            for s in selectednesses:
                Destroy(s)

            selected = []
            selectednesses = []

    # Check for mouse clicks
    def mouse_click_update():
        if Input.GetMouseButtonUp(0):
            if mouse.hover_obj != null:
                handle_left_click(mouse.hover_obj)
            else:
                selected = []
                selectednesses = []
                collider_active = true

        if Input.GetMouseButtonUp(1):
            if mouse.hover_obj != null:
                handle_right_click(mouse.hover_obj)
            elif selected:
                set_waypoints()

    # Check for keyboard input
    def keyboard_update():
        inc = 1
        if Input.GetKey("right"):
            Camera.main.transform.position.x += inc
        if Input.GetKey("left"):
            Camera.main.transform.position.x -= inc
        if Input.GetKey("up"):
            Camera.main.transform.position.y += inc
        if Input.GetKey("down"):
            Camera.main.transform.position.y -= inc
        if Input.GetKeyDown(KeyCode.Escape):
            Application.LoadLevel(0)


    def OnTriggerEnter2D(c as Collider2D):
        if collider_active:
            handle_left_click(c.gameObject, false)

    def OnTriggerStay2D(c as Collider2D):
        if collider_active:
            transform.position = Vector3(-100,-100,0)
            (collider2D cast BoxCollider2D).size = Vector2(0.0001,0.0001)
            collider_active = false

    # For each selected unit, if that unit is a gun, target the argument unit
    def target_guns(obj as GameObject):
        for selected_obj in selected:
            #component = (selected_obj cast GameObject).GetComponent[of gun_movement]()
            #if component != null:
            #    component.gun_target = obj
            component = (selected_obj cast GameObject).GetComponent[of grunt_movement]()
            component.target_guns(obj)

    # For each selected unit, set the unit's waypoint to the mouse position
    def set_waypoints():
        waypoint = Camera.main.ScreenToWorldPoint(Input.mousePosition)
        waypoint.z = 0
        for selected_obj in selected:
            component = (selected_obj cast GameObject).GetComponent[of grunt_movement]()
            if component != null:
                component.target = waypoint
        create_waypoint_indicator(waypoint)

    def create_waypoint_indicator(target):
        Destroy(waypoint_indicator)
        waypoint_indicator = Instantiate(Resources.Load("doonk"),
                                         target,
                                         Quaternion.identity)

    def register_owned(obj as Object):
        owned[obj.GetInstanceID()] = true

    def handle_left_click(obj as GameObject):
        handle_left_click(obj, true)

    def handle_left_click(obj as GameObject, reset as bool):
        if owned.ContainsKey(obj.GetInstanceID()):
            actual_obj = obj.GetComponent[of grunt_movement]().get_parent()
            selected.Add(actual_obj.gameObject)

            the_obj = Instantiate(Resources.Load("selectedness_obj"), 
                                  actual_obj.transform.position, 
                                  Quaternion.identity)
            (the_obj cast GameObject).GetComponent[of selectedness_obj]().\
                game_object = actual_obj.gameObject
            selectednesses.Add(the_obj)

    def handle_right_click(obj as GameObject):
        if obj not in owned:
            for selected_obj as GameObject in selected:
                #so = (selected_obj cast GameObject)
                component = selected_obj.GetComponent[of grunt_movement]()
                if component != null:
                    component.target_guns(obj)

