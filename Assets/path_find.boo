import UnityEngine

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


    def expand(n_rdm_branch as int, dist as single, goal as Vector2) as List:
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

            if check_pt(p2):
                goal_node = path_node(p2,
                                      self,
                                      cost + dist,
                                      (p2 - goal).magnitude,
                                      true,
                                      coll_rad)

                children.Add(goal_node)

            i = 0
            while len(children) < n_rdm_branch:
                p = pos + Random.insideUnitCircle.normalized * dist

                if check_pt(p):
                    children.Add(path_node(p,
                                           self,
                                           cost + dist,
                                           (p-goal).magnitude,
                                           true,
                                           coll_rad))
                i += 1
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

            opt_plan = []
            cur_pt = start
            cur_idx = 0
            for _ in range(20):
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

        result = ((Physics2D.Raycast(start + right_shoulder, (end-start.normalized), d).collider == null) and
                (Physics2D.Raycast(start - right_shoulder, (end-start.normalized), d).collider == null))
        Debug.Log("vis_test returning " + result)
        return result

    static def make_plan(start as Vector2, 
                         end as Vector2, 
                         n_rdm_branch as int,
                         exp_dist as single,
                         coll_rad as single):
        # l is a list of nodes to expand
        l = System.Collections.Generic.SortedList[of single, List]()
        n = path_node(start,
                      null,
                      0,
                      (start-end).magnitude,
                      false,
                      coll_rad)
        l.Add((start-end).magnitude,
              [n])

        for i in range(1000):
            Debug.Log("l.Count == " + l.Count)
            n = l.Values[0][0]
            #l0_cpy = l.Values[0][:]
            #Debug.Log("l.Keys[0]="+l.Keys[0]+" l.Keys[-1]="+l.Keys[0])
            new_children = n.expand(n_rdm_branch,
                                    exp_dist,
                                    end)
            if len(new_children) == 0:
                Debug.Log("OOOOOOOOHHHHHH")
            if len(l.Values[0]) > 1:
                l[l.Keys[0]] = l.Values[0][1:]

            else:
                l.RemoveAt(0)

            if len(new_children) > 0 and new_children[0] == end:
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
                if l.ContainsKey(costplus):
                    l[costplus].Add(new_children[j])
                else:
                    l.Add(costplus,
                          [new_children[j]])

