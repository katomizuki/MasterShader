Shader "Unlit/MV"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture",2D) = "white" {}
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
            sampler2D _CameraMotionVectorsTexture;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float2 motion = tex2D(_CameraMotionVectorsTexture, i.uv).xy;
                motion.xy = abs(motion.xy);
                motion.xy *= 10;
                return float4(motion.xy, 0, 1);
            }
            ENDCG
        }
    }
}
