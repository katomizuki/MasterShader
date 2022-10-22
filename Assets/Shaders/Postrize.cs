using UnityEngine;
using UnityEngine.UI;

public class Postrize : MonoBehaviour
{
    // Start is called before the first frame update
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
            return;
        }

        var result = new RenderTexture(_texture2D.width, _texture2D.height, 0, RenderTextureFormat.Default);
        result.enableRandomWrite = true;
        result.Create();
        
        // Postrizeのカーネルインデックス0を取得
        var kernelIndex = _computeShader.FindKernel("Posterize");
        ThreadSize threadSize = new ThreadSize();
        _computeShader.GetKernelThreadGroupSizes(kernelIndex, out threadSize.x, out threadSize.y, out threadSize.z);
        
        _computeShader.SetTexture(kernelIndex,"Texture",_texture2D);
        _computeShader.SetTexture(kernelIndex, "Result",result);

        int[] Step = new int[] { 4, 4, 4 };
        _computeShader.SetInts("Step",Step);

        _computeShader.Dispatch(kernelIndex,_texture2D.width / (int)threadSize.x,_texture2D.height / (int)threadSize.y, (int) threadSize.z);
        // テクスチャを適応
        _rawImage.texture = result;
    }

    void Update()
    {
        
    }
}
