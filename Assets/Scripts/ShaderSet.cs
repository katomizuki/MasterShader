using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderSet : MonoBehaviour
{
    [Range(0, 1)]
    public float floatValue;

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalFloat("_FloatValue", floatValue);
    }
}
