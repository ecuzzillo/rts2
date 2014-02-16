import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public owned as Hash

    virtual def Start():
        selected = []
        owned = {}

    def register_owned(obj as Object):
        owned[obj.GetInstanceID()] = true

    def handle_click(obj as GameObject):
        selected = []
        Debug.Log(obj.GetInstanceID())
        hash_str = "{\n"
        for key in owned.Keys:
            hash_str += "$(key): $(owned[key])\n"
        hash_str += "}\n"
        Debug.Log(hash_str)
        if owned.ContainsKey(obj.GetInstanceID()):
            Debug.Log("Owned")
            selected.Add(obj)
