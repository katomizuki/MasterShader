Shader "Unlit/CherryShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Common.cginc"

            float rand(float2 st)
            {
                return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
            }

            float2 rotate(float2 st, float angle)
            {
    // 与えられた角度のcosとsinを出して回転行列を作る
                float2x2 mat = float2x2(cos(angle), -sin(angle),
                                sin(angle), cos(angle));
// 中心//
                st -= 0.5;
// 中心を軸に回転させる
                st = mul(mat, st);
                st += 0.5;
                return st;
            }

            float4 draw_cherry(float2 st, float size)
            {
// 時間によってy方向に回転させる

                st = rotate(st, _Time.y);
// 座標の真ん中に原点があるとする　
                st = 0.5 - st;
                size *= 0.2;
        // 見てる座標の原点から距離
                float r = length(st);
        // アークタンジェント 出力（原点からの距離（真ん中）と角度を使って絵を描く準備(回転するほど1に近づく)
                float a = atan2(st.y, st.x);

                float f = min(abs(cos(a * 2.5)) + 0.4,
                      abs(sin(a * 2.5)) + 1.1) * size * 1.4;
    // rを閾値としてそれ以外をstepで切り落とす。
                float petal = step(r, f);

                float4 color = petal * lerp(float4(0.3, 0.3, 1, 1), 1, r / size * 0.5);

                float cap = step(length(0.5 - (st + 0.5)), size * 0.3);
                return lerp(color, float4(0.99, 0.78, 0, 1), cap);
            }
            

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float2 st = i.uv;
        
        //sky 開始値0.8 終了値float4で指定 感化値をuv座標のyにしておく ｙ座標に近づくにつれグラデーションになる　
                float4 color = lerp(0.8, float4(0, 0.4, 1, 1), i.uv.y);
        
        // circle
                float size_offset = rand(floor(st * 10)) * 5;
                float circle = step(length(0.5 - frac(st * 10)),
                            (1 + sin(size_offset + -_Time.y * 3)) * 0.2);
                color = lerp(color, 1, circle * 0.2);
        
        //cherry cherrySizeは最低限のサイズ(0.4だけ決めておき、あとはランダム)
                float cherry_size = 0.4 + 0.9 * rand(floor(st * 4));
// 画面を4分割にしつつ お花サイずを入れる
                float4 cherry = draw_cherry(frac(st * 4), cherry_size);
// 
                color = lerp(color, cherry, cherry.w);

                return color;
            }
            ENDCG
        }
    }
}
