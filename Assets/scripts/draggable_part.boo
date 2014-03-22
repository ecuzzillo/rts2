import UnityEngine
import System.Collections

class draggable_part(MonoBehaviour):
    public mouse_down as bool
    public sel_mgr as networked_draggable_selection_manager
    public connectors as List
    public inited as bool
    public mouse_coll as Collider2D
    public is_core as bool
    public attached as bool
    public grunt_prefab_name as string
    public sprite_name as string

    def constructor():
        grunt_prefab_name = "grunt"
        sprite_name = "arrow-block-corners"
        is_core = false
        attached = false
        connectors = [[Vector3(0.5,0,0),
                       Vector3(1,0,0)],
                      [Vector3(-0.5,0,0),
                       Vector3(-1, 1, 0)]]

    virtual def Start():
        sel_mgr = FindObjectOfType(networked_draggable_selection_manager)
        mouse_down = false
        inited = false
        mouse_coll = FindObjectOfType(mouse_follow).collider2D
        Debug.Log("dp start running")
        sel_mgr.register_owned(self.gameObject)

    def Update():
        if not inited:
            s = (renderer as SpriteRenderer).sprite.bounds.size
            (collider2D cast BoxCollider2D).size = s

            for i in range(len(connectors)):
                (connectors[i] cast List)[0] = ((connectors[i] cast List)[0] cast Vector3) * s.x
            Debug.Log("we have "+len(connectors)+" connectors")
            sel_mgr.connector_objs.Add(self)
            inited = true

        if mouse_down and self in sel_mgr.selected:
            transform.position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            transform.position.z = 0

            if Input.GetKeyDown("right"):
                transform.Rotate(Vector3(0,0,90))
            if Input.GetKeyDown("left"):
                transform.Rotate(Vector3(0,0,-90))

    def FixedUpdate():
        rigidbody2D.AddTorque(-rigidbody2D.angularVelocity/2)
        rigidbody2D.AddForce(-rigidbody2D.velocity*2)

    def OnTriggerStay2D(other as Collider2D):
        if other == mouse_coll:
            if not mouse_down and Input.GetMouseButtonDown(0) and len(sel_mgr.selected) == 0:
                sel_mgr.handle_click(self)
                mouse_down = true

            elif mouse_down and not Input.GetMouseButton(0):
                sel_mgr.selected = []
                mouse_down = false

    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)

    def get_mount_path() as string:
        str as string = ""
        cur as Transform = transform.parent
        while cur != null and cur.parent != null:
            str = cur.name + "/" + str
            cur = cur.parent
        if len(str) > 0 and str[0] == "/":
            return str[1:]
        else:
            return str

    [RPC]
    def link_to_parent(root_id as NetworkViewID,
                       l_pos as Vector3,
                       l_euler as Vector3):
        root_point as Transform = NetworkView.Find(root_id).transform
        StartCoroutine(do_mount(root_point, l_pos, l_euler))

    def do_mount(root_point as Transform,
                 l_pos as Vector3,
                 l_euler as Vector3) as IEnumerator:
        mount_point = root_point.transform
        while mount_point == null:
            yield WaitForSeconds(0.5f)
            mount_point = root_point.transform
        transform.parent = mount_point
        transform.localEulerAngles = l_euler
        transform.localPosition = l_pos

    def sync_mount():
        if networkView.isMine:
            view_id = transform.parent.networkView.viewID
            networkView.RPC("link_to_parent",
                            RPCMode.OthersBuffered,
                            view_id,
                            transform.localPosition,
                            transform.localEulerAngles)

    def set_sprname(sprname as string):
        Debug.Log("running set sprname")
        sprite_name = sprname
        networkView.RPC("on_receive_sprname", RPCMode.Others, sprite_name)

    [RPC]
    def on_receive_sprname(sprname as string):
        Debug.Log("running receive sprname")
        sprite_name = sprname
        o = GameObject.Find("netw_draggable_sel_mgr")
        n = o.GetComponent[of networked_draggable_selection_manager]()
        n.set_sprite(self, n.make_sprite(sprite_name))

    def OnSerializeNetworkView(stream as BitStream, info as NetworkMessageInfo) as void:
        att as bool
        core as bool
        if stream.isWriting:
            att = attached
            core = is_core
            stream.Serialize(att)
            stream.Serialize(core)
        else:
            stream.Serialize(att)
            stream.Serialize(core)
            attached = att
            is_core = core
                
