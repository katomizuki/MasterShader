Shader "Unlit/StripeShader"
{
    Properties
    {
        _StripeColor1("StripeColor1",Color) = (1,0,0,0)
        _StripeColor2("StripeColor2", Color ) = (0, 1, 0, 0)
        _SliceSpace("SliceSpace",Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            half4 _StripeColor1;
            half4 _StripeColor2;
            half _SliceSpace;

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


            v2f vert (appdata v)
            {
                v2f o;
                // UVスクロール
                o.uv = v.uv + _Time.x * 2;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 0か1が帰ってくる
                half interpolation = step(frac(i.uv.y * 15), _SliceSpace);
                // lerpでinterpolationでブレンドしてくれる。0か1なのでどっちかのいろが描画される。
                half4 color = lerp(_StripeColor1, _StripeColor2, interpolation);
                return color;
            }
            ENDCG
        }
    }
}
