Shader "Unlit/VertexShadow"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
            fixed4 _Color;
            fixed4 _LightColor0;

            fixed4 frag (v2f i) : SV_Target
            {
                float attenuation = LIGHT_ATTENUATION(i);
                return _Color * attenuation * _LightColor0;
            }
            ENDCG
        }
    }
}
