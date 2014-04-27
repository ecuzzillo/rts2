import UnityEngine

class path_node(Object):
    public pos as Vector2
    public parent as path_node
    public children as (path_node)
    public cost as single
    public valid as bool
    public coll_rad as single
    public costplus as single
    public parent_valid as bool

    def constructor(_pos as Vector2, 
                    _parent as path_node,
                    _cost as single,
                    togoal as single,
                    _parent_valid as bool):
        pos = _pos
        parent = _parent
        cost = _cost
        costplus = cost + togoal
        children = array(path_node, 0)
        valid = true
        coll_rad = 1
        parent_valid = _parent_valid

    def check_pt(p as Vector2):
        colls = Physics2D.OverlapCircleAll(p, coll_rad)
        for c in colls:
            if c.gameObject.GetComponent[of mouse_follow]() == null:
                return false

        return true


    def expand(n_rdm_branch as int, dist as single, goal as Vector2):
        if dist > 100:
            Debug.Log("oh no dist > 100"+dist)
            return array(path_node, 0)

        if len(children) > 0:
            Debug.Log("oh no we're already expanded! length is "+len(children))
            return children

        if (goal-pos).magnitude < dist:
            children = (path_node(goal, 
                                  self, 
                                  cost + (goal-pos).magnitude,
                                  0,
                                  true),)

        else:
            p2 = pos + (goal - pos).normalized * dist
            

            if check_pt(p2):
                goal_node = path_node(p2,
                                      self,
                                      cost + dist,
                                      (p2 - goal).magnitude,
                                      true)

                children = array(path_node, n_rdm_branch+1)
                children[n_rdm_branch] = goal_node
            else:
                children = array(path_node, n_rdm_branch)



            i = 0
            while i < n_rdm_branch:
                p = pos + Random.insideUnitCircle.normalized * dist

                if check_pt(p):
                    children[i] = path_node(p,
                                            self,
                                            cost + dist,
                                            (p-goal).magnitude,
                                            true)
                else:
                    node = path_node(Vector2(0, 0), self, 0.0, goal.magnitude, true)
                    node.valid = false
                    children[i] = node
                i += 1
        return children

class path_find(Object): 
    static def plan(start as Vector2, 
                    end as Vector2, 
                    n_rdm_branch as int,
                    exp_dist as single):
        prelim_plan = make_plan(start,
                                end,
                                n_rdm_branch,
                                exp_dist)

        opt_plan = []
        for i in range(len(prelim_plan), 0, -1):
            if 

    static def vis_test(start as Vector2, 
                        end as Vector2,
                        rad as single):
        d = (end-start).magnitude

        right_shoulder = Vector3.Cross(end-start, Vector3(0,0,1)).normalized * rad
        
        return (Physics2D.Raycast(right_shoulder, (end-start.normalized), d).collider == null and 
                Physics2D.Raycast(-right_shoulder, (end-start.normalized), d).collider == null)

    static def make_plan(start as Vector2, 
                         end as Vector2, 
                         n_rdm_branch as int,
                         exp_dist as single):
        l = System.Collections.Generic.SortedList[of single, List]()
        n = path_node(start, 
                      null, 
                      0, 
                      (start-end).magnitude,
                      false)
        l.Add((start-end).magnitude, 
              [n])
        
        for i in range(1000):
            mylist = l.Values[0][:]
            #Debug.Log("l.Keys[0]="+l.Keys[0]+" l.Keys[-1]="+l.Keys[0])
            for n as path_node in mylist:
                if n.valid:
                    new_children = n.expand(n_rdm_branch, 
                                            exp_dist, 
                                            end)
                    if len(mylist) > 1:
                        l[l.Keys[0]] = l.Values[0][1:]
                        
                    else:
                        l.RemoveAt(0)

                    if len(new_children) == 1:
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
                        if new_children[j].valid:
                            if l.ContainsKey(new_children[j].costplus):
                                l[new_children[j].costplus].Add(new_children[j])
                            else:
                                l.Add(new_children[j].costplus, 
                                      [new_children[j]])

