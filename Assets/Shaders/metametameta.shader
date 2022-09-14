Shader "Unlit/metametameta"
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
// 回転行列
            float2 rotate(float2 st, float angle)
            {
                st -= 0.5;
                st = mul(float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)),st);
                st += 0.5;
                return st;
            }
// 動かす offsetに動かす量を調べる
            float2 move(float2 st, float offset)
            {
                float t = _Time.y;
                return st + float2(sin(offset + t), sin(offset + t * 3)) * 0.5;
            }
//　星をかく
            float star(float2 st)
            {
                
                st = (st - 0.5) / 0.7;
                float a = atan2(st.y, st.x) + _Time.y;
                float l = pow(length(st), 0.8);
                return l - 0.5 + cos(a * 5.0) * 0.08;
            }

            float4 meta_xx(float2 st)
            {
                // starを2個ずつずらしてあげる
             float d = star(move(st, 0)) *
                  star(move(st, 2)) *
                  star(move(st, 4));
                // 時間によって枠を作る
                float ft = frac(_Time.y * 3);

                float a = smoothstep(0.6, 0.8, ft) * (1 - smoothstep(0.8, 1.0, ft));
                float n = 100 - a * 95;
                d *= n;
                float id = floor(d) / n * 5;
                float th = lerp(0.25, 1.1, a);
                return float4(lerp(float3(0.16, 0.80, 0.80),
                           float3(0.16, 0.07, 0.31),
                           id),step(th, abs(sin(d)))); 
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                // アスペクト比を調整
                i.uv = screen_aspect(i.uv);
                // 線形補完
                float4 xx = lerp(0.1, float4(0.9, 0.9,0.99, 1), meta_xx(i.uv + 0.01).w);
                // stx
                float stx = abs(0.5 - rotate(i.uv, -_Time.y * 3));
                // 線
                float4 lines = meta_xx(stx);
                return lines;
                // 線形補完
               // return lerp(float4(lines.xyz, 1), xx, lines.w);
            }
            ENDCG
        }
    }
}
