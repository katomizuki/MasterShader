Shader "Unlit/frenel"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 11)) = 1
        _F0 ("F0", Range(0.0, 0.3)) = 0.02
        Frequency("Frequency", Range(0,20)) = 5
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f 
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : WORLD_POS;
            };

            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float4 _MainColor;
            float _Reflection;
            float _F0;
            float _Frequency;

            float Wave(float3 position)
            {
                float random1 = rand(position.xy);
                float random2 = rand(position.xz);
                return position + sin(position.x * _Frequency + _Time.y) * cos(position.z * _Frequency + _Time.y) * random1 * random2 * 0.3;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                // 接空間のベクトル近傍点を作成
                // tangent方向に一つと
                float3 posT = v.vertex + v.tangent;
                // 従法線(法線と接戦の外積を正規化することで出せる)側に一つ
                float3 posB = v.vertex + normalize(cross(v.normal, v.tangent));
 //頂点を動かす
                v.vertex.y = Wave(v.vertex);
 //近傍値も動かす
                posT.y = Wave(posT);
                posB.y = Wave(posB);

                //動かした頂点座標と近傍点で接空間のベクトルを再計算する
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;

                // 計算した接空間のベクトルを使って、法線を再計算する（接戦、従法線）の外積、正規化を行う。
                o.normal = normalize(cross(modifiedTangent, modifiedBinormal));
                // クリップ空間変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 行列をかけてワールド座標に変換
                o.worldPos = mul(unity_WorldToObject,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ライトの方向を正規化
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // ライトベクトルと法線ベクトルから反射ベクトルをreflectメソッドで計算
                float3 refVec = reflect(-lightDir, i.normal);
                // 視線ベクトル（カメラ位置ーワールド座標）を正規化
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                // 視線ベクトルと反射ベクトルの内積を計算
                float dotVR = dot(refVec,viewDir);
                // 0以下はそもそもレンダリングしないのでmaxで切り捨て
                dotVR(0, dotVR);
                dotVR = pow(dotVR, 10 - _Reflection);
                // 鏡面反射
                float3 specular = _LightColor0.xyz * dotVR;
                // フレネル
                float vdotn = dot(viewDir, i.normal);
                half frsnel = _F0 + (1.0h - _F0) * pow(1.0h - vdotn, 5);
                // 最終的ないろを計算
                float4 finalColor = _MainColor + float4(specular * frsnel, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
