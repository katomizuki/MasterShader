using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RendererSet : MonoBehaviour
{
    new public Renderer renderer;
    public int instanceID;
    [Range(0, 1)]
    public float floatValue;

    // Update is called once per frame
    void Update()
    {
        renderer.material.SetFloat("_FloatValue", floatValue);
        // renderer.sharedMaterial.SetFloat("_FloatValue", floatValue);
        instanceID = renderer.material.GetInstanceID();
    }
}
