using System.Collections.Generic;
using UnityEngine;

public class FrameEffect : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    private Material _material;
    private List<RenderTexture> _textures = new List<RenderTexture>();

    private void Awake()
    {
        Initalize();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_material == null)
        {
            Initalize();
        }

        int width = src.width;
        int height = src.height;
        const int FLAME_NUM = 3;
        for (int i = 0; i < FLAME_NUM; i++)
        {
            _textures.Add(new RenderTexture(width, height, 0, RenderTextureFormat.Default));
        }
        
        // 1フレームずつずらしたものをコピーする
        RenderTexture tmpTexture = _textures[Time.frameCount % FLAME_NUM];
        Graphics.Blit(src,tmpTexture);
        for (int i = 0; i < _textures.Count; i++)
        {
            _material.SetTexture("_Tex" + i.ToString(), _textures[i]);
            Debug.Log(i.ToString());
        }
       Debug.Log("ああああ"); 
        Graphics.Blit(src, dest, _material);
    }

    private void Initalize()
    {
        _material = new Material(_shader);
        _material.hideFlags = HideFlags.DontSave;
    }
    
}
