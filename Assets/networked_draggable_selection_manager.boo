import UnityEngine

#public sm as selection_manager

class networked_draggable_selection_manager(MonoBehaviour): 
    public connector_objs as List
    public max_force as double
    public this_held as bool
    public prev_held as bool
    public prev_closest_info as List
    public prev_selected as draggable_part
    public close_enough as bool
    public selected as List
    public selectednesses as List

    def Start():
        selected = []
        selectednesses = []
        connector_objs = []
        max_force = 4.0
        prev_held = false
        this_held = false

    def make_sprite(name as string):
        bloo = Instantiate(Resources.Load(name),
                           Vector3(0,0,0),
                           Quaternion.identity) cast Texture2D
        blah = Sprite.Create(bloo,
                             Rect(0,0,bloo.width,bloo.height),
                             Vector2(0.5,0.5),
                             100)
        blah.bounds.center.x = 0
        blah.bounds.center.y = 0
        blah.hideFlags = HideFlags.None

        return blah


    def handle_click(obj as draggable_part):
        selected = []
        for s in selectednesses:
            Destroy(s)
        selectednesses = []
        selected.Add(obj)
        the_obj = Instantiate(Resources.Load("selectedness_obj"), 
                              obj.transform.position, 
                              Quaternion.identity)
        (the_obj cast GameObject).GetComponent[of selectedness_obj]().game_object = obj.gameObject
        selectednesses.Add(the_obj)

    def make_core():
        new_obj = (Network.Instantiate(Resources.Load("block_part"),
                              Camera.main.ScreenToWorldPoint(Input.mousePosition),
                              Quaternion.identity, 0) cast GameObject)
        new_obj.transform.position.z = 0

        dp = new_obj.GetComponent[of draggable_part]()
        s = (dp.renderer cast SpriteRenderer).sprite
        Debug.Log("orig sprite has "+s.rect+" "+s.bounds)


        if 1:
            (dp.renderer cast SpriteRenderer).sprite = make_sprite("red-block")
        Debug.Log("setting dp connectors")
        dp.connectors = [[Vector3(0.5,0,0),
                          Vector3(1,0,0)],
                         [Vector3(-0.5,0,0),
                          Vector3(-1, 0, 0)],
                         [Vector3(0,0.5,0),
                          Vector3(0, -1, 0)],
                         [Vector3(0,-0.5,0),
                          Vector3(0, 1, 0)]]
        dp.inited = false
        dp.is_core = true

    def make_block():
        new_obj = (Network.Instantiate(Resources.Load("block_part"),
                                       Camera.main.ScreenToWorldPoint(Input.mousePosition),
                                       Quaternion.identity, 0) cast GameObject)
        new_obj.transform.position.z = 0

    def make_grunt_tree(dp as draggable_part, 
                        sel_mgr as selection_manager) as grunt_movement:
        new_grunt = (Network.Instantiate(Resources.Load("grunt"), 
                                dp.transform.position, 
                                dp.transform.rotation, 0) 
                     cast GameObject).GetComponent[of grunt_movement]()
        (new_grunt.renderer cast SpriteRenderer).sprite = (dp.renderer cast SpriteRenderer).sprite
        new_grunt.is_core = dp.is_core
        sel_mgr.register_owned(new_grunt.gameObject)
        for child as Transform in dp.transform:
            child_grunt = make_grunt_tree(child.gameObject.GetComponent[of draggable_part](),
                                          sel_mgr)
            child_grunt.transform.parent = new_grunt.transform

        Destroy(dp.gameObject)

        return new_grunt

    def Update():
        if Input.GetKeyDown("c"):
            make_core()
        if Input.GetKeyDown("r"):
            make_block()
        if Input.GetKeyDown("g"):
            sel_mgr = (Network.Instantiate(Resources.Load("selection_manager_obj"),
                                   Vector3(0,0,0),
                                   Quaternion.identity, 0) 
                       cast GameObject).GetComponent[of selection_manager]()

            for i in range(len(connector_objs)):
                c = (connector_objs[i] cast draggable_part)

                if c.is_core:
                    Debug.Log("making core grunt tree!")
                    grunt = make_grunt_tree(c, sel_mgr)

            for s in selectednesses:
                Destroy(s)
            Destroy(self)

    def FixedUpdate():
        prev_held = this_held
        this_held = false
        if len(selected) > 0:
            obji = (selected[0] cast draggable_part)
            for j in range(len(obji.connectors)):
                closest_ind = -1
                closest_subind = -1
                closest_dist = -1
                closest_pos = Vector3(0,0,0)
                closest_cntr_ind = -1

                jpos = obji.transform.\
                       TransformPoint((obji.connectors[j] cast List)[0])

                for k in range(len(connector_objs)):
                    objk = (connector_objs[k] cast draggable_part)
                    if objk == obji:
                        continue

                    for l in range(len(objk.connectors)):
                        lpos = objk.transform.\
                               TransformPoint((objk.connectors[l] cast List)[0])
                        d = (lpos - jpos).magnitude
                        if closest_dist == -1 or d < closest_dist:
                            closest_dist = d
                            closest_cntr_ind = j
                            closest_ind = k
                            closest_subind = l
                            closest_pos = lpos

                this_held = true
                    
                if closest_dist < 2 and closest_ind != -1:
                    if closest_dist == 0:
                        force_mag = max_force
                    else:
                        force_mag = Mathf.Min(max_force, 1/closest_dist**2)
                    obji.rigidbody2D.\
                        AddForceAtPosition(force_mag*((closest_pos - jpos).normalized), 
                                           jpos)
                    prev_closest_info = [closest_dist, 
                                         closest_cntr_ind, 
                                         closest_ind, 
                                         closest_subind]
                    close_enough = true
                    break
                else:
                    close_enough = false
                    prev_closest_info = [0, -1, -1, -1]
                    
                    

            prev_selected = obji

        if prev_held and not this_held:
            Debug.Log("Setting position omgomgomg")
            closest_dist = prev_closest_info[0]
            closest_cntr_ind = prev_closest_info[1]
            closest_ind = prev_closest_info[2]
            closest_subind = prev_closest_info[3]

            if closest_ind != -1:

                close_obj = (connector_objs[closest_ind] cast draggable_part)
                our_connector = (prev_selected.connectors[closest_cntr_ind]
                                                  cast List)
                other_connector = (close_obj.connectors[closest_subind] cast List)

                prev_selected.transform.rotation \
                    = (close_obj.transform.rotation * 
                       Quaternion.FromToRotation(-(other_connector[1] cast Vector3),
                                                 (our_connector[1] cast Vector3)))
                prev_selected.transform.position \
                    = (close_obj.transform.TransformPoint(other_connector[0]) 
                       - prev_selected.transform.rotation * (our_connector[0] cast Vector3))

                prev_selected.rigidbody2D.velocity = Vector3(0,0,0)
                prev_selected.rigidbody2D.angularVelocity = 0
                prev_selected.transform.parent = close_obj.transform
                prev_selected.attached = true
                prev_selected.sync_mount()
            

                                                             

