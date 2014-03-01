import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public selectednesses as List
    public owned as Hash
    public dragging  as bool
    public selection_topleft as Vector3
    public selection_botright as Vector3

    def constructor():
        selected = []
        selectednesses = []
        dragging = false
        owned = {}


    virtual def Start():
        transform.position = Vector3(-100,-100,0)

    def Update():
        if Input.GetMouseButtonDown(0):
            dragging = true
            selection_topleft = Camera.main.ScreenToWorldPoint(Input.mousePosition)

        if Input.GetMouseButton(0):
            selection_botright = Camera.main.ScreenToWorldPoint(Input.mousePosition)
        else:
            if dragging:
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


    def OnTriggerEnter2D(c as Collider2D):
        Debug.Log("calling handle click from trigger")
        handle_click(c.gameObject, false)

    def OnTriggerStay2D(c as Collider2D):
        transform.position = Vector3(-100,-100,0)
        (collider2D cast BoxCollider2D).size = Vector2(0.0001,0.0001)

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
