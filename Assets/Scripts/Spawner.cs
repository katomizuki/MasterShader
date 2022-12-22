using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class ObjData
{
    public Vector3 pos;
    public Vector3 scale;
    public Quaternion rot;

    public Matrix4x4 matrix
    {
        get
        {
            return Matrix4x4.TRS(pos, rot, scale);
        }   
    }

    public ObjData(Vector3 pos, Vector3 scale, Quaternion rot)
    {
        this.pos = pos;
        this.scale = scale;
        this.rot = rot;
    }
}
public class Spawner : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] private int instances;
    [SerializeField] private Vector3 maxPos; 
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;
    private List<List<ObjData>> batches = new List<List<ObjData>>();
    void Start()
    {
        int batchIndexNum = 0;
        List<ObjData> currBatch = new List<ObjData>();
        for (int i = 0; i < instances; i++)
        {
            AddObj(currBatch, i);
            batchIndexNum++;
            if (batchIndexNum >= 1000)
            {
                batches.Add(currBatch);
                currBatch = BuildNewBatch();
                batchIndexNum = 0;
            }
        }
    }

    private void AddObj(List<ObjData> list, int index)
    {
        Vector3 position = new Vector3(Random.Range(-maxPos.x, maxPos.x), Random.Range(-maxPos.y, maxPos.y),
            Random.Range(-maxPos.z, maxPos.z));
        list.Add(new ObjData(position, new Vector3(2,2,2), Quaternion.identity));
    }

    private List<ObjData> BuildNewBatch()
    {
        return new List<ObjData>();
    }

    // Update is called once per frame
    void Update()
    {
        RenderBatches();
    }

    private void RenderBatches()
    {
        foreach (var batch in batches)
        {
            Graphics.DrawMeshInstanced(mesh,0,material, batch.Select((a) => a.matrix).ToList());
        }
    }
}
