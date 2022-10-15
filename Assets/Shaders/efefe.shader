Shader "Unlit/efefe"
{
    Properties
    {
        [HideInInspector] _SrcBlend("_src", Float) = 1.0
        [HideInInspector] _DstBlend("_dest", Float) = 1.0
        [HideInInspector] _ZWrite("_zw", Float) = 1.0
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _Glossiness("Smoothness",Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        UsePass "Standard/FORWARD"
        UsePass "Standard/ShadowCaster"
    }
}
