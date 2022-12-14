Shader "Unlit/oilEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", Range(0,10)) = 0
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _Radius;
            float4 _MainTex_TexelSize;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
// kuwahara Filterというフィルタを利用している。ある点Aを基準にして左下、左上、右下、右上の領域に分ける。この領域の大きさがRadiusになる
            //その領域のうち一番色が均質なものを一つ選び出す。それを点Aに適用させる。
            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                float3 mean[4]= {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0} 
                };

                float3 sigma[4] = {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };

                float2 start[4] = {{-_Radius, -_Radius}, {-_Radius, 0}, {0, -_Radius}, {0, 0}};
                float2 pos;
                float3 col;
                // 四つの領域 https://qiita.com/Cartelet/items/5c1c012c132be3aa9608
                for (int k = 0; k < 4; k++) {
                    for(int i = 0; i <= _Radius; i++) {
                        for(int j = 0; j <= _Radius; j++) {
                            pos = float2(i, j) + start[k];
                            col = tex2Dlod(_MainTex, float4(uv + float2(pos.x * _MainTex_TexelSize.x, pos.y * _MainTex_TexelSize.y), 0., 0.)).rgb;
                            mean[k] += col;
                            sigma[k] += col * col;
                        }
                    }
                }
 
                float sigma2;
                float n = pow(_Radius + 1, 2);
                float4 color = tex2D(_MainTex, uv);
                float min = 1;
 
                for (int l = 0; l < 4; l++) {
                    mean[l] /= n;
                    sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
                    sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;
 
                    if (sigma2 < min) {
                        min = sigma2;
                        color.rgb = mean[l].rgb;
                    }
                }
                return color;
            }
            ENDCG
        }
    }
}
