import UnityEngine

class network_manager_script(MonoBehaviour):
    public game_name as string
    public refreshing as bool
    public host_data as (HostData)

    def Start():
        game_name = "MY_UNIQUE_RTS_GAME_NAME"
        refreshing = false

    def start_server():
        Network.InitializeServer(32, 25001, (not Network.HavePublicAddress()))
        MasterServer.RegisterHost(game_name, "RTS Game", "whateva")

    def refresh_host_list():
        MasterServer.RequestHostList(game_name)
        refreshing = true

    def OnMasterServerEvent(mse as MasterServerEvent):
        if mse == MasterServerEvent.RegistrationSucceeded:
            Debug.Log("Registration Succeeded")

    def Update():
        if refreshing and MasterServer.PollHostList().Length != 0:
            refreshing = false
            host_data = MasterServer.PollHostList()
