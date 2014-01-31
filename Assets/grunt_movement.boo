import UnityEngine

class grunt_movement(MonoBehaviour): 
    public vel as Vector3
    public target as Vector3
    public the_doonk as GameObject
    public is_selected as bool

    def Start():
        target = transform.position
        the_doonk = GameObject("garbage")

    def Update():
        pass

    def FixedUpdate():
        Debug.Log(transform.position)
        if Input.GetButtonDown("Fire1"):
            target = Camera.main.ScreenToWorldPoint(Input.mousePosition)

            Destroy(the_doonk)
            target.z = 0
            the_doonk = Instantiate(Resources.Load("block_obj"), target, Quaternion.identity)

        diff = target - transform.position

        mag = diff.magnitude

        mul = (Mathf.Atan(mag)/mag if Mathf.Abs(mag) > 0.001 else 0)

        vel = diff*mul

        transform.position += vel
        transform.position.z = 0

    def OnTriggerStay2D(other as Collider2D):
        if Input.GetButtonDown("Fire1"):
            sel_mgr as selection_manager = FindObjectOfType(selection_manager)
            sel_mgr.HandleObjectClick(self)

    def OnTriggerEnter2D(other as Collider2D):
        Debug.Log("Trigger enter")
        OnTriggerStay2D(other)
