Shader "Unlit/NewUnlitShader 1"
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
            #define PI 3.141592

            #include "UnityCG.cginc"
            #include "Common.cginc"

            float4 palette(float a)
            {
                float t = _Time.y;
                // 色を時間ごとに変える。
                float r = 0.6 + 0.3 * sin(a * 8 + t * 2);
                float g = 0.6 + 0.3 * sin(a * 5 + t * 3);
                return float4(r, g, 1, 1);
            }
            
            float polygon(float2 p, int n, float size)
            {
                float a = atan2(p.x, p.y) + PI;
                float r = 2 * PI / n;
                return cos(floor(0.5 + a / r) * r - a) * length(p) - size;
            }

            float star(float2 p, int n, float t, float size)
            {
                float a = 2 * PI / float(n) / 2;
                float c = cos(a);
                float s = sin(a);
                float2 r = mul(p, float2x2(c, -s, s, c));
                return (polygon(p, n, size) - polygon(r, n, size) * t) / (1 - t); 
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv = screen_aspect(i.uv);
                // 距離関数で原点0.0の左の距離から遠い順でアニメーションする
                float4 pa = palette(length(i.uv));
                float st = star(i.uv,10, 1,0.01);
                return st;
             //   return lerp(palette(length(i.uv)),0, star(i.uv));
            }
            ENDCG
        }
    }
}
