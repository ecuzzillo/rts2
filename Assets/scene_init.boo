import UnityEngine

class scene_init(MonoBehaviour):
    sel_mgr as selection_manager

    def Start():
        sel_mgr = FindObjectOfType(selection_manager)

        grunt = Instantiate(Resources.Load("grunt"),
                            Vector3(-20, 0, 0),
                            Quaternion.identity)
        sel_mgr.register_owned(grunt)

        gun = Instantiate(Resources.Load("gun"),
                          Vector3(20, 0, 0),
                          Quaternion.identity)
        sel_mgr.register_owned(gun)

    def Update():
        pass
