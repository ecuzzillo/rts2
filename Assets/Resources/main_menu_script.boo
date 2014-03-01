import UnityEngine
import System.Collections

class main_menu_script(MonoBehaviour):
    public btn_x as double
    public btn_y as double
    public btn_w as double
    public btn_h as double
    public netw_mgr as network_manager_script

    def Start():
        btn_x = Screen.width * 0.05
        btn_y = Screen.width * 0.05
        btn_w = Screen.width * 0.1
        btn_h = Screen.width * 0.1
        netw_mgr = FindObjectOfType(network_manager_script)

    def Update():
        pass

    def OnGUI():
        main_menu()

    def main_menu():
        if not Network.isClient and not Network.isServer:
            if GUI.Button(Rect(btn_x,
                               btn_y, 
                               btn_w, 
                               btn_h), 
                          "Start Server"):
                Debug.Log("Starting Server")
                netw_mgr.start_server()
                StartCoroutine(create_grunt(6, 0, 0))

            if GUI.Button(Rect(btn_x, 
                               btn_y * 1.2 + btn_h, 
                               btn_w, 
                               btn_h), 
                          "Refresh Hosts"):
                Debug.Log("Refreshing")
                netw_mgr.refresh_host_list()

            if netw_mgr.host_data:
                for i in range(0, netw_mgr.host_data.Length):
                    if GUI.Button(Rect(btn_x*2 + btn_w, 
                                       btn_y*1.2 + btn_h*i, 
                                       btn_w*3, 
                                       btn_h), 
                                  netw_mgr.host_data[i].gameName):
                        Network.Connect(netw_mgr.host_data[i])
                        StartCoroutine(create_grunt(-6, 0, 0))

    def create_grunt(x, y, z) as IEnumerator:
        yield WaitForSeconds(1)
        pos = Vector3(x, y, z)
        obj = Network.Instantiate(Resources.Load("grunt"), pos, Quaternion.identity, 0)
        sel_mgr as selection_manager = FindObjectOfType(selection_manager)
        sel_mgr.register_owned(obj)
