import UnityEngine
import System.Collections

class network_manager_script(MonoBehaviour):
    public game_name as string
    public btn_x as double
    public btn_y as double
    public btn_w as double
    public btn_h as double

    def Start():
        game_name = "MY_UNIQUE_RTS_GAME_NAME"
        btn_x = Screen.width * 0.05
        btn_y = Screen.width * 0.05
        btn_w = Screen.width * 0.1
        btn_h = Screen.width * 0.1

    def start_server():
        Network.InitializeServer(32, 25001, (not Network.HavePublicAddress()))
        MasterServer.RegisterHost(game_name, "RTS Game", "whateva")

    def refresh_host_list() as IEnumerator:
        MasterServer.RequestHostList(game_name)
        yield WaitForSeconds(3)
        Debug.Log(MasterServer.PollHostList().Length)

    def OnGUI():
        if GUI.Button(Rect(btn_x, btn_y, btn_w, btn_h), "Start Server"):
            Debug.Log("Starting Server")
            start_server()

        if GUI.Button(Rect(btn_x, btn_y * 1.2 + btn_h, btn_w, btn_h), "Refresh Hosts"):
            Debug.Log("Refreshing")
            StartCoroutine(refresh_host_list())

    def OnMasterServerEvent(mse as MasterServerEvent):
        if mse == MasterServerEvent.RegistrationSucceeded:
            Debug.Log("Registration Succeeded")
