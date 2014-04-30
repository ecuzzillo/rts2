import UnityEngine

class grunt_movement(MonoBehaviour): 
    public vel as Vector3
    public target as Vector3
    public the_doonk as GameObject
    public sel_mgr as networked_draggable_selection_manager
    public mouse_coll as Collider2D
    public mouse_down as bool
    public is_core as bool
    public health as int
    public max_health as int
    public sprite_name as string
    public path as List
    public inited as bool

    def constructor():
        sprite_name = "arrow-block-corners"
        mouse_down = false
        is_core = true
        max_health = 5
        health = max_health

    def Start():
        the_doonk = GameObject("garbage")
        sel_mgr = FindObjectOfType(networked_draggable_selection_manager)
        mouse_coll = FindObjectOfType(mouse_follow).collider2D
        target = transform.position

    def get_parent() as grunt_movement:
        if transform.parent == null:
            return self
        else:
            return transform.parent.gameObject.GetComponent[of grunt_movement]().get_parent()

    def OnSerializeNetworkView(stream as BitStream, info as NetworkMessageInfo) as void:
        targ as Vector3
        if stream.isWriting:
            targ = target
            stream.Serialize(targ)
        else:
            stream.Serialize(targ)
            target = targ

    def OnTriggerStay2D(other as Collider2D):
        if other == mouse_coll:
            if not mouse_down and Input.GetMouseButtonDown(0) and len(sel_mgr.selected) == 0:
                sel_mgr.handle_click(self)
                mouse_down = true

    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)

    virtual def FixedUpdate():
        pass

    def Update():
        #Debug.Log("FixedUpdate")
        if mouse_down and not Input.GetMouseButton(0):
            sel_mgr.selected = []
            mouse_down = false


        if is_core:
            diff = target - transform.position
            mag = diff.magnitude
            size_ish = (renderer as SpriteRenderer).sprite.bounds.size.x
            if mag < size_ish and the_doonk.name.IndexOf("doonk") != -1:
                Destroy(the_doonk)
                the_doonk = GameObject("garbage")

            d = (transform.position - target).magnitude
            if path == null and d > 0.5:
                path = path_find.plan(transform.position, 
                                      target, 
                                      3, 
                                      3,
                                      2)

            if path != null:
                
                if ((path[0] cast Vector2) - transform.position).magnitude < 0.01:
                   path = path[1:] 
                if len(path) == 0:
                    path = null
                else:
                    diff = (path[0] cast Vector2) - transform.position
                    mag = diff.magnitude

                    mul = (Mathf.Atan(mag)/mag if Mathf.Abs(mag) > 0.001 else 0)
                    vel = diff*mul

                    transform.position += vel
                    transform.position.z = 0

            else:
                target = transform.position
                    

    def set_sprname(sprname as string):
        sprite_name = sprname
        networkView.RPC("on_receive_sprname", RPCMode.Others, sprite_name)

    [RPC]
    def on_receive_sprname(sprname as string):
        sprite_name = sprname
        o = GameObject.FindObjectOfType(networked_draggable_selection_manager)
        if o == null:
            p = GameObject.FindObjectOfType(selection_manager)
            m = p.GetComponent[of selection_manager]()
            set_sprite(self, make_sprite(sprite_name))
        else:
            n = o.GetComponent[of networked_draggable_selection_manager]()
            n.set_sprite(self, n.make_sprite(sprite_name))

    def set_sprite(dp as MonoBehaviour,
                   s as Sprite):
        (dp.renderer cast SpriteRenderer).sprite = s

    def make_sprite(name as string):
        bloo = Instantiate(Resources.Load(name),
                           Vector3(0,0,0),
                           Quaternion.identity) cast Texture2D
        blah = Sprite.Create(bloo,
                             Rect(0,0,bloo.width,bloo.height),
                             Vector2(0.5,0.5),
                             100)
        blah.bounds.center.x = 0
        blah.bounds.center.y = 0
        blah.hideFlags = HideFlags.None

        return blah

    def damage(damage_amt as int) as bool:
        ret = update_health(-1 * damage_amt)
        networkView.RPC("RPC_damage", RPCMode.Others, damage_amt)
        return ret

    [RPC]
    def RPC_damage(damage_amt as int):
        update_health(-1 * damage_amt)

    def update_health(amt as int) as bool:
        health += amt
        if health > max_health:
            health = max_health
        elif health <= 0:
            die()
            return true
        return false

    def die():
        #if self.gameObject.GetInstanceID() in sel_mgr.owned:
        #    sel_mgr.owned.Remove(self.gameObject.GetInstanceID())
        Destroy(self.gameObject)

    def select_guns():
        return gameObject.GetComponentsInChildren(gun_movement, true)

    def target_guns(obj as GameObject):
        guns as (Component) = select_guns()
        for gun as gun_movement in guns:
            gun.gun_target = obj.networkView.viewID
            gun.target_valid = true

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
        transform.gameObject.GetComponent[of grunt_movement]().is_core = false
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

