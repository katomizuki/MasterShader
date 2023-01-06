Shader "Unlit/PhongShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ambient("Ambient", Range(0,1)) = 0
        _SpecColor("Specular", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _LightColor0;
            float4 _SpecColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(normal, lightDir);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = dot(normal, viewDir);
                float4 tex = tex2D(_MainTex, i.uv);
                float diffusePower = max(0, NdotL);
                float4 diffuse = diffusePower * tex * _LightColor0;
                float3 R = -1 * viewDir * 2.0 * NdotV * normal;
                float LdotR = dot(lightDir, R);
                float3 specularPower = pow(max(0, LdotR), 10.0);
                float4 specular = float4 (specularPower, 1.0) * _SpecColor * _LightColor0;
                fixed4 color = diffuse + specular;
                return color;
            }
            ENDCG
        }
    }
}
