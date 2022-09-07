Shader "Unlit/SliceScrollShader"
{
    Properties
    {
        _Color ("MainColor", Color) = (0, 0, 0, 0)
        _SliceSpace("SliceSpace", Range(0, 30)) = 15
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
                float4 pos : SV_POSITION;
                
            };

            half4 _Color;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv + _Time.y / 2;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(frac(i.uv.y * _SliceSpace) - 0.5);
                
                return half4(_Color);
            }
            ENDCG
        }
    }
}
