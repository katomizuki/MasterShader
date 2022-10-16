Shader "Unlit/NewUnlitShader 3"
{
    Properties
    {
        _ShadowIntensity("Shadow Intensty", Range(0, 1)) = 0.6
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="geometry-1" 
            "LightMode"="ForwardBase"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            float _ShadowIntensity;
            float _ShadowDistance;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
                float3 worldNormal: TEXCOORD0;
                SHADOW_COORDS(1)
            };

            v2f vert (appdata v)
            {
                v2f o;
                // mvp変換
                o.pos = UnityObjectToClipPos(v.vertex);
                // 影の計算のマクロ関数
                TRANSFER_SHADOW(o);
                // ワールド法線を計算
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // モデル座標=>ワールド座標に行列をmulして変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラ位置-ワールド座標=>2点間の距離を出してlengthで原点をからの距離を出す；
                // 距離,0　影の距離を閾値して0,1としてまとめる
                float cameraToObjLenght = clamp(length(_WorldSpaceCameraPos - i.worldPos),0, _ShadowDistance);
// ライトベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // 法線を正規化
                float3 N = normalize(i.worldNormal);
                // 内積を出して0か1にまとめる
                float front = step(0, dot(N, L));
                // 影の場合0 それ以外は1 ForwardBaseの時につかえる
                float attenuation = SHADOW_ATTENUATION(i);
                // 影の減衰率
                float fade = 1 - pow(cameraToObjLenght / _ShadowDistance, _ShadowDistance);
                return float4(0, 0, 0,(1 - attenuation) * _ShadowIntensity * front * fade);
            }
            ENDCG
        }
    }
}
