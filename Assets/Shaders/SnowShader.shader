Shader "Unlit/SnowShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float2 rotate(float2 st, float angle)
            {
                 float2x2 mat = float2x2(cos(angle), -sin(angle),
                                sin(angle), cos(angle));
                 st -= 0.5;
                 st = mul(mat, st);
                 st += 0.5;
                 return st;
            }
            float wave(float2 st, float n)
            {   // 真ん中の座標に移動
                st = floor(st * n) / n;
                float pos = st.y + st.x;
                // 時間によって変化する1 ~ 0 sizeとして使用して時間によって変化できるようになっている。
                return (1 + sin(-_Time.y * 5 + pos * 5)) * 0.5;
            }

            float snow(float2 st, float size)
            {
                // 10はスケラーで時間によって早く回転させる
                st = rotate(st, _Time.x * 10);
                // 中心からの距離を撮りたいので0.5 - stをする
                st = 0.5 - st;
                float r = length(st) * 2;
                // 長
                float a = atan2(st.y, st.x);
                // 座標のアークタンジェント
                float f = abs(cos(a * 12) * sin(a + 3)) * size;
                // sizeにはwaveからの0 ~ 1を入る。
                return 1 - smoothstep(f,f + 0.02, r);
            }

            float circle(float2 st, float size)
            {
                return step(length(0.5 - st), size);
            }
            
            fixed4 frag (v2f_img i) : SV_Target
            {
                // アスペクト比の調整
                i.uv = screen_aspect(i.uv);
                // snow作成
                // 3*3マス
                float2 snow_fst = frac(i.uv * 3);
                float snow_size = 0.8 * wave(i.uv,3);
                float s = snow(snow_fst, snow_size);
                // 10*10マス
                float2 circle_fst = frac(i.uv * 10);
                float circle_size = 0.45 * wave(i.uv, 10);
                float c = circle(circle_fst, circle_size);
                return float4(0.1, 0.13, 0.5, 1) * c + s;
            }
            ENDCG
        }
    }
}
