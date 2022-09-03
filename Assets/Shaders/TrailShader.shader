Shader "Unlit/TrailShader"
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

            #define PI 3.1415926539

            float rotate(float2 st, float angle)
            {
                float2x2 mat = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }
// ランダム値

            float rand(float2 uv)
              {
                 return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
              }

float box(float2 st, float t)
    {
// 同様に回転させる
        st = rotate(st, t * 2.0 * PI / 4 * rand(t));
        float size = t;
        st = step(size, st) * step(size, 1.0 - st);
        return st.x * st.y;
    }

float lattice(float2 st, float n)
{
// sin波生成
    float size = sin(st.y + _Time.y + rand(floor(st * n).x));
// 45当分で更新を分割

    return box(frac(st * n), size);
}



            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
// 45度回転させる
                i.uv = rotate(i.uv, PI / 4);
                //return float4(i.uv.x,i.uv.y,0,1);
                float l1 = lattice(i.uv, 45);
                float l2 = lattice(i.uv, 20);
                return float4(l1, 1.2, l2, 1);
            }
            ENDCG
        }
    }
}
