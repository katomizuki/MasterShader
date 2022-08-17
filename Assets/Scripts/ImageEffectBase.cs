using UnityEngine;

[ExecuteAlways, ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ImageEffectBase : MonoBehaviour
{
    public Material material;


    void Start()
    {
        enabled = material && material.shader.isSupported;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
