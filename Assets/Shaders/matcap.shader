Shader "Unlit/matcap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MatCapTex("Mat Cap Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MatCapTex;
            float4 _MainTex_ST;

            v2f vert (appdata v) {
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    float3 normal = UnityObjectToWorldNormal(v.normal);
                // ワールド空間の法線をview空間の法線に変換。目的(カメラから見た法線が常にz軸上にあるようにする必要がある。)
                // 解決策 ビュー空間でのXY方向と法線のXY方向が重なる必要がある。）
    normal = mul((float3x3)UNITY_MATRIX_V, normal);
                // これを法線に入れる。(0 ~ 1)にする。
    o.uv = normal * 0.5 + 0.5;
    return o;
}

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MatCapTex, i.uv);
            }
            ENDCG
        }
    }
}
