Shader "Unlit/lllambart"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f
            {
                float3 normal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // N
                float3 normal = normalize(i.normal);
                // L
                float3 light = normalize(_WorldSpaceLightPos0.xyz);
                // 拡散反射
                float diffuse = saturate(dot(normal, light));
                return diffuse * _MainColor;
            }
            ENDCG
        }
    }
}
