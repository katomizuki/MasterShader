using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlatMeshCreater : MonoBehaviour
{

    void FlatShading()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        Mesh mesh = Instantiate(meshFilter.sharedMesh) as Mesh;
        meshFilter.sharedMesh = mesh;

        Vector3[] oladVerts = mesh.vertices;
        int[] triangles = mesh.triangles;
        Vector3[] vertices = new Vector3[triangles.Length];

        for (int i = 0; i < triangles.Length; i++)
        {
            vertices[i] = oladVerts[triangles[i]];
            triangles[i] = i;
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            FlatShading();
        }
        
    }
}
