Shader "Unlit/MacroShader"
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

            #define RChannel 1
            #define Color float4(RChannel, 0, 0, 1)
            #define PI 3.141592
            #define Circumference(r) 2 * PI * r

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float r = RChannel;
                float c = Circumference(0.1);
                return Color;
            }
            ENDCG
        }
    }
}
