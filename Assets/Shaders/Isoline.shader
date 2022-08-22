Shader "Unlit/Isoline"
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


            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                float2 st = i.uv;
// 歪みの計算

                float x = 2 * st.y + sin(_Time.y * 5);
                float distort = sin(_Time.y * 10) * 0.1 *
                        sin(5 * x) * (- (x - 1) * (x - 1) + 1);
//座標を歪ませる

                st.x += distort;
// 0.1 -> 0.15 -> 0.2
                float t = -_Time.y * 10;
                
                return float4(abs(sin(t * length(0.5 - st + distort * 0.1))),
                      abs(sin(t * length(0.5 - st + distort * 0.15))),
                      abs(sin(t * length(0.5 - st + distort * 0.2))),
                      1);
            }
            ENDCG
        }
    }
}
