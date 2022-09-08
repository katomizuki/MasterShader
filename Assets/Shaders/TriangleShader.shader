Shader "Unlit/TriangleShader"
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
// 四角形を作成
            float box(float2 st, float2 size)
            {
                size = 0.5 - size * 0.5;
                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }
// 行列をかけて移動する。
            float3x3 translate(float x, float y)
            {
                return float3x3(1, 0, x,
                                0, 1, y,
                                 0, 0, 1);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float2 st = i.uv;
                float t = _Time.y;
                st = mul(translate(sin(t) * 0.1,cos(t) * 0.1), float3(st, 1));
                
                return box(st, 0.25);
            }
            ENDCG
        }
    }
}
