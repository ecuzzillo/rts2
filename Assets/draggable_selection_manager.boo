import UnityEngine

#public sm as selection_manager

class draggable_selection_manager(MonoBehaviour): 
    public connector_objs as List
    public max_force as double
    public this_held as bool
    public prev_held as bool
    public prev_closest_info as List
    public prev_selected as draggable_part
    public close_enough as bool
    public selected as List

    def Start():
        selected = []
        connector_objs = []
        max_force = 4.0
        prev_held = false
        this_held = false

    def handle_click(obj as draggable_part):
        selected = []
        selected.Add(obj)

    def FixedUpdate():
        prev_held = this_held
        this_held = false
        if len(selected) > 0:
            obji = (selected[0] cast draggable_part)
            for j in range(len(obji.connectors)):
                closest_ind = -1
                closest_subind = -1
                closest_dist = -1
                closest_pos = Vector3(0,0,0)
                closest_cntr_ind = -1

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
                    obji.rigidbody2D.\
                        AddForceAtPosition(force_mag*((closest_pos - jpos).normalized), 
                                           jpos)
                    prev_closest_info = [closest_dist, 
                                         closest_cntr_ind, 
                                         closest_ind, 
                                         closest_subind]
                    if 0:
                        (connector_objs[closest_ind] cast draggable_part).rigidbody2D.\
                            AddForceAtPosition(force_mag*((jpos - closest_pos).normalized), 
                                               closest_pos)
                    close_enough = true
                else:
                    close_enough = false

            prev_selected = obji

        if prev_held and not this_held:
            Debug.Log("Setting position omgomgomg")
            closest_dist = prev_closest_info[0]
            closest_cntr_ind = prev_closest_info[1]
            closest_ind = prev_closest_info[2]
            closest_subind = prev_closest_info[3]
            
            close_obj = (connector_objs[closest_ind] cast draggable_part)

            Debug.Log(prev_selected)
            Debug.Log(prev_selected.connectors)
            Debug.Log(closest_cntr_ind)
            Debug.Log(prev_selected.connectors[closest_cntr_ind])
            Debug.Log(prev_selected.connectors[closest_cntr_ind] cast List)
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
            

                                                             

