import UnityEngine

class grunt_movement(MonoBehaviour): 
    public vel as Vector3
    public target as Vector3
    public the_doonk as GameObject
    public sel_mgr as selection_manager
    public mouse_coll as Collider2D
    public is_core as bool
    public health as int
    public max_health as int

    def constructor():
        is_core = true
        max_health = 5
        health = max_health

    def Start():
        the_doonk = GameObject("garbage")
        sel_mgr = FindObjectOfType(selection_manager)
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

    virtual def FixedUpdate():
        if is_core:
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

    def damage(damage_amt as int):
        update_health(-1 * damage_amt)

    def update_health(amt as int):
        health += amt
        if health > max_health:
            health = max_health
        elif health <= 0:
            die()

    def die():
        Destroy(self.gameObject)
