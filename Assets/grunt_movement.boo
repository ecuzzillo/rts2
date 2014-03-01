import UnityEngine

class grunt_movement(MonoBehaviour): 
    public vel as Vector3
    public target as Vector3
    public the_doonk as GameObject
    public sel_mgr as selection_manager
    public mouse_coll as Collider2D

    def OnSerializeNetworkView(stream as BitStream, info as NetworkMessageInfo) as void:
        targ as Vector3
        if stream.isWriting:
            targ = target
            stream.Serialize(targ)
        else:
            stream.Serialize(targ)
            target = targ

    def Start():
        target = transform.position
        the_doonk = GameObject("garbage")
        sel_mgr = FindObjectOfType(selection_manager)
        mouse_coll = FindObjectOfType(mouse_follow).collider2D

    def Update():
        if Input.GetMouseButton(1) and gameObject in sel_mgr.selected:
            target = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            Destroy(the_doonk)

            target.z = 0
            the_doonk = Instantiate(Resources.Load("doonk"), target, Quaternion.identity)

    virtual def FixedUpdate():
        diff = target - transform.position
        mag = diff.magnitude
        size_ish = (renderer as SpriteRenderer).sprite.bounds.size.x

        if mag < size_ish and the_doonk.name.IndexOf("doonk") != -1:
            Destroy(the_doonk)
            the_doonk = GameObject("garbage")

        mul = (Mathf.Atan(mag)/mag if Mathf.Abs(mag) > 0.001 else 0)
        vel = diff*mul

        transform.position += vel
        transform.position.z = 0

    def OnTriggerStay2D(other as Collider2D):
        if Input.GetMouseButtonDown(0) and other == mouse_coll:
            Debug.Log("calling handle click from grunt")
            sel_mgr.handle_click(gameObject)

    def OnTriggerEnter2D(other as Collider2D):
        OnTriggerStay2D(other)
