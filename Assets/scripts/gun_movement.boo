import UnityEngine

class gun_movement(grunt_movement):
    public cooling_down as bool
    public cooldown_timer as int
    public gun_target as NetworkViewID
    public target_valid as bool
    public static GUN_COOLDOWN = 60

    def constructor():
        cooling_down = false
        cooldown_timer = 0
        target_valid = false

    override def FixedUpdate():
        super.FixedUpdate()
        if cooling_down:
            cooldown_timer -= 1
            if cooldown_timer == 0:
                cooling_down = false
        elif target_valid:
            my_network_view = NetworkView.Find(gun_target)
            fire(my_network_view)

    def fire(my_network_view as NetworkView):
        if my_network_view != null:
            my_bullet = Network.Instantiate(Resources.Load("bullet"),
                                            transform.position,
                                            Quaternion.identity, 
                                            0) as GameObject
            bullet_attrs = my_bullet.GetComponent[of bullet]()
            bullet_attrs.owned = true
            normed_vel = (my_network_view.gameObject.transform.position - 
                          transform.position).normalized
            Debug.Log("bullet attrs speed: "+bullet_attrs.speed)
            bullet_attrs.velocity = normed_vel * bullet_attrs.speed
            bullet_attrs.damage = (transform.position - 
                                   get_parent().transform.position).magnitude / 2
            my_bullet.transform.localScale *= bullet_attrs.damage
            my_bullet.transform.eulerAngles.z = Mathf.Atan2(-normed_vel.y, 
                                                            -normed_vel.x) * Mathf.Rad2Deg
            bullet_attrs.shooter = gameObject
            cooling_down = true
            cooldown_timer = GUN_COOLDOWN
            
            GameObject.Find("audio_source").GetComponent[of AudioSource]().Play()
