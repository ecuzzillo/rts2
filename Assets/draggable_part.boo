import UnityEngine

class draggable_part(MonoBehaviour):
    public mouse_down as bool
    public sel_mgr as selection_manager
    public connectors as List
    public inited as bool

    def Start():
        sel_mgr = FindObjectOfType(selection_manager)
        mouse_down = false
        inited = false
        s = (renderer as SpriteRenderer).sprite.bounds.size
        (collider2D cast BoxCollider2D).size = s
        connectors = [Vector3(s.x/2, 0,0), Vector3(-s.x/2, 0,0)]

    def Update():
        if not inited:
            sel_mgr.connector_objs.Add(self)
            inited = true

        if mouse_down and self in sel_mgr.selected:
            transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            transform.position.z = 0

            if Input.GetKeyDown("right"):
                transform.Rotate(Vector3(0,0,90))
            if Input.GetKeyDown("left"):
                transform.Rotate(Vector3(0,0,-90))
            

    def OnTriggerStay2D(other as Collider2D):
        if not mouse_down and Input.GetMouseButton(0) and len(sel_mgr.selected) == 0:
            sel_mgr.handle_click(gameObject)
            mouse_down = true

        elif mouse_down and not Input.GetMouseButton(0):
            sel_mgr.selected = []
            mouse_down = false

            
    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)
