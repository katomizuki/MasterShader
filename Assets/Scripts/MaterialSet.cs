using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSet : MonoBehaviour
{
    public Material material;
    [Range(0, 1)]
    public float floatValue;
    public int floatValueId;

    // Start is called before the first frame update
    void Start()
    {
        // floatValueのIDを取ってくる
        floatValueId = Shader.PropertyToID("_FloatValue");
    }

    // Update is called once per frame
    void Update()
    {
        material.SetFloat("_FloatValue", floatValue);
        material.SetFloat(floatValueId, floatValue);
    }
}
