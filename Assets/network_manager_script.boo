import UnityEngine

class network_manager_script(MonoBehaviour):
    public btn_x as double
    public btn_y as double
    public btn_w as double
    public btn_h as double

	def Start():
        btn_x = Screen.width * 0.05
        btn_y = Screen.width * 0.05
        btn_w = Screen.width * 0.1
        btn_h = Screen.width * 0.1
	
    def OnGUI():
        if GUI.Button(Rect(btn_x, btn_y, btn_w, btn_h), "Start Server"):
            Debug.Log("Starting Server")

        if GUI.Button(Rect(btn_x, btn_y * 1.2 + btn_h, btn_w, btn_h), "Refresh Hosts"):
            Debug.Log("Refreshing")
