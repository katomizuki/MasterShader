Shader "Unlit/TransformTriangleShader"
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

            float2 transform_uv(float2 uv, float2 radius)
            {
                // lengthで距離を出す
                float distance = length(0.5 - uv);
                // 歪みを実装。
                float disortion = 1 - smoothstep(radius * 10, radius, distance);
                return uv + (0.5 - uv) * disortion;
            }

            float2 tri_uv(float2 uv)
            {
                float sx = uv.x - uv.y / 2;
                float sxf = frac(sx);
                float offs = step(frac(1 - uv.y), sxf);
                return float2(floor(sx) * 2 + sxf + offs, uv.y);
            }

            float tri(float2 uv)
            {
                float sp = 3 * floor(tri_uv(uv));
                return max(0, sin(sp * _Time.y));
            }


            fixed4 frag (v2f_img i) : SV_Target
            {

                i.uv = screen_aspect((i.uv));
                float radius = (1 + sin(_Time.y)) * 0.05;
                float2 uv = transform_uv(i.uv, radius);
                return tri(uv * 7);
            }
            ENDCG
        }
    }
}
