import UnityEngine

class draggable_part(MonoBehaviour):
    public mouse_down as bool
    public sel_mgr as draggable_selection_manager
    public connectors as List
    public inited as bool
    public mouse_coll as Collider2D
    public is_core as bool

    def constructor():
        is_core = false
        connectors = [[Vector3(0.5,0,0),
                       Vector3(1,0,0)],
                      [Vector3(-0.5,0,0),
                       Vector3(-1, 1, 0)]]
    virtual def Start():
        sel_mgr = FindObjectOfType(draggable_selection_manager)
        mouse_down = false
        inited = false
        mouse_coll = FindObjectOfType(mouse_follow).collider2D
        Debug.Log("dp start running")

    def Update():
        if not inited:
            s = (renderer as SpriteRenderer).sprite.bounds.size
            (collider2D cast BoxCollider2D).size = s

            for i in range(len(connectors)):
                (connectors[i] cast List)[0] = ((connectors[i] cast List)[0] cast Vector3) * s.x
            Debug.Log("we have "+len(connectors)+" connectors")
            sel_mgr.connector_objs.Add(self)
            inited = true

        if mouse_down and self in sel_mgr.selected:
            transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            transform.position.z = 0

            if Input.GetKeyDown("right"):
                transform.Rotate(Vector3(0,0,90))
            if Input.GetKeyDown("left"):
                transform.Rotate(Vector3(0,0,-90))

    def FixedUpdate():
        rigidbody2D.AddTorque(-rigidbody2D.angularVelocity/2)
        rigidbody2D.AddForce(-rigidbody2D.velocity*2)
            
    def OnTriggerStay2D(other as Collider2D):
        if other == mouse_coll:
            if not mouse_down and Input.GetMouseButtonDown(0) and len(sel_mgr.selected) == 0:
                sel_mgr.handle_click(self)
                mouse_down = true

            elif mouse_down and not Input.GetMouseButton(0):
                sel_mgr.selected = []
                mouse_down = false
            
    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)
