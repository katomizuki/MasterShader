Shader "Unlit/Eletric"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseColor("Color", Color) = (0,0,0,0)
        _NoiseTilling("Tilling", Range(0,50)) = 10
        _NoiseSpeed("Speed", Range(0,50)) = 10
        _NoiseSize("Size", Range(0, 100)) = 50
        }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "NoiseUtil/SimplexNoise2D.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _NoiseTilling;
            float4 _NoiseColor;
            float _NoiseSpeed;
            float _NoiseSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 noiseA = simplexNoise2D(i.uv - _Time.x * _NoiseSpeed) * _NoiseTilling;
                float4 noiseB = simplexNoise2D(i.uv + _Time.x * _NoiseSpeed) * _NoiseTilling;
                /// Remap
                float mixNoise = (noiseA + noiseB) * 100 - _NoiseSpeed;
                mixNoise = abs(mixNoise);
                mixNoise = saturate(1 - mixNoise);
                float4 tex = tex2D(_MainTex, i.uv);
                return lerp(mixNoise + tex, _NoiseColor, mixNoise);
            }
            ENDCG
        }
    }
}
