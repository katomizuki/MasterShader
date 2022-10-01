Shader "Unlit/CustomHolo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor("LineColor", Color) = (0, 0, 0, 0)
        _LineSpeed("LineSpeed", Range(0, 10)) = 5
        _LineSize("ColorGap",Range(0, 1.0)) = 0.01
        _Alpha("Alpha", Range(0, 1)) = 0.5
        _FrameRate("FrameRate", Range(0, 30)) = 15
        _Frequency("Frequency", Range(0,1)) = 0.1
        _GlitchScale("GlitchScale", Range(1,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
// フラグメントシェーダー出力のアルファ * 1 - ソースアルファ
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
                float2 line_uv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 line_uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float _ColorGap;
            float _Alpha;
            float _FrameRate;
            float _Frequency;
            float _GlitchScale;

            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //パーリンノイズ
            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + fixed2(0, 0));
                float v10 = rand(p + fixed2(1, 0));
                float v01 = rand(p + fixed2(0, 1));
                float v11 = rand(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                            lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                            u.y) + 0.5f;
            }
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // _LineSpeedはスケーラー UVスクロール
                o.line_uv.y = v.line_uv.y - _Time.y * _LineSpeed;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                // RGBずらしてホログラムっぽくする(パーリンノイズでランダムで動かす）
                float r = tex2D(_MainTex, uv + _ColorGap * perlinNoise(_Time.z)).r;
                float b = tex2D(_MainTex, uv - _ColorGap * perlinNoise(_Time.z)).b;

                // tex2DでUV座標のその時の色値をgreeenとアルファ値を取り出す
                float2 ga = tex2D(_MainTex, uv).ga;
                // gaはかえずに色を生成する
                float4 shiftColor = fixed4(r, ga.x, b, ga.y);
                //  uvスクロールされてきたUV座標を15かけてfracにして0~1で小数点を取り出しつつ。
                // LineSizeを閾値としてstepすることでノイズラインを計算。
                float interpolation = step(frac(i.line_uv.y * 15), _LineSize);
                // 前段でノイズラインの補間値を閾値にピクセルカラーとLineColorで色付け。
                float4 noiseLineColor = lerp(shiftColor, _LineColor, interpolation);
                // 任意の値に基づいて値を丸メル処理をかく。
                float posterize = floor(frac(perlinNoise(frac(_Time)) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                // uv.y 方向のノイズ計算 - 1 < random < 1
                float noiseY = 2.0 * rand(posterize) - 0.5;
                // グリッチの高さの補間値を計算する 高さに出現するかは時間変化
                float glitchLine1 = step(uv.y - noiseY, rand(uv));
                float glitchLine2 = step(uv.y - noiseY, 0);
                // 0 ~ 1 に変換する
                float glitch = saturate(glitchLine1 - glitchLine2);
                // x方向のNoise計算
                float noiseX = (2.0 * rand(posterize) - 0.5) * 0.1;
                // frequency
                float frequency = step(abs(noiseX), _Frequency);
                noiseX *= frequency;
                // 速度調整
                uv.x = lerp(uv.x, uv.x + noiseX * _GlitchScale, glitch);
                // テクスチャサンプリング
                float4 noiseColor = tex2D(_MainTex, uv);
                float4 finalColor = noiseLineColor * noiseColor;
                finalColor.a = _Alpha;
                return finalColor;
            }
            ENDCG
        }
    }
}
