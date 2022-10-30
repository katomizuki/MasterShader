Shader "Unlit/vertimg"
{
    Properties
    {
        [HideInspector]
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                color.rgb = 1 - color.rgb;
                return color;
            }
            ENDCG
        }
    }
}
