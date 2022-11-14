Shader "Unlit/transitionCircle" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _CircleSideNum ("Circle Side Num", int) = 16
        _CircleValue ("Circle Value", Range(0, 1)) = 0
        _Threshold ("Threshold", Range(0, 1)) = 0
        _Direction ("Direction(X, Y)", Vector) = (1, 1, 0, 0)
    }
    SubShader {
        Tags { "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _CircleSideNum;
            float _CircleValue;
            float _Threshold;
            float2 _Direction;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // 内積を出す
            float circle(float2 p) {
                return dot(p, p);
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 div = float2(_CircleSideNum, _CircleSideNum * _ScreenParams.y / _ScreenParams.x);
                // 円の数
                float2 st = i.uv * div;
                float2 i_st = floor(st);
                // 正規化した方向
                float2 dir = normalize(_Direction);
                // 最後の円が大きくなるタイミングを加味したトランジション
                float value = _CircleValue * (dot(div - 1.0, abs(dir)) * _Threshold + 2.0);
                float2 sg = sign(dir);
                float a = 1;
                // 自身と周囲8つの円を描画
                for (int i = -1; i <= 1; i++) {
                    for (int j = -1; j <= 1; j++) {
                        // 円の消えるタイミング
                        float2 f = (div - 1.0) * (0.5 - sg * 0.5) + (i_st + float2(i, j)) * sg;
                        float v = value - dot(f, abs(dir)) * _Threshold;
                        float2 f_st = frac(st) * 2.0 - 1.0;
                        float ci = circle(f_st  - float2(2.0 * i, 2.0 * j));
                        a = min(a, step(v, ci));
                    }
                }
                fixed4 col = 0.0;
                col.a = a;
                return col;
            }
            ENDCG
        }
    }
}