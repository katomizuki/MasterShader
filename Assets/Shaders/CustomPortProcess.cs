using System;
using UnityEngine;

public class CustomPortProcess : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private UsePass _usePass;

    private enum UsePass
    {
        UsePass1,
        UsePass2
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        
        // Graphics.Blit=> パスの番号を指定。
        Graphics.Blit(src, dest, _material, (int)_usePass);
    }
}
