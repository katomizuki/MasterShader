using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGenerator : MonoBehaviour
{
  // Start is called before the first frame update
  public Material material;
  void Start()
  {
    MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
    meshRenderer.material = material;
    Mesh mesh = new Mesh();

    mesh.vertices = new Vector3[]
   {
            new Vector3(-0.5f, -0.5f, 0f), //0
            new Vector3(0.5f, -0.5f, 0f),  //1
            new Vector3(0.5f, 0.5f, 0f),   //2
            new Vector3(-0.5f, 0.5f, 0f)   //3
   };

    mesh.colors = new Color[]
    {
        Color.red,
        Color.green,
        Color.blue,
        Color.gray
    };

    mesh.triangles = new int[]
    {
        0,2,1,0,3,2
    };
// 領域と法線を自動で計算する。
    mesh.RecalculateBounds();

    MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
    meshFilter.mesh = mesh;
  }

  // Update is called once per frame
  void Update()
  {

  }
}
