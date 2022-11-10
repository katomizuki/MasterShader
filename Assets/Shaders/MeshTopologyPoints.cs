using UnityEngine;

public class MeshTopologyPoints : MonoBehaviour
{
    void Start()
    {
        // MeshFilterを取ってくる
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        // MeshFilterはMeshRendererにMeshのデータを渡すクラス。
        // MeshFilterのmeshにIndexをGetIndicesでindexを取ってくる。サブメッシュ→マテリアル
        // Mesh.SetIndicesはMeshを再構成するクラス。
        var indices = meshFilter.mesh.GetIndices(0); // subMeshのインデックス
        meshFilter.mesh.SetIndices(indices, MeshTopology.Lines, 0);
        // MeshTopologyはポリゴンの分割の仕方。
    }
}
