Shader "Unlit/AmbientShader 1"
{
    Properties
    {
        _MainColor("Main Color", Color) = "white" {}
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
    }
    SubShader
    {

        Tags 
        {
            "LightMode"="ForwardBase"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            float _DiffuseShade;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ambient : COLOR;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 法線からワールド座標を起点として法線にする
                o.worldNormal = UnityObjectToWorldNormal(v.vertex);
                // ShadeSH9は環境光のRGBを取得する
                o.ambient = ShadeSH9(half4(o.worldNormal,1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // ワールド座標の法線を正規化
                float3 N = normalize(i.worldNormal);
                // ライトベクトルと法線の単位ベクトル同志の内積を計算することで明るさをを計算する。
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));
                // LightColor0でDirectional Lightの色を該当させる。 Unityがマテリアルにライトの情報を渡してくれる。シェーダーで扱える
                // Tags { "LightMode" = ForwardBaseを追加することでで取得できる。 ForwardAddを記述すれば2パス目でもいける
                // 色をつけるために _LightColor0を乗算する。 i.ambientは環境光
                fixed4 finalColor = _MainColor * diffuseColor * _LightColor0 * float4(i.ambient, 0);
                return finalColor;
            }
            ENDCG
        }
    }
}
