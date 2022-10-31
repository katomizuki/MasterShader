using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MP : ImageEffectBase
{
    public override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // RenderTextureの取得
        RenderTexture brightnessTex = RenderTexture.GetTemporary(source.descriptor);
        // 何番目のPassを使うかどうか？
        Graphics.Blit(source, brightnessTex, material, 1);

        // 
        Graphics.Blit(brightnessTex, brightnessTex, material, 2);
        // 
        material.SetTexture("_BrightnessTex", brightnessTex);

        Graphics.Blit(source, destination, material, 3);
        // 一時テクスチャを解放
        RenderTexture.ReleaseTemporary(brightnessTex);
    }
    
}
