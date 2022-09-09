Shader "Unlit/TransformTriangleshader2"
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
                // 原点からの距離を出す
                float distance = length(0.5 - uv);
                // radiusの10がスケーラーとして機能。歪みになる。
                float distortion = 1 - smoothstep(radius * 10, radius, distance);
                return uv + (0.5 - uv) * distortion;
            }

            float tri(float2 st)
            {
                st.x -= st.y * 0.5;
                float2 fst = frac(st);
                return step(1, fst.x + fst.y);
            }

            
            
            fixed4 frag (v2f_img i) : SV_Target
            {

                i.uv = screen_aspect(i.uv);
                float t = smoothstep(0.1, 0.8, frac(_Time.y * 0.3));
                float t1 = frac(t * 0.5);
                float2 st1 = transform_uv(i.uv, 0.01 + t * 0.069);
                float2 st2 = st1 +(abs(1 - 2 * frac(t1))) * (1 / 3.5);
                return lerp(tri(st2 * 7), tri(st1 * 7), abs(1 - 2 * frac(t1)));
            }
            ENDCG
        }
    }
}
