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
        if other.gameObject != shooter:
            unit_attrs = other.gameObject.GetComponent[of grunt_movement]()
            unit_attrs.damage(BULLET_DAMAGE)
            Destroy(self.gameObject)
