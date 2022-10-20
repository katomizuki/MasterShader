using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ToHSV : MonoBehaviour
{
    [SerializeField] private ComputeShader _computeShader;

    [SerializeField] private Texture2D _texture2D;

    [SerializeField] private RawImage _rawImage;

    struct ThreadSize
    {
        public uint x;
        public uint y;
        public uint z;

        public ThreadSize(uint x, uint y, uint z)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
    }

    private void Start()
    {
        if (!SystemInfo.supportsComputeShaders)
        {
            Debug.LogError("ComputeShader is not support");
            return;
        } 
        
        // 結果を取ってくるようのRenderTexture
        var result = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.ARGB32);
        result.enableRandomWrite = true;
        result.Create();
        
        // InvertHueのカーネルインデックス(0)取得
        var kernelIndex = _computeShader.FindKernel("InvertHue");
        
        // 一つのグループのなかに何個のスレッドがあるかどうか
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        // GPUにデータをコピーする
        _computeShader.SetTexture(kernelIndex,"Texture", _texture2D);
        // 結果を表示する用のRenderTextureをセット。enableRandoWriteがtrueは必須
        _computeShader.SetTexture(kernelIndex,"Result", result);
        
        // GPUの処理を実行する
        _computeShader.Dispatch(kernelIndex,_texture2D.width / (int)threadSize.x, _texture2D.height / (int)threadSize.y, (int)threadSize.z);
// RawImageのTextureにresultにセット。
        _rawImage.texture = result;
    }
}
