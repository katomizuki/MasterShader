using System;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class OtsuBinarization : MonoBehaviour
{
    [SerializeField] private ComputeShader _computeShader;
    [SerializeField] private Texture2D _texture2D;
    [SerializeField] private RawImage _rawImage;
    private ComputeBuffer _computeBuffer;
    private const int COLOR_SIZE = 256;

    // グレースケールから2値化を用いたテクスチャ
    private RenderTexture BinarizeOtsu(Texture2D texture)
    {
        if (!SystemInfo.supportsComputeShaders)
        {
            return null;
        }

        var target = RGB2Gray(texture);
        var threshold = FindThreshold(target);
        CreateTexture(target, threshold);
        return target;
    }

    // RGBからグレースケール算出
    private RenderTexture RGB2Gray(Texture2D texture)
    {
        // RenderTextureの初期化
        var target = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.ARGB32);
        target.enableRandomWrite = true;
        target.Create();
        // GrayScaleのカーネルインデックス
        var kernelIndex = _computeShader.FindKernel("GrayScale");
        // 一つのグループのなかに何個のスレッドがあるか
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        // GPUにデータをコピーする
        _computeShader.SetTexture(kernelIndex, "Texture", texture);
        _computeShader.SetTexture(kernelIndex, "Result", target);

        return target;
    }
    
// グレースケールから大津の2値化を用いて閾値を求める
    private float FindThreshold(RenderTexture gray)
    {
        var kernelIndex = _computeShader.FindKernel("FindThreashold");

        _computeBuffer = new ComputeBuffer(COLOR_SIZE, sizeof(float));
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        // GPUにデータをコピーする
        _computeShader.SetBuffer(kernelIndex, "buffer", _computeBuffer);
        _computeShader.SetTexture(kernelIndex, "Texture", gray);
        _computeShader.SetInt("Width", _texture2D.width);
        _computeShader.SetInt("Height", _texture2D.height);

        _computeShader.Dispatch(kernelIndex, COLOR_SIZE / (int)threadSize.x, (int)threadSize.y, (int)threadSize.z);

        var result = new float[COLOR_SIZE];
        _computeBuffer.GetData(result);
        return result.Select((p, i) => new { Sb2 = p, Index = i })
            .OrderByDescending(p => p.Sb2)
            .First()
            .Index; 
    }
    

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
    void Start()
    {
        var result = BinarizeOtsu(_texture2D);
        _rawImage.texture = result;
    }

    private void CreateTexture(RenderTexture texture, float threshold)
    {
        // CreateTextureのカーネルインデックスを取得
        var kernelIndex = _computeShader.FindKernel("CreateTexture");
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        // GPUにデータをコピーする
        _computeShader.SetTexture(kernelIndex, "Texture", texture);
        _computeShader.SetTexture(kernelIndex, "Result",texture);
        _computeShader.SetFloat("Threashold", threshold);
        _computeShader.Dispatch(kernelIndex, _texture2D.width / (int)threadSize.x, _texture2D.height / (int)threadSize.y, (int)threadSize.z); 
    }

    private void OnDestroy()
    {
        _computeBuffer.Release();
        _computeBuffer = null;
    }
}
