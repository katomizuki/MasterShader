Shader "Unlit/ReNormal"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _DiffuseShade("Diffuse Shade", Range(0,1)) = 0.5
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
                float3 ambient: COLOR0;
            };

            float4 _MainColor;
            float _DiffuseShade;
            
            v2f vert (appdata v)
            {
                v2f o;
                // 接戦の大きさ分offsetをたす
                float3 tangent = v.tangent;
                // 近傍点
                float3 posTangent = v.vertex + tangent;
                float3 bioNormal = normalize(cross(v.normal, v.tangent));
                // 従法線の大きさ分offsetを足す(近傍点を出す(ある点から一定の距離以内の点のこと）
                float3 posBioNormal = v.vertex + bioNormal;
                // 頂点を動かす
                v.vertex.y = v.vertex.y + sin(v.vertex.x * 2.0 + _Time.y) * cos(v.vertex.z * 2.0 + _Time.y);
                // 近傍値を頂点の変化量と同じだけ動かす
                posTangent.y = posTangent.y + sin(posTangent.x * 2.0 + _Time.y) * cos(posTangent.z * 2.0 + _Time.y);
                posBioNormal.y = posBioNormal.y + sin(posBioNormal.x * 2.0 + _Time.y) * cos(posBioNormal.z * 2.0 + _Time.y);

                // 動かした頂点座標を近傍点から引くことで動かした後の接戦とbinormalを出す　
                float3 modifiedTangent = posTangent - v.vertex;
                float3 modifiedBinormal = posBioNormal - v.vertex;
                // クロス積で動かした後の法線を出す
                float3 modifiedNormal = normalize(cross(modifiedTangent, modifiedBinormal));
                
                o.normal = modifiedNormal;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 法線を引数に入れることで環境光を取ってこれる
                o.ambient = ShadeSH9(float4(o.normal, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float4 diffuse = max(0, dot(i.normal, lightDir) * _DiffuseShade + (1 - _DiffuseShade));
                float4 finalColor = _MainColor * diffuse * _LightColor0 * float4(i.ambient, 0);
                return finalColor;
            }
            ENDCG
        }
    }
}
