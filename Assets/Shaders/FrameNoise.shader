Shader "Unlit/FrameNoise"
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
            sampler2D _Tex0;
            sampler2D _Tex1;
            sampler2D _Tex2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * 0.25;
                fixed4 col0 = tex2D(_Tex0, i.uv) * 0.25;
                fixed4 col1 = tex2D(_Tex1, i.uv) * 0.25;
                fixed col2 = tex2D(_Tex2, i.uv) * 0.25;
                return col + col0 + col1 + col2;
            }
            ENDCG
        }
    }
}
