using UnityEngine;

public class ParamsSetter : MonoBehaviour
{
    public float TimeValue;
    public float AlphaValue;
    [SerializeField] private Material _material;
    private string _timeFactor = "_TimeFactor";
    private string _alphaFactor = "_Alphafactor";
    private void Update()
    {
        _material?.SetFloat(_timeFactor, TimeValue);
        _material?.SetFloat(_alphaFactor, AlphaValue);
    }
}
