using UnityEngine;

public class MeshTopologyPoints : MonoBehaviour
{
    void Start()
    {
        // MeshFilterを取ってくる
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        // MeshFilterはMeshRendererにMeshのデータを渡すクラス。
        // MeshFilterのmeshにIndexをGetIndicesでindexを取ってくる。サブメッシュ→マテリアル
        meshFilter.mesh.SetIndices(meshFilter.mesh.GetIndices(0), MeshTopology.Lines, 0);
        // MeshTopologyはポリゴンの分割の仕方。
    }
}
