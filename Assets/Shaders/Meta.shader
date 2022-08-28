Shader "Unlit/Meta"
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

            float2 move(float2 st, float offset)
    {
        float t = _Time.y;
        return st + float2(sin(offset + t),
                           sin(offset + t));
    }

            float circle(float2 st)
            {
//distanceで座標をそのまま出す。

                return -0.1 + distance(0.5, st);
            }

            float meta_xx(float2 st)
            {
            float d = circle(move(st, 0)) *
                  circle(move(st, 4)) *
                  circle(move(st, 8));
// 時間×1.5分割
            float ft = frac(_Time.y * 1.5);

            float a = smoothstep(0.6, 0.8, ft) * (1 - smoothstep(0.8, 1.0, ft));
        
            return smoothstep(lerp(0.25, 1, a), abs(sin(d * 150)), 1);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
// アスペクト比を調整する
                i.uv = screen_aspect(i.uv);

                return lerp(float4(0.80, 0.1, 0.1, 1), float4(0.15, 0.1, 0.1, 1), meta_xx(i.uv));
            }
            ENDCG
        }
    }
}
