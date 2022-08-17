using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageEffect : MonoBehaviour
{
    public Material material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //引数 source はカメラに入力されるテクスチャ、すなわちカメラの描画結果、des
//tination はカメラが出力するテクスチャです。

        Graphics.Blit(source, destination, material);
    }
}
