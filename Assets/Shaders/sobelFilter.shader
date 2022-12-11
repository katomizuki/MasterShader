Shader "Unlit/sobelFilter"
{
    Properties
    {
        _MainTex("Texture",2D) = "white" {}
        _OutlineThick("_OutlineThick", Range(0.0, 1.0)) = 0.1
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
            float4 _MainTex_TexelSize;
            float _OutlineThick;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half3 Sobel(float2 uv) {
                // 自分以外のピクセルの上下左右斜めのピクセルを取ってくる
                float diffU = _MainTex_TexelSize.x * _OutlineThick;
                float diffV = _MainTex_TexelSize.y * _OutlineThick;
                half3 col00 = tex2D(_MainTex, uv + half2(-diffU, -diffV));
                half3 col01 = tex2D(_MainTex, uv + half2(-diffU, 0.0));
                half3 col02 = tex2D(_MainTex, uv + half2(-diffU, diffV));
                half3 col10 = tex2D(_MainTex, uv + half2(0.0, -diffV));
                half3 col12 = tex2D(_MainTex, uv + half2(0.0, diffV));
                half3 col20 = tex2D(_MainTex, uv + half2(diffU, -diffV));
                half3 col21 = tex2D(_MainTex, uv + half2(diffU, 0.0));
                half3 col22 = tex2D(_MainTex, uv + half2(diffU, diffV));

                // 横方向のカーネルを計算
                half3 horizontalColor = 0;
                horizontalColor += col00 * -1.0;
                horizontalColor += col01 * -2.0;
                horizontalColor += col02 * -1.0;
                horizontalColor += col20;
                horizontalColor += col21 * 2.0;
                horizontalColor += col22;

                // 縦方向のカーネルを計算
                half3 verticalColor = 0;
                verticalColor += col00;
                verticalColor += col10 * 2.0;
                verticalColor += col20;
                verticalColor += col02 * -1.0;
                verticalColor += col12 * -2.0;
                verticalColor += col22 * -1.0;

                half3 outline = sqrt(horizontalColor * horizontalColor + verticalColor * verticalColor);
                return outline;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float col = tex2D(_MainTex, i.uv);
                col -= Sobel(i.uv);
                return float4(col, col, col, 1);
                return col;
            }
            ENDCG
        }
    }
}
