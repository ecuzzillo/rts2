import UnityEngine
import System.Collections

class network_manager_script(MonoBehaviour):
    public game_name as string
    public btn_x as double
    public btn_y as double
    public btn_w as double
    public btn_h as double

    public refreshing as bool
    public host_data as (HostData)

    def Start():
        game_name = "MY_UNIQUE_RTS_GAME_NAME"
        btn_x = Screen.width * 0.05
        btn_y = Screen.width * 0.05
        btn_w = Screen.width * 0.1
        btn_h = Screen.width * 0.1
        refreshing = false

    def start_server():
        Network.InitializeServer(32, 25001, (not Network.HavePublicAddress()))
        MasterServer.RegisterHost(game_name, "RTS Game", "whateva")
        pos as Vector3
        pos.x = -2
        pos.y = 0
        pos.z = 0
        obj = Network.Instantiate(Resources.Load("grunt"), pos, Quaternion.identity, 0)
        Debug.Log(obj.GetInstanceID())
        sel_mgr as selection_manager = FindObjectOfType(selection_manager)
        sel_mgr.register_owned(obj)

    def refresh_host_list():
        MasterServer.RequestHostList(game_name)
        refreshing = true
        #Debug.Log(MasterServer.PollHostList().Length)

    def OnGUI():
        if not Network.isClient and not Network.isServer:
            if GUI.Button(Rect(btn_x, btn_y, btn_w, btn_h), "Start Server"):
                Debug.Log("Starting Server")
                start_server()

            if GUI.Button(Rect(btn_x, btn_y * 1.2 + btn_h, btn_w, btn_h), "Refresh Hosts"):
                Debug.Log("Refreshing")
                refresh_host_list()

            if host_data:
                for i in range(0, host_data.Length):
                    if GUI.Button(Rect(btn_x*2 + btn_w, btn_y*1.2 + btn_h*i, btn_w*3, btn_h), host_data[i].gameName):
                        Network.Connect(host_data[i])
                        StartCoroutine("create_grunt")

    def create_grunt() as IEnumerator:
        yield WaitForSeconds(1)
        pos as Vector3
        pos.x = 2
        pos.y = 0
        pos.z = 0
        obj = Network.Instantiate(Resources.Load("grunt"), pos, Quaternion.identity, 0)
        sel_mgr as selection_manager = FindObjectOfType(selection_manager)
        sel_mgr.register_owned(obj)


    def OnMasterServerEvent(mse as MasterServerEvent):
        if mse == MasterServerEvent.RegistrationSucceeded:
            Debug.Log("Registration Succeeded")

    def Update():
        if refreshing and MasterServer.PollHostList().Length != 0:
            refreshing = false
            Debug.Log(MasterServer.PollHostList().Length)
            host_data = MasterServer.PollHostList()
