Shader "Unlit/DN"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
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
            sampler2D _CameraDepthNormalsTexture;

            
            fixed4 frag (v2f_img i) : SV_Target
            {
                float depth;
                float3 normal;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
                return float4(normal, 1);
                // return float4(depth.rgb, 1);
            }
            ENDCG
        }
    }
}
