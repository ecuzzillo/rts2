import UnityEngine

class gun_movement(grunt_movement):
    public cooling_down as bool
    public cooldown_timer as int
    public gun_target as GameObject
    public static GUN_COOLDOWN = 120

    def constructor():
        cooling_down = false
        cooldown_timer = 0
        gun_target = null

    override def FixedUpdate():
        super.FixedUpdate()
        if cooling_down:
            cooldown_timer -= 1
            if cooldown_timer == 0:
                cooling_down = false
        elif gun_target:
            fire()

    def fire():
        my_bullet = Instantiate(Resources.Load("bullet"),
                             transform.position,
                             Quaternion.identity) as GameObject
        bullet_attrs = my_bullet.GetComponent[of bullet]()
        bullet_attrs.velocity = (gun_target.transform.position - transform.position).normalized * bullet_attrs.speed
        bullet_attrs.shooter = gameObject
        cooling_down = true
        cooldown_timer = GUN_COOLDOWN
