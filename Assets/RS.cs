using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RS : MonoBehaviour
{
    new public Renderer renderer;

    public int instanceId;

    [Range(0, 1)] public float floatValue;

    private MaterialPropertyBlock _materialPropertyBlock;
    // Start is called before the first frame update
    void Start()
    {
        _materialPropertyBlock = new MaterialPropertyBlock();
    }

    // Update is called once per frame
    void Update()
    {
        renderer.material.SetFloat("FloatValue", floatValue);
        // インスタンスを複製してマテリアルを参照すmaterialを参照する
        instanceId = renderer.material.GetInstanceID();
        // インスタンスを複製せずにMaterialを参照するにはこれをsharedMaterialを利用する
        renderer.sharedMaterial.SetFloat("FloatValue",floatValue);
       
        /// インスタンスを複製しないかつ、異なる値を少しだけ変えたい場合に使う。
        _materialPropertyBlock.SetFloat("FloatValue", floatValue);
        renderer.SetPropertyBlock(_materialPropertyBlock);
        // instanceId = 
    }

    private void OnGUI()
    {
       GUILayout.BeginArea(new Rect(0, 0, 200, 100));
       // GUILayout.Label("Shader LOD" + );
       GUILayout.EndArea();
       Shader.globalMaximumLOD = 500;
    }
}
