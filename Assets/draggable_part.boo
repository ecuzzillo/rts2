import UnityEngine

class draggable_part(MonoBehaviour):
    public mouse_down as bool
    public sel_mgr as selection_manager

    def Start():
        sel_mgr = FindObjectOfType(selection_manager)
        mouse_down = false
        (collider2D cast BoxCollider2D).size = (renderer as SpriteRenderer).sprite.bounds.size

    def Update():
        if mouse_down and self in sel_mgr.selected:
            transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            transform.position.z = 0

    def OnTriggerStay2D(other as Collider2D):
        if not mouse_down and Input.GetMouseButton(0):
            sel_mgr.handle_click(self)
            mouse_down = true

        elif mouse_down and not Input.GetMouseButton(0):
            sel_mgr.selected = []
            mouse_down = false

            
    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)
