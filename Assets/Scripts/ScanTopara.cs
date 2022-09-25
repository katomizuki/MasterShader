using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class ScanTopara : MonoBehaviour
{
    public float TimeValue;

    public float AlphaValue;

    [SerializeField] private Material mat;

    private string _timeFactor = "_TimeFactor";

    private string _alphaFactor = "_AlphaFactor";
    // Start is called before the first frame update
    void Update()
    {
        mat.SetFloat(_timeFactor, TimeValue);
        mat.SetFloat(_alphaFactor,AlphaValue);
        
    }
}
