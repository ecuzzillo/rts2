import UnityEngine

class priority_queue(Object):
    public sorted_list as System.Collections.Generic.SortedList[of single, List]

    def constructor():
        sorted_list = System.Collections.Generic.SortedList[of single, List]()

    def insert(priority as single, elem):
        if sorted_list.ContainsKey(priority):
            sorted_list[priority].Add(elem)
        else:
            sorted_list.Add(priority, [elem])

    def remove_head():
        if sorted_list.Count == 0:
            return null
        elif len(sorted_list.Values[0]) > 1:
            Debug.Log("going from len "+len(sorted_list.Values[0])+" to len "+len(sorted_list.Values[0][1:]))
            result = sorted_list.Values[0][0]
            copy = sorted_list.Values[0][1:]
            key = sorted_list.Keys[0]
            sorted_list[key] = copy
            return result
        else:
            result = sorted_list.Values[0][0]
            sorted_list.RemoveAt(0)
            return result


def raycast_on_screen(p as Vector2, 
                      v as Vector2,
                      des_coll as Collider2D):

        ray = Physics2D.Raycast(p, v)
        if ray.collider != des_coll:
            ignore_list = []
            while (ray.collider != des_coll):

                ignore_list.Add(ray.collider.gameObject)
                ray.collider.gameObject.layer = LayerMask.NameToLayer("Ignore Raycast")
                ray = Physics2D.Raycast(p, v)
                

            for i in range(len(ignore_list)):
                obj as GameObject = ignore_list[i]
                obj.layer = LayerMask.NameToLayer("Default")

        return ray.point

class prox(Object):
    public res as int
    public margin as int
    public arr as (int, 2)

    def constructor(res as int, margin as int):
        arr = matrix(int, res, Mathf.Round(Camera.main.aspect*res))
        for i in range(len(arr, 0)):
            for j in range(len(arr, 1)):
                if (i < margin or 
                    i >= res-margin or 
                    j < margin or 
                    j >= len(arr, 1)-margin):
                    arr[i,j] = 1
                else:
                    arr[i,j] = 0
    def node_dist():
        return (get_pt(Vector2(0,0)) - get_pt(Vector2(0,1))).magnitude

    def get_ind(pt as Vector2):
        pt = Camera.main.WorldToScreenPoint(pt)
        pt.x /= Camera.main.pixelWidth
        pt.y /= Camera.main.pixelHeight
        
        ret = Vector2(Mathf.Round(pt.x * (len(arr, 0)-margin) + margin), 
                      Mathf.Round(pt.y * (len(arr, 1)-margin) + margin))

        return ret
    def get_pt(ind as Vector2):
        pt = Vector2(((ind.x - margin) / (len(arr, 0) - margin)) * Camera.main.pixelWidth,
                     ((ind.y - margin) / (len(arr, 1) - margin)) * Camera.main.pixelHeight)
        
        ret = Camera.main.ScreenToWorldPoint(pt)
        ret.z = 0
        return ret

    def inc(pt as Vector2):
        p = get_ind(pt)
        arr[p.x, p.y] += 1
    def at(pt as Vector2):
        p = get_ind(pt)
        return arr[p.x, p.y]

def vis_test(start as Vector2,
             end as Vector2,
             rad as single):
    d = (end-start).magnitude
    
    right_shoulder = Vector3.Cross(end-start, Vector3(0,0,1)).normalized * rad
    
    result = ((Physics2D.Raycast(start + right_shoulder, (end-start).normalized, d).collider == null) and
              (Physics2D.Raycast(start - right_shoulder, (end-start).normalized, d).collider == null))
    #Debug.Log("vis_test returning " + result)
    return result


class path_node(Object):
    public pos as Vector2
    public parent as path_node
    public children as List
    public cost as single
    public valid as bool
    public coll_rad as single
    public costplus as single
    public parent_valid as bool
    public gobj as GameObject

    def constructor(_pos as Vector2, 
                    _parent as path_node,
                    _cost as single,
                    togoal as single,
                    _parent_valid as bool,
                    _coll_rad as single):
        pos = _pos
        parent = _parent
        cost = _cost
        costplus = cost + togoal
        children = []
        valid = true
        coll_rad = _coll_rad
        parent_valid = _parent_valid
        #gobj = Instantiate(Resources.Load("path_node_obj"), 
        #_pos, 
        #Quaternion.identity)

    def check_pt(p as Vector2):
        colls = Physics2D.OverlapCircleAll(p, coll_rad)
        for c in colls:
            if c.gameObject.GetComponent[of mouse_follow]() == null:
                return false

        return vis_test(pos, p, coll_rad)


    def expand(goal as Vector2,
               the_prox as prox) as List:

        dist = the_prox.node_dist()

        if len(children) > 0:
            #Debug.Log("oh no we're already expanded! length is "+len(children))
            return children

        if (goal-pos).magnitude < dist:
            children = [path_node(goal,
                                  self,
                                  cost + (goal-pos).magnitude,
                                  0,
                                  true,
                                  coll_rad)]

        else:
            p = pos + (goal - pos).normalized * dist

            add_if_good(the_prox, p, goal, dist, coll_rad)

            ind = the_prox.get_ind(pos)
            p0 = the_prox.get_pt(Vector2(ind.x+1, ind.y))
            p1 = the_prox.get_pt(Vector2(ind.x-1, ind.y))
            p2 = the_prox.get_pt(Vector2(ind.x, ind.y+1))
            p3 = the_prox.get_pt(Vector2(ind.x, ind.y-1))
            #Debug.Log("pts: "+p+" "+ind+" "+p0+" "+p1+" "+p2+" "+p3)
            add_if_good(the_prox, 
                        p0,
                        goal, 
                        dist, 
                        coll_rad)
            add_if_good(the_prox, 
                        the_prox.get_pt(Vector2(ind.x-1, ind.y)),
                        goal, 
                        dist, 
                        coll_rad)
            add_if_good(the_prox, 
                        the_prox.get_pt(Vector2(ind.x, ind.y+1)),
                        goal, 
                        dist, 
                        coll_rad)
            add_if_good(the_prox, 
                        the_prox.get_pt(Vector2(ind.x, ind.y-1)),
                        goal,
                        dist, 
                        coll_rad)
            
        return children

    def add_if_good(the_prox as prox, 
                    p as Vector2,
                    goal as Vector2,
                    dist as single,
                    coll_rad as single):
        if not(the_prox.at(p)) and check_pt(p):
            children.Add(path_node(p,
                                   self,
                                   cost + dist,
                                   (p-goal).magnitude,
                                   true,
                                   coll_rad))
            the_prox.inc(p)



class path_find(Object): 
    static def plan(start as Vector2, 
                    end as Vector2, 
                    coll_rad as single):

        colls = Physics2D.OverlapCircleAll(end, coll_rad)
        for c in colls:
            if c.gameObject.GetComponent[of mouse_follow]() == null:
                Debug.Log("target unreachable, refusing to plan")
                return null

        prelim_plan = make_plan(start,
                                end,
                                coll_rad)
        if prelim_plan != null:
            #Debug.Log("prelim plan has len "+len(prelim_plan))
            #return prelim_plan
            opt_plan = []
            cur_pt = start
            cur_idx = 0
            for _ in range(10000):
                breakflag = false
                for i in range(len(prelim_plan)-1, cur_idx, -1):
                    
                    if vis_test(cur_pt, prelim_plan[i], coll_rad):
                        opt_plan.Add(prelim_plan[i])
                        cur_pt = prelim_plan[i]
                        cur_idx = i
                        if i == len(prelim_plan)-1:
                            breakflag = true
                        break

                if breakflag: break

            #Debug.Log("len(opt_plan) == " + len(opt_plan))
            if len(opt_plan) == 0:
                return prelim_plan
            else:
                return opt_plan
        else:
            return prelim_plan


        

    static def make_plan(start as Vector2, 
                         end as Vector2, 
                         coll_rad as single):
        pq = priority_queue()

        the_prox = prox(50, 5)

        n = path_node(start,
                      null,
                      0,
                      (start-end).magnitude,
                      false,
                      coll_rad)
        the_prox.inc(n.pos)
        pq.insert((start-end).magnitude,
                  n)


        for i in range(10000):
            #Debug.Log("pq.Count == " + pq.sorted_list.Count)
            #Debug.Log("pq.Keys[0]="+pq.sorted_list.Keys[0])
            n = pq.remove_head()
            #l0_cpy = l.Values[0][:]
            #Debug.Log("l.Keys[0]="+l.Keys[0]+" l.Keys[-1]="+l.Keys[0])
            new_children = n.expand(end, 
                                    the_prox)

            if len(new_children) > 0 and (new_children[0] cast path_node).pos == end:
                # found the goal
                n = new_children[0]
                ret = [n.pos]
                #Debug.Log("n.pos="+n.pos+" n.parent_valid="+n.parent_valid)
                while n.parent_valid:
                    ret.Add(n.pos)
                    n = n.parent
                    #Debug.Log("new parent valid is "+n.parent_valid)

                return List(reversed(ret))

            for j in range(len(new_children)):
                costplus = (new_children[j] cast path_node).costplus
                pq.insert(costplus, new_children[j])

