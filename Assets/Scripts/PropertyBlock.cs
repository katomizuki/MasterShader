using UnityEngine;

public class PropertyBlock : MonoBehaviour
{
    new public Renderer renderer;
    public Material material;
    public int instanceID;
    private MaterialPropertyBlock materialPropertyBlock;
    [Range(0, 1)]
    public float floatValue;

    void Start()
    {
        materialPropertyBlock = new MaterialPropertyBlock();
    }

    // Update is called once per frame
    void Update()
    {
        materialPropertyBlock.SetFloat("_FloatValue", floatValue);
        renderer.SetPropertyBlock(materialPropertyBlock);
        instanceID = material.GetInstanceID();
    }
}
