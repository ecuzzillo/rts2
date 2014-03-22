import UnityEngine

class bullet(MonoBehaviour):
    public shooter as GameObject
    public velocity as Vector3
    public speed as single
    public static BULLET_DAMAGE = 1

    def constructor():
        velocity = Vector3(0, 0, 0)
        speed = 3
        bullet_damage = 1

    def FixedUpdate():
        transform.position += velocity

    def OnTriggerEnter2D(other as Collider2D):
        sel_mgr as selection_manager = FindObjectOfType(selection_manager)
        if other.gameObject != shooter and not other.gameObject.GetInstanceID() in sel_mgr.owned:
            unit_attrs = other.gameObject.GetComponent[of grunt_movement]()
            Debug.Log("foo: " + other.gameObject)
            Debug.Log("bar: " + other.gameObject.GetComponent[of grunt_movement]())
            unit_attrs.damage(BULLET_DAMAGE)
            Network.Destroy(self.networkView.viewID)
