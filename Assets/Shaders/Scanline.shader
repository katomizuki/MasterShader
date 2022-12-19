Shader "Unlit/Scanline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OpacityScanLine("Opacity ScanLine", Range(0,2)) = 0.8
        _OpacityNoise("Opacity Noise",Range(0,1)) = 0.1
        _FlickeringSpeed("Flickering Speed",Range(0,1000)) = 600
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
            float4 _MainTex_ST;
            half _OpacityScanLine;
            half OpacityNoise;
            half _FlickeringSpeed;
            half _FlickeringStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            float random (float2 st) {
    return frac(sin(dot(st.xy, float2(12.9898,78.233)))*43758.5453123);
}

            fixed4 frag (v2f i) : SV_Target
            {
                // テキスちゃ
                fixed4 img = tex2D(_MainTex, i.uv);
                float3 col = float3(0,0,0);
                // y方向にすごいスピードで波が打つようになる。
                float s = sin(i.uv.y * 1000);
                float c = cos(i.uv.y * 1000);
                float3 scanlines = float3(c,s,c); 
                col += scanlines * _OpacityScanLine;
                // 乱数0~1の乱数
                float r = random(i.uv * _Time);
                col += float3(r,r,r) * _OpacityScanLine;
                float flash = sin(_FlickeringSpeed * _Time);
                col += float3(flash, flash, flash) * _FlickeringStrength;
                return img * float4(col,1.0);
            }
            ENDCG
        }
    }
}
