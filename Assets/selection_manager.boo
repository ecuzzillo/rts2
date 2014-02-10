import UnityEngine

class selection_manager(MonoBehaviour):
    public selected as List
    public connector_objs as List
    public max_force as double

    def Start():
        connector_objs = []
        selected = []
        max_force = 4.0

    def FixedUpdate():
        #for i in range(len(connector_objs)):
        if len(selected) > 0:
            obji = (selected[0] cast draggable_part)#(connector_objs[i] cast draggable_part)
            for j in range(len(obji.connectors)):
                closest_ind = -1
                closest_subind = -1
                closest_dist = -1
                closest_pos = Vector3(0,0,0)

                jpos = obji.transform.\
                       TransformPoint(obji.connectors[j])

                for k in range(len(connector_objs)):
                    objk = (connector_objs[k] cast draggable_part)
                    if objk == obji:
                        continue

                    for l in range(len(objk.connectors)):
                        lpos = objk.transform.\
                               TransformPoint(objk.connectors[l])
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
                    if 0:
                        (connector_objs[closest_ind] cast draggable_part).rigidbody2D.\
                            AddForceAtPosition(force_mag*((jpos - closest_pos).normalized), 
                                               closest_pos)

                
                    
                
                

    def handle_click(obj as MonoBehaviour):
        selected = []
        Debug.Log(obj)
        selected.Add(obj)
