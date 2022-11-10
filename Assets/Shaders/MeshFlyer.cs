using System;
using UnityEngine;

public class MeshFlyer : MonoBehaviour
{
    private Material _material;
    private float _normalPow;
    void Start()
    {
        _material = GetComponent<Renderer>().material;
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        var indices = meshFilter.mesh.GetIndices(0);
        var topology = MeshTopology.Points;
        meshFilter.mesh.SetIndices(indices,topology, 0);
    }

    private void Update()
    {
        // 経過時間
        _normalPow += Time.deltaTime * 3;
        _material.SetFloat("_NormalPow", _normalPow);
    }
}
