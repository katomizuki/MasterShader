using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class iE : MonoBehaviour
{
    public Material material;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
       Graphics.Blit(src,dest,material); 
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
