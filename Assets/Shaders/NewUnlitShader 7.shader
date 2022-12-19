Shader "Unlit/NewUnlitShader 7"
{
    Properties
    {
        [HDR] _BaseColor("Colo",Color) = (1,1,1)
        [HDR] _EdgeColor("Dissolve Color",Color) = (0,0,0)
        _MainTex("Texture", 2D) = "white" {}
        _DissolveTex("DissolveTexture",2D) = "white" {}
        _Threshold("Threshold",Range(0,1)) = 1
        _EdgeWidth("Edge Width",Range(0,1)) = 0.01
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
            fixed4 _BaseColor;
            fixed4 _EdgeColor;
            half _Threshold;
            half _EdgeWidth;
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 edgeCol = fixed4(1,1,1,1);
                fixed4 dissolve = tex2D(_DissolveTex, i.uv);
                float alpha = dissolve.r * 0.2 + dissolve.g * 0.7 + dissolve.b * 0.1;
                // dissolveを段階的な色変化によって実現する
                if (alpha < _Threshold + _EdgeWidth && _Threshold > 0)
                {
                    edgeCol = _EdgeColor;
                }

                if (alpha < _Threshold)
                {
                    discard;
                }
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor * edgeCol;
                return col;
            }
            ENDCG
        }
    }
}
