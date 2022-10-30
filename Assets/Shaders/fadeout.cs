using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fadeout : ImageEffectBase
{
    [Range(0, 1)] public float fadeOut = 1;

    public override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_FadeOut", fadeOut);
        base.OnRenderImage(source, destination);
    }
}
