using System;
using UnityEngine;

public class RightLeftNoise : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    [SerializeField, Range(0, 1)] private float _horizonValue;
    private Material _material;

    private void Awake()
    {
        Initialize();
        if (GUI.changed) {
            // Repaint ();
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Debug.Log("おい！");
        if (_material == null)
        {
            Initialize();
        }
        _material.SetInt("_Seed", Time.frameCount);
        _material.SetFloat("_HorizonValue", _horizonValue);
        Debug.Log("おい！");
        Graphics.Blit(src,dest,_material);
    }

    private void Initialize()
    {
        Debug.Log("あれ?");
        _material = new Material(_shader); 
        _material.hideFlags = HideFlags.DontSave;
    }
}
