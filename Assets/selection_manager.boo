import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List

    def Start():
        selected = []

    def handle_click(obj as MonoBehaviour):
        selected = []
        Debug.Log(obj)
        selected.Add(obj)
