import UnityEngine


class selectedness_obj(MonoBehaviour): 
    public lr as LineRenderer
    public n_incs as int
    public game_object as GameObject
    def Start():
        lr = GetComponent[of LineRenderer]()
        n_incs = 50
        lr.SetVertexCount(n_incs+20)
        lr.SetWidth(0.1, 0.1)
        lr.SetColors(Color.green, Color.green)

    def Update():
        i = 0
        for i in range(n_incs+20):
            ang = i*(2*Mathf.PI)/n_incs
            lr.SetPosition(i, 5 * Vector3(Mathf.Sin(ang), Mathf.Cos(ang), 0))

        lr.transform.position = game_object.transform.position
