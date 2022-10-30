Shader "Unlit/ts"
{
    Properties
    {
        [HideInspector] _MainTex ("Texture", 2D) = "white" {}
        [IntRange] _FilterSize("FilterSize", Range(1, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            int _FilterSize;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float4 color = float4(0, 0, 0, 1);
                for (int x = -_FilterSize; x <= _FilterSize; x++)
                {
                    for(int y = -_FilterSize; y <= _FilterSize; y++)
                    {
                        float2 temp = float2(i.uv.x + _MainTex_TexelSize.x * x,i.uv.y + _MainTex_TexelSize.y * y);
                        color.rgb += tex2D(_MainTex, temp).rgb;
                    }
                }
                color.rgb /= pow(_FilterSize * 2 + 1, 2);
                return color;
            }
            ENDCG
        }
    }
}
