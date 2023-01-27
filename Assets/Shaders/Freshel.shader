Shader "Unlit/Freshel"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0,11)) = 1
        _F0("F0", Range(0.0, 0.3)) = 0.02
        _Frequency("Frequency", Range(0,20)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Random.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : WORLD_POS;
            };

            float4 _MainColor;
            float _Reflection;
            float _F0;
            float _Frequency;

            float Wave(float3 position)
            {
                float random1 = random(position.xy);
                float random2 = random(position.xy);
                return position.y + sin(position.x * _Frequency + _Time.y) * cos(position.z * _Frequency + _Time.y) * random1 * random2 * 0.3;
            }

            v2f vert (appdata v)
            {
                v2f o;

                float3 posT = v.vertex + v.tangent;
                float3 posB = v.vertex + normalize(cross(v.normal,v.tangent));

                // 頂点を動かす
                v.vertex.y = Wave(v.vertex);

                posT.y = Wave(posT);
                posB.y = Wave(posB);

                // 動かした頂点座標を再計算
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;

                o.normal = normalize(cross(modifiedTangent, modifiedBinormal));
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float refVec = reflect(-lightDir, i.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float dotVR = dot(refVec, viewDir);
                dotVR = max(0, dotVR);
                dotVR = pow(dotVR, 10 - _Reflection);

                float3 specular = _LightColor0.xyz * dotVR;
                float vdotn = dot(viewDir, i.normal);
                half fresnel = _F0 + (1.0h - _F0) * pow(1.0 - vdotn, 5);
                float4 finalColor = _MainColor + float4(specular * fresnel, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
