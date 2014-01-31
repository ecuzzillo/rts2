import UnityEngine

class mouse_follow(MonoBehaviour): 
    def Start():
        pass

    def Update():
        transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)

    def FixedUpdate():
        pass
