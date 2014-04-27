import UnityEngine

class path_node(Object):
    public pos as Vector2
    public parent as path_node
    public children as (path_node)
    public cost as single
    public valid as bool

    def constructor(_pos as Vector2, 
                    _parent as path_node,
                    _cost as single):
        pos = _pos
        parent = _parent
        cost = _cost
        children = array(path_node, 0)

    def expand(n_rdm_branch as int, dist as single, goal as Vector2):
        Debug.Log("dist "+dist)
        if dist > 100:
            Debug.Log("oh no dist > 100"+dist)
            return array(path_node, 0)

        if len(children) > 0:
            Debug.Log("oh no we're already expanded! length is "+len(children))

        if (goal-pos).magnitude < dist:
            children = (path_node(goal, 
                                  self, 
                                  cost + (goal-pos).magnitude),)
            
        else:
            p2 = pos + (goal - pos).normalized * dist
            do_goal = false
            if len(Physics2D.OverlapCircleAll(p2, 1.0)) == 0:
                goal_node = path_node(p2,
                                      self,
                                      cost + dist)
                do_goal = true

            if do_goal:
                children = array(path_node, n_rdm_branch+1)
                Debug.Log("setting children["+n_rdm_branch+"]")
                children[n_rdm_branch] = goal_node
            else:
                children = array(path_node, n_rdm_branch)



            i = 0
            while i < n_rdm_branch:
                p = pos + Random.insideUnitCircle.normalized * dist

                if len(Physics2D.OverlapCircleAll(p, 1)) == 0:
                    Debug.Log("WTFFFF: path_node(" + p + ", " + self + ", " + (cost + dist) + ")")
                    children[i] = path_node(p,
                                            self,
                                            cost + dist)
                    Debug.Log("setting children["+i+"]")
                else:
                    node = path_node(Vector2(0, 0), self, 0.0)
                    node.valid = false
                    children[i] = node
                i += 1

        return children

class path_find(Object): 
    static def plan(start as Vector2, 
                    end as Vector2, 
                    n_rdm_branch as int,
                    exp_dist as single):

        Debug.Log("exp_dist "+exp_dist)

        l = System.Collections.Generic.SortedList[of single, List]()

        l.Add(0, [path_node(start, null, 0)])
        
        for i in range(3):
            mylist = l.Values[l.Count-1][:]
            for n as path_node in mylist:
                Debug.Log("hi i="+i+" n="+n+" pos="+n.pos+" cost="+n.cost+" len(mylist)="+len(mylist))
                if n.valid:
                    new_children = n.expand(n_rdm_branch, 
                                            exp_dist, 
                                            end)
                    if len(new_children) == 1:
                        # found the goal
                        ret = []
                        n = new_children[0]
                        while n.parent != null:
                            ret.Add(n.pos)
                            n = n.parent
                            return reversed(ret)

                    for j in range(len(new_children)):
                        Debug.Log("new_children["+j+"]="+new_children[j])
                        Debug.Log("new_children["+j+"].cost"+new_children[j].cost)
                        Debug.Log("l.ContainsKey(new_children[j].cost)"+l.ContainsKey(new_children[j].cost))
                        if l.ContainsKey(new_children[j].cost):
                            l[new_children[j].cost].Add(new_children[j])
                        else:
                            l.Add(new_children[j].cost, 
                                  [new_children[j]])
