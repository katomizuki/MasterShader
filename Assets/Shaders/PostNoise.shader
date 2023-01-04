Shader "Unlit/PostNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Tex", 2D) = "white" {}
        _OffsetX("OffsetX",float) = 0.0
        _OffsetY("OffsetY",float) = 0.0
        _Intensity("Intensity", Range(0,1)) = 1.0
        _Color("Color", Color) = (1.0, 1.0, 1.0,1.0)
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

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _SecondaryTex; 
            half _OffsetY;
            half _OffsetX;
            fixed4 _Color;
            fixed4 _Intensity;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv2 = v.texcoord + float2(_OffsetX, _OffsetY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_SecondaryTex, i.uv2);
                // 0 ~ 1にクランプした後、、切り上げ
                float threshold = ceil(saturate(1 - col2.r - _Intensity));
                return lerp(col, col2, threshold); 
            }
            ENDCG
        }
    }
}
