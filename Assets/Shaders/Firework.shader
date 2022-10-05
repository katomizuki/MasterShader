Shader "Unlit/Firework"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull Off
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
                float4 color : COLOR;
                float alpha : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.color.a = v.alpha;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャの色をとってくる
                fixed4 tex_color = tex2D(_MainTex,i.uv);
               // 引数の値がAlphaが0.5以下なら描画しない
                clip(tex_color.a - 0.5);
                float4 color = float4(tex_color * i.color.xyz, i.color.w);
                return color;
            }
            ENDCG
        }
    }
}
