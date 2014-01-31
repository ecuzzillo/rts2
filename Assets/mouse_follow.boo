import UnityEngine

class mouse_follow(MonoBehaviour): 
    def Start():
        pass

        #p1 = Camera.main.ScreenToWorldPoint(Vector
        #collider2D.radius = 
        
    
    def Update():
        transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            #hit as RaycastHit
            #if Physics.Raycast(Camera.main.ScreenPointToRoy(Input.mousePosition), hit):
            
    def FixedUpdate():
        pass
