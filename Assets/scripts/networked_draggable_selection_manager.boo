import UnityEngine

#public sm as selection_manager

class networked_draggable_selection_manager(MonoBehaviour): 
    public owned as Hash
    public selected as List
    public selectednesses as List
    public part_counter as int
    public ready as bool
    public other_ready as bool
    public ground as GameObject
    public texture as Texture2D
    public conns as List
    public mouse as mouse_follow
    public waypoint_indicator as GameObject
    public ld as line_drawer
    public collider_active as bool

    def constructor():
        owned = {}
        part_counter = 8
        ready = false
        other_ready = false
        conns = []


    def Start():
        selected = []
        selectednesses = []
        ground = GameObject.Find("Ground")
        mouse = FindObjectOfType(mouse_follow)
        mesh_utils.set_black_plane(ground)

    def make_sprite(name as string):
        bloo = Instantiate(Resources.Load(name),
                           Vector3(0,0,0),
                           Quaternion.identity) cast Texture2D
        blah = Sprite.Create(bloo,
                             Rect(0,0,bloo.width,bloo.height),
                             Vector2(0.5,0.5),
                             100)
        blah.bounds.center.x = 0
        blah.bounds.center.y = 0
        blah.hideFlags = HideFlags.None

        return blah


    def handle_click(obj as MonoBehaviour):
        selected = []
        for s in selectednesses:
            Destroy(s)
        selectednesses = []
        selected.Add(obj)

        the_obj = Instantiate(Resources.Load("selectedness_obj"), 
                              obj.transform.position, 
                              Quaternion.identity)
        (the_obj cast GameObject).GetComponent[of selectedness_obj]().game_object = obj.gameObject
        selectednesses.Add(the_obj)

    def make_part_at_cursor() as GameObject:
        if part_counter > 0:
            new_obj = (Network.Instantiate(Resources.Load("gun_obj"),
                                           Camera.main.ScreenToWorldPoint(Input.mousePosition),
                                           Quaternion.identity, 0) cast GameObject)
            new_obj.transform.position.z = 0
            register_owned(new_obj)
            part_counter -= 1
            conns.Add(new_obj)
            return new_obj
        else:
            return null

    def set_sprite(dp as MonoBehaviour, s as Sprite):
        (dp.renderer cast SpriteRenderer).sprite = s

    def make_unit():
        new_obj = make_part_at_cursor()
        if new_obj == null:
            return null
        dp = new_obj.GetComponent[of grunt_movement]()
        dp.inited = false
        dp.is_core = true
        dp.set_sprname("red-block")
        set_sprite(dp, make_sprite("red-block"))
        return new_obj

    [RPC]
    def set_other_ready(val as bool):
        other_ready = val

    def Update():
        mouse_click_update()
        update_fog_of_war()
        if Input.GetKeyDown("g"):
            ready = true
            networkView.RPC("set_other_ready", RPCMode.Others, true)
        if Input.GetKeyDown("c"):
            make_unit()
        if ready and other_ready:
            pass

    def world_space_to_texture_space(position as Vector3):
        bounds = ground.renderer.bounds
        texture_space_x = ((position.x - bounds.min.x) / (bounds.max.x - bounds.min.x)) * 10
        texture_space_y = ((position.y - bounds.min.y) / (bounds.max.y - bounds.min.y)) * 10
        return ((texture_space_x cast int), (texture_space_y cast int))

    def apply_connector_visibility(connector as grunt_movement,
                                   vertices as (Vector3), 
                                   pixels as (Color)):
        location = connector.transform.position
        texture_location = world_space_to_texture_space(location)

        for i in range(len(vertices)):
            pixels[i].a = Mathf.Min(pixels[i].a,
                                    1.0 - 1.0 / ((vertices[i].y-location.y/2.0)**2.0 + 
                                                 (vertices[i].x-location.x/2.0)**2.0 + 1.0)**0.3)
            
        return pixels
    def update_fog_of_war():
        mymesh = ground.GetComponent[of MeshFilter]()
        colors = array(Color, len(mymesh.mesh.vertices))
        c = Color(0,0,0,1.0)
        for i in range(len(mymesh.mesh.colors)):
            colors[i] = c

        for c as GameObject in conns:
            colors = apply_connector_visibility(c.GetComponent[of grunt_movement](), 
                                                mymesh.mesh.vertices, 
                                                colors)

        mymesh.mesh.colors = colors
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
        if Input.GetKeyDown("c"):
            make_unit()
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
        owned[obj.GetInstanceID()] = obj

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
        if obj.GetInstanceID() not in owned:
            for selected_obj as GameObject in selected:
                #so = (selected_obj cast GameObject)
                component = selected_obj.GetComponent[of grunt_movement]()
                if component != null:
                    component.target_guns(obj)

