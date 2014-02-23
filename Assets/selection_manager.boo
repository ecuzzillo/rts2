import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public selectednesses as List
    public owned as Hash
    public dragging  as bool
    public selection_topleft as Vector2
    public selection_botright

    virtual def Start():
        selected = []
        selectednesses = []
        dragging = false
        
        owned = {}

    def Update():
        if Input.GetMouseButtonDown(0):
            dragging = true
            selection_topleft = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            
        if Input.GetMouseButton(0):
            selection_botright = Camera.main.ScreenToWorldPoint(Input.mousePosition)
        else:
            if dragging:
                (collider2D cast BoxCollider2D).center \
                    = Vector2((selection_topleft + selection_botright)/2)
                (collider2D cast BoxCollider2D).size \
                    = Vector2(selection_botright - selection_botleft)
                # backwards because coords positive is up and right, 
                # but intuition for dragging is down and right
                (collider2D cast BoxCollider2D).size.y *= -1 

                dragging = false

    def OnTriggerEnter2D(c as Collider2D):
        handle_click(c.gameObject, False)
        (collider2D cast BoxCollider2D).size = Vector2(0,0)

    def register_owned(obj as Object):
        owned[obj.GetInstanceID()] = true

    def handle_click(obj as GameObject):
        handle_click(obj, True)

    def handle_click(obj as GameObject, reset as bool):
        if reset:
            selected = []
        hash_str = "{\n"
        for key in owned.Keys:
            hash_str += "$(key): $(owned[key])\n"
        hash_str += "}\n"
        if owned.ContainsKey(obj.GetInstanceID()):
            selected.Add(obj)

            for s in selectednesses:
                Destroy(s)
            selectednesses = []
            the_obj = Instantiate(Resources.Load("selectedness_obj"), 
                                  obj.transform.position, 
                                  Quaternion.identity)
            (the_obj cast GameObject).GetComponent[of selectedness_obj]().\
                game_object = obj.gameObject
            selectednesses.Add(the_obj)
