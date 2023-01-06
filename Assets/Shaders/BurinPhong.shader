Shader "Unlit/BurinPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ambient("Ambient", Range(0,1)) = 1
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

            sampler2D _MainTex;
            float4 _LightColor0;
            float _Ambient;
            float4 _SpecColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float NdotL = dot(normal, lightDir);
                float viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float4 tex = tex2D(_MainTex, i.uv);
                float diffusePower = max(_Ambient, NdotL);
                float4 diffuse = diffusePower * tex * _LightColor0;
                float3 halfDir = normalize(lightDir + viewDir);
                float NdotH = dot(normal, halfDir);
                float3 specularPower = pow(max(0, NdotH), 10.0);
                float4 specular = float4(specularPower , 1.0) * _SpecColor * _LightColor0;
                // 拡散色と反射色を合算
                fixed4 col = diffuse + specular;
                return col;
            }
            ENDCG
        }
    }
}
