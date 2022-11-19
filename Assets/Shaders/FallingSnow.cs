using System;
using UnityEngine;
using Random = UnityEngine.Random;

[RequireComponent(typeof(MeshFilter),typeof(MeshRenderer))]
public class FallingSnow : MonoBehaviour
{
// Unityの一回のドローコールが64000までなので雪の頂点が4つ（三角形二つ（インデックスつき頂点）
    private const int SNOW_NUM = 16000;
    private Vector3[] _vertices;

    private int[] _triangles;

    private Vector2[] _uvs;

    private float _range;

    private float _rangeR;

    private Vector3 _move;

    private void Start()
    {
        // 雪を降らせる範囲
        _range = 16.0f;
        // _rangeの逆数
        _rangeR = 1.0f / _range;
        // 雪の頂点配列
        _vertices = new Vector3[SNOW_NUM * 4];

        for (int i = 0; i < SNOW_NUM; i++)
        {
            // _rangeと rangeの間で乱数を返す
            float x = Random.Range(-_range, _range);
            float y = Random.Range(-_range, _range);
            float z = Random.Range(-_range, _range);

            // 頂点座標を作る
            var point = new Vector3(x, y, z);

            // インデックスがあるので6 - 2(かぶっている頂点）で終了
            _vertices[i * 4 + 0] = point;
            _vertices[i * 4 + 1] = point;
            _vertices[i * 4 + 2] = point;
            _vertices[i * 4 + 3] = point;
        }

        // どのように頂点を結ぶか?
        _triangles = new int[SNOW_NUM * 6];
        for (int i = 0; i < SNOW_NUM; i++) {
            // 頂点のインデックスを入れる。
            // 時計回り(1と2がかぶっている。）
            _triangles[i * 6 + 0] = i * 4 + 0;
            _triangles[i * 6 + 1] = i * 4 + 1;
            _triangles[i * 6 + 2] = i * 4 + 2;
            // 2個目の三角形
            _triangles[i * 6 + 3] = i * 4 + 2;
            _triangles[i * 6 + 4] = i * 4 + 1;
            _triangles[i * 6 + 5] = i * 4 + 3;
        }
        // uv値を入れる。
        _uvs = new Vector2[SNOW_NUM * 4];
        for (int i = 0; i < SNOW_NUM; i++) {
            _uvs[i * 4 + 0] = new Vector2(0.0f, 0.0f);
            _uvs[i * 4 + 1] = new Vector2(1.0f, 0.0f);
            _uvs[i * 4 + 2] = new Vector2(0.0f, 1.0f);
            _uvs[i * 4 + 3] = new Vector2(1.0f, 1.0f);
        }

        Mesh mesh = new Mesh();
        mesh.name = "SnowFlakes";
        mesh.vertices = _vertices;
        // mesh
        mesh.triangles = _triangles;
        // meshのuv値を追加
        mesh.uv = _uvs;
        mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 9999);
        var mf = GetComponent<MeshFilter>();
        mf.sharedMesh = mesh;
    }

    private void LateUpdate()
    {
        var targetPosition = Camera.main.transform.TransformPoint(Vector3.forward * _range);
        var renderer = GetComponent<Renderer>();
        renderer.material.SetFloat("_Range", _range);
        renderer.material.SetFloat("_RangeR", _rangeR);
        renderer.material.SetFloat("_Size", 0.1f);
        renderer.material.SetVector("_MoveTotal", _move);
        renderer.material.SetVector("_CamUp", Camera.main.transform.up);
        renderer.material.SetVector("_TargetPosition", targetPosition);

        float x = (Mathf.PerlinNoise(0f, Time.time * 0.1f) - 0.5f) * 10f;
        float y = -2f;
        float z = (Mathf.PerlinNoise(Time.time * 0.1f, 0f) - 0.5f) * 10f;
        _move += new Vector3(x, y, z);
        _move.x = Mathf.Repeat(_move.x, _range * 2.0f);
        _move.y = Mathf.Repeat(_move.y, _range * 2.0f);
        _move.z = Mathf.Repeat(_move.z, _range + 2.0f);
        
    }
}
