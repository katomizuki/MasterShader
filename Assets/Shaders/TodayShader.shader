Shader "Unlit/TodayShader"
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
// hue値をrgb値にかえるパターン https://qiita.com/keim_at_si/items/c2d1afd6443f3040e900
            float3 hue_to_rgb(float h)
            {
                h = frac(h) * 6 - 2;
                return saturate(float3(abs(h - 1) - 1, 2 - abs(h), 2 - abs(h - 2)));
            }
// sizeが闢血として三角形をかく距離関数
            float tri(float2 st, float size)
            {
                // 入ってきた座標の小数点を取り出す
                float2 fst = frac(st);
                // 闢血よりxとyが合計されてstepする
                return step(size, fst.x + fst.y);
            }
            float swirl(float2 st)
            {
                // x軸となす座標の角度を出す（弧度法）-3.14 ~ 3.14が帰ってくる
                float phi = atan2(st.y, st.x);
                float scaler = 10;
                float distance = length(st);
                float time = _Time * 4;
                return sin(distance * scaler + phi - time) * 0.5 + 0.5;
            }
            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float2 st = i.uv + float2(i.uv.y * 0.5 - 0.25, 0);
                float sw = swirl(floor(st) * 13 / 13 - 0.5);
                return lerp(float4(hue_to_rgb(sw * 0.4 + 0.8), 1),
                    float4(0, 0, 0, 1),
                    tri(frac(st * 13), sw));
                
            }
            ENDCG
        }
    }
}
