import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public selectednesses as List
    public owned as Hash

    virtual def Start():
        selected = []
        selectednesses = []
        owned = {}

    def register_owned(obj as Object):
        owned[obj.GetInstanceID()] = true

    def handle_click(obj as GameObject):
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
