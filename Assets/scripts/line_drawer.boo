import UnityEngine

def mod(x as int, y as int):
    if x < 0:
        while x < 0:
            x += y
        return x
    else:
        return x%y

class line_drawer(Component):
    def draw_line(meshf as MeshFilter, 
                  pts as List,
                  lw as single,
                  closed as bool):
        verts = array(Vector3, len(pts)*2)

        for i in range(len(pts)):
            p = (pts[i] cast Vector3)

            if closed or i < len(pts)-1:
                next_line_vec = (p - (pts[(i+1)%len(pts)] cast Vector3)).normalized            
            if closed or i > 0:
                prev_line_vec = (p - (pts[(i-1)%len(pts)] cast Vector3)).normalized

            if not closed and i == 0:
                prev_line_vec = next_line_vec
            if not closed and i == len(pts)-1:
                next_line_vec = prev_line_vec

            extra_vec = (prev_line_vec + next_line_vec).normalized

            verts[i*2] = p + extra_vec*lw/2
            verts[i*2 + 1] = p - extra_vec*lw/2

        tries = array(int, len(pts)*6)
        for i in range(len(pts)):
            tries[i*6] = mod((i*2), len(verts))
            tries[i*6+1] = mod((i*2+1), len(verts))
            tries[i*6+2] = mod((i*2+2), len(verts))

            tries[i*6+3] = mod((i*2), len(verts))
            tries[i*6+4] = mod((i*2-2), len(verts))
            tries[i*6+5] = mod((i*2+1), len(verts))

        if 0:
            for i in range(len(tries)):

        uv = array(Vector2, len(pts)*2)
        for i in range(len(pts)*2):
            uv[i] = Vector2(i%2, i%2)

        mesh = Mesh()
        meshf.mesh = mesh
        mesh.vertices = verts
        mesh.uv = uv
        mesh.triangles = tries
