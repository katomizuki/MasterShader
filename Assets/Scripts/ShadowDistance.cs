using System;
using UnityEngine;

public class ShadowDistance : MonoBehaviour
{
    private void Start()
    {
       Shader.SetGlobalFloat("_ShadowDistance", QualitySettings.shadowDistance); 
    }

    private void Update()
    {
        if (!Application.isEditor) return;
        Shader.SetGlobalFloat("_ShadowDistance", QualitySettings.shadowDistance);
    }
}
