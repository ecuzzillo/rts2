﻿import UnityEngine

#public sm as selection_manager

class networked_draggable_selection_manager(MonoBehaviour): 
    public owned as Hash
    public selected as List
    public selectednesses as List
    public part_counter as int
    public ready as bool
    public other_ready as bool
    public ground as GameObject
    public texture as Texture2D
    public conns as List

    def constructor():
        owned = {}
        part_counter = 8
        ready = false
        other_ready = false
        conns = []

    def make_plane():
        mesh = Mesh()

        h = 90
        w = 160
        
        vs = array(Vector3, h*w)
        uv = array(Vector2, len(vs))
        
        for i in range(h):
            for j in range(w):
                ind = i*w + j
                vs[ind] = Vector3(i-h/2.0, j-w/2.0, 0.0)
                uv[ind] = Vector2(i*1.0/h, j*1.0/w)

        tries = array(int, (h-1)*(w-1)*6)
        
        for i in range(h-1):
            for j in range(w-1):
                tr_ind= i*(w-1) + j
                vind = i*w+j
                vind2 = (i+1)*w + j+1
                tries[ind] = vind
                tries[ind+1] = vind2
                tries[ind+2] = vind + 1
                tries[ind+3] = vind
                tries[ind+4] = (i+1)*w + j
                tries[ind+5] = vind2

        mesh.vertices = vs
        mesh.uv = uv
        mesh.triangles = tries

        return mesh

    def Start():
        selected = []
        selectednesses = []

        ground = GameObject.Find("Ground")

        mymesh = ground.GetComponent[of MeshFilter]()

        texture = ground.renderer.material.mainTexture cast Texture2D

        pixels = texture.GetPixels()
        for i in range(len(pixels)):
            pixels[i].r = 0
            pixels[i].g = 0
            pixels[i].b = 0
            pixels[i].a = 1
            

        texture.SetPixels(pixels)
        texture.Apply()

        mymesh.mesh = make_plane()


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
            conns.Add(new_obj)
            return new_obj
        else:
            return null

    def set_sprite(dp as MonoBehaviour, s as Sprite):
        (dp.renderer cast SpriteRenderer).sprite = s

    def make_unit():
        new_obj = make_part_at_cursor()
        if new_obj == null:
            return null
        dp = new_obj.GetComponent[of draggable_part]()
        dp.inited = false
        dp.is_core = true
        dp.set_sprname("red-block")
        set_sprite(dp, make_sprite("red-block"))
        return new_obj

    [RPC]
    def set_other_ready(val as bool):
        other_ready = val

    def Update():
        update_fog_of_war()
        if Input.GetKeyDown("g"):
            ready = true
            networkView.RPC("set_other_ready", RPCMode.Others, true)
        if Input.GetKeyDown("c"):
            make_unit()
        if ready and other_ready:
            pass

    def world_space_to_texture_space(position as Vector3):
        bounds = ground.renderer.bounds
        texture_space_x = ((position.x - bounds.min.x) / (bounds.max.x - bounds.min.x)) * 10
        texture_space_y = ((position.y - bounds.min.y) / (bounds.max.y - bounds.min.y)) * 10
        return ((texture_space_x cast int), (texture_space_y cast int))

    def apply_connector_visibility(connector as draggable_part,
                                   vertices as (Vector3), 
                                   pixels as (Color)):
        location = connector.transform.position
        texture_location = world_space_to_texture_space(location)

        for i in range(len(vertices)):
            pixels[i].a = Mathf.Min(pixels[i].a,
                                    1.0 - 1.0 / ((vertices[i].z-location.x)**2.0 + 
                                                 (vertices[i].x+location.y)**2.0 + 1.0))
            
        return pixels
    def update_fog_of_war():
        mymesh = ground.GetComponent[of MeshFilter]()
        c = Color(0,0,0,1.0)
        colors = array(Color, len(mymesh.mesh.colors))
        for i in range(len(mymesh.mesh.colors)):
            colors[i] = c

        for c as GameObject in conns:
            colors = apply_connector_visibility(c.GetComponent[of draggable_part](), 
                                                mymesh.mesh.vertices, 
                                                colors)

        mymesh.mesh.colors = colors
