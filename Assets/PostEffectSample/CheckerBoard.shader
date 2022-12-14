Shader "Unlit/CheckerBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        [PowerSlider(2.0)] _Val("Size", Range(0.0, 1)) = 0
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            half _Val;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float2 val = floor(i.pos.xy * _Val) * 0.5;
                if(frac(val.x + val.y) > 0) return _Color;
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
