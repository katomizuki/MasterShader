using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(Renderer))]
public class PostEffect : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    private Material _material;

    private void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        _material = new Material(_shader);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
       Graphics.Blit(src,dest,_material); 
    }
}
