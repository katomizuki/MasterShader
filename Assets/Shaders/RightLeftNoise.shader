Shader "Unlit/RightLeftNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            float _HorizonValue;
            int _Seed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // 乱数生成
            float rand(float2 value, int seed) {
                return frac(sin(dot(value, fixed2(12.9898f, 78.233f)) + seed) * 43758.5453);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float random = rand(i.uv, _Seed);
                int tmp = step(random, 0.5) * 2 - 1; // -1~1
                float randomValue = _HorizonValue * tmp * random;
                float2 uv = float2(frac(i.uv.x + randomValue), i.uv.y);
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
