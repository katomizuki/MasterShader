Shader "Unlit/SimplePostEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EffectColor("EffectColor", Color) = (0,0,0,0)
    }
    SubShader
    {
        // CGINCLUDEで共通の値として保持する。
            CGINCLUDE
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            ENDCG
            
            Pass 
            {
                CGPROGRAM
                float4 _EffectColor;
                float4 frag(v2f i): SV_Target {
                    float4 renderingColor = tex2D(_MainTex, i.uv);
                    return renderingColor * _EffectColor;
                }
                ENDCG
            }
            
            Pass {
                CGPROGRAM
                float4 frag(v2f i) : SV_Target {
                    float4 renderingColor = tex2D(_MainTex, i.uv);
                    float monochrome = 0.3 * renderingColor.r + 0.6 * renderingColor;
                    float4 monochromeColor = float4(monochrome.xxx, 1);
                    return monochromeColor;
                }
                ENDCG
        }
    }
}
