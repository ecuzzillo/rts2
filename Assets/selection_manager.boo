import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public selectednesses as List
    public owned as Hash
    public dragging  as bool
    public selection_topleft as Vector3
    public selection_botright as Vector3
    public mouse as mouse_follow
    public waypoint_indicator as GameObject

    def constructor():
        selected = []
        selectednesses = []
        dragging = false
        owned = {}


    virtual def Start():
        waypoint_indicator = GameObject("garbage")
        transform.position = Vector3(-100,-100,0)
        mouse = FindObjectOfType(mouse_follow)

    def Update():
        if Input.GetMouseButtonDown(0):
            dragging = true
            selection_topleft = Camera.main.ScreenToWorldPoint(Input.mousePosition)

        if Input.GetMouseButton(0):
            selection_botright = Camera.main.ScreenToWorldPoint(Input.mousePosition)
        elif dragging:
            # (collider2D cast BoxCollider2D).center \
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

        if Input.GetMouseButtonUp(0):
            if mouse.hover_obj != null:
                handle_click(mouse.hover_obj)
            else:
                selected = []

        if Input.GetMouseButtonUp(1):
            if mouse.hover_obj != null:
                target_guns(mouse.hover_obj)
            elif selected:
                set_waypoints()


    def OnTriggerEnter2D(c as Collider2D):
        Debug.Log("calling handle click from trigger")
        handle_click(c.gameObject, false)

    def OnTriggerStay2D(c as Collider2D):
        transform.position = Vector3(-100,-100,0)
        (collider2D cast BoxCollider2D).size = Vector2(0.0001,0.0001)

    # For each selected unit, if that unit is a gun, target the "obj" unit
    def target_guns(obj as GameObject):
        for selected_obj in selected:
            component = (selected_obj cast GameObject).GetComponent[of gun_movement]()
            if component != null:
                component.gun_target = obj

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

    def handle_click(obj as GameObject):
        handle_click(obj, true)

    def handle_click(obj as GameObject, reset as bool):
        if reset:
            selected = []
        hash_str = "{\n"
        for key in owned.Keys:
            hash_str += "$(key): $(owned[key])\n"
        hash_str += "}\n"
        if owned.ContainsKey(obj.GetInstanceID()):
            selected.Add(obj)
            Debug.Log("selected len " + len(selected))

            the_obj = Instantiate(Resources.Load("selectedness_obj"), 
                                  obj.transform.position, 
                                  Quaternion.identity)
            (the_obj cast GameObject).GetComponent[of selectedness_obj]().\
                game_object = obj.gameObject
            selectednesses.Add(the_obj)

    def handle_right_click(obj as GameObject):
        for selected_obj in selected:
            component = (selected_obj cast GameObject).GetComponent[of gun_movement]()
            if component != null:
                component.gun_target = obj
