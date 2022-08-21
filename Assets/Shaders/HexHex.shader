Shader "Unlit/HexHex"
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

            float hexDist(float2 p)
             {
                p = abs(p);
                float d = dot(p, normalize(float2(1.0, 1.73)));
                return max(p.x, d);
             }

            float4 hexCoords(float2 uv)
             {
                float2 r = float2(1.0, 1.73);
                float2 h = 0.5 * r;
                float2 a = fmod(uv, r) - h;
                float2 b = fmod(uv - h, r) - h;
                float2 gv = length(a) < length(b) ? a : b;
                float x = atan2(gv.x , gv.y);
                float y = 0.5 - hexDist(gv);
                float2 id = uv - gv;
                return float4(x, y, id);
             }

            fixed4 frag (v2f_img i) : SV_Target
            {
                // i.uv = screen_aspect(i.uv - 0.5);
                 i.uv *= 10.0;

                 float3 col = float3(0.0, 0.0,0.0);
                 float4 hc = hexCoords(i.uv);

                 float time = _Time * 0.5;
                 float wavy = pow(sin(length(hc.zw) - time), 4.0) + 0.1;
                 float c = smoothstep(0., 15./_ScreenParams.y, hc.y);

                 col = float3(c * wavy, c * wavy, c * wavy);
                 return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
