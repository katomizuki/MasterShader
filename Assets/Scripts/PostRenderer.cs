using System;
using System.Collections;
using UnityEngine;
using Random = UnityEngine.Random;

namespace DefaultNamespace
{
    public class PostRenderer : MonoBehaviour
    {
        public Material _material;

        private void Awake()
        {
            _material.SetFloat("_OffsetPosY", 0f);
            _material.SetFloat("_OffsetColor", 0.01f);
            _material.SetFloat("_OffsetDistortion", 480f);
            _material.SetFloat("_Intensity", 0.64f); 
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            // TV noise
            _material.SetFloat("_OffsetNoiseX", Random.Range(0f, 0.6f));
            float offsetNoise = _material.GetFloat("_OffsetNoiseY");
            _material.SetFloat("_OffsetNoiseY", offsetNoise + Random.Range(-0.03f, 0.03f));
 
            // Vertical shift
            float offsetPosY = _material.GetFloat("_OffsetPosY");
            if(offsetPosY > 0.0f)
            {
                _material.SetFloat("_OffsetPosY", offsetPosY - Random.Range(0f, offsetPosY));
            }
            else if (offsetPosY < 0.0f)
            {
                _material.SetFloat("_OffsetPosY", offsetPosY + Random.Range(0f, -offsetPosY));
            }
            else if (Random.Range(0, 150) == 1)
            {
                _material.SetFloat("_OffsetPosY", Random.Range(-0.5f, 0.5f));
            }
 
            // Channel color shift
            float offsetColor = _material.GetFloat("_OffsetColor");
            if (offsetColor > 0.003f)
            {
                _material.SetFloat("_OffsetColor", offsetColor - 0.001f);
            }
            else if (Random.Range(0, 400) == 1)
            {
                _material.SetFloat("_OffsetColor", Random.Range(0.003f, 0.1f));
            }
       
            // Distortion
            if (Random.Range(0, 15) == 1)
            {
                _material.SetFloat("_OffsetDistortion", Random.Range(1f, 480f));
            }
            else
            {
                _material.SetFloat("_OffsetDistortion", 480f);
            }
 
            Graphics.Blit(src, dest, _material);
        }
    }
}