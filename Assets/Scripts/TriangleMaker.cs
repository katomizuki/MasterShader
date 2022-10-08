using System.Collections.Generic;
using UnityEngine;

public class TriangleMaker : MonoBehaviour
{
    private void Start()
    {
        FourSidedPyramid();
    }

    private void FourSidedPyramid()
    {
        // 四角錐。の頂点を作成

        var vertices = new List<Vector3>()
        {
            // 0,1,2,3
            new Vector3(0f, 0f, 0f),
            new Vector3(1f, 0f, 0f),
            new Vector3(1f, 0f, 1f),
            new Vector3(0f, 0f, 1f),
            // 4,5,6
            new Vector3(0f, 0f, 0f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(1f, 0f, 0f),
            // 7,8,9
            new Vector3(1f, 0f, 0f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(1f, 0f, 1f),
            // 10,11,12
            new Vector3(1f, 0f, 1f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(0f, 0f, 1f),
            // 13,14,15
            new Vector3(0f, 0f, 1f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(0f, 0f, 0f),
        };
        
        // 頂点のインデックスを整える
        // この順番を参照し、面が出来上がる
        
        // 頂点のインデックスを整える。

        var triangles = new List<int>
        {
            3, 0, 1, 3, 1, 2,
            4, 5, 6,
            7, 8, 9,
            10, 11, 12,
            13, 14, 15
        };
        
        // メッシュ作成
        var mesh = new Mesh();
        // 初期化
        mesh.Clear();
        // メッシュに頂点を登録
        mesh.SetVertices(vertices);
        // メッシュにインデックスリストを登録する。
        // 第二引数はサブメッシュ（複数マテリアル割り当てる場合に使われるメッシュ）指定用
        mesh.SetTriangles(triangles, 0);
        //　法線の再計算
        mesh.RecalculateNormals();
        // 作成したメッシュを適応
        var meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }
}
// ポリゴン　複数の頂点と頂点と線で繋げた図形のことを指す
// メッシュ 複数のポリゴンをまとまったものをメッシュと言います。
// メッシュには頂点情報の他に頂点インデックスや法線情報、頂点カラーなどが含まれる。
