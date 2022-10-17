using System;
using UnityEngine;
using UnityEngine.UI;

public class BinarizationCS : MonoBehaviour
{
    [SerializeField] private ComputeShader _computeShader;
    [SerializeField] private Texture2D _texture2D;
    [SerializeField] private RawImage _rawImage;
    private RenderTexture _renderTexture;

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
            return;
        }
        // RenderTextureの初期化
        _renderTexture = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.ARGB32);
        _renderTexture.enableRandomWrite = true;
        _renderTexture.Create();
        
        // Binarizationのカーネルインデックス(0)の取得
        var kernelIndex = _computeShader.FindKernel("Binarization");
        // 一つのグループのなかに何個のスレッドがあるか
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        // GPUにデータをコピーする
        _computeShader.SetTexture(kernelIndex, "Texture", _texture2D);
        _computeShader.SetTexture(kernelIndex,"Result",_renderTexture);
        
        // GPUの処理を実行する
        _computeShader.Dispatch(kernelIndex, _texture2D.width / (int) threadSize.x, _texture2D.height / (int) threadSize.y,(int) threadSize.z);
        
        // テキスチャを適応する
        _rawImage.texture = _renderTexture;
    }

    private void OnDestroy()
    {
        _renderTexture = null;
    }
}
