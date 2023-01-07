using System;
using UnityEngine;
public class Render : MonoBehaviour
{
    [SerializeField] private Material _material;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, _material);
    }
}
