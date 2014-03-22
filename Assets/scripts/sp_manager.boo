import UnityEngine

class sp_manager(MonoBehaviour): 
    sel_mgr as selection_manager
    player_grunts as List
    npc_grunts as List
    def Start():
        sel_mgr = FindObjectOfType(selection_manager)
        player_grunts = []
        npc_grunts = []

        for i in range(5):
            player_grunts.Add(Instantiate(Resources.Load("grunt"), 
                                          Vector3(i*15-40, -8, 0), 
                                          Quaternion.identity))
            sel_mgr.register_owned(player_grunts[i])
            npc_grunts.Add(Instantiate(Resources.Load("grunt"), 
                                          Vector3(i*15-40, 8, 0), 
                                          Quaternion.identity))
            
                              
    def Update():
        pass
