import UnityEngine

class bullet(MonoBehaviour):
    public shooter as GameObject
    public velocity as Vector3
    public speed as single
    public owned as bool
    public damage as single

    def constructor():
        owned = false
        velocity = Vector3(0, 0, 0)
        speed = 0.02
        damage = 1

    def FixedUpdate():
        transform.position += velocity

    def OnTriggerEnter2D(other as Collider2D):
        sel_mgr as selection_manager = FindObjectOfType(selection_manager)
        if (other.gameObject != shooter and 
            not other.gameObject.GetInstanceID() in sel_mgr.owned and
            owned):
            unit_attrs = other.gameObject.GetComponent[of grunt_movement]()
            if unit_attrs == null or unit_attrs.damage(damage):
                shooter.GetComponent[of gun_movement]().target_valid = false
            
            Network.Destroy(self.networkView.viewID)
