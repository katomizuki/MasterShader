using System;
using TMPro.EditorUtilities;
using UnityEngine;

[ExecuteInEditMode]
public class BloomTexture : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    [SerializeField, Range(0, 1f)] private float _strenght = 0.3f;
    [SerializeField, Range(1, 64)] private int _blur = 20;
    [SerializeField, Range(0, 1f)] private float _threshold = 0.3f;
    [SerializeField, Range(1, 12)] private int _ratio = 1;
    [SerializeField, Range(1f, 10f)] private float _offset = 1f;
    private Material _material;
    private float[] _weights = new float[10];
    
    void Start()
    {
        
    }

    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_material == null)
        {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        int renderTextureX = src.width / _ratio;
        int renderTextureY = src.height / _ratio;
        RenderTexture tmp = CreateRenderTexture(renderTextureX, renderTextureY);
        RenderTexture tmp2 = CreateRenderTexture(renderTextureX, renderTextureY);
         
        // Bloom
        _material.SetFloat("_Strength", _strenght);
        _material.SetFloat("_Threshold", _threshold);
        _material.SetFloat("Blur",_blur);
        _material.SetTexture("_Tmp",tmp);
        Graphics.Blit(src, tmp, _material, 0);
        
        // ガウしアンブラー
        UpdateWeights();
        
        _material.SetFloatArray("_Weights", _weights);
        float x = _offset / tmp2.width;
        float y = _offset / tmp2.height;
        
        _material.SetVector("_Offset",new Vector4(x,0,0,0));
        Graphics.Blit(src, tmp2, _material, 1);
        _material.SetVector("_Offset", new Vector4(0, y, 0, 0));
        Graphics.Blit(tmp2, dest, _material, 1);
        
        RenderTexture.ReleaseTemporary(tmp);
        RenderTexture.ReleaseTemporary(tmp2);
    }

    RenderTexture CreateRenderTexture(int width, int height)
    {
        RenderTexture renderTexture = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
        renderTexture.filterMode = FilterMode.Bilinear;
        return renderTexture;
    }

    private void UpdateWeights()
    {
        float total = 0;
        float d = _blur * _blur * 0.01f;
        for (int i = 0; i < _weights.Length; i++)
        {
            float x = 1.0f + i * 2f;
            float w = Mathf.Exp(-0.5f * (x * x) / d);
            _weights[i] = w;
            if (i > 0)
            {
                w *= 2.0f;
            }
            total += w;
        }
        // 正規化
        for (int i = 0; i < _weights.Length; i++)
        {
            _weights[i] /= total;
        }
    }
}
