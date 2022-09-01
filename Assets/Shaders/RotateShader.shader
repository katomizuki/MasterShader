Shader "Unlit/RotateShader"
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

            #define PI 3.1415926539
            

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float box(float2 st, float2 size)
            {
                size = 0.5 - size * 0.5;
                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }

            float2x2 rotate(float angle)
            {
                return float2x2(cos(angle),-sin(angle), sin(angle), cos(angle));
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                 i.uv = screen_aspect(i.uv);

                float2 st = i.uv;
                float t = _Time.y;
// 原点を中心に移動して

                st -= 0.5;
// 入ってきたラジアン文回転させるのとsin波になるので行ったり来たりする

                st = mul(rotate(sin(t) * PI), st);
                st += 0.5;
                                                    
                return box(st, 0.4);
            }                       
            ENDCG
        }
    }
}
