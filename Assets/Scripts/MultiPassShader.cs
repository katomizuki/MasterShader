using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MultiPassShader : ImageEffectBase
{
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture brightnessTex = RenderTexture.GetTemporary(source.descriptor);

        Graphics.Blit(source, brightnessTex, material, 1);

        // Graphics.Blit(brightnessTex, destination, material, 0);
        // RenderTexture.ReleaseTemporary(brightnessTex);
        // return;
        // 引数を指定することでPass番号を指定できる。
        Graphics.Blit(brightnessTex, brightnessTex, material, 2);

        // Graphics.Blit(brightnessTex, destination, material, 0);
        // RenderTexture.ReleaseTemporary(brightnessTex);
        // return;

        material.SetTexture("_BrightnessTex", brightnessTex);

        Graphics.Blit(source, destination, material, 3);

        RenderTexture.ReleaseTemporary(brightnessTex);
    }
}
