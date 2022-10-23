using UnityEngine;

public class MS : MonoBehaviour
{
    public Material material;

    [Range(0, 1)] public float floatValue;

    private int floatValueId;
    // Start is called before the first frame update
    void Start()
    {
        /// IDをとってくる。
        floatValueId = Shader.PropertyToID("_FloatValue");
    }

    void Update()
    {
        material.SetFloat("FloatValue",floatValue);
        material.SetFloat(floatValueId, floatValue);
    }
}
