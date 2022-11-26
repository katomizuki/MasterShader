Shader "Unlit/kaze"
{
    Properties
    {
        _MainTex("Textures", 2D) = "white" {}
        _NoiseTilingOffset("Offset",Vector) = (0.1,0.1,0.0)
        _NoiseSizeScroll("NoiseSizeScroll", Color) = (1,1,1,1)
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _GradationColor("Gradation Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"= "Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseutil.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 texuv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _NoiseTilingOffset;
            fixed4 _NoiseSizeScroll;
            fixed4 _BaseColor;
            fixed4 _GradationColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_NOISE_TEX(v.uv,_NoiseTilingOffset, _NoiseSizeScroll);
                o.texuv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed p = perlinNoise(i.uv, _NoiseSizeScroll.xy);
                return lerp(_GradationColor, _BaseColor, p) * tex2D(_MainTex, i.texuv);
            }
            ENDCG
        }
    }
}
