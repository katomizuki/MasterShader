Shader "Unlit/hexhex"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Common.cginc"
// ShaderGraphのmodと同じ。
            float2 mod(float2 a, float2 b)
            {
                return a - b * floor(a / b);
            }
// ひし型の書き方 rにサイズを入れる。
            float hex(float2 st, float2 r)
            {
                // 絶対値
                st = abs(st);
                // 
                return max(st.x + st.y, st.y) - r.x;
            }

            float hex_grid(float2 st)
            {
                // gridをたす。
                st.x += 0.02;
                
                float2 g = float2(0.7, 0.4);
                float r = 0.005;
                // 繰り返し処理
                float2 p1 = mod(st, g) - g * 0.5;
                // 繰り返し処理
                float2 p2 = mod(st + g * 0.5, g) - g * 0.5;
                // どちらの繰り返し処理。小さい方を返す
                return min(hex(p1, r), hex(p2, r));
            }

            float wave(float2 st)
            {
                // stには-1~1が入ってくる-> 0 ~ 2
                float pos = st.y + st.x;
                // 8 + 3 * (-Time)
                return 1 + sin(-_Time.y * 3 + pos * 4);
            }

            
            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float4 color = 0;
                // 歪み
                float w = wave(i.uv);
                // 時間によってuv座標のｘｙ座標をずらす。
                i.uv.xy += _Time.x;
                // sin->0~1が入り 100はスケーラーグリッドを生やす。
                float sinN = sin(hex_grid(i.uv) * 100); 
                float h1 = abs(0.4 + sinN * w);
                // 閾値で色を黒とそのほかで分ける
                h1 = step(h1,0.1);
                // グレースケールに色をつける
                color = lerp(color, float4(1, 0, 1, 1), h1);

                //  
                float h2 = abs(0.3 + sin(hex_grid(i.uv) * 40) * w);
                // 閾値で色を黒とその他で分ける (0か1が入る）
                h2 = step(h2, 0.1);
                // グレースケールにlerpで色を付ける h2　（0か1） float4の青色線形補完
                color = lerp(color, float4(0, 0, 1, 1), h2);
                return color;
            }
            ENDCG
        }
    }
}
