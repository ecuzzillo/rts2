import UnityEngine

class mesh_utils(Object):
    static def set_black_plane(obj as GameObject):
        mymesh = obj.GetComponent[of MeshFilter]()

        texture = obj.renderer.material.mainTexture cast Texture2D

        pixels = texture.GetPixels()
        for i in range(len(pixels)):
            pixels[i].r = 0
            pixels[i].g = 0
            pixels[i].b = 0
            pixels[i].a = 1
            

        texture.SetPixels(pixels)
        texture.Apply()
        mymesh.mesh = make_plane()

    static def make_plane():
        mesh = Mesh()

        h = 55
        w = 55
        
        vs = array(Vector3, h*w)
        ns = array(Vector3, len(vs))
        uv = array(Vector2, len(vs))
        
        for i in range(h):
            for j in range(w):
                myh = 1.0*h
                myw = 1.0*w
                ind = i*w + j
                y = -(myh/2.0)+i
                #y /= myh
                x = -myw/2.0 + j
                #x /= myw
                vs[ind] = Vector3(x,
                                  -y, 0.0)
                uv[ind] = Vector2(i%2, j%2)
                ns[ind] = Vector3(0,0,-1)

        tries = array(int, (h-1)*(w-1)*6)
        
        for i in range(h-1):
            for j in range(w-1):
                tr_ind= (i*(w-1) + j)*6
                vind = i*w+j
                vind2 = (i+1)*w + j+1
                tries[tr_ind] = vind
                tries[tr_ind+1] = vind2
                tries[tr_ind+2] = vind + 1
                tries[tr_ind+3] = vind
                tries[tr_ind+4] = (i+1)*w + j
                tries[tr_ind+5] = vind2
                
        mesh.vertices = vs
        mesh.uv = uv
        mesh.triangles = tries
        mesh.normals = ns

        return mesh
