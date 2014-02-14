﻿import UnityEngine

class grunt_movement(MonoBehaviour): 
    public vel as Vector3
    public target as Vector3
    public the_doonk as GameObject
    public sel_mgr as selection_manager

    def Start():
        target = transform.position
        the_doonk = GameObject("garbage")
        sel_mgr = FindObjectOfType(selection_manager)

    def Update():
        if Input.GetMouseButtonDown(1) and self in sel_mgr.selected:
            target = Camera.main.ScreenToWorldPoint(Input.mousePosition)
            Debug.Log("before destruction, the_doonk's name was"+the_doonk.name)
            Destroy(the_doonk)

            target.z = 0
            the_doonk = Instantiate(Resources.Load("doonk"), target, Quaternion.identity)
            Debug.Log("after instantiation, the_doonk's name was"+the_doonk.name)


    def FixedUpdate():

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
        if Input.GetMouseButtonDown(0):
            sel_mgr as selection_manager = FindObjectOfType(selection_manager)
            sel_mgr.handle_click(self)

    def OnTriggerEnter2D(other as Collider2D):
        Debug.Log("Trigger enter")
        OnTriggerStay2D(other)
