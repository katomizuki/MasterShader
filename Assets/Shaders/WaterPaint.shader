Shader "Unlit/WaterPaint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ToneCount("Tone Count",Range(1,20)) = 17
        _ToneScale("Tone Scale", Range(0.1, 3)) = 1.272
        _GrayMin("Gray Min", Range(0.0, 1)) = 0.913
        _SaturateScale("Saturate Scale", Range(0.1,2.0)) = 1
        _ValueMin("Value Min", Range(0.0, 1.0)) = 0.983
    }
    SubShader
    {
        // カリング　深度値の書き込みオフ
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
            float _ToneCount;
            float _ToneScale;
            float _GrayMin;
            float _SaturateScale;
            float _ValueMin;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                float gray = dot(col.rgb, fixed3(0.299,0.587, 0.11f));
                uint toneIndex = uint(gray * _ToneCount * _ToneScale);
                gray = float(toneIndex) / float(_ToneCount);
                gray = clamp(gray,_GrayMin, 1.0);
                float3 hsv = rgb2hsv(col.rgb);
                hsv.y = saturate(hsv.y + (1.0 - (gray * _SaturateScale)));
                hsv.z = clamp(gray, _ValueMin, 1.0);
                col.rgb = hsv2rgb(hsv);
                return col;
            }
            ENDCG
        }
    }
}
