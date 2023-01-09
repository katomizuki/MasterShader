Shader "Unlit/EcholocationEffect"
{
    Properties
    {
        _Radius("Radius", float) = 0
        _Color("Color", Color) = (1,1,1,1)
        _Center("Center", vector) = (0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Color;
            float3 _Center;
            float _Radius;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = distance(_Center, i.worldPos);
                float val = 1 - step(dist,_Radius - 0.1) * 0.5;
                return fixed4(val * _Color.r, val * _Color.g, val * _Color.b, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
