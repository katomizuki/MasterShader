Shader "Unlit/BasicMT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleUVX("Scaleuvx",Range(1,10)) = 10
        _ScaleUVY("ScaleY", Range(1,10)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Trasparent" }

        GrabPass {
            "_GrabTexture"
            }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _GrabTexture;
            float4 _MainTex_ST;
            sampler2D _MainTex;
            float _ScaleUVX;
            float _ScaleUVY;
           

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // o.uv.x = sin(o.uv.x * _ScaleUVX);
                // o.uv.y = sin(o.uv.y * _ScaleUVY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_GrabTexture, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
