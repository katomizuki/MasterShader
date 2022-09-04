Shader "Unlit/TransformGridShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float2 transform_uv(float2 uv, float2 radius)
            {
// 距離
                float distance = length(0.5 - uv);

                float distortion = 1 - smoothstep(radius * 10, radius, distance);
                return uv + (0.5 - uv) * distortion;
            }

            float4 frag(v2f_img i) : SV_Target
              {
// アスペクト比の正規化
                i.uv = screen_aspect(i.uv);
// radius (時間によるサイン波を)

                float radius = (1 + sin(_Time.y)) * 0.5 + 0.05;
//uvの移動

                float2 uv = transform_uv(i.uv, radius);
//7分割 a + x * (b - a)

                float2 fst = frac(uv * 7);

                float4 grid = lerp(float4(0, 0, 0, 1),
                           float4(0.5, 0.5, 1, 1),
                           smoothstep(0.1, 1.0, fst.x) + smoothstep(0.1,1, fst.y));
                return grid;
              }
            ENDCG
        }
    }
}
