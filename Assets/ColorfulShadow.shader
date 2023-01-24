Shader "Unlit/ColorfulShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowColor("ShadowColor", Color) = (0,0,0,1)
        _ShadowTex("ShadowTexture", 2D) = "white" {}
        _ShadowIntensity("Shadow Intensity", Range(0,1)) = 0.6
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
                float3 pos : SV_POSITION;
            };

            half4 _MainColor;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : COLOR 
            {
                return _MainColor;
            }
            ENDCG
        }
        
        Pass 
        {
            Tags 
            {
                "Queue"="geometry" "LightMode"="ForwardBase"
            }
           // finalValue = sourceFactor * sourceValue operation destinationFactor * destinationValue
            Blend SrcAlpha OneMinusSrcSrcAlpha
            
            
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            float4 _ShadowColor;
            float _ShadowIntensity;

            // グローバル変数
            float _ShadowDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 shadow_uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 shadow_uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 worldPos : WORLD_POS;
                SHADOW_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.shadow_uv = TRANSFORM_TEX(v.shadow_uv, _ShadowTex);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 frag(v2f i)
            {
                float cameraToObjLength = clamp(length(_WorldSpaceCameraPos - i.worldPos), 0,_ShadowDistance);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float N = normalize(i.worldNormal);
                float front = step(0, dot(N,L));
                float attenuation = SHADOW_ATTENUATION(i);
                float fade = 1 - pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);
                float3 shadowColor = tex2D(_ShadowTex, i.shadow_uv) * _ShadowColor;
                float4 finalColor = float4(shadowColor, (1 - attenuation) * _ShadowIntensity * front * fade);
                return finalColor;
            }
            ENDCG
        }
    }
}
