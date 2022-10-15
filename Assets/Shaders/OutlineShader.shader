Shader "Unlit/OutlineShader"
{
    Properties
    {
       _RimColor("RimColor", Color) = (0, 1, 1, 1)
       _RimPower("Rim Power", Range(0, 1)) = 0.4
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        ZWrite On 
        ColorMask 0
        Blend OneMinusDstColor One

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _RimColor;
            float4 _RimPower;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.world_pos = mul(unity_WorldToObject, v.vertex).xyz;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラのベクトルを計算
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
                half rim = 1.0 - saturate(dot(viewDirection, i.normalDir));
                float col = lerp(float4(0, 0, 0, 0), _RimColor, rim * _RimColor);
                return col;
            }
            ENDCG
        }
    }
}
