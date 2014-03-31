import UnityEngine

#public sm as selection_manager

class networked_draggable_selection_manager(MonoBehaviour): 
    public connector_objs as List
    public max_force as double
    public this_held as bool
    public owned as Hash
    public prev_held as bool
    public prev_closest_info as List
    public prev_selected as draggable_part
    public close_enough as bool
    public selected as List
    public selectednesses as List
    public part_counter as int
    public ready as bool
    public other_ready as bool
    public ground as GameObject
    public texture as Texture2D

    def constructor():
        owned = {}
        part_counter = 8
        ready = false
        other_ready = false
        prev_closest_info = []

    def Start():
        selected = []
        selectednesses = []
        connector_objs = []
        max_force = 4.0
        prev_held = false
        this_held = false
        ground = GameObject.Find("Ground")
        texture = ground.renderer.material.mainTexture cast Texture2D

    def register_owned(obj as Object):
        owned[obj.GetInstanceID()] = true

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

    def make_part_at_cursor() as GameObject:
        if part_counter > 0:
            new_obj = (Network.Instantiate(Resources.Load("block_part"),
                                           Camera.main.ScreenToWorldPoint(Input.mousePosition),
                                           Quaternion.identity, 0) cast GameObject)
            new_obj.transform.position.z = 0
            register_owned(new_obj)
            part_counter -= 1
            return new_obj
        else:
            return null

    def set_sprite(dp as MonoBehaviour, 
                   s as Sprite):
        (dp.renderer cast SpriteRenderer).sprite = s

    def make_core():
        new_obj = make_part_at_cursor()
        if new_obj == null:
            return null
        dp = new_obj.GetComponent[of draggable_part]()
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
        dp.set_sprname("red-block")
        set_sprite(dp, make_sprite("red-block"))
        return new_obj


    def make_gun():
        new_obj = make_part_at_cursor()
        if new_obj == null:
            return null

        dp = new_obj.GetComponent[of draggable_part]()
        dp.set_sprname("gun")
        set_sprite(dp, make_sprite("gun"))
        dp.connectors = [[Vector3(0,-1,0),
                          Vector3(0,1,0)]]
        dp.inited = false
        dp.is_core = false
        dp.grunt_prefab_name = "gun_obj"
        return new_obj

    def make_grunt_tree(dp as draggable_part, 
                        sel_mgr as selection_manager) as grunt_movement:
        new_grunt = (Network.Instantiate(Resources.Load(dp.grunt_prefab_name), 
                                dp.transform.position, 
                                dp.transform.rotation, 0) 
                     cast GameObject).GetComponent[of grunt_movement]()
        new_grunt.is_core = dp.is_core
        sel_mgr.register_owned(new_grunt.gameObject)
        (new_grunt.renderer cast SpriteRenderer).sprite = (dp.renderer cast SpriteRenderer).sprite
        new_grunt.set_sprname(dp.sprite_name)
        for child as Transform in dp.transform:
            child_grunt = make_grunt_tree(child.gameObject.GetComponent[of draggable_part](),
                                          sel_mgr)
            child_grunt.transform.parent = new_grunt.transform
            child_grunt.sync_mount()

        Network.Destroy(dp.networkView.viewID)

        return new_grunt
        
    [RPC]
    def set_other_ready(val as bool):
        other_ready = val

    def Update():
        draw_shit()
        if Input.GetKeyDown("c"):
            make_core()
        if Input.GetKeyDown("r"):
            make_part_at_cursor()
        if Input.GetKeyDown("u"):
            make_gun()
        if Input.GetKeyDown("g"):
            ready = true
            networkView.RPC("set_other_ready", RPCMode.Others, true)
        if ready and other_ready:
            sel_mgr = (Instantiate(Resources.Load("selection_manager_obj"),
                                   Vector3(0,0,0),
                                   Quaternion.identity)
                       cast GameObject).GetComponent[of selection_manager]()

            for i in range(len(connector_objs)):
                c = (connector_objs[i] cast draggable_part)

                if c != null and c.gameObject.GetInstanceID() in owned:
                    if c.is_core:
                        grunt = make_grunt_tree(c, sel_mgr)

            for s in selectednesses:
                Destroy(s)
            Destroy(self)

    def world_space_to_texture_space(position as Vector3):
        bounds = ground.renderer.bounds
        texture_space_x = ((position.x - bounds.min.x) / (bounds.max.x - bounds.min.x)) * texture.width
        texture_space_y = ((position.y - bounds.min.y) / (bounds.max.y - bounds.min.y)) * texture.height
        return ((texture_space_x cast int), (texture_space_y cast int))

    def apply_connector_visibility(connector as draggable_part, pixels as (Color)):
        location = connector.transform.position
        texture_location = world_space_to_texture_space(location)
        for i in range(texture.height):
            for j in range(texture.width):
                index = i * texture.width + j
                pixels[index].a = Mathf.Min(pixels[index].a, 1 - 1.0 / ((i-(texture_location[1]))**2 + (j-(texture_location[0]))**2 + 1) ** 0.4)

    def draw_shit():
        pixels = texture.GetPixels()
        texture_space_origin = Vector3(texture.width / 2.0,
                                       texture.height / 2.0,
                                       0)

        for i in range(len(pixels)):
            pixels[i].r = 0
            pixels[i].g = 0
            pixels[i].b = 0
            pixels[i].a = 1
        for connector as draggable_part in connector_objs:
            apply_connector_visibility(connector, pixels)
        texture.SetPixels(pixels)
        texture.Apply()

    def FixedUpdate():
        prev_held = this_held
        this_held = false

        if len(selected) > 0:
            obji = (selected[0] cast draggable_part)
            closest_ind = -1
            closest_subind = -1
            closest_dist = -1
            closest_pos = Vector3(0,0,0)
            closest_cntr_ind = -1

            for j in range(len(obji.connectors)):

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
                    if 0:
                        obji.rigidbody2D.\
                            AddForceAtPosition(force_mag*((closest_pos - jpos).normalized), 
                                               jpos)
                    prev_closest_info = [closest_dist, 
                                         closest_cntr_ind, 
                                         closest_ind, 
                                         closest_subind]
                    close_enough = true
                else:
                    close_enough = false
                    prev_closest_info = [-1, -1, -1, -1]
                    
                    

            prev_selected = obji

        if len(prev_closest_info) > 0:
            closest_dist = prev_closest_info[0]
            closest_cntr_ind = prev_closest_info[1]
            closest_ind = prev_closest_info[2]
            closest_subind = prev_closest_info[3]

            if closest_ind != -1:

                close_obj = (connector_objs[closest_ind] cast draggable_part)
                if not close_obj.transform.parent == prev_selected.transform:
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
                    if prev_held and not this_held:
                        Debug.Log("attaching!")
                        prev_selected.transform.parent = close_obj.transform
                        prev_selected.attached = true
                        prev_selected.sync_mount()

