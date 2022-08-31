Shader "Unlit/ScaleShader"
{
    
    SubShader
    {
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                float4 vert = v.vertex * 0.75;
                o.vertex = UnityObjectToClipPos(vert);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
