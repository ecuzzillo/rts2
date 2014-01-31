import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List

    def Start():
        selected = []

    def HandleObjectClick(obj as MonoBehaviour):
        selected = []
        selected.Add(obj)
        Debug.Log("Clicked")

    def GetSelectedObjects():
        return selected
