Shader "Unlit/Diiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1番目のライト(DirectionalLight)を正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // ワールド座標系の法線を正規化して単位ベクトルにする
                float3 N = normalize(i.worldNormal);
                // ライトベクトルとは単位ベクトルの法線の内積からピクセルの明るさを計算　ランバートの調整を行う。
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));
                // 色を乗算
                fixed4 finalColor = _MainColor * diffuseColor;
                return finalColor;
            }
            ENDCG
        }
    }
}
