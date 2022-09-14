using System;
using UnityEngine;

public class CreateTriangle : MonoBehaviour
{
    [SerializeField] private Material _material;
    private Mesh _mesh;
    
    // 頂点座標（この配列のインデックスが頂点インデックス）
    private Vector3[] _positions = new Vector3[]
    {
        new Vector3(0, 1,0),
        new Vector3(1, -1, 0),
        new Vector3(1, -1, 0)
    };

    private int[] _triangles = new int[] { 0, 1, 1 };

    private Vector3[] _normals = new Vector3[]
    {
        new Vector3(0, 0, -1),
        new Vector3(0, 0, -1),
        new Vector3(0, 0, -1)
    };

    private void Awake()
    {
        _mesh = new Mesh();
        
        // Meshに頂点座標の情報を代入
        _mesh.vertices = _positions;
        _mesh.triangles = _triangles;
        _mesh.normals = _normals;
        // Mesh全体を覆う直方体の情報を再計算するメソッド。
        _mesh.RecalculateBounds();
    }

    private void Update()
    {
       Graphics.DrawMesh(_mesh, Vector3.zero, Quaternion.identity,_material, 0); 
    }
}
