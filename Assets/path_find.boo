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
            result = sorted_list.Values[0][0]
            sorted_list.Values[0] = sorted_list.Values[0][1:]
            return result
        else:
            result = sorted_list.Values[0][0]
            sorted_list.RemoveAt(0)
            return result



def get_prox_ind(prox as (int, 2), 
                 pt as Vector2):
    pt = Camera.main.WorldToScreenPoint(pt)
    pt.x /= Camera.main.pixelWidth
    pt.y /= Camera.main.pixelHeight
    
    ret = Vector2(Mathf.Round(pt.x * len(prox, 0)), 
                  Mathf.Round(pt.y * len(prox, 1)))

    return ret
def inc_prox(prox as (int, 2),
             pt as Vector2):
    p = get_prox_ind(prox, pt)
    prox[p.x, p.y] += 1
def get_prox(prox as (int, 2),
             pt as Vector2):
    p = get_prox_ind(prox, pt)
    ret = prox[p.x, p.y]
    return ret

class path_node(Object):
    public pos as Vector2
    public parent as path_node
    public children as List
    public cost as single
    public valid as bool
    public coll_rad as single
    public costplus as single
    public parent_valid as bool

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

    def check_pt(p as Vector2):
        colls = Physics2D.OverlapCircleAll(p, coll_rad)
        for c in colls:
            if c.gameObject.GetComponent[of mouse_follow]() == null:
                return false

        return true


    def expand(n_rdm_branch as int, 
               dist as single, 
               goal as Vector2,
               prox as (int, 2)) as List:
        if dist > 100:
            Debug.Log("oh no dist > 100"+dist)
            return []

        if len(children) > 0:
            Debug.Log("oh no we're already expanded! length is "+len(children))
            return children

        if (goal-pos).magnitude < dist:
            children = [path_node(goal,
                                  self,
                                  cost + (goal-pos).magnitude,
                                  0,
                                  true,
                                  coll_rad)]

        else:
            p2 = pos + (goal - pos).normalized * dist

            if not(get_prox(prox, p2)) and check_pt(p2):
                goal_node = path_node(p2,
                                      self,
                                      cost + dist,
                                      (p2 - goal).magnitude,
                                      true,
                                      coll_rad)

                children.Add(goal_node)

            i = 0
            while (i < 15) and (len(children) < n_rdm_branch):
                p = pos + Random.insideUnitCircle.normalized * dist

                if not(get_prox(prox, p)) and check_pt(p):
                    children.Add(path_node(p,
                                           self,
                                           cost + dist,
                                           (p-goal).magnitude,
                                           true,
                                           coll_rad))
                i += 1

        for i in range(len(children)):
            inc_prox(prox, (children[i] cast path_node).pos)


        return children

class path_find(Object): 
    static def plan(start as Vector2, 
                    end as Vector2, 
                    n_rdm_branch as int,
                    exp_dist as single,
                    coll_rad as single):
        prelim_plan = make_plan(start,
                                end,
                                n_rdm_branch,
                                exp_dist,
                                coll_rad)
        if prelim_plan != null:
            Debug.Log("prelim plan has len "+len(prelim_plan))
            #return prelim_plan
            opt_plan = []
            cur_pt = start
            cur_idx = 0
            for _ in range(200):
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

            Debug.Log("len(opt_plan) == " + len(opt_plan))
            if len(opt_plan) == 0:
                return prelim_plan
            else:
                return opt_plan
        else:
            return prelim_plan

    static def vis_test(start as Vector2,
                        end as Vector2,
                        rad as single):
        d = (end-start).magnitude

        right_shoulder = Vector3.Cross(end-start, Vector3(0,0,1)).normalized * rad

        result = ((Physics2D.Raycast(start + right_shoulder, (end-start).normalized, d).collider == null) and
                (Physics2D.Raycast(start - right_shoulder, (end-start).normalized, d).collider == null))
        Debug.Log("vis_test returning " + result)
        return result

        

    static def make_plan(start as Vector2, 
                         end as Vector2, 
                         n_rdm_branch as int,
                         exp_dist as single,
                         coll_rad as single):
        pq = priority_queue()

        res = 50
        prox = matrix(int, res, Mathf.Round(Camera.main.aspect*res))
        for i in range(len(prox, 0)):
            for j in range(len(prox, 1)):
                prox[i,j] = 0
        n = path_node(start,
                      null,
                      0,
                      (start-end).magnitude,
                      false,
                      coll_rad)
        inc_prox(prox, n.pos)
        pq.insert((start-end).magnitude,
                  n)


        for i in range(1000):
            Debug.Log("pq.Count == " + pq.sorted_list.Count)
            Debug.Log("pq.Keys[0]="+pq.sorted_list.Keys[0])
            n = pq.remove_head()
            #l0_cpy = l.Values[0][:]
            #Debug.Log("l.Keys[0]="+l.Keys[0]+" l.Keys[-1]="+l.Keys[0])
            new_children = n.expand(n_rdm_branch,
                                    exp_dist,
                                    end, 
                                    prox)

            if len(new_children) > 0 and (new_children[0] cast path_node).pos == end:
                # found the goal
                n = new_children[0]
                ret = [n.pos]
                Debug.Log("n.pos="+n.pos+" n.parent_valid="+n.parent_valid)
                while n.parent_valid:
                    ret.Add(n.pos)
                    n = n.parent
                    Debug.Log("new parent valid is "+n.parent_valid)

                return List(reversed(ret))

            for j in range(len(new_children)):
                costplus = (new_children[j] cast path_node).costplus
                pq.insert(costplus, new_children[j])

