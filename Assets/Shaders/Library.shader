Shader "Unlit/Library"
{
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "LibraryShader.cginc"
           

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1, 0, 0, 0.5);
            }
            ENDCG
        }
    }
}
