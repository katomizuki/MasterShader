using System;
using UnityEngine;
[ExecuteInEditMode]
public class Render : MonoBehaviour
{
    [SerializeField] private Material _material;

    private void Awake()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, _material);
    }
}
