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
        # Instantiate bullet in direction of enemy
        cooling_down = true
        cooldown_timer = GUN_COOLDOWN
