using UnityEngine;

public class Blur : MonoBehaviour
{
    [SerializeField] private Texture _texture;
    [SerializeField] private Shader _shader;
    [SerializeField, Range(1f, 10f)] private float _offset;
    [SerializeField, Range(10f, 1000f)] private float _blurValue = 10f;
    private Material _material;
    private Renderer _renderer;
    private RenderTexture _renderTexture1;
    private RenderTexture _renderTexture2;
    private float[] _weights = new float[10];
    private bool _isInitizlized = false;


    private void Awake()
    {
        Initialize();
    }
    private void Initialize()
    {
        if (_isInitizlized)
        {
            return;
        }

        _material = new Material(_shader);
        _material.hideFlags = HideFlags.HideAndDontSave;
        _renderTexture1 =
            RenderTexture.GetTemporary(_texture.width / 2, _texture.height / 2, 0, RenderTextureFormat.ARGB32);
        _renderTexture2 = RenderTexture.GetTemporary(_texture.width / 2, _texture.height / 2, 0, RenderTextureFormat.ARGB32);

        _renderer = GetComponent<Renderer>();
        UpdateWeights();
        _isInitizlized = true;
    }

    private void UpdateWeights()
    {
        float total = 0;
        float d = _blurValue * _blurValue * 0.001f;
        for (int i = 0; i < _weights.Length; i++) {
            float x = 1.0f + i * 2f;
            float w = Mathf.Exp(-0.5f * (x * x) / d);
            _weights[i] = w;
            if (i > 0) {
                w *= 2.0f;
            }
            total += w;
        }

        for (int i = 0; i < _weights.Length; i++) {
            _weights[i] /= total;
        }
    }

    private void OnValidate()
    {
        if (!Application.isPlaying)
        {
            return;
        } 
        
        UpdateWeights();
        BlurMethod();
    }

    private void BlurMethod()
    {
        if (!_isInitizlized)
        {
            Initialize();
        }
        
        Graphics.Blit(_texture, _renderTexture1);
        _material.SetFloatArray("_Weights", _weights);
        float x = _offset / _renderTexture1.width;
        float y = _offset / _renderTexture1.height;
        _material.SetVector("_Offset", new Vector4(x, 0, 0, 0));
        Graphics.Blit(_renderTexture1, _renderTexture2, _material);
        _material.SetVector("_Offset", new Vector4(0, y, 0, 0));
        Graphics.Blit(_renderTexture2, _renderTexture1, _material);
        _renderer.material.mainTexture = _renderTexture1;
    }

    private void OnDestroy()
    {
       RenderTexture.ReleaseTemporary(_renderTexture1); 
       RenderTexture.ReleaseTemporary(_renderTexture2);
    }
}
