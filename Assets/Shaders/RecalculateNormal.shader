Shader "Unlit/RecalculateNormal"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
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
                float3 tangent: TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 ambient : COLOR0;
            };

            float4 _MainColor;
            float _DiffuseShade;
            
            v2f vert (appdata v)
            {
                v2f o;

                // 接空間のベクトルの近傍点を作成
                float3 posT = v.vertex + v.tangent;
                // 法線、タンジェントの外積を出して正規化　頂点を足す
                float3 posB = v.vertex + normalize(cross(v.normal, v.tangent));

                // 頂点を動かす
                v.vertex.y += sin(v.vertex.x * 2.0 + _Time.y) * cos(v.vertex.z * 2.0);

                // 近傍値を動かす(頂点と同様の変化量をさせる）
                posT.y += sin(posT.x * 2.0 + _Time.y) * cos(posT.z * 2.0 + _Time.y);
                posB.y += sin(posB.x * 2.0 + _Time.y) * cos(posB.z * 2.0 + _Time.y);

                // 動かした頂点座標と近傍点で接空間のベクトルを再計算 頂点との差でもとまるよね！　動かした変化量が同じだし
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;

                // 計算した接空間のベクトルを用いて再計算
                // 外積を出して正規化すると法線を求めることができる。
                o.normal = normalize(cross(modifiedTangent, modifiedBinormal));
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 環境光 引数に法線を追加して環境光をゲットできる。
                o.ambient = ShadeSH9(float4(o.normal, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ライトの方向を変数から出して正規化
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 拡散反射の光を求める処理　法線と光のベクトルで内積を出して、 影の処理をかける。maxで0以下を切り落とす。
                float4 diffuseColor = max(0, dot(i.normal, lightDir) * _DiffuseShade + (1 - _DiffuseShade));
                // 色を乗算 メインカラー * 拡散反射光のカラー　* ライトカラー * 環境光
                float4 finalColor = _MainColor * diffuseColor * _LightColor0 * float4(i.ambient, 0);
                return finalColor;
            }
            ENDCG
        }
    }
}
