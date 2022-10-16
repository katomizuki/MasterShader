using System;
using UnityEngine;
using UnityEngine.UI;
public class GrayScale : MonoBehaviour
{
    [SerializeField] private ComputeShader _computeShader;
    [SerializeField] private Texture2D _texture2D;
    [SerializeField] private RawImage _rawImage;
    private RenderTexture _renderTexture;
    void Start()
    {
        if (!SystemInfo.supportsComputeShaders)
        {
            return;
        }

        // テキスちゃと同じサイズのRenderTextureをインスタンス
        _renderTexture = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.ARGB32);
        // コンピュートシェーダーに渡すためにtrueにする
        _renderTexture.enableRandomWrite = true;
        // 実際に作成
        _renderTexture.Create();

        // KernelIndexを関数名で探してくる
        var kernelIndex = _computeShader.FindKernel("GrayScale");
        // ThreadSizeをインスタンス化
        ThreadSize threadSize = new ThreadSize();
        // それぞれコンピュータシェーダーからスレッドグループのサイズを取ってきて、参照型でthreadSizeに入れる 
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        // コンピュートシェーダーにTextureとRenderTextureをコピーする
        _computeShader.SetTexture(kernelIndex, "Texture", _texture2D);
        _computeShader.SetTexture(kernelIndex, "Result", _renderTexture);
        
        // GPUの処理を実行 スレッドサイズをテキスチャの幅と高さををスレッドサイズで除算して送信
        _computeShader.Dispatch(kernelIndex, _texture2D.width / (int) threadSize.x,_texture2D.height / (int)threadSize.y,(int) threadSize.z);
        _rawImage.texture = _renderTexture;
    }

    private void OnDestroy()
    {
        _renderTexture = null;
    }
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