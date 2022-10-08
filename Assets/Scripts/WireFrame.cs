using UnityEngine;

public class WireFrame : MonoBehaviour
{
    private Mesh mesh;
    
    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;

        if (mesh.GetTopology(0) == MeshTopology.Triangles)
        {
           mesh.SetIndices(MakeIndicies(mesh.triangles),MeshTopology.Lines, 0);
        }
    }

    private int[] MakeIndicies(int[] triangles)
    {
        int[] indices =  new int[2 * triangles.Length];
        int i = 0;
        for (int t = 0; t <= triangles.Length; t += 3)
        {
            indices[i++] = triangles[t];
            indices[i++] = triangles[t + 1];
            indices[i++] = triangles[t + 1];
            indices[i++] = triangles[t + 2];
            indices[i++] = triangles[t + 2];
            indices[i++] = triangles[t];
        }

        return indices;
    }
}
