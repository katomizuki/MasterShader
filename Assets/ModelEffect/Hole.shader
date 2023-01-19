Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _ClipSize("ClipSize", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="geometry-1" }

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

            float _ClipSize;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float circle(float2 p, float radius)
            {
                return length(p) - radius;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 fst = frac(i.uv) * 2 -1;
                float ci = circle(fst, 0);
                float4 col = step(_ClipSize, ci);
                clip(col.a - 0.5);
                return col;
            }
            ENDCG
        }
    }
}
