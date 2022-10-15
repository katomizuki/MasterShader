using System;
using UnityEngine;
using UnityEngine.UI;
public class RGB2GBR : MonoBehaviour
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
            Debug.Log("not supported computeShader");
        } 
        // RenderTextureの初期化
        _renderTexture = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.ARGB32);
        // RenderTextureをComputeShaderに送信してRWTextureとしてComputeShaderで受け取る場合はこれをtrueにする必要がある
        _renderTexture.enableRandomWrite = true;
        // 実際にオブジェクトを作成する
        _renderTexture.Create();
        
        // RGB2BGRのカーネルインデックス0を取得
        var kernelIndex = _computeShader.FindKernel("RGB2BGR");
        // 1つのグループの中にスレッドがあるかどうか
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y,out threadSize.z);
        
        // GPUデータをコピーする
        _computeShader.SetTexture(kernelIndex, "Texture", _texture2D);
        _computeShader.SetTexture(kernelIndex, "Result", _renderTexture);
        // Dispathで送信する
        _computeShader.Dispatch(kernelIndex, _texture2D.width / (int)threadSize.x,_texture2D.height / (int)threadSize.y, (int)threadSize.z);
        // テキスちゃを適応させる
        _rawImage.texture = _renderTexture;
    }

    private void OnDestroy()
    {
        _renderTexture = null;
    }
}
