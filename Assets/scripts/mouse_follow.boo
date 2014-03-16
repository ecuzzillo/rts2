import UnityEngine

class mouse_follow(MonoBehaviour):
    public hover_obj as GameObject
    public hover_timer as int

    def constructor():
        hover_obj = null
        hover_timer = 0

    def Start():
        pass

    def Update():
        transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
        if hover_obj != null:
            if hover_timer != 0:
                hover_timer -= 1
            else:
                hover_obj = null

    def OnTriggerStay2D(other as Collider2D):
        hover_obj = other.gameObject
        hover_timer = 1

    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)
