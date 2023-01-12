Shader "Unlit/Dissolve3D"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
 
        [Header(Dissolution)]
        _DisVal ("Threshold", Range(0., 1.01)) = 0.
 
        [Header(Ambient)]
        _Ambient ("Intensity", Range(0., 1.)) = 0.1
        _AmbColor ("Color", color) = (1., 1., 1., 1.)
 
        [Header(Diffuse)]
        _Diffuse ("Val", Range(0., 1.)) = 1.
        _DifColor ("Color", color) = (1., 1., 1., 1.)
 
        [Header(Specular)]
        [Toggle] _Spec("Enabled?", Float) = 0.
        _Shininess ("Shininess", Range(0.1, 10)) = 1.
        _SpecColor ("Specular color", color) = (1., 1., 1., 1.)
 
        [Header(Emission)]
        _EmissionTex ("Emission texture", 2D) = "gray" {}
        _EmiVal ("Intensity", float) = 0.
        [HDR]_EmiColor ("Color", color) = (1., 1., 1., 1.)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "LightMode"="ForwardBase" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets/NoiseUtil/ClassicPerlinNoise3D.cginc"

            #pragma shader_feature __ _SPEC_ON
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, v.normal));
                return o;
            }

            fixed4 _LightColor0;
           
            // Diffuse
            fixed _Diffuse;
            fixed4 _DifColor;
 
            //Specular
            fixed _Shininess;
            fixed4 _SpecColor;
           
            //Ambient
            fixed _Ambient;
            fixed4 _AmbColor;
 
            // Emission
            sampler2D _EmissionTex;
            fixed4 _EmiColor;
            fixed _EmiVal;
 
            // Dissolution
            fixed _DisVal;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
 
                // Light direction
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
 
                float3 worldNormal = normalize(i.worldNormal);
 
                // Compute ambient lighting
                fixed4 amb = _Ambient * _AmbColor;
 
                // Compute the diffuse lighting
                fixed4 NdotL = max(0., dot(worldNormal, lightDir) * _LightColor0);
                fixed4 dif = NdotL * _Diffuse * _LightColor0 * _DifColor;
 
                fixed4 light = dif + amb;
 
                // Compute the specular lighting
                #if _SPEC_ON
                float3 refl = normalize(reflect(-lightDir, worldNormal));
                float RdotV = max(0., dot(refl, viewDir));
                fixed4 spec = pow(RdotV, _Shininess) * _LightColor0 * ceil(NdotL) * _SpecColor;
 
                light += spec;
                #endif
 
                c.rgb *= light.rgb;
 
                // Compute emission
                fixed4 emi = tex2D(_EmissionTex, i.uv).r * _EmiColor * _EmiVal;
                c.rgb += emi.rgb;
 
                if((perlinNoise(i.worldPos) + 1.) / 2. < _DisVal)
                    discard;
 
                return c;
            }
            ENDCG
        }
    }
}
