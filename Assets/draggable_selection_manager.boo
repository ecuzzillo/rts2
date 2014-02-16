import UnityEngine

#public sm as selection_manager

class draggable_selection_manager(selection_manager): 
    public connector_objs as List
    public max_force as double
    public prev_held as bool

    override def Start():
        super()
        connector_objs = []
        max_force = 4.0
        prev_held = false

    def FixedUpdate():
        this_held = false
        if len(selected) > 0:
            obji = (selected[0] cast draggable_part)
            for j in range(len(obji.connectors)):
                closest_ind = -1
                closest_subind = -1
                closest_dist = -1
                closest_pos = Vector3(0,0,0)

                Debug.Log(obji.transform)
                Debug.Log(obji.connectors)

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
                            closest_ind = k
                            closest_subind = l

                if closest_dist < 1 and closest_ind != -1:
                    if closest_dist == 0:
                        force_mag = max_force
                    else:
                        force_mag = Mathf.Min(max_force, 1/closest_dist**2)
                    obji.rigidbody2D.\
                        AddForceAtPosition(force_mag*((closest_pos - jpos).normalized), 
                                           jpos)
                    this_held = true
                    if 0:
                        (connector_objs[closest_ind] cast draggable_part).rigidbody2D.\
                            AddForceAtPosition(force_mag*((jpos - closest_pos).normalized), 
                                               closest_pos)
                    
        if prev_held and not this_held:
            pass

