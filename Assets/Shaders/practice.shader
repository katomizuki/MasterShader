#warning Upgrade NOTE: unity_Scale shader variable was removed; replaced '_WorldSpaceCameraPos.w' with '1.0'

Shader "Unlit/practice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularPow("Speclar Pow", float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _LightColor0;

        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        struct  appdata
        {
            float4 vertex : POSITION;
            float2 uv : TECVOORD;
            float3 normal : NORMAL;
        };
        ENDCG
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            float3 normal : NORMAL;
            float3 viewDir : TEXCOORD1;
            float3 lightDir : TEXCOORD2;
            };

            half _SpecularPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float isDirectional = step(1, 1.0);
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz - (worldPos.xyz * isDirectional));
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);

                float3 diffuse = saturate(dot(i.normal, i.lightDir)) * _LightColor0;

                float3 reflectVector = reflect(-i.lightDir, i.normal);
                float3 specular = pow(saturate(dot(reflectVector, i.viewDir)), _SpecularPow);

                float3 ambient = ShadeSH9(float4(i.normal, 1));

                fixed4 col = fixed4(texCol.rgb * (ambient + diffuse) + specular, texCol.a);
                
                return col;
            }
            ENDCG
        }
        Pass {
            Tags {"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM

            struct v2f
            {
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
                float3 lightDir : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float isDirectional = step(1, _WorldSpaceLightPos0.w);
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz - (worldPos.xyz * isDirectional));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                float3 lightCol = saturate(dot(i.normal, i.lightDir)) * _LightColor0;
                return fixed4(texCol.rgb * lightCol, 1);
            }
            ENDCG
            }
    }
}
