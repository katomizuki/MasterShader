Shader "Unlit/BlockNoiseTransition"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Size("Size",Vector) = (1,1,0,0)
        _Seed("Seed", int) = 0
        _Value("Value", Range(0,1)) = 0
        _Smoothing("Smoothing", Range(0.0001, 0.5)) = 0
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "Quaue"="Transparent"
            }

        Blend SrcAlpha OneMinusSrcAlpha
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
            float4 _Color;
            int2 _Size;
            float _Seed;
            float _Value;
            float _Smoothing;

             float random(float2 st, int seed) {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233)) + seed) * 43758.5453123);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 格子上にする
                float2 st = i.uv * _Size;
                // それぞれ個別に扱うようにする。
                float2 i_st = floor(st);
// 0.001~0.5
                float sm = _Smoothing;
                // value(0~1)
                float val = _Value * (1 + sm);
                // val = smの場合 alphaが0か1になる
                float a = smoothstep(val - sm, val, random(i_st,_Seed));
                // 黒
                fixed4 col = _Color;
                // alphaを調整
                col.a = a;
                return col;
            }
            ENDCG
        }
    }
}
