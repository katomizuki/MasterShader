Shader "Unlit/shisaMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HeightMap("Height Map", 2D) = "white" {}
        _HeightScale("Height", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 objectViewDir : TEXCOORD1;
                float3 objectPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _HeightMap;
            float _HeightScale;

            v2f vert (appdata v)
            {
                v2f o;
                // ワールド座標に変換
                o.position = mul(unity_ObjectToWorld, v.position);
                // 法線ベクトル
                o.normal = v.normal;
                // UV座標
                o.uv = v.uv;
                // 視線ベクトル = 頂点のワールド座標 - 視線（カメラ）のワールド座標
                o.objectViewDir = o.position - _WorldSpaceCameraPos.xyz;
                // ワールド座標をobjectPosに入れる
                o.objectPos = o.position;
                // プロジェクション変換 
                o.position = mul(UNITY_MATRIX_VP, o.position);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 視線ベクトルを正規化
                float3 rayDir = normalize(i.objectViewDir);
                float2 uv = i.uv;
                // 何回乗算すれば最低面(_HeightScale)と衝突するかどうか？
                float rayScale = (_HeightScale / rayDir.y);
                // 視線ベクトルと乗算してベクトルの大きさを求める(実際にかける）
                float3 rayStep = rayDir * rayScale;
                // xz平面を加算
                uv += rayStep.xz;
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
